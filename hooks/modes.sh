#!/bin/bash
# Caveman + ponytail rules, replacing the upstream plugins' hooks.
# Caveman lives in output-styles/caveman.md (outputStyle in settings.json), so
# the main session gets it in the system prompt on every request. Subagents run
# their own system prompt, so they get its body here.
#   modes.sh start     SessionStart: ponytail rules as context
#   modes.sh subagent  SubagentStart: caveman body + ponytail, as hookSpecificOutput JSON
#   modes.sh prompt    UserPromptSubmit: one-line drift guard
# The flag files feed the caveman and ponytail statusline badges.
D="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
case "$1" in
  start)
    printf ultra > "$D/.caveman-active"; printf ultra > "$D/.ponytail-active"
    cat "$D/modes/ponytail.md" ;;
  subagent)
    { awk 'f>=2; /^---$/{f++}' "$D/output-styles/caveman.md"; cat "$D/modes/ponytail.md"; } \
      | jq -Rs '{hookSpecificOutput:{hookEventName:"SubagentStart",additionalContext:.}}' ;;
  prompt)
    echo "Caveman ultra + ponytail ultra apply unless the user turned them off this session." ;;
esac
