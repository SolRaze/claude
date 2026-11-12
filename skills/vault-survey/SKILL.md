---
name: vault-survey
description: Refresh or extend a ~/Notes survey (printers/, recomps/, any hub + topic-note set tracking open-source projects) with GitHub stats, Reddit and tracker findings, and other sessions' results. Use on "update research", "newer findings", "reddit research", "refresh stars", or adding a project or category to a survey.
---

# vault-survey

A survey is a hub dashboard plus topic notes of project tables. Current ones:
`printers/` (hub `printers.md`), `recomps/` (hub `recomps.md`). Note shape and
footers follow the vault's own note rules; this skill is the research
loop that feeds them.

## Shape that every survey keeps

- table columns `project | ★ | pushed | licence | what`; project cell links the repo
- ★, pushed (YYYY-MM), licence come from the GitHub API on the read date, never from memory
- licence: SPDX id; `NOASSERTION` → `custom` unless the readme states one; no file → `none`
- `verify` on anything not confirmed against a primary source; drop it once confirmed
- hub carries: read date and counts line, map table, state table, "where the work is",
  a dated findings section, legend, `own`, links, keywords
- frontmatter `updated:` bumped on every edit; intro read-date only when all stats were refreshed

## Loop

1. **Read state.** `ls` the folder, read the hub and the target note. Grep before adding:
   other sessions write here too.
2. **Other sessions.** `t3_thread_list` with `allProjects` + `titleContains` (topic words),
   `t3_thread_read` the hits. Grep each finding in the folder; most are already filed.
   Only file what is missing.
3. **Refresh stats.** For every repo link in the note:
   ```bash
   rg -o 'github\.com/([^/)]+/[^/)]+)\)' -r '$1' NOTE.md | sort -u | while read r; do
     gh api repos/$r --jq '[.full_name,.stargazers_count,.pushed_at[0:7],(.license.spdx_id//"none"),.archived]|@tsv'
   done
   ```
   Pushed month moved → `gh api 'repos/R/commits?since=DATE'` to learn what changed
   (a release, not a typo fix, earns a line).
4. **New projects.** `gh search repos --created '>DATE' 'terms' --sort stars`; owner sweep
   for big orgs: `gh search repos --owner VoronDesign --sort updated`.
5. **Reddit.** See below. Read the release posts and the "what upgrades / which X" threads:
   they say what the community actually picks.
6. **Trackers and sites.** recomps: allrecomps.com/updates, recompsoftware.com platform pages.
   printers: docs.vorondesign.com, Printables for off-GitHub designs.
7. **Write.** Re-read the file inside the edit script (the phone edits via LiveSync),
   replace with `assert s.count(old)==1`, never rewrite from stale context.
   Add rows in place; add a dated `## reddit read YYYY-MM-DD` / `## week to YYYY-MM-DD`
   section with linked posts; one line in the hub's "where the work is" for big news.
   Route finds to the note that owns them (toolchangers → `printers-multi`, not `printers-parts`).
8. **Reply.** What changed, a table of rows touched, what stayed open, `Sources:` list.

## Reddit access

- `curl` to `reddit.com/*.json` and `pullpush.io`: blocked (HTML / 526). WebSearch rarely
  returns Reddit threads. Use the T3 preview browser on `www.reddit.com`;
  `old.reddit.com` redirects to login.
- Search, many queries in one `preview_evaluate` (same-origin fetch of HTML works, JSON does not):
  ```js
  const h=await (await fetch(`/r/${sub}/search/?q=${encodeURIComponent(q)}&sort=new&t=month`)).text();
  const d=new DOMParser().parseFromString(h,'text/html');
  [...d.querySelectorAll('a[data-testid="post-title"]')]  // title, href
  // date: closest unit faceplate-timeago[ts]; score: faceplate-number[number]
  ```
- Post bodies: `preview_navigate` to the post, then read the live DOM:
  `shreddit-post` attrs `created-timestamp`, `score`; `[slot="text-body"]` innerText and links;
  `shreddit-comment` `score` + `[slot="comment"]`. Fetching a post URL returns an empty
  shell, and an iframe loop exceeds the 15 s evaluate limit: one navigate per post.
- `/top/?t=month` renders only ~3 posts without scrolling: use search.
- Close the tab (`t3_preview_close`) before replying.
- Printables: search page renders empty to agents. From a preview tab on printables.com,
  POST `https://api.printables.com/graphql/` `searchPrints2(query, limit, ordering: popular)`;
  enum values unquoted.
- MakerWorld: from a preview tab on makerworld.com, GET
  `/api/v1/search-service/select/design2?keyword=Q&limit=N&offset=0&orderBy=most_download`;
  hits carry `likeCount`, `downloadCount`, `license`, `createTime`.
- Subs: printers r/VORONDesign r/klippers r/3Dprinting · recomps r/recomps r/decomps
  r/emulation r/SteamDeck.

## Never

- prices, currency, order numbers
- inline `#tags` or `tags:` frontmatter
- bulk data or dumps in the vault: CSV exports, archives stay outside the vault
- stars or dates typed from memory
