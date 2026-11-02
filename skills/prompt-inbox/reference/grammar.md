# Inbox line grammar (default)

Fallback when a project has no `Prompt/PROMPTING.md`. The project's own file
always wins.

## Tags (fixed set)

| Tag | Meaning |
|-----|---------|
| `Q` | Open question, no decision yet |
| `Q→A` | A `Q` the user has now resolved; records what was asked and what won |
| `FEAT` | New feature / new behavior |
| `CHG` | Modify existing behavior |
| `ADD` | New UI element |
| `BUG` | Broken / edge case |
| `NICE` | Optional, low priority |

## Line template

```
section:(TAG)#id title — current: X | want: Y | depends/fallback: Z | pri: H/M/L
```

`section` is the surface, lowercase, no spaces: `home`, `library`, `nowplaying`,
`fetch`, `settings`, `search`, `import`. Reuse an existing section name before
inventing one.

Examples:

```
home:(CHG)#12 edit entry — current: toolbar Edit button | want: hold-to-edit, button removed | depends: #9 drag tiles | pri: M
fetch:(BUG)#13 tie-break — current: equal play counts order randomly | want: most recent play wins, then title A→Z | pri: L
fetch:(Q→A)#6 origin: lean search field vs full batch review | resolved: full batch review | expands: #6a–#6h
```

## Status annotations

Written under the item, quoted, never reworded once written:

```
> **DONE** (2026-07-26) — one-line what changed + files touched. Open leftovers named.
> **PARTIAL** (2026-07-26) — which half landed, which didn't, why.
> **ISSUE** (2026-07-26) — tried, blocked; the blocker in one sentence.
> **BACKLOG** (2026-07-26) — deferred deliberately; what would unblock it.
```

## Pre-send checklist (for the human writing the raw ask)

- [ ] One ask per line?
- [ ] `current` and `want` both stated?
- [ ] Exact numbers given, or explicitly deferred to agent judgment?
- [ ] Every affected surface named?
- [ ] Name checked against the glossary?
- [ ] id continues the master counter?

## Friction patterns (each cost a real round-trip)

- **Bundled asks** — one sentence carrying 3–4 requests.
- **`want` with no `current`** — forces a guess at the starting state.
- **Rename churn** — a name picked, reused inconsistently, then reversed.
- **Vague magnitude** — "a bit more spacing" with no number or reference.
- **Typos in names** — names get quoted literally into code and UI strings.
- **Unstated scope** — change applies to 3 similar screens, only 1 named.
