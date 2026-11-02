---
name: prompt-inbox
disable-model-invocation: true
description: >
  Turn a raw prompt log into structured inbox items, resolve what's ambiguous
  with the question UI, then implement top-down and commit. Project-agnostic:
  works in any repo that has an `Inbox/` folder (raw-prompt.md + inbox-N.md)
  and optionally a `Prompt/` folder of grammar docs. Use when the user says
  "process the inbox", "check inbox", "convert the prompt log", "triage inbox",
  "work the inbox", "clean up inbox", or hands over a wall of bundled asks that
  needs splitting into atomic items before anything gets built.
argument-hint: "[inbox file | 'convert' | 'work']"
---

# Prompt inbox

Pipeline: **raw prompt → atomic items → clarify → build → annotate → commit.**
Each phase exists to kill one class of rework. Do them in order; skip a phase
only when the user names one (`/prompt-inbox convert`).

## Phase 0 — locate

At the repo root, expect:

```
Inbox/raw-prompt.md     verbatim prompt log, appended by the prompt-log hook
Inbox/inbox-N.md        structured items, annotated in place, never drained
Prompt/PROMPTING.md     project's grammar + checklist (if absent: reference/grammar.md)
Prompt/GLOSSARY.md      settled names — read before naming anything
```

No `Inbox/`? Say so, offer to create it plus the hook opt-in (the hook at
`~/.claude/hooks/prompt-log.js` only logs in projects that have `Inbox/`).
Read `Prompt/PROMPTING.md` if it exists — the project's grammar wins over this
skill's default. Read `Prompt/GLOSSARY.md` before writing any name into an item.

These files are LiveSync/vault-synced in some projects and change on the phone
mid-session. **Re-read any inbox file immediately before you write to it.**

## Phase 1 — convert

Source is the untriaged tail of `Inbox/raw-prompt.md` (or the file the user
named). Convert to the line grammar in `reference/grammar.md`:

```
section:(TAG)#id title — current: X | want: Y | depends/fallback: Z | pri: H/M/L
```

- One atomic ask per line. A sentence with "and… and… also…" is 3+ lines.
- `id` runs on ONE master counter across all inbox files. Never reset it — find
  the highest id in use and continue. Cross-file `depends: #N` breaks otherwise.
- Fill `current` yourself by reading the code, not by asking. `want:` alone
  forces a guess at today's behavior; a grep is cheaper than a round-trip.
- Name every surface a change touches when several are similar (album finder AND
  artwork finder AND lyrics search). Unstated scope is the top round-trip cause.
- Raw asks get split and reshaped. **Agent-written status notes (`> DONE`,
  `> PARTIAL`, `> ISSUE`, `> BACKLOG` blocks) are copied verbatim — never
  reworded, never re-summarized, never merged.**

## Phase 2 — clarify (the question UI)

Before building, sort every unclear item into one of three buckets:

1. **Answerable from the code** → answer it yourself. Grep first. An item saying
   "current: unknown" is a research task, not a question.
2. **Answerable by a sensible default** → pick it, state the pick in one line,
   move on. Tie-break rules, spacing values, icon names.
3. **Genuinely the user's call** → AskUserQuestion. Only architecture forks,
   irreversible direction, taste calls, and conflicts between items.

Batching rules for AskUserQuestion:

- Max 4 questions per call; ask the highest-leverage 4, not the first 4.
- Each option carries the concrete consequence — what gets built, what it costs,
  what it blocks. "Option A / Option B" with no tradeoff wastes the round-trip.
- Recommended option first, labelled `(Recommended)`.
- Ask BEFORE writing code, once, in one batch — not trickled per item.
- Answers get written back as one compact line each, not prose:
  `section:(Q→A)#id origin: <what was asked> | resolved: <what user picked> | expands: #Na–#Nc`

## Phase 3 — build (ponytail)

Laziest solution that actually works. Standard library before custom code,
native platform features before dependencies, one line before fifty. Question
whether an item needs to exist at all before building it.

Deliberate shortcuts get a `ponytail:` comment naming the ceiling and the
upgrade path — `/ponytail-debt` harvests those into a ledger later.

Work top-down through the inbox. After each item, annotate it **in place**:

```
> **DONE** (YYYY-MM-DD) — what actually changed, which files, what's still open.
```

Legend: `DONE` · `PARTIAL` · `ISSUE` · `BACKLOG`. Never delete an item, never
drain a file — later corrections ("this is reversed") need something to point at.
`PARTIAL` states exactly which half landed.

Anything non-trivial leaves behind one runnable check — the smallest thing that
fails if the logic breaks.

## Phase 4 — commit

`/caveman-commit` for every commit and push. No AI attribution in messages.
Batch commits logically (one item or one coherent group per commit), not one
giant dump. Push only when the user has asked for pushes, or the project's
CLAUDE.md makes it the standing per-batch ritual.

## Token rules

Cost tracks round-trips and rework, not prompt length. Spend words to prevent a
reversal; spend none on restating what a file already says.

- Compact grammar over prose: one line per ask beats a paragraph per ask.
- Never re-summarize the inbox back to the user — they wrote it. Report deltas:
  what changed state, what's blocked, what needs their call.
- Quote code by `path:line`, not by pasting the block.
- One front-loaded question batch beats ten trickled pokes.
