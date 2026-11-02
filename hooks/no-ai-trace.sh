#!/bin/bash
# shellcheck disable=SC2016,SC2013,SC2020,SC2015
# PreToolUse(Bash): deny anything that would put an AI trace on a git remote.
#   git commit / tag / notes, gh pr|issue|release|api  -> scan the command text (and any -F/--file message file)
#   git push                               -> scan every outgoing commit's message and author
# The rule itself is in ~/.claude/CLAUDE.md, "Git attribution".
# Verify: ~/.claude/hooks/no-ai-trace.sh --selftest
JQ=/usr/bin/jq; [ -x $JQ ] || JQ=/opt/homebrew/bin/jq

# `claude` preceded by `.`, `/` or a word char is a path or identifier (~/.claude, claude.sh), not a mention.
TRACE='co-authored-by|generated with|noreply@anthropic|anthropic|(^|[^./[:alnum:]_-])claude([^[:alnum:]_.-]|$)'

hit() { grep -qiE "$TRACE"; }

deny() {
  $JQ -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

check() {
  local cmd=$1 cwd=$2
  # Message-bearing commands: the message is somewhere in the command text.
  if grep -qE '(^|[;&|(]\s*|\s)git(\s+-[Cc]\s+\S+)*\s+(commit|tag|notes)\b|(^|\s)gh\s+((pr|issue|release)\s+\S+|api)\b' <<<"$cmd"; then
    # Ignore paths in the scan: strip tokens containing '/' or starting with '.'.
    local text; text=$(tr ' \t' '\n\n' <<<"$cmd" | grep -vE '/|^\.' | tr '\n' ' ')
    hit <<<"$text" && deny "AI trace in commit/tag/PR text. CLAUDE.md: nothing that reaches a remote may name Claude, Anthropic or an AI tool, and no Co-Authored-By / Generated-with trailer. Rewrite the message."
    local f
    for f in $(grep -oE '(-F|--file)[ =]+[^ ;&|]+' <<<"$cmd" | sed -E 's/^(-F|--file)[ =]+//'); do
      [[ $f != /* ]] && f="$cwd/$f"
      [ -f "$f" ] && hit <"$f" && deny "AI trace in commit message file $f. Rewrite it."
    done
  fi
  # Push: everything outgoing must already be clean.
  if grep -qE '(^|[;&|(]\s*|\s)git(\s+-[Cc]\s+\S+)*\s+push\b' <<<"$cmd"; then
    local repo=$cwd c
    c=$(grep -oE 'git\s+-C\s+\S+\s+push' <<<"$cmd" | head -1 | awk '{print $3}')
    [ -n "$c" ] && { c=${c/#\~/$HOME}; [[ $c == /* ]] && repo=$c || repo="$cwd/$c"; }
    git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || return 0
    local out
    out=$(git -C "$repo" log --branches --tags --not --remotes --format='%an <%ae>%n%cn <%ce>%n%B' 2>/dev/null)
    [ -n "$out" ] && hit <<<"$out" && deny "Outgoing commits in $repo carry an AI trace (message, author or committer). Strip it from unpushed history before pushing: git log --branches --not --remotes --format='%h %an%n%B' | grep -iE 'co-authored|generated with|claude|anthropic'"
  fi
  return 0
}

if [ "$1" = --selftest ]; then
  t() { local want=$1; shift; out=$(check "$1" /tmp); got=allow; [ -n "$out" ] && got=deny
        [ "$got" = "$want" ] && echo "ok   $want  $1" || { echo "FAIL want $want got $got: $1"; fail=1; }; }
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
  exit "${fail:-0}"
fi

input=$(cat)
cmd=$($JQ -r '.tool_input.command // empty' <<<"$input")
cwd=$($JQ -r '.cwd // empty' <<<"$input"); [ -n "$cwd" ] || cwd=$PWD
[ -n "$cmd" ] && check "$cmd" "$cwd"
exit 0
