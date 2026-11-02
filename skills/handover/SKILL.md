---
name: handover
description: 'Distill the chat into one fenced paste-box that lets a fresh session act cold — whole session, or one named thread. Use on "handover", "hand off", "relay this session", "resume brief", "what changed here", "chat title".'
---

# Handover

**Hard rule: one fenced paste-box printed in the chat. Never a file** — no `handover.md`,
no `HANDOFF.md`, no note, no doc.

The reader is another session that must **act**, not a human filing a report. Every line
costs that session context. Size it to the job, not to the chat.

Variants — read the reference only when invoked that way:
- "handoff <task>" / "handoff prompt for X" — brief for a *new* task: `references/forward.md`
- "archive" — persist to memory: `references/archive.md`

## Read everything, emit little

Read the whole chat — tool results, edits, reversals. Only final state is true; a fact
reverted later is not a fact. Narrow at the emit step, never the read step.

**Keep test, per line:** the next session acts on it, or breaks something without it.
Otherwise cut. The receiver can read the code, the entry-point doc and `git log` itself —
do not transcribe what it can look up in one command. Cut:
- rationale for work already done and not being touched
- internals of the done side when the receiver only consumes its interface
- repo state of repos the receiver will not touch
- decisions that cannot come up in the receiver's task

## Shape

Everything inside ONE plain ``` fence (no language tag): title, facts, directive. Nothing
outside it except at most one short line offering the next step. Title fenced and facts
loose below it = failed handover.

1. **Title** — one line, ≤6 words, `<project>: <outcome>`. Project name first, primary
   outcome not first topic. No quotes, no period. ≤3 comma-separated workstreams.
2. **Facts** — terse bullets, concrete: path, `file:line`, command, port, PID, sha.
3. **Directive** — ≤6 lines: what to do, entry-point doc to read, the boundary.

### Scoped (`handover the relay work`, `for an atlas session`) — default lean

No section headers. ~5–12 bullets:
- the interface the receiver builds on (command, verb, behaviour) — not how it works inside
- where to edit: repo path, branch, `file:line`, what each edit becomes
- traps: foreign uncommitted changes to leave alone, anything live or expiring
- boundary: what is done and must not be touched

Out-of-scope fact only when the scoped work breaks without it.

### Whole session — headers, omit any that is empty

- **Changed** — what behaves differently, where. One bullet per change.
- **Repo state** — only repos the next session works in: branch, short-sha, dirty count,
  pushed or not per moved branch (`git log origin/<b>..<b> --oneline | wc -l`). Run
  `git status --short` / `git log --oneline -1` now; never from memory.
- **Files** — absolute paths, created/edited/deleted, ≤3 words each.
- **Decisions** — only ones the next session could relitigate. Choice + one-clause reason.
- **Verified** — what ran and the result; otherwise "unverified". Re-verify one-liner if cheap.
- **Live state** — running processes, watchers, non-persistent settings, expiry dates. Name
  pid/host/path/date.
- **Pending** — priority order. Include stale docs contradicting final state.
- **Risks** — destructive, irreversible, security-relevant, backup paths. Carry forward or
  explicitly retire risks from a previous handover.

## Rules

- Done ≠ attempted ≠ planned. "Wrote X" ≠ "verified X".
- Quote errors verbatim only when they are the evidence.
- No preamble, no prose paragraphs.
- Before sending: one fence? every line passes the keep test?

## Receiving a handover

- Spot-check 2–3 load-bearing claims against reality first.
- Live state first, then Pending top-down.
- Don't relitigate Decisions.

## Boundaries

Read-only: prints to chat, changes no files (`git status`/`log` fine). Memory is touched
only when a store fact is now wrong or a durable trap was learned — fix that line in
place; an explicit archive is the only full write.
