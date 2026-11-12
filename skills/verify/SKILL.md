---
name: verify
description: Pre-commit check for sol's repos - commit message shape, never-published files staged, currency in the diff. Runs before every commit.
effort: low
---

Run before `git commit`, with the exact message:

    ${CLAUDE_SKILL_DIR}/verify.sh [-C <repo>] "<message>"

Exit 0 = commit. Any `verify:` line = fix it first, never commit around it.

Checks: message lowercase, two to four words, no body, no `type(scope):`, no AI mention.
Staged `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `MEMORY.md`, `raw-prompt.md`, `Inbox/`, `plans/`, `.claude/` are refused, in any letter case.
A currency amount in an added line or in the message is refused.
Outside a git repo it exits 1. `verify.sh --selftest` runs its own cases.

Gotchas
- Repos that track `.claude/` on purpose (the dotfiles stow tree) still fail; unstage or confirm with sol.
- Repo pushed only to private infra, never a public host: `git config verify.private true` skips the path check, never the currency or message checks.
- Full rules live in `repo-shape`; this is the mechanical floor.
