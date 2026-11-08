---
name: interface
description: One complete UI/UX and motion design skill for any interface work. Use it to design, build, redesign, polish or review web and mobile UI (landing pages, SaaS apps, dashboards, forms, onboarding, e-commerce, portfolios, native iOS/Android screens) and game or canvas menus, launchers and controller button prompts. Covers design direction, typography, color, layout, components and states, UX copy, motion and animation (durations, easing, springs, reduced motion, performance), UX laws (Jakob, Hick, Fitts, Doherty, Gestalt, Tesler, Postel, Peak-End), accessibility numbers, AI-slop tells to avoid, a scored review method, and sol's own design taste translated so strangers can still use it.
---

interface

direction | build to floor | purposeful motion | verify
this file holds workflow + every shared number | references hold detail | load only what the step needs

references
- references/taste.md sol's design philosophy | what sol likes + rejects | translation that keeps it intuitive | stranger test
- references/direction.md contract detail | dials | product presets | redesign | page pacing | native
- references/styles-catalog.md named visual styles | only when brief names a style or asks for options
- references/typography.md fonts | scale | line length | numerals
- references/color.md palette strategy | OKLCH | contrast | dark mode
- references/layout.md spacing | grids | responsive | mobile | safe areas
- references/components.md states | forms | nav | modals | tables | empty, loading, error | accessibility structure | UX copy
- references/motion.md when | durations | easing | springs | patterns | perf | a11y
- references/polish.md micro-details | icons | images | depth
- references/anti-slop.md machine-made tells + alternatives
- references/laws.md UX laws | Nielsen heuristics | Norman principles
- references/review.md critique | required passes | scores | personas | hardening | pre-ship checklist
- references/console.md Play surfaces | controller mapping | button prompts | hybrid DOM + canvas | input testing

load by task
| Task | Load |
|---|---|
| New surface or redesign | direction, taste, typography, color, layout |
| Component, form, copy | components, polish |
| Animation | motion |
| Review | review, taste | plus file behind each finding |
| Play surface | console | plus above by task |
| Named style or options | styles-catalog |
| Final pass on generated UI | anti-slop |

slash companions | manual only
- /design-critique heuristic evaluation depth
- /interaction-design state machines | microinteractions
- /web-design-guidelines code compliance review

six rules | override everything else
1. brief wins | named font, palette, era, reference followed exactly | taste only fills gaps | "like X" means X as captured, never X as remembered
2. refinement keeps, redesign replaces | refinement preserves identity, copy, IA, URLs, form field names, analytics IDs | fixing an existing UI means function only: buttons, labels, icons, colors, spacing and layout stay as they are, unless asked by name | redesign changes visual world, never product truth | never polish a look marked for replacement
3. match codebase | existing tokens, components, icon set, motion library first | no second design system, icon family, animation library
4. every element has a job | no one-sentence reason for a section, color, effect, animation | remove it
5. never invent product truth | prices, customers, metrics, testimonials, logos, capabilities real or marked placeholder | demo data synthetic, realistic, labeled
6. sol's taste fills open choices, user's comprehension is never spent on it | load references/taste.md for any new look | run its audience check + translation table | never overlay it on an existing look

workflow

1 read before design
- read design doc | tokens | theme file | one representative screen
- brief names existing game, film or product | capture real source before contract: own screenshots first | shipped assets next: textures, fonts, sounds, strings | web last | references/direction.md
- capture from build carrying the named look | deployed build may lag source theme, check before matching it
- name surface mode | decides most later choices
  - Persuade | landing, pricing, campaign | understand + act within seconds
  - Operate | app, dashboard, settings, admin | speed, scanability, density, zero surprise
  - Read | docs, blog, changelog | comprehension, wayfinding
  - Experience | portfolio, launch, brand piece | work itself leads
  - Play | game menu, console UI, launcher, canvas tool | input first, every device, direct feedback | references/console.md
- at most one round of 1 to 3 questions | only what changes result: audience, page job, what must not change | otherwise state assumptions, go

2 contract | new surfaces + redesigns only | skip for tweaks
state in reply before code | never in source | single pre-build artifact, nothing else to write
```
THESIS:    surface mode + what product does in one sentence + what first screen must prove
AUDIENCE:  who, where, under what light/device/stress
WORLD:     visual world from subject's own materials, not category default
SIGNATURE: the ONE bold move; everything else quiet
DIALS:     variance / motion / density, 1-10
SYSTEM:    type pair, color strategy + accent, radius system, spacing base, motion personality
```
how to fill each line + presets: references/direction.md

