#!/bin/bash
# Caveman + ponytail rules, replacing the upstream plugins' hooks.
#   modes.sh start     SessionStart: both rulesets as context
#   modes.sh subagent  SubagentStart: same, as hookSpecificOutput JSON
#   modes.sh prompt    UserPromptSubmit: one-line drift guard
# The flag files feed the caveman and ponytail statusline badges.
D="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
case "$1" in
  start)
    printf ultra > "$D/.caveman-active"; printf ultra > "$D/.ponytail-active"
    cat "$D/modes/caveman.md" "$D/modes/ponytail.md" ;;
  subagent)
    cat "$D/modes/caveman.md" "$D/modes/ponytail.md" \
      | jq -Rs '{hookSpecificOutput:{hookEventName:"SubagentStart",additionalContext:.}}' ;;
  prompt)
    echo "Caveman ultra + ponytail ultra apply unless the user turned them off this session." ;;
esac
