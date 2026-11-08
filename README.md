claude

personal config | skills | hooks | modes | output styles | settings | symlinked into ~/.claude

install
git clone https://github.com/SolRaze/claude && cd claude && ./install.sh
existing files left alone and printed | settings merged | backup at settings.json.bak

what it is
- skills/  self-made skills
- hooks/  statusline badges | mode rules | commit trace guard | lint on stop | handover at 200k | read cap | prompt log
- output-styles/  caveman voice, set by outputStyle in settings.json | system prompt every request
- modes/  ponytail rules, injected every session by hooks/modes.sh | subagents get caveman too
- repos.md  third-party skills, cloned and linked at install | credits
- settings.json  merged into ~/.claude/settings.json
- regen-man-skills.sh  builds tmux | ghostty | sketchybar | aerospace | zsh skills from installed man pages | run by hand
- trim-skills.sh  sets which skills auto-invoke | list measured on one machine, re-measure before use

gotchas
hooks need jq | prompt-log.js needs node, logs only in projects with an Inbox/ folder
caveman on via outputStyle | drop the key to opt out
modes.sh turns ponytail on at ultra every session | remove its hooks from settings to opt out
read-cap.sh denies whole-file reads past 500 lines | READ_CAP overrides
auto-compact off | handover-at.sh makes the session print a handover past 200k context | HANDOVER_AT, HANDOVER_STEP override
some skills name local paths under ~/Projects | edit before use

license mit
