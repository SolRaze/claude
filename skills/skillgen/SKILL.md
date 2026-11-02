---
name: skillgen
disable-model-invocation: true
description: Turn documentation into Claude skills from man pages, documentation websites, GitHub repos, or PDFs — verifying that content actually survives extraction. Use when asked to build a skill from docs, capture a tool's manual, scrape a doc site into a reference, or convert a repo/PDF into a skill.
---

# skillgen

Converts documentation into skills under `~/.claude/skills/<name>/`, and refuses
to write one that silently lost its content.

## Usage

```bash
scripts/skillgen.py man tmux zsh --name unix-tools
scripts/skillgen.py web https://docs.example.com/guide --name example --max-pages 50
scripts/skillgen.py repo owner/repo --name thing
scripts/skillgen.py pdf ./manual.pdf --name manual
```

Runs via `uv run` with inline PEP 723 dependencies — no install step, nothing
global to clean up. First run takes a few seconds to build the cached env.

Flags: `--name`, `--description`, `--dry-run` (extract and check, write nothing),
`--force` (write despite a failed retention check).
Web-only: `--prefix` (restrict the crawl), `--max-pages`, `--delay`.

**Always `--dry-run` first** on an unfamiliar source. It prints the retention
table and writes nothing.

## The retention check

Every extractor reports source words → output words per document. The run fails
and writes nothing if either:

- a document yields under 50 words (`EMPTY`) — a nav-only shell, a scanned PDF
  page, a stub man page; or
- retention falls under the floor (`LOSSY`) — 90% for man/repo/pdf, which are
  verbatim copies, and 50% for web, measured against `<body>` where dropping
  nav and footer chrome is correct.

This exists because the tool this replaces printed "✅ Skill built" while
discarding 96% of the tmux manual — the generated skill had zero mentions of
`status-left` or `copy-mode`. A skill that is silently 4% complete is worse than
no skill, because you trust it. Prefer a loud failure.

If a run reports `LOSSY`, fix the extractor or narrow the source. Reach for
`--force` only once you understand *why* the loss is legitimate.

## Source notes

- **man** — the best source for installed CLI tools: version-matched to the
  local binary, no network, no scraper to break. Multi-page tools need every
  page named (`zshall` is one blob; `zshoptions`, `zshbuiltins`, … are the
  useful split).
- **web** — picks the content container by text volume, never by selector
  order. Use `--prefix` to keep the crawl inside one section. Has a request
  delay; these are usually volunteer-run hosts.
- **repo** — shallow-clones and harvests `.md`/`.mdx`. No token, no API rate
  limit.
- **pdf** — text-layer only. Scanned PDFs extract nothing and the tool says so;
  OCR first (`ocrmypdf`).

## Layout

`SKILL.md` is an index and is always in context; the bulk lives in
`references/` and is read on demand. For large outputs, grep the references —
do not read them whole.

## Related

`~/.claude/skills/regen-man-skills.sh` regenerates the five hand-tuned config
skills (tmux, ghostty, sketchybar, aerospace, zsh) with curated SKILL.md prose.
skillgen is the general engine; that script is the pinned recipe. Re-run it
after `brew upgrade`.

Self-check: `scripts/test_skillgen.py`.
