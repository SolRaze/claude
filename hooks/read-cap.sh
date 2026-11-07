#!/bin/bash
# PreToolUse Read: deny a whole-file read of a text file longer than READ_CAP lines.
# Claude retries with offset/limit, or locates with rg first. Images, PDFs and
# notebooks pass, as does any read that sets limit.
# Verify: ~/.claude/hooks/read-cap.sh --selftest
JQ=/usr/bin/jq; [ -x $JQ ] || JQ=/opt/homebrew/bin/jq
CAP=${READ_CAP:-500}

selftest() {
  local d; d=$(mktemp -d); trap 'rm -rf "$d"' RETURN
  seq 1 600 >"$d/big.txt"; seq 1 10 >"$d/small.txt"; seq 1 600 >"$d/big.pdf"
  r() { printf '{"tool_input":{"file_path":"%s"%s}}' "$1" "$2" | bash "$0"; }
  r "$d/big.txt" "" | grep -q '"deny"' || { echo "FAIL big read allowed"; return 1; }
  [ -z "$(r "$d/big.txt" ',"limit":100')" ] || { echo "FAIL limited read denied"; return 1; }
  [ -z "$(r "$d/small.txt" "")" ] || { echo "FAIL small read denied"; return 1; }
  [ -z "$(r "$d/big.pdf" "")" ] || { echo "FAIL pdf denied"; return 1; }
  [ -z "$(r "$d/missing.txt" "")" ] || { echo "FAIL missing file denied"; return 1; }
  echo "ok"
}
[ "$1" = --selftest ] && { selftest; exit; }

in=$(cat)
[ "$($JQ -r '.tool_input.limit // empty' <<<"$in")" ] && exit 0
f=$($JQ -r '.tool_input.file_path // empty' <<<"$in"); [ -f "$f" ] || exit 0
case "${f##*.}" in png|jpg|jpeg|gif|webp|heic|pdf|ipynb) exit 0 ;; esac
grep -Iq . "$f" 2>/dev/null || exit 0
n=$(wc -l <"$f" | tr -d ' '); [ "$n" -gt "$CAP" ] || exit 0
$JQ -n --arg r "$f has $n lines. Locate with rg first, then Read with offset/limit (or set limit to read on purpose)." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
