polish

details that make UI feel expensive

geometry
- concentric radius: inner = outer minus padding | 16px card + 8px padding holds 8px-radius children | mismatched radii most visible amateur tell
- one radius system per product: sharp (0 to 4px) | soft (8 to 16px) | pill | documented exceptions only (pill buttons on soft-card system valid when written down)
- optical alignment: nudge asymmetric icons (play triangle, arrows, chevrons) 1 to 2px toward visual center | icon-leading buttons slightly less padding on icon side
- hit areas larger than visuals: 20px icon button gets 44px hit area via padding or `::before { inset: -12px }`, no overlapping neighbors

depth
- shadows layered, soft, tinted to background hue | never single hard black shadow on light UI
  ```css
  --shadow-sm: 0 1px 2px oklch(20% 0.02 250 / 0.06), 0 1px 1px oklch(20% 0.02 250 / 0.04);
  --shadow-md: 0 4px 12px -2px oklch(20% 0.02 250 / 0.08), 0 2px 4px -2px oklch(20% 0.02 250 / 0.06);
  --shadow-lg: 0 16px 40px -12px oklch(20% 0.02 250 / 0.16);
  ```
- ring shadow `0 0 0 1px oklch(0% 0 0 / 0.06)` instead of border works on varied backgrounds
- elevation means something: flat content | sm cards | md dropdowns | lg modals
- images get 1px inner outline (`outline: 1px solid oklch(0% 0 0 / 0.08); outline-offset: -1px`, white at 0.1 alpha in dark mode) | stops bleed into background
- glass (backdrop blur) only on layers floating over content (sticky header, sheet) | 1px light inner border | solid fallback for `prefers-reduced-transparency` | not every card
- grain/noise: fixed, `pointer-events: none`, 3 to 5% opacity, never on scrolling containers

type and numbers
- tabular numerals on anything changing or aligning
- `text-wrap: balance` on headings | `pretty` on paragraphs
- real punctuation: curly quotes, ellipsis, ×, non-breaking spaces before units
- long words + URLs: `overflow-wrap: anywhere` in user-generated content

icons
- one family, one stroke width (1.5 or 2), one size scale (16 / 20 / 24) | good families: Lucide, Phosphor, Tabler, Radix Icons, Heroicons | SF Symbols + Material Symbols natively
- icons on text baseline, match text color, about 1.25x cap height of adjacent text
- no emoji as UI icons | no hand-drawn SVG paths when library icon exists
- icon-only buttons only universally known actions (close, search, menu, more) | everything else labeled

images and illustration
- real images beat decoration: product screenshots, real photos, custom illustration in one style
- never fake product UI with divs in marketing hero | real screenshot or real interactive component
- `aspect-ratio` + `width`/`height` on every image, stops layout shift | `loading="lazy"` below fold | `fetchpriority="high"` on hero | AVIF/WebP + responsive `srcset`
- text over photos needs scrim or gradient for 4.5:1
- avatars: real initials on tinted background when no photo | no generic gray silhouette
- logos: official SVGs (Simple Icons for common brands) | one treatment (monochrome or original) | sized by optical weight, not equal width

interaction details
- name transitioned properties | never `transition: all`
- disable text selection only on draggable handles, never content
- `cursor: pointer` on clickable non-link elements | `cursor: grab/grabbing` on draggables
- scroll containers: `overscroll-behavior: contain` in modals + sheets | `scrollbar-gutter: stable` stops layout jumps
- sticky headers shrink or gain border only after scrolling begins
- preserve scroll position + form state on back navigation
- instant feedback on every click: state change within 100ms, even if result takes longer
- optimistic updates for likes, toggles, reorder | roll back with message on failure
- keyboard: Tab order follows visual order | Escape closes top layer | Enter submits forms | `/` or Cmd+K for search in tools
- `::selection` in brand color | `accent-color` on native checkboxes + radios | `caret-color` matching accent
- favicon | page `<title>` per route | `theme-color` meta for mobile browser chrome

final polish pass
1. replace every hard-coded value with token
2. check concentric radii + alignment to one left edge
3. squint test + 2-second test: what page is, main action
4. remove one element not earning its place
5. check all states with real, ugly data
