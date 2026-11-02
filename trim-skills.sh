#!/usr/bin/env bash
# Reduce skills to the ones this machine actually invokes.
#
# A skill's `description:` frontmatter sits in the system prompt on every single
# request; the body costs nothing until the skill runs. So a skill you only ever
# reach by typing /name should carry `disable-model-invocation: true` — that
# keeps the slash command and drops its standing cost to zero.
#
# KEEP_AUTO is the evidence-backed exception list, measured by counting Skill
# invocations across the transcripts:
#
#   rg -oIN '"skill"\s*:\s*"([a-z0-9:_-]+)"' -r '$1' ~/.claude/projects/ |
#     sort | uniq -c | sort -rn
#
# Re-measure before adding to it. The transcript window is only as long as the
# last prune left behind, so a zero there means "not used lately", not "never".
#
# caveman and ponytail are deliberately NOT in the list. Both are injected in
# full by their SessionStart hooks on every session, so auto-invocation was
# buying a second copy of something already present, and level switching goes
# through /caveman and /ponytail regardless.
#
# Plugin skills are edited under plugins/cache/, which is what actually loads —
# plugins/marketplaces/ is only the source clone. A `/plugin update` installs a
# fresh version directory and drops those edits, so re-run this after any
# update. Idempotent.
set -euo pipefail

CACHE="${PLUGIN_CACHE:-$HOME/.claude/plugins/cache}"
SKILLS="${SKILLS_DIR:-$HOME/.claude/skills}"

# repo-shape carries the markdown, commit and publishing rules that the global
# CLAUDE.md only points at, so it must fire unprompted whenever a .md, commit or
# repo is touched. burn is triggered by phrases ("burn this session") rather than
# by /burn, which needs its description in context. verify, model-preview,
# needs Skill-tool access. interface is the one design skill left auto-invocable;
# design-critique, interaction-design and web-design-guidelines are its /slash
# companions.

cost() { awk '/^name:/,/^---$/' "$1" | wc -c | tr -d ' '; }

before=0 after=0 trimmed=0

for f in "$CACHE"/*/*/*/skills/*/SKILL.md "$SKILLS"/*/SKILL.md; do
  [ -f "$f" ] || continue
  skill=$(basename "$(dirname "$f")")
  n=$(cost "$f"); before=$((before + n))

  case " $KEEP_AUTO " in
    *" $skill "*) after=$((after + n)); echo "  keep  $skill"; continue ;;
  esac

  if grep -q '^disable-model-invocation: true' "$f"; then
    echo "  done  $skill"
  else
    # Insert into the frontmatter block, immediately after the name: line.
    perl -i -pe 's/^(name:.*\n)/${1}disable-model-invocation: true\n/ if $. < 20' "$f"
    grep -q '^disable-model-invocation: true' "$f" || { echo "  FAIL  $skill" >&2; exit 1; }
    echo "  trim  $skill"
    trimmed=$((trimmed + 1))
  fi
done

echo
echo "auto-invocable description cost: ~$((before / 4)) tok -> ~$((after / 4)) tok  ($trimmed newly trimmed)"
