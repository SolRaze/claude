#!/bin/bash
# shellcheck disable=SC2016,SC2181
# Stop: run the repo's linters and type checkers over uncommitted work before Claude finishes.
# Failure exits 2, which feeds the errors back to Claude and makes it continue.
#   package.json  -> its "lint" / "typecheck" scripts, via the lockfile's package manager
#   Cargo.toml    -> cargo check
#   Package.swift -> swift build
#   *.py / *.sh   -> ruff / shellcheck on the changed files, when installed
# Runs only when a changed file is newer than the last pass (stamp in .git), so turns
# that touch no code cost nothing. Each changed file is checked against its nearest manifest.
# Verify: ~/.claude/hooks/verify-stop.sh --selftest
JQ=/usr/bin/jq; [ -x $JQ ] || JQ=/opt/homebrew/bin/jq
export PATH="/opt/homebrew/bin:$HOME/.cargo/bin:$PATH"

selftest() {
  local d; d=$(mktemp -d); trap 'rm -rf "$d"' RETURN
  git -C "$d" init -q
  printf '{"scripts":{"lint":"exit 1"}}' >"$d/package.json"; : >"$d/package-lock.json"; mkdir "$d/node_modules"
  echo 'x' >"$d/a.js"
  local hook=(bash "$(cd "$(dirname "$0")" && pwd)/$(basename "$0")") in="{\"cwd\":\"$d\"}"
  "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 2 ] || { echo "FAIL lint error not caught"; return 1; }
  "${hook[@]}" <<<"{\"cwd\":\"$d\",\"stop_hook_active\":true}"; [ $? = 0 ] || { echo "FAIL loop guard"; return 1; }
  (cd "$d" && "${hook[@]}" <<<'{"cwd":' 2>/dev/null); [ $? = 0 ] || { echo "FAIL bad input blocked"; return 1; }
  (cd "$d" && "${hook[@]}" <<<'{}' 2>/dev/null); [ $? = 0 ] || { echo "FAIL input without cwd blocked"; return 1; }
  printf '{"scripts":{"lint":"true"}}' >"$d/package.json"; touch "$d/a.js"
  "${hook[@]}" <<<"$in"; [ $? = 0 ] || { echo "FAIL clean lint blocked"; return 1; }
  [ -f "$d/.git/claude-verify-stamp" ] || { echo "FAIL no stamp"; return 1; }
  printf '{"scripts":{"lint":"exit 1"}}' >"$d/package.json"; touch -t 200001010000 "$d/package.json" "$d/a.js"
  "${hook[@]}" <<<"$in"; [ $? = 0 ] || { echo "FAIL ran with nothing newer than stamp"; return 1; }
  touch -t 200001010001 "$d/.git/claude-verify-stamp"
  mkdir -p "$d/pkg/a/src" "$d/pkg/a/node_modules"
  printf '{"scripts":{"typecheck":"exit 1"}}' >"$d/pkg/a/package.json"; echo 'x' >"$d/pkg/a/src/b.ts"
  "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 2 ] || { echo "FAIL nested package not checked"; return 1; }
  echo "ok"
}
[ "$1" = --selftest ] && { selftest; exit; }

in=$(cat)
# No jq or bad input: the loop guard is unreadable, so never block.
active=$($JQ -r '.stop_hook_active // false' <<<"$in" 2>/dev/null) || exit 0
[ "$active" = true ] && exit 0
cwd=$($JQ -r '.cwd // empty' <<<"$in"); [ -n "$cwd" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
stamp="$(git rev-parse --absolute-git-dir)/claude-verify-stamp"

changed=()
while IFS= read -r f; do
  f=${f:3}; f=${f##* -> }; f=${f#\"}; f=${f%\"}
  [ -f "$f" ] || continue
  [ -f "$stamp" ] && [ ! "$f" -nt "$stamp" ] && continue
  changed+=("$f")
done < <(git status --porcelain --untracked-files=all)
[ ${#changed[@]} = 0 ] && exit 0

has() { printf '%s\n' "${changed[@]}" | grep -qE "$1"; }
pick() { printf '%s\n' "${changed[@]}" | grep -E "$1"; }

report=""
run() {
  local label=$1; shift
  local out; out=$("$@" 2>&1) || report+="== $label"$'\n'"$(tail -n 40 <<<"$out")"$'\n'
}

# Nearest manifest above each matching changed file, deduplicated: covers monorepo packages.
roots() {
  local f d
  pick "$2" | while IFS= read -r f; do
    d=$(dirname "$f")
    while [ ! -f "$d/$1" ] && [ "$d" != . ]; do d=$(dirname "$d"); done
    [ -f "$d/$1" ] && echo "$d"
  done | sort -u
}

while IFS= read -r d; do
  [ -d "$d/node_modules" ] || [ -d node_modules ] || continue
  pm=npm
  for l in . "$d"; do
    [ -f "$l/pnpm-lock.yaml" ] && pm=pnpm; [ -f "$l/yarn.lock" ] && pm=yarn; ls "$l"/bun.lock* >/dev/null 2>&1 && pm=bun
  done
  for s in lint typecheck; do
    $JQ -e ".scripts[\"$s\"]" "$d/package.json" >/dev/null 2>&1 && run "$d: $pm run $s" sh -c 'cd "$0" && exec "$@"' "$d" $pm run "$s"
  done
done < <(roots package.json '\.(m|c)?[jt]sx?$|\.(vue|svelte|astro)$|(^|/)package\.json$')

while IFS= read -r d; do
  run "$d: cargo check" cargo check -q --message-format short --manifest-path "$d/Cargo.toml"
done < <(roots Cargo.toml '\.rs$|(^|/)Cargo\.toml$')

# SwiftPM only; .xcodeproj apps are skipped, an xcodebuild per turn is too slow.
while IFS= read -r d; do
  run "$d: swift build" swift build -q --package-path "$d"
done < <(roots Package.swift '\.swift$|(^|/)Package\.swift$')

if command -v ruff >/dev/null && has '\.py$'; then
  py=(); while IFS= read -r f; do py+=("$f"); done < <(pick '\.py$')
  run "ruff check" ruff check -q "${py[@]}"
fi

if command -v shellcheck >/dev/null && has '\.(ba)?sh$'; then
  sh=(); while IFS= read -r f; do sh+=("$f"); done < <(pick '\.(ba)?sh$')
  run "shellcheck" shellcheck "${sh[@]}"
fi

if [ -n "$report" ]; then
  printf 'Checks failed on uncommitted work. Fix before finishing:\n%s' "$report" >&2
  exit 2
fi
touch "$stamp"
exit 0
