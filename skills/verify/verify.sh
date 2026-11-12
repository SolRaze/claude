#!/bin/bash
# shellcheck disable=SC2015,SC2016
# Pre-commit check for sol's repos: staged files and the commit message.
# usage: verify.sh [-C repo] "<commit message>"
# Exit 1 with one line per problem. Attribution is also enforced by ~/.claude/hooks/no-ai-trace.sh.
# Verify: verify.sh --selftest [script under test]

selftest() {
  local self=${1:-$0} t n=0 fail=0; t=$(mktemp -d); trap 'rm -rf "$t"' RETURN
  # c want-exit label path content [message]: one fresh repo with one staged file
  c() {
    local d="$t/$((n+=1))" got; git init -q "$d"; mkdir -p "$d/$(dirname "$3")"; printf '%s\n' "$4" >"$d/$3"
    [ "$2" = private ] && git -C "$d" config verify.private true
    git -C "$d" add -A; bash "$self" -C "$d" "${5-hook fix}" >/dev/null 2>&1; got=$?
    [ $got = "$1" ] && echo "ok   $1  $2" || { echo "FAIL want $1 got $got: $2"; fail=1; }
  }
  # Amounts are split across quotes so this file passes its own currency check.
  local eur=$'\xe2\x82\xac'
  c 0 "plain file"                a.txt x
  c 1 "CLAUDE.md"                 CLAUDE.md x
  c 1 "nested claude.md, lower"   docs/claude.md x
  c 1 "CLAUDE.local.md"           CLAUDE.local.md x
  c 1 "plans/"                    plans/a.md x
  c 1 "Plans/ capitalised"        Plans/a.md x
  c 1 "Inbox/ non-ASCII name"     $'Inbox/caf\xc3\xa9.md' x
  c 1 ".claude/"                  .claude/x.json x
  c 0 private                     CLAUDE.md x
  c 1 "dollar amount"             a.txt "cost \$""50.00"
  c 1 "added line starting +"     a.md "+ cost \$""50.00"
  c 1 "symbol after amount"       a.txt "cost 5$eur"
  c 1 "code before amount"        a.txt "cost USD"" 20"
  c 1 "PHP before amount"         a.txt "cost PHP"" 500"
  c 1 "Rs without dot"            a.txt "cost Rs"" 500"
  c 1 "private keeps currency"    private.txt "cost \$""50.00"
  c 0 "shell positional"          a.sh 'echo $1 $2'
  c 0 "PHP version"               a.txt "needs PHP"" 8.3"
  c 0 "file named +++"            a.txt "+++ not a header"
  c 1 "message capitals"          a.txt x "Hook fix"
  c 1 "message one word"          a.txt x "fix"
  c 1 "message five words"        a.txt x "one two three four five"
  c 1 "message body"              a.txt x $'hook fix\n\nbody'
  c 1 "message type(scope):"      a.txt x "fix(hooks): thing"
  c 1 "message AI mention"        a.txt x "claude hook fix"
  c 1 "message currency"          a.txt x "saved \$""50.00 today"
  mkdir "$t/norepo"; bash "$self" -C "$t/norepo" "hook fix" >/dev/null 2>&1
  [ $? = 1 ] && echo "ok   1  not a git repo" || { echo "FAIL not a git repo passed"; fail=1; }
  return $fail
}
[ "$1" = --selftest ] && { selftest "$2"; exit; }

repo=.; [ "$1" = -C ] && { repo=$2; shift 2; }
msg=$1; fail=0
bad() { echo "verify: $*"; fail=1; }
git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || { echo "verify: $repo is not a git repo, nothing was checked"; exit 1; }

# Never-published paths (repo-shape "never published"). A repo whose remote is
# private infra opts out: git config verify.private true. Currency still checked.
# Case-insensitive like the filesystem; -z because git quotes non-ASCII names.
if [ "$(git -C "$repo" config --bool verify.private)" != true ]; then
  git -C "$repo" diff --cached --name-only -z --diff-filter=ACMR | tr '\0' '\n' |
    grep -iE '(^|/)(CLAUDE(\.local)?\.md|AGENTS\.md|raw-prompt\.md|MEMORY\.md)$|(^|/)(Inbox|plans|\.claude)/' |
    while read -r f; do echo "verify: never published: $f"; done | grep . && fail=1
fi

# Currency in added lines and in the message. `$N` needs two digits or a decimal so shell
# positionals pass; `PHP N` needs two digits so the language version passes.
eur=$'\xe2\x82\xac' gbp=$'\xc2\xa3' yen=$'\xc2\xa5' php=$'\xe2\x82\xb1' inr=$'\xe2\x82\xb9'
CUR="($eur|$gbp|$yen) ?[0-9]|[0-9] ?($eur|$gbp|$yen)|\\\$[0-9]+[.,]?[0-9]|[0-9] ?(USD|EUR|GBP|PHP|INR|JPY)\\b|\\b(USD|EUR|GBP|INR|JPY) ?[0-9]|\\bPHP ?[0-9]{2}|$php|$inr ?[0-9]|\\bRs\\.? ?[0-9]"
# Added lines are those after a hunk header; the +++ file header is not one.
git -C "$repo" diff --cached -U0 --no-color --no-ext-diff | awk '/^diff --git/{h=0} /^@@/{h=1;next} h && /^\+/' |
  grep -E "$CUR" | head -5 | sed 's/^/verify: currency: /' | grep . && fail=1

# Commit message: lowercase, two to four words, subject only.
if [ -n "$msg" ]; then
  [ "$(printf '%s' "$msg" | wc -l)" -eq 0 ] || bad "message has a body; subject only"
  n=$(wc -w <<<"$msg"); [ "$n" -ge 2 ] && [ "$n" -le 4 ] || bad "message is $n words; two to four"
  [[ $msg =~ [A-Z] ]] && bad "message has capitals; lowercase"
  [[ $msg =~ ^[A-Za-z]+(\(.*\))?!?: ]] && bad "message is type(scope): form"
  grep -qiE 'co-authored|generated with|claude|anthropic' <<<"$msg" && bad "message names an AI tool"
  grep -qE "$CUR" <<<"$msg" && bad "message has a currency amount"
fi
exit $fail
