review

how to run
1. specificity first: could unrelated product use this layout, copy, palette unchanged | answer before details
2. walk 2 to 3 relevant personas | note exact failing elements
   - impatient power user: keyboard, speed, bulk actions
   - confused first-timer: jargon, missing guidance, unclear next step
   - screen-reader + keyboard-only user: labels, focus order, announcements
   - distracted one-handed mobile user: thumb reach, target size, interruptions
   - stress tester: long names, 1,000 rows, slow network, double clicks
3. score (below)
4. report | this table is the one review format | most severe first | one-line verdict after

| Sev | Where | Problem | Rule | Fix (exact values) |
|---|---|---|---|---|
| P1 | Checkout, "Pay" button | 32px tall, beside "Cancel" with 4px gap | Fitts, touch target | 48px height, 16px gap, Cancel as text link |

severity: P0 blocks task or loses data | P1 major, users would contact support | P2 minor, workaround exists | P3 polish
motion reviews: Problem + Fix cells give before + after durations and curves

scores
- Nielsen heuristics (`laws.md`): 0 to 4 each, total /40 | 36+ excellent | 28 to 35 good | 20 to 27 acceptable | 12 to 19 poor | under 12 critical | n/a where not applicable, rescale
- technical audit: 0 to 4 each, total /20: accessibility, performance, theming (tokens, dark mode), responsive, implementation integrity (states, no hard-coded values) | 18+ excellent | 14 to 17 good | 10 to 13 acceptable | under 10 poor
- cognitive load, count failures: single focus | chunking (4 or fewer per group) | grouping | hierarchy | one decision at a time | 4 or fewer visible choices at a decision point | no memory across screens | progressive disclosure | 0 to 1 low | 2 to 3 moderate | 4+ high

pre-ship checklist

direction
- [ ] contract stated for new surfaces + redesigns | brief constraints honored
- [ ] one signature move | everything else quiet | specificity test passes
- [ ] one theme per mode, one accent, one radius system, one icon family, one motion library
- [ ] existing look untouched unless redesign was asked | new look passes `taste.md` stranger test unless audience is sol only

layout and type
- [ ] hero fits viewport | headline 2 lines max on desktop | one primary CTA visible without scrolling
- [ ] spacing from scale | groups separated by space | no cards in cards
- [ ] body size per surface mode (SKILL.md) | measure under 75ch | headings balanced | tabular numerals on data
- [ ] at most one eyebrow per three sections | no repeated layout family back to back

color and accessibility
- [ ] contrast 4.5:1 text | 3:1 large text, icons, input borders, focus
- [ ] color never only signal | text over images has scrim
- [ ] keyboard: skip link, everything reachable, visible focus not obscured by sticky bars, logical order, Escape closes overlays, focus returns to trigger
- [ ] inputs labeled | icon buttons `aria-label` | images alt | landmarks + one `h1` | `aria-current` on active nav
- [ ] dragging has single-pointer alternative
- [ ] works at 200% zoom + largest system text size | `forced-colors` keeps borders + focus
- [ ] dark mode checked separately (if supported)

states and content
- [ ] default, hover, focus, active, disabled, loading, empty, error, success all exist
- [ ] forms keep input on error | errors next to fields | double submit blocked
- [ ] real or marked placeholder content | no fake metrics | no lorem ipsum
- [ ] copy: verb + object buttons | one label per intent | no filler words | no em dashes

motion
- [ ] each animation has stated purpose | none on keyboard or high-frequency actions
- [ ] transform + opacity unless `motion.md` exception | named properties | durations from table | exits shorter
- [ ] popovers grow from trigger | nothing scales from 0 | no bounce on utility UI
- [ ] reduced-motion path written | loops pause off-screen + pause control if over 5s

responsive and performance
- [ ] no horizontal scroll at 320px | checked 375px, 1440px, landscape phone | `dvh` not `vh`
- [ ] touch targets 44px+ | primary action in thumb reach on mobile | safe areas respected
- [ ] LCP < 2.5s, INP < 200ms, CLS < 0.1 | images sized with `aspect-ratio` | fonts preloaded + subset
- [ ] no console errors, unused imports, `any` left from build

hardening inputs
100+ character names | emoji | RTL text | CJK | Lithuanian diacritics | empty strings | 0 + negative numbers | 1,000+ list items | offline | 3G throttling | rapid double submit | forced API 500 | expired session | every empty state

bounded verification
batch inspection (desktop + mobile together) | fix batch | one confirming round | stop
third round seems necessary = direction wrong, not details | back to contract
