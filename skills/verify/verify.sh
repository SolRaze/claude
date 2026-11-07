#!/bin/bash
# Pre-commit check for sol's repos: staged files and the commit message.
# usage: verify.sh [-C repo] "<commit message>"
# Exit 1 with one line per problem. Attribution is also enforced by ~/.claude/hooks/no-ai-trace.sh.
repo=.; [ "$1" = -C ] && { repo=$2; shift 2; }
msg=$1; fail=0
bad() { echo "verify: $*"; fail=1; }

# Never-published paths (repo-shape "never published"). A repo whose remote is
# private infra opts out: git config verify.private true. Currency still checked.
if [ "$(git -C "$repo" config --bool verify.private)" != true ]; then
  git -C "$repo" diff --cached --name-only --diff-filter=ACMR |
    grep -E '(^|/)(CLAUDE\.md|AGENTS\.md|raw-prompt\.md|MEMORY\.md)$|(^|/)(Inbox|plans|\.claude)/' |
    while read -r f; do echo "verify: never published: $f"; done | grep . && fail=1
fi

# Currency in added lines.
eur=$'\xe2\x82\xac' gbp=$'\xc2\xa3' yen=$'\xc2\xa5' php=$'\xe2\x82\xb1' inr=$'\xe2\x82\xb9'
git -C "$repo" diff --cached -U0 | grep -E '^\+[^+]' | grep -E "($eur|$gbp|$yen)[0-9]|\\\$[0-9]+[.,]?[0-9]|[0-9] ?(USD|EUR|GBP|PHP)\\b|$php|$inr ?[0-9]|Rs\\. ?[0-9]|[0-9] ?INR\\b" | head -5 |
  sed 's/^/verify: currency: /' | grep . && fail=1

# Commit message: lowercase, two to four words, subject only.
if [ -n "$msg" ]; then
  [ "$(printf '%s' "$msg" | wc -l)" -eq 0 ] || bad "message has a body; subject only"
  n=$(wc -w <<<"$msg"); [ "$n" -ge 2 ] && [ "$n" -le 4 ] || bad "message is $n words; two to four"
  [[ $msg =~ [A-Z] ]] && bad "message has capitals; lowercase"
  [[ $msg =~ ^[A-Za-z]+(\(.*\))?!?: ]] && bad "message is type(scope): form"
  grep -qiE 'co-authored|generated with|claude|anthropic' <<<"$msg" && bad "message names an AI tool"
fi
exit $fail
