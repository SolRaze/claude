---
name: cc-canary-plus
disable-model-invocation: true
description: Three drift signals that cc-canary does not compute — cohort split (is it the model or the harness?), instruction decay (how fast do this user's CLAUDE.md rules stop being obeyed?), and stylometric step-change (silent model swap). Runs a stdlib-only Python script over ~/.claude/projects/**/*.jsonl in ~1s and prints a short report. Use alongside /cc-canary, or when asked "has Claude got worse", "is this drift or the harness", "did the model change", "are my rules still being followed".
argument-hint: "[window, default 60d]"
allowed-tools: Read Bash(python3 *) Bash(date *)
---

# cc-canary-plus

Companion to `/cc-canary`. Same inputs, same dedupe rule, same constraints:
pure stdlib, read-only, no network. It answers three questions cc-canary
cannot.

## Run it

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/canary_plus.py \
  --window ${1:-60d} --exclude-project config-sketchybar
```

**`--exclude-project config-sketchybar` is mandatory on this machine.** The
sketchybar usage pill spawns a session per poll; without the flag those are
~96% of the session count and every average collapses toward zero. Add more
`--exclude-project` flags if another automated caller appears.

`--json` emits the raw numbers instead of the report.

## Reading the output

**A. Cohorts** — requests grouped by `effort | model | cc-version`, with output
tokens per request.

- Same model, two cc-versions, different out/req → **harness change, not model drift**.
- Same version, two models → a real comparison.
- `odd` counts stop reasons that are neither `end_turn` nor `tool_use`.

The obvious cohort keys (`inference_geo`, `service_tier`, `speed`) are **not**
used: measured on this account they are 100% `not_available` / `standard` /
`standard`, so they yield a single cell. If that ever changes they become the
better split — re-check before assuming.

**B. Instruction decay** — violations per 100 tool calls, by week, of the three
mechanically checkable rules in `~/.claude/CLAUDE.md`:

| column | rule | how it is judged |
|---|---|---|
| `bash` | pipe Bash output through `head`/`rg` | result exceeded 10 KB *and* the command had no limiter |
| `read` | files >500 lines: use `offset`/`limit` | result exceeded 40 KB *and* the call had neither |
| `attr` | no AI attribution, ever | the string appears in a `git commit` command, or is written into a file that is not itself documenting the ban |

Each is judged on the **result**, not the intent — `mkdir -p x` needs no `head`,
so commanding without a limiter is only a violation when the output was
actually large. Rules needing judgement are deliberately not measured.

**C. Stylometry** — per-week fingerprint of the assistant's prose, cosine
distance against the previous week.

- `sent_var` falling while `sent_mean` stays flat is the classic quantization
  tell: sentence lengths becoming uniform.
- A cosine dip **with no model change in section A** is the thing to escalate —
  that is what a silent swap looks like.
- Weeks with under ~800 words of prose are skipped; the vector is noise below
  that.

## Honest limits

- **Not a benchmark.** Task mix moves these numbers too. A week of dense config
  work reads differently from a week of prose. Treat a step change as a
  question, not a verdict.
- **Parallel tool-call rate was removed.** It is the sharpest degradation signal
  in principle, but this harness emits one `tool_use` per assistant record
  (measured: 6114 records with 0, 2928 with 1, exactly 1 with 2), so it can
  never be non-zero here. Re-add it if the harness ever batches.
- Weeks are ISO Monday-anchored, from the record timestamp.
