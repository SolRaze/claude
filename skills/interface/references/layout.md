layout

structure check | before moving boxes
primary reading path | what groups | what separates | which element leads | density from contract DIALS
diagnose structure before decorating

spacing
- scale + grouping values per SKILL.md | semantic names (`--space-xs` .. `--space-3xl`) in tokens
- proximity (Gestalt): inside group clearly smaller than between groups | label to input 4 to 8px | field to field 16 to 24px | group to group 32 to 48px | section to section 64 to 160px
- rhythm: alternate tight + generous | equal spacing flattens hierarchy
- separate with space first, then 1px divider, then container | cards only for actual objects (product, project, message)
- never cards inside cards | inner level uses spacing + dividers
- `gap` for siblings, not margins on children
- squint test: primary, secondary, main groups visible in that order

grid and structure
- flexbox one-dimensional rows | grid two-dimensional page structure
- container `max-width: 72rem to 80rem` | side padding `clamp(1rem, 4vw, 3rem)` | text columns `max-width: 65ch`
- auto-fit without breakpoints: `grid-template-columns: repeat(auto-fit, minmax(16rem, 1fr))`
- left alignment reads designed | center only short symmetrical moments (final CTA, empty state)
- one left edge per column | align to grid | deliberate offsets big enough to read as intent
- bento: cell count = content count | no empty cells | 3 to 6 cells, real visual variety | interlocking spans (`grid-auto-flow: dense`)
- z-index scale: base 0 | dropdown 10 | sticky 20 | overlay 30 | modal 40 | toast 50 | tooltip 60 | no `z-[9999]`
- overflow: `min-width: 0` on flex/grid children with text | single-line ellipsis | multi-line `display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 3; overflow: hidden`
- dropdowns inside `overflow: hidden` ancestors clip | Popover API, `<dialog>`, portal, `position: fixed`
- CSS logical properties (`margin-inline`, `padding-block`, `inset-inline-start`) so RTL mirrors without overrides

density by surface
- Persuade: generous | sections 96 to 160px desktop, 64 to 96px mobile
- Operate: compact, breathable | table rows 40 to 48px | form fields 40 to 44px tall | sidebar 240 to 280px
- power-user data tools may go 32px rows with density toggle
- second neutral layer (slightly darker or tinted) for sidebars + toolbars, not borders everywhere

responsive
- mobile-first: base small screens, add `min-width` queries
- breakpoints where content breaks | anchors 640, 768, 1024, 1280px | test 320, 375, 768, 1024, 1440, one ultra-wide
- restructure, not shrink: reorder by importance | collapse secondary | tables to stacked cards | sidebars to drawers or bottom sheets
- container queries (`@container`) for components in varying widths
- fluid `clamp()` reduces breakpoints
- full-height: `min-height: 100dvh`, never `100vh` (mobile browser bars)
- no horizontal scroll at 320px | check landscape on phones
- detect input, not device: `@media (hover: hover) and (pointer: fine)` for hover | `(pointer: coarse)` for larger targets | nothing important depends on hover
- fixed headers + footers reserve space | `scroll-padding-top` so focused + anchored content is not obscured (WCAG 2.4.11)
- cap content on huge screens | 2560px-wide paragraph unreadable

mobile and touch
- primary actions in thumb zone (bottom third) | long forms + checkout: sticky bottom bar with main CTA
- touch targets 44x44pt / 48x48dp even for 20px icon | extend with padding or pseudo-element
- bottom nav: 3 to 5 items, icon + label, current item clearly marked
- safe areas: `viewport-fit=cover` in viewport meta + `padding: max(1rem, env(safe-area-inset-bottom))` for edge bars
- inputs 16px font minimum, avoids iOS zoom | correct `type`, `inputmode`, `autocomplete` for right keyboard
- no horizontal swipe for primary content (conflicts with system back)

specific layouts
- dashboard: one key question per screen | KPI row 3 to 5 decision-driving numbers | charts below | tables last | filters persistent + visible
- settings: grouped titled sections | left labels + right controls desktop, stacked mobile | save per section or autosave with feedback
- forms: single column | related short fields (city + postcode) may share a row
- email: 600px single column | table-based | inline CSS | dark-mode-safe images | live text, no images of text
