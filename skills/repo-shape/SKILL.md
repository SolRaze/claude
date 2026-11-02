---
name: repo-shape
description: How every one of sol's repos is laid out, written and committed - folder structure, terse markdown style, commit message style, what never gets published, and de-branding. Read before creating any repo local or remote, before writing or editing any .md, and before writing a commit message.
---

repo shape

one layout | one writing style | one commit style | every repo | local and remote
applied when the repo is created, not retrofitted after

reference https://github.com/SolRaze/extentions | https://github.com/SolRaze/solder

structure
group by role, not by filetype
folder per role once that role holds two or more files
- hardware/ what the thing is | bom | pin map | physical mods
- setup/ build | configure | calibrate | recover
- log/ what is proven | what bites
- config/ live copies, pulled not hand-written
- slicer/ presets beside the doc explaining them
no single-child folders | `slicer/orca/` collapses to `slicer/`
scripts sit at root | one file, not a `bin/`

markdown
every `.md` written or touched | not only the README
no `#` headings | bare lowercase labels on their own line
keyword lines not sentences | drop articles | drop verbs carrying no information | drop connectives
  `cpu tamer | timer callbacks on animation frames | applies on reload` not a sentence saying the same
`|` separates terms and variants inline | no trailing periods
one line per item | cut words rather than wrap onto a second line
lists as `- name/ what it is` | links as `label url | label url`
`license mit` last where a repo carries one
tables only where they carry real data — pin maps | bom rows | per-directory contents
identifiers keep their case — `SET_VELOCITY_LIMIT` | `printer.cfg` | `PA0` | `v0.13.0`

README
name | blank | one-line keyword summary | blank | labelled blocks
blocks: what it is | docs map | state | gotchas
no github link | no license line | no badges | no emoji | no titles

commits
lowercase | two to four words | subject only | no body | no trailers | no `type(scope):`
`readme update` | `new bridge` | `terse docs drop cura` | `initial commit solder`
same for PR titles and bodies | tag messages | release notes
first commit of a new repo `initial commit <name>`
no Conventional Commits in any repo | local and remote share one style
never fix sol's spelling already in history or on a remote — `extentions` | `verion` | `greasefork`
governs the message only | code, comments and docs stay careful and complete

never published
CLAUDE.md | any agent instruction file
Inbox/ | working queues | triage lists | order lists | parts backlogs
raw-prompt.md | any verbatim session log
plans/ | memory stores | anything under `.claude/`

never written, anywhere
costing | prices | currency | order references | supplier records
big brand names — use the model number, or what the part does, so it stays buyable
  `V4.2.7` not `Creality V4.2.7` | `LRS-350-24` not `Mean Well LRS-350-24`
  keep a brand only where it is an identifier something resolves by —
  a profile `inherits` string | an upstream filename | a real url
check grammar after de-branding — blind replacement leaves "the stock the vendor one"

before publishing
public repo under `SolRaze` is read with none of this tree's context | ship the artefact, not the workspace
prose in sol's register — plain words | short sentences | no hedging | no agent voice | match the files being published
narrowest subtree that stands alone | say which subtree was picked
fix every link the narrowing breaks | a dangling `../../Inbox/…` names what was withheld
confirm the file list before creating the repo
deleting a public repo does not un-publish it | history holds what the worktree dropped
a rebuild-and-force-push replaces history | fetch first, remote web-UI edits are lost

preserve
every value | version | pin | exact invariant | upstream bug | command to verify
terse is about wording | never delete a fact to shorten a line
