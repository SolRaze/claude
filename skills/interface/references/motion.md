motion

functional layer | cause + effect | spatial continuity | feedback
decoration doing none of those is animation debt

decide whether to animate
1. name purpose in one sentence: feedback | state change | spatial continuity | attention to one thing | softening abrupt appearance | "looks nice" is not a purpose
2. frequency gate
   - hundreds of times a day (typing, list navigation, command palette, hover in dense tools): none or near instant
   - daily (menus, tabs, modals, toasts): subtle + fast, 150 to 250ms
   - rare (onboarding, first success, launch page hero): may be expressive
3. keyboard-initiated actions do not animate (shortcuts, arrow navigation, Cmd+K open)
4. removal test: turn off | users lose understanding = functional | nothing lost = delete
5. motion gaps are bugs: pop in/out on conditional render | content jump when loading ends | snapping accordions | check every `cond && <X/>` + ternary swap
6. at most one motion personality per product | named in contract: its curve replaces default enter curve | none named: default enter curve

| Personality | Durations quick / standard / slow | Curve | Overshoot |
|---|---|---|---|
| Corporate / productivity | 150 / 200 / 300ms | `cubic-bezier(0.2, 0, 0, 1)` | 0 |
| Premium / calm | 200 / 350 / 500ms | `cubic-bezier(0.25, 1, 0.5, 1)` | 0 |
| Energetic / marketing | 120 / 220 / 400ms | `cubic-bezier(0.16, 1, 0.3, 1)` | 0 |
| Playful / kids / games | 150 / 250 / 400ms | springs, bounce 0.2 to 0.3 | 1.5 to 5% |

durations
| Interaction | Duration |
|---|---|
| Hover in (color, background) | 100 to 150ms |
| Hover out | 150 to 200ms |
| Press feedback | 100 to 160ms |
| Toggle, checkbox, small icon swap | 150 to 200ms |
| Tooltip, small popover | 125 to 200ms |
| Dropdown, menu, select | 150 to 250ms |
| Toast in | 200 to 300ms |
| Modal, sheet | 200 to 400ms |
| Drawer | up to 500ms with iOS-like curve |
| Accordion / height change | 200 to 300ms |
| Page or route transition | 200 to 300ms |
| Marketing focal entrance | 500 to 800ms, one per page |
| Spinner rotation | 700 to 1000ms per turn, linear |

- overlay + element exits faster than entrances: 60 to 75% of enter duration | hover out excepted
- bigger distance + bigger elements need more time | 20px badge + full-screen panel never share a duration
- mobile ~20% shorter than desktop | feedback over 500ms feels laggy anywhere

easing
- entering or reacting: strong ease-out | default `cubic-bezier(0.23, 1, 0.32, 1)` | quart `(0.25, 1, 0.5, 1)` | quint `(0.22, 1, 0.36, 1)` | expo `(0.16, 1, 0.3, 1)`
- moving on-screen element (reorder, slide between positions): ease-in-out `cubic-bezier(0.77, 0, 0.175, 1)` or Material standard `(0.2, 0, 0, 1)`
- leaving: short ease-out | quick ease-in `cubic-bezier(0.3, 0, 1, 1)` when exiting screen entirely | always short
- drawers + sheets: `cubic-bezier(0.32, 0.72, 0, 1)`, 400 to 500ms
- linear only for spinners, progress bars, continuous rotation
- built-in `ease` + `ease-in-out` weak | custom curves or springs
- no bounce or elastic on utility UI (menus, dropdowns, toggles, settings, modals) | never on errors

springs
anything interactive or interruptible (drag, gestures, layout changes, re-clickable toggles) | keep velocity when interrupted, keyframes restart
values assume mass 1 | bounce = 1 - damping ratio | ratio = damping / (2 * sqrt(stiffness))

| Use | Setting (Motion / Framer) |
|---|---|
| Default UI | `{ type: "spring", duration: 0.4, bounce: 0 }` or stiffness 300 / damping 35 |
| Panels, cards, modals | stiffness 200 / damping 29, or duration 0.45 bounce 0 |
| Tooltips, popovers | stiffness 500 / damping 45 (fast, no overshoot) |
| Playful / celebration | duration 0.5, bounce 0.2 to 0.3 (stiffness 400 / damping 30) |
| Drag release | stiffness 200 / damping 20, keep velocity |

bounce 0 to 0.3 | above looks broken