3 build to floor | never announced, always shipped
- semantic HTML | skip link | visible focus ring on every interactive element | keyboard reachable | labels on inputs | `aria-label` on icon buttons
- text contrast 4.5:1 | large text + UI parts 3:1 | touch targets 44px+ | 24px absolute minimum with spacing
- body text 16px+ on Persuade + Read | Operate body 14px+ | mobile inputs always 16px+
- all states: default, hover, focus-visible, active, disabled, loading, empty, error, success
- responsive 320px to 1440px+ | no horizontal scroll | `min-h-dvh` not `100vh` | safe-area insets on mobile
- spacing, type, color, radius, shadow from tokens | no magic numbers
- motion: transform + opacity by default, exceptions in references/motion.md | ~150 to 300ms in product UI | reduced-motion path in same commit
- real content shapes: long names | empty lists | 1,000 rows | slow network | errors
- non-web surface: focus ring = selected state | every input surface has: controller, keyboard, mouse | drive tests through real input path, virtual device over direct method calls
- web page drawn on canvas is web: selection + Tab focus look different | references/console.md

4 verify | bounded loop
- check mobile (375px) + desktop (1440px) | light + dark if both exist | screenshot when tools allow | otherwise read computed values
- visible tab | settled state, never mid-animation | separate browser profile when user's data lives in default one | user's data never deleted by a test
- brief names existing look: render beside capture at same size | one image, both shown | every difference fixed or stated
- run pre-ship checklist references/review.md | fix batch, check once more, stop | two rounds ceiling
- reviews of existing UI: method + report format in references/review.md

numbers | single source | references add detail, never different values
| Topic | Value |
|---|---|
| Body text | Persuade + Read 16px+ web, Operate 14px+, inputs 16px+ on mobile (prevents iOS input zoom), 17pt iOS, 14-16sp Android |
| Line length | 45 to 75 characters (65ch default), mobile 35 to 60; data tables may run wider |
| Line height | body 1.5 to 1.7, headings 1.05 to 1.25, big display 0.95 to 1.1 |
| Type scale | 1.125 to 1.2 ratio product UI, 1.25 to 1.333 marketing |
| Spacing | 4px base; steps 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128, 160 |
| Grouping | inside group 4 to 12px, between groups 24 to 48px, between sections 64 to 160px |
| Contrast | 4.5:1 text, 3:1 large text (24px or 18.66px bold), icons, input borders, focus rings |
| Touch target | 44x44pt iOS, 48x48dp Android, WCAG 2.2 AA min 24x24 CSS px, 8px between targets |
| Min width | no horizontal scroll at 320px; check 375px, 1440px |
| Response | 100ms feels instant, 400ms Doherty pace, 1s flow limit + needs indicator, 10s attention limit + needs progress + cancel |
| Motion | micro 100-150ms, UI 150-300ms, overlays 200-400ms, drawers up to 500ms, focal marketing moments up to 800ms |
| Easing | enter `cubic-bezier(0.23, 1, 0.32, 1)` unless contract names a motion personality, move `cubic-bezier(0.77, 0, 0.175, 1)`, never linear for movement |
| Press | `scale(0.97)` on `:active`, 100 to 160ms |
| Stagger | 30 to 80ms per item, whole sequence under 500ms |
| Choices | 3 to 4 plans, one primary action per view, 5 or fewer top-level nav items on mobile |
| Web vitals | LCP < 2.5s, INP < 200ms, CLS < 0.1 |

ten AI-made tells | full list references/anti-slop.md
1. purple/blue gradient hero | gradient text | glowing orbs | neon outer glows
2. three identical icon + title + text cards as page structure
3. centered hero over dark gradient, no real visual, "trusted by" logo row inside
4. Inter or default sans as display face on brand page | reflex cream background + high-contrast serif + terracotta
5. eyebrow labels + "01 / 02 / 03" above every section
6. emoji or random glyphs as icons | mixed icon families
7. fake dashboards from divs | fake-precise numbers (99.97%, 4.1x) | "John Doe" testimonials
8. cards inside cards | colored left-border callouts | everything in soft-shadowed rounded box
9. every section fades up on scroll same way | pulsing dots | bouncy springs on menus
10. filler copy: "Elevate", "Seamless", "Unleash", "Next-gen", "Revolutionize"

output
- build: working code first | then at most 5 lines: direction chosen + anything user must decide
- review: findings table per references/review.md | every required pass | what was not checked | one-line verdict | no essay
- no em dashes in UI copy | periods, commas, colons instead
