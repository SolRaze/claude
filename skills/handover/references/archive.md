## Archiving

When the user asks to **archive** the session (not just print), persist it to memory:

- Extract only facts worth keeping — the **necessary and recurring** ones (preferences, decisions, constraints that outlive this chat). Drop one-off, session-local detail.
- Compress the brief: shortest form that keeps every technical fact, path, and number.
- If a fact contains code, **improve it** before saving — fix bugs, tighten, use stdlib/native over custom.
- On conflict between old and new state, **always take the newest version to date**. Overwrite the stale one, don't append both.
- **Prune while archiving.** New facts that obsolete an old memory file's content: rewrite that file, and fix its MEMORY.md index line to match. Never leave an index line pointing at stale content — index rot is worse than no memory.
