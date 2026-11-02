#!/usr/bin/env bash
# Links this repo into ~/.claude. Existing files that are not symlinks are left alone and printed.
# Verify: HOME=$(mktemp -d) ./install.sh  # run twice with the same HOME, second run changes nothing
set -euo pipefail
R=$(cd "$(dirname "$0")" && pwd)
D=$HOME/.claude
mkdir -p "$D/skills" "$D/hooks" "$D/modes" "$D/repos"

link() {
  if [ -e "$2" ] && [ ! -L "$2" ]; then echo "skip $2 (exists)"; else ln -sfn "$1" "$2"; fi
}

for s in "$R"/skills/*/; do s=${s%/}; link "$s" "$D/skills/$(basename "$s")"; done
for f in "$R"/hooks/*; do link "$f" "$D/hooks/$(basename "$f")"; done
for f in "$R"/modes/*; do link "$f" "$D/modes/$(basename "$f")"; done

# repos.md lines: - name | owner/repo | path
awk -F' [|] ' '/^- / && NF==3 {sub(/^- /,"",$1); print $1"\t"$2"\t"$3}' "$R/repos.md" |
while IFS=$'\t' read -r name repo path; do
  dir=$D/repos/${repo//\//-}
  if [ -d "$dir/.git" ]; then git -C "$dir" pull -q --ff-only || echo "stale $repo"
  else git clone -q --depth 1 "https://github.com/$repo" "$dir" || { echo "failed $repo"; continue; }; fi
  if [ -e "$dir/$path" ]; then link "$dir/$path" "$D/skills/$name"; else echo "missing $repo/$path"; fi
done

# This repo's settings win on conflict, other keys survive, hooks are unioned per event.
s=$D/settings.json
[ -f "$s" ] || echo '{}' > "$s"
cp "$s" "$s.bak"
jq -s '.[0] as $a | .[1] as $b | ($a * $b) | .hooks =
  ([$a.hooks, $b.hooks] | map((. // {}) | to_entries) | add | group_by(.key)
   | map({key: .[0].key, value: (map(.value) | add | unique)}) | from_entries)' \
  "$s.bak" "$R/settings.json" > "$s"
