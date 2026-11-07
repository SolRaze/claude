#!/bin/bash
# Stop: once the main context passes HANDOVER_AT tokens, make Claude print a handover
# paste-box instead of the session growing on. Auto-compact stays off; this is the
# replacement. Exit 2 feeds stderr back to Claude and makes it continue one more step.
# Fires once per session, then again each HANDOVER_STEP tokens past the last firing.
# Context = input + cache read + cache write of the last assistant message in the transcript.
# Verify: ~/.claude/hooks/handover-at.sh --selftest
JQ=/usr/bin/jq; [ -x $JQ ] || JQ=/opt/homebrew/bin/jq
AT=${HANDOVER_AT:-200000}
STEP=${HANDOVER_STEP:-150000}
STATE=${HANDOVER_STATE:-$HOME/.claude/state/handover}

ctx_of() {
  tail -n 200 "$1" 2>/dev/null | $JQ -s '[.[] | select(.type=="assistant") | .message.usage
    | select(.) | (.input_tokens // 0) + (.cache_read_input_tokens // 0)
    + (.cache_creation_input_tokens // 0)] | last // 0' 2>/dev/null
}

selftest() {
  local d; d=$(mktemp -d); trap 'rm -rf "$d"' RETURN
  local t="$d/t.jsonl" hook=(env HANDOVER_STATE="$d/state" HANDOVER_AT=1000 HANDOVER_STEP=500 bash "$0")
  u() { printf '{"type":"assistant","message":{"usage":{"input_tokens":1,"cache_read_input_tokens":%s,"cache_creation_input_tokens":0}}}\n' "$1" >>"$t"; }
  in="{\"session_id\":\"s1\",\"transcript_path\":\"$t\"}"
  u 500; "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 0 ] || { echo "FAIL fired below threshold"; return 1; }
  u 1200; "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 2 ] || { echo "FAIL not fired at threshold"; return 1; }
  "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 0 ] || { echo "FAIL fired twice"; return 1; }
  "${hook[@]}" <<<"{\"session_id\":\"s1\",\"transcript_path\":\"$t\",\"stop_hook_active\":true}"; [ $? = 0 ] || { echo "FAIL loop guard"; return 1; }
  u 1800; "${hook[@]}" <<<"$in" 2>/dev/null; [ $? = 2 ] || { echo "FAIL no refire after step"; return 1; }
  echo "ok"
}
[ "$1" = --selftest ] && { selftest; exit; }

in=$(cat)
[ "$($JQ -r '.stop_hook_active // false' <<<"$in")" = true ] && exit 0
t=$($JQ -r '.transcript_path // empty' <<<"$in"); [ -f "$t" ] || exit 0
id=$($JQ -r '.session_id // empty' <<<"$in"); [ -n "$id" ] || exit 0
ctx=$(ctx_of "$t"); [ "${ctx:-0}" -ge "$AT" ] 2>/dev/null || exit 0
mkdir -p "$STATE"; mark="$STATE/$id"
last=$(cat "$mark" 2>/dev/null || echo 0)
[ "$last" -gt 0 ] && [ "$ctx" -lt $((last + STEP)) ] && exit 0
echo "$ctx" >"$mark"
echo "Context is at $((ctx / 1000))k tokens. Load the handover skill and print the handover paste-box now, then tell the user to start a fresh thread with it. Do not start new work in this session." >&2
exit 2
