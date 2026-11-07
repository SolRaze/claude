---
name: burn
description: Wipe Claude-side state (transcripts, memory store, memory.md row) for a session, name or project. To Trash, dry run until --yes. Use on "burn this session", "burn <project>", "wipe this chat".
effort: low
---

burn

wipes agent state | never touches work files
script `burn.zsh` beside this file | dry run unless `--yes`

what goes

- `~/.claude/projects/<slug>/*.jsonl` session transcripts
- `~/.claude/projects/<slug>/memory/MEMORY.md` memory store
- table rows in `~/Projects/memory.md` naming a burned slug

what never goes

- anything under `~/Projects`, `~/Notes`, `~/Reference` | repos, unpushed commits, vault notes
- prose in `memory.md` that mentions a slug — only `|` table rows are stripped
- the live session transcript, unless `--include-current`

targets

| form | resolves to |
| ---- | ----------- |
| `session` | transcripts for `$PWD`'s slug, memory store kept |
| `<name>` | every slug containing that substring, whole store |
| `<path>` | that directory's slug, whole store |

slug = absolute path, every non-alphanumeric character replaced by `-`

run

    ${CLAUDE_SKILL_DIR}/burn.zsh chip            # dry run, prints sizes
    ${CLAUDE_SKILL_DIR}/burn.zsh --yes chip      # burns
    ${CLAUDE_SKILL_DIR}/burn.zsh session         # this project, live chat kept
    ${CLAUDE_SKILL_DIR}/burn.zsh --yes --include-current session

rules

- always show the dry run first and wait for the user to confirm. never pass `--yes` unprompted
- a bare `<name>` is a substring match and can hit several stores — read the dry-run list aloud before burning
- removal is `/usr/bin/trash`, so a wrong burn is recoverable from Finder until the Trash is emptied
- `--include-current` kills the transcript of the chat you are in. only on explicit request

gotchas

- renaming a folder orphans its store under the old slug — burn by `<name>`, not by path, once a folder has moved
- `session` and `<path>` resolve symlinks first: `~/.config/zsh` burns the `-Users-sol-Projects-Code-dotfiles-zsh` store
- `autoMemoryEnabled` is `false` in `~/.claude/settings.json`, so the stores are a dormant archive; burning one changes nothing in a live session until that flag goes back on
