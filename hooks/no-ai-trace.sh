#!/bin/bash
# shellcheck disable=SC2016,SC2013,SC2020,SC2015,SC2181
# PreToolUse(Bash): deny anything that would put an AI trace on a git remote.
#   git commit / tag / notes, gh pr|issue|release|repo|gist|api  -> scan the command text and every file it takes the message from
#   git push, gh repo create --push                              -> scan every outgoing commit's message and author
# The rule itself is in ~/.claude/CLAUDE.md, "Git attribution".
# Verify: ~/.claude/hooks/no-ai-trace.sh --selftest
JQ=/usr/bin/jq; [ -x $JQ ] || JQ=/opt/homebrew/bin/jq

# `claude` preceded by `.`, `/` or a word char, or followed by `-`, a word char or `.ext`, is a path or
# identifier (~/.claude, claude.sh), not a mention. Product and model names are mentions in any position.
TRACE='co-authored-by|generated with|noreply@anthropic|anthropic|claude-(code|opus|sonnet|haiku|fable|mythos|[0-9])|claude\.(ai|com)\b|(^|[^./[:alnum:]_-])claude(\.?$|\.[^[:alnum:]]|[^[:alnum:]_.-])'

# Command boundary: line start or any char that cannot continue a word, so `sh -c 'git ...'`,
# `$(git ...)` and `/usr/bin/git` match while `.git` and `legit` do not.
B='(^|[^[:alnum:]_.-])'
# Global options may sit between the program and its subcommand (git -c a=b --no-pager commit, gh -R o/r pr).
MSG="${B}git\s+([^;&|]*\s)?(commit|tag|notes)\b|${B}gh\s+([^;&|]*\s)?(pr|issue|release|repo|gist|api)\b"
PUSH="${B}git\s+([^;&|]*\s)?push\b|${B}gh\s+repo\s+[^;&|]*--push\b"

hit() { grep -qiE "$TRACE"; }

deny() {
  $JQ -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}' ||
    { echo "$1" >&2; exit 2; }
  exit 0
}

