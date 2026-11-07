## Archiving

When the user asks to **archive** the session (not just print), persist it to memory. The ask is the yes; no separate proposal step.

- Store is one `MEMORY.md` per cwd, terse fact lines. No leaf files, no index. Under 200 lines / 25 KB.
- Extract only facts worth keeping — the **necessary and recurring** ones (preferences, decisions, constraints that outlive this chat). Drop one-off, session-local detail and anything one command shows.
- Compress: shortest form that keeps every technical fact, path, and number.
- If a fact contains code, **improve it** before saving — fix bugs, tighten, use stdlib/native over custom.
- On conflict between old and new state, **always take the newest version to date**. Edit the stale line in place, don't append both. Delete lines that stopped being true.
- Never store a credential.
