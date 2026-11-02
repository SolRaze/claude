## Forward handoff (task brief)

"handoff <task>" / "handoff prompt for X" = the **forward** variant: not extracting this session, but writing a paste-ready brief so a fresh session can execute a *new* task cold. Same discipline, different direction:

- Recon first: verify paths, versions, file formats on the target machine *now*; a handoff built on guesses wastes the next session's first hour.
- Structure: `# TASK` title → Goal → Machine facts (constraints the doc can't know: sudo scope, display, input methods) → Verified facts (paths, sizes) → Steps → Gotchas → "Done when" (observable criteria).
- Bake in every environment constraint the next session would otherwise trip on.
- Fence the whole brief in one block — it must survive copy-paste.