patterns
- enter: opacity 0 to 1 + translateY 8 to 16px to 0 | optional blur 4px to 0 for softer premium | exit smaller: translateY -4 to -8px, opacity 0
- scale-in: start 0.95 to 0.98 | never `scale(0)`
- popover + dropdown: scale 0.96 to 1 + opacity from trigger (`transform-origin` = trigger side; Radix exposes `--radix-popover-content-transform-origin`) | modals stay centered
- modal: backdrop fades 150 to 200ms | panel scale 0.96 to 1 + opacity + translateY 8px, 200 to 300ms | no content stagger in product UI
- toast: slide from edge + fade | stack shifts with layout animation | dismiss toward edge
- press: `transform: scale(0.97)` + `transition: transform 150ms var(--ease-out)`, `--ease-out` = enter curve token
- hover lift (cards): translateY -2px + shadow change 150 to 200ms | image zoom 1.03 inside `overflow: hidden` | no same hover scale on every element in view
- icon swap (copy to check): crossfade + scale 0.8 to 1 + blur 4px to 0, ~200ms
- lists + stagger: 30 to 80ms between items | total under 500ms | only lists that read as lists | once per view | never blocks interaction
- accordion + height: `grid-template-rows: 0fr` to `1fr` | `interpolate-size: allow-keywords` with `height: auto` only as progressive enhancement, not Baseline, height snaps where unsupported | no px height | rotate chevron in parallel
- layout changes: FLIP or Motion `layout` prop for small isolated shifts | `layoutId` for shared-element morphs (card to detail) | no `layout` on huge subtrees
- page transitions: View Transitions API (`document.startViewTransition`, cross-document `@view-transition { navigation: auto; }`) | crossfade 200 to 300ms + shared elements
- skeletons: shimmer sweep 1.2 to 2s linear, low contrast (base 6 to 10%, highlight +4 to 6% lightness), or gentle opacity pulse | swap with short fade, no layout jump
- numbers: count up only celebratory or summary, 600 to 1000ms ease-out, tabular numerals, rounded values | never numbers users scan repeatedly
- scroll reveal: once (`viewport: { once: true }`) | 16 to 24px | 400 to 600ms | trigger 15 to 20% into view | visible without JavaScript | not every section same way
- scroll-linked: CSS `animation-timeline: view()` / `scroll()` + IntersectionObserver fallback | never `window.addEventListener('scroll')` driving styles | parallax under ~100px total, never on text, off on mobile + reduced motion
- hold to confirm: `clip-path: inset(0 100% 0 0)` to `inset(0 0 0 0)` over 1.5 to 2s linear while pressed | snap back 200ms on release
- drag to dismiss: on distance OR velocity (fast flick) | rubber-band past bounds | pointer capture | also offer a button (WCAG 2.5.7)
- error shake: 3 cycles ±6 to 10px, 300 to 400ms, once | pair with text message
- success: check draws (stroke-dashoffset) 200 to 300ms after container settles | milestone confetti under 1s, real milestones only

interruptibility
- CSS transitions or springs for anything re-triggerable | `@keyframes` restart from zero, jank when spam-clicked
- entry without JS mount tricks: `@starting-style { opacity: 0; transform: translateY(8px); }`
- test by clicking rapidly + reversing mid-animation | should blend, not queue
- review in slow motion (DevTools animation panel at 10% or 25%) + next day with fresh eyes

performance
- default `transform` + `opacity` (compositor)
- allowed exceptions: color + background on hover | shadow on hover lift | `filter`, `clip-path`, `background-position` on small surfaces | `grid-template-rows` on accordions, small subtrees only
- never `width`, `height` in px, `top`, `left`, `margin`, `padding`, `font-size`
- name properties: `transition: transform 200ms, opacity 200ms` | never `transition: all`
- `will-change: transform` only right before + during animation, handful of elements | never `will-change: all`
- blur under ~8 to 12px, short, small areas | large or continuous `backdrop-filter` kills scrolling on mid-range phones
- never read layout (`getBoundingClientRect`, `offsetHeight`) + write styles in same frame repeatedly | batch reads, then writes
- pause loops + canvases off-screen (IntersectionObserver) or tab hidden (`visibilitychange`)
- drag: set `element.style.transform` directly, no CSS variables on parent every frame
- budget: 60fps (16.7ms per frame) | fewer than ~20 moving elements per viewport | 1 to 2 animated properties per element on mobile

tool choice
| Need | Tool |
|---|---|
| Hover, press, simple enter/exit, toggles | CSS transitions, `@starting-style` |
| Repeating/predetermined sequences | CSS `@keyframes` or WAAPI (`el.animate`) |
| React enter/exit, layout, gestures, springs | Motion (`motion/react`) |
| Timeline choreography, pinning, scrubbing, SVG morphing | GSAP + ScrollTrigger |
| Route changes | View Transitions API |
| Vector illustrations, icons with character | Lottie / Rive |

one library per project | no Motion + GSAP on same elements | no `framer-motion` + `motion` imports together

reduced motion
`prefers-reduced-motion: reduce` = fewer + gentler, not zero
- remove: translation | scaling | parallax | zoom | auto-playing loops | scroll-jacking | large slides | spinning large elements
- keep: opacity crossfades 150 to 200ms | color changes | focus rings | progress indicators
- every animation ships reduced path in same change

```css
@media (prefers-reduced-motion: reduce) {
  .enter { transform: none; transition: opacity 150ms ease-out; }
  .parallax, .marquee { animation: none; }
}
```

```js
const reduce = useReducedMotion(); // motion/react
<motion.div initial={{ opacity: 0, y: reduce ? 0 : 12 }} animate={{ opacity: 1, y: 0 }} />
```

- loops or anything over 5 seconds: pause control (WCAG 2.2.2)
- nothing flashes more than 3 times per second
- no critical information only in motion | all tasks work with animation off
- native: iOS Reduce Motion becomes crossfades | Android "Remove animations" becomes instant or crossfade

anti-patterns
- same fade-up on every section | staggering two lists in one view
- pulsing/breathing dots + glowing CTAs with no state to communicate
- bouncy springs on menus, toggles, modals | elastic easing on errors
- `scale(0)` entrances | popovers growing from center
- exit as long + dramatic as entrance
- linear easing on movement | default `ease` everywhere
- animating layout properties | `transition: all`
- scroll listeners driving animations | `whileInView` replaying every time
- motion on keyboard shortcuts + high-frequency actions
- custom cursor, magnetic buttons, parallax on productivity tool
- shipping without reduced-motion path