# Directories the command may act in: every `cd` and `-C` target, then the hook cwd.
dirs_of() {
  { grep -oE -- "(${B}cd\s+|\s-C\s*)(\"[^\"]+\"|'[^']+'|[^ ;&|)]+)" <<<"$1" |
      sed -E "s/^.?cd[[:space:]]+//; s/^[[:space:]]-C[[:space:]]*//; s/[\"']//g"; echo "$2"; } |
    while IFS= read -r d; do d=${d/#\~/$HOME}; d=${d/#\$HOME/$HOME}; [[ $d == /* ]] || d="$2/$d"; echo "$d"; done
}

check() {
  local cmd=$1 cwd=$2
  # Read-only forms carry no message; drop them so text beside them (| rg claude) is not scanned.
  # gh api is read-only only when the whole command has no method, field or input flag.
  local scan; scan=$(sed -E "s/${B}gh[[:space:]]+(pr|issue|release|repo|gist)[[:space:]]+(view|list|status|checks|diff)([[:space:]][^;&|\$\`(]*)?/\1/g; s/${B}git[[:space:]]+tag[[:space:]]+(-l|--list)([[:space:]][^;&|\$\`(]*)?/\1/g" <<<"$cmd")
  grep -qE -- '(^|\s)(-X|-f|-F|--method|--field|--raw-field|--input)' <<<"$cmd" ||
    scan=$(sed -E "s/${B}gh[[:space:]]+api([[:space:]][^;&|\$\`(]*)?/\1/g" <<<"$scan")
  # Message-bearing commands: the message is somewhere in the command text or in a file it names.
  if grep -qE "$MSG" <<<"$scan"; then
    # Ignore paths in the scan: strip tokens containing '/' or starting with '.'.
    local text; text=$(tr ' \t' '\n\n' <<<"$scan" | grep -vE '/|^\.' | tr '\n' ' ')
    hit <<<"$text" && deny "AI trace in commit/tag/PR text. CLAUDE.md: nothing that reaches a remote may name Claude, Anthropic or an AI tool, and no Co-Authored-By / Generated-with trailer. Rewrite the message."
    # Message files: -F / --file / --body-file / --notes-file / --input targets, key=@file fields, $(cat file).
    # One named inside the message command itself must be readable here, or the command is denied.
    local raw f d p strict segs; segs=$(grep -oE "($MSG)[^;&|]*" <<<"$scan")
    while IFS= read -r raw; do
      f=$(sed -E 's/^[[:space:]]*(-[[:alpha:]]*F|--[a-z-]+|\$\((cat|<))[ =]*//; s/\)$//' <<<"$raw"); f=${f//[\"\']/}
      case $f in ''|'<'*) continue ;; *=@*) f=${f##*=@} ;; *=*) continue ;; esac
      strict=; grep -qF -- "$raw" <<<"$segs" && strict=1
      if [ "$f" = - ]; then
        [ -n "$strict" ] && [[ $cmd != *'<<'* ]] && deny "Message is piped in on stdin, where this guard cannot read it. Pass the file by path, or use a heredoc."
        continue
      fi
      f=${f/#\~/$HOME}; p=
      if [[ $f == /* ]]; then [ -f "$f" ] && p=$f
      else while IFS= read -r d; do [ -f "$d/$f" ] && { p="$d/$f"; break; }; done < <(dirs_of "$cmd" "$cwd"); fi
      if [ -n "$p" ]; then hit <"$p" && deny "AI trace in message file $p. Rewrite it."
      elif [ -n "$strict" ]; then deny "Message file '$f' is not readable by this guard, so its text cannot be checked. Name it by a literal absolute path."; fi
    done < <(grep -oE -- '(^|\s)-[[:alpha:]]*F[ =]*[^ ;&|]+|--(file|body-file|notes-file|input)[ =]+[^ ;&|]+|\$\((cat|<)\s*[^)|;&]+\)' <<<"$scan")
  fi
  # Push: everything outgoing must already be clean, in every repo the command names (cwd when it names none).
  if grep -qE "$PUSH" <<<"$cmd"; then
    local repo out h any=
    while IFS= read -r repo; do
      git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || continue
      [ -n "$any" ] && [ "$repo" = "$cwd" ] && continue
      any=1; h=HEAD; git -C "$repo" rev-parse -q --verify HEAD >/dev/null 2>&1 || h=
      out=$(git -C "$repo" log $h --branches --tags --not --remotes --format='%an <%ae>%n%cn <%ce>%n%B' 2>/dev/null)
      [ -n "$out" ] && hit <<<"$out" && deny "Outgoing commits in $repo carry an AI trace (message, author or committer). Strip it from unpushed history before pushing: git log HEAD --branches --not --remotes --format='%h %an%n%B' | grep -iE 'co-authored|generated with|claude|anthropic'"
    done < <(dirs_of "$cmd" "$cwd")
  fi
  return 0
}

if [ "$1" = --selftest ]; then
  T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; export HOME="$T/home"
  mkdir -p "$T/home" "$T/sub" "$T/a b"
  echo 'Reviewed with Claude.' | tee "$T/body.md" "$T/sub/sub.md" "$T/home/h.md" >/dev/null
  echo 'plain subject' >"$T/ok.txt"
  g() { git -C "$1" -c core.hooksPath=/dev/null -c user.name=sol -c user.email=s@x "${@:2}" >/dev/null 2>&1; }
  for r in dirty det clean; do git init -q "$T/$r"; g "$T/$r" commit --allow-empty -m "base one"; done
  g "$T/dirty" commit --allow-empty -m fix -m "Co-Authored-By: x <x@y>"
  g "$T/det" checkout --detach; g "$T/det" commit --allow-empty -m "generated with x"
  # t want command [cwd under $T]
  t() { local want=$1 out got=allow; out=$(check "$2" "$T${3:+/$3}"); [ -n "$out" ] && got=deny
        [ "$got" = "$want" ] && echo "ok   $want  ${2//$T/T}" || { echo "FAIL want $want got $got: $2"; fail=1; }; }
  t deny  'git commit -m "fix x" -m "Co-Authored-By: Claude <noreply@anthropic.com>"'
  t deny  'git commit -m "$(cat <<EOF
fix
🤖 Generated with Claude Code
EOF
)"'
  t deny  'gh pr create --title "x" --body "made with claude"'
  t allow 'git add ~/.claude/hooks/x.sh && git commit -m "hook fix"'
  t deny  'git -c core.editor=true commit -m "by claude"'
  t deny  'gh pr merge 1 --squash --body "by claude"'
  t deny  'gh pr review 1 --body "by claude"'
  t deny  'gh api repos/x/y/pulls -f body="by claude"'
  t deny  'git notes add -m "by claude"'
  t allow 'gh pr view 1'
  t allow 'git commit -m "claude.sh pill tick"'
  t allow 'git status'
  t allow 'echo claude'
  # command forms
  t deny  "sh -c 'git commit -m \"by claude\"'"
  t deny  '/usr/bin/git commit -m "by claude"'
  t deny  'git --no-pager commit -m "by claude"'
  t deny  "git -C \"$T/a b\" commit -m \"by claude\""
  t deny  'git commit --amend -m "by claude"'
  t deny  'gh -R o/r pr create --title x --body "by claude"'
  t deny  'gh repo edit --description "built with claude"'
  t deny  'gh gist create --desc "by claude" f.txt'
  # mention forms
  t deny  'git commit -m "written by Claude."'
  t deny  'git commit -m "made with claude-code"'
  t deny  'git commit -m "see claude.ai"'
  t allow 'git commit -m "claude-statusline.sh width"'
  # message from a file
  t deny  'gh pr create --title x --body-file body.md'
  t deny  'gh release create v1 --notes-file body.md'
  t deny  'gh api repos/o/r/issues -F body=@body.md'
  t deny  'gh api repos/o/r/issues --input body.md'
  t deny  'git commit -F "body.md"'
  t deny  'git tag -a v1 -F body.md'
  t deny  'git commit -F ~/h.md'
  t deny  'git commit -aF body.md'
  t deny  'cd sub && git commit -F sub.md'
  t deny  "git -C $T commit -F body.md" clean
  t deny  'git commit -m "$(cat body.md)"'
  t deny  'gh pr create --title x --body "$(cat body.md)"'
  t deny  'gh pr create --title "a & b" -F body.md'
  t deny  'cat body.md | gh pr create --title x -F -'
  t deny  'git commit -F nosuch.txt'
  t deny  'git commit -F "$MSGFILE"'
  t allow 'git commit -F ok.txt'
  t allow 'git commit -F - <<EOF
plain subject
EOF'
  t allow 'gh api repos/o/r/issues -F per_page=100 -f state=open'
  t allow 'git commit -m "hook fix" && ls | grep -F x'
  # read-only forms beside bare text
  t allow 'gh api repos/o/r/contents | rg claude'
  t allow 'gh pr list --search claude'
  t allow 'gh pr view 1 --json body | rg -i claude'
  t allow 'git tag -l | rg claude'
  t deny  'gh api repos/o/r/issues --jq ".a | .b" -f body="by claude"'
  t deny  'gh pr view 1; gh pr comment 1 --body "by claude"'
  t deny  'gh pr view $(gh pr create --title x --body "by claude")'
  # push
  t deny  'git push' dirty
  t allow 'git push' clean
  t deny  "cd $T/dirty && git push"
  t deny  "cd $T/dirty && git push" clean
  t deny  "git -c a=b -C $T/dirty push" clean
  t deny  "git -C $T/dirty --no-pager push origin main" clean
  t allow "git -C $T/clean push" dirty
  t deny  'git push origin HEAD:main' det
  t deny  'git subtree push --prefix=x origin main' dirty
  t deny  'gh repo create x --source . --push' dirty
  t deny  'git push --mirror' dirty
  t deny  'git push origin main:refs/heads/other' dirty
  # unreadable input: git and gh blocked, the rest allowed
  printf '{"tool_input":{"command":"git commit -m x' | bash "$0" 2>/dev/null
  [ $? = 2 ] && echo "ok   block bad JSON carrying git" || { echo "FAIL bad JSON carrying git not blocked"; fail=1; }
  printf '{"tool_input":{"command":"ls' | bash "$0" 2>/dev/null
  [ $? = 0 ] && echo "ok   allow bad JSON without git" || { echo "FAIL bad JSON without git blocked"; fail=1; }
  exit "${fail:-0}"
fi

input=$(cat)
# No jq or unparseable input: the command cannot be inspected. Block git and gh (exit 2), let the rest through.
cmd=$($JQ -r '.tool_input.command // empty' <<<"$input" 2>/dev/null) || {
  grep -qE "${B}(git|gh)([^[:alnum:]_.-]|$)" <<<"$input" || exit 0
  echo "no-ai-trace: hook input unreadable (jq missing or bad JSON), so git and gh are blocked until it can be checked." >&2
  exit 2
}
cwd=$($JQ -r '.cwd // empty' <<<"$input"); [ -n "$cwd" ] || cwd=$PWD
[ -n "$cmd" ] && check "$cmd" "$cwd"
exit 0
