claude

personal config | skills | hooks | modes | settings | symlinked into ~/.claude

install
git clone https://github.com/SolRaze/claude && cd claude && ./install.sh
existing files left alone and printed | settings merged | backup at settings.json.bak

what it is
- skills/  self-made skills
- hooks/  statusline badges | mode rules | commit trace guard | lint on stop | prompt log
- modes/  caveman and ponytail rules, injected every session by hooks/modes.sh
- repos.md  third-party skills, cloned and linked at install | credits
- settings.json  merged into ~/.claude/settings.json
- regen-man-skills.sh  builds tmux | ghostty | sketchybar | aerospace | zsh skills from installed man pages | run by hand
- trim-skills.sh  sets which skills auto-invoke | list measured on one machine, re-measure before use

gotchas
hooks need jq | prompt-log.js needs node, logs only in projects with an Inbox/ folder
modes.sh turns caveman and ponytail on at ultra every session | remove its hooks from settings to opt out
some skills name local paths under ~/Projects | edit before use
