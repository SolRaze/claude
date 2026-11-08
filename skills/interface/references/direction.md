direction

how to fill contract lines in SKILL.md | before writing CSS

THESIS + AUDIENCE | read the brief
most signals already in request or repo
1. page kind: landing, app screen, dashboard, docs, portfolio, store, form flow
2. vibe words user used: "clean", "bold", "playful", "like Linear"
3. references: named products, URLs, screenshots | study structure, not just colors
   named existing look | evidence order below | contract WORLD cites what was captured
   - user's own screenshots | device, game, app, disk | exact state, exact resolution
   - shipped assets: textures, atlases, fonts, audio banks, UI strings, layout files | decode before redrawing | real asset beats any imitation
   - web captures | fan recreations for structure only | hotlink failures and title pages are not evidence
   - sample colors + measure sizes, spacing, order from capture | estimated palette = not done
   - asset license + use: user's own copy, local use only | never publish extracted assets
4. audience + scene: who, device, light, stress | nurse at 3am + designer on 5K monitor need different things
5. brand assets: logo, colors, fonts, tokens, current site
6. quiet constraints: accessibility requirements, public sector, regulated (finance, health), children, trust-first commerce | constraints beat taste

DIALS
stop everything drifting to same middle
| Dial | 1-3 | 4-7 | 8-10 |
|---|---|---|---|
| Variance (layout boldness) | symmetric 12-col grid, predictable | offsets, mixed aspect ratios, some overlap | fractional columns (2fr 1fr 1fr), big empty zones, broken grid |
| Motion | hover/press feedback only | CSS transitions, one entrance moment, small cascades | scroll-driven choreography, pinning, kinetic type |
| Density | gallery: huge whitespace, py-32+ sections | normal app/marketing | cockpit: tight padding, 1px rules instead of cards, mono numerals |

presets | variance / motion / density
| Product | Dials | Notes |
|---|---|---|
| SaaS landing | 7 / 5 / 4 | one real product visual (screenshot or live component) |
| SaaS app / admin | 3 / 3 / 6 | speed + consistency over personality |
| Data dashboard | 2 / 2 / 8 | no decorative motion, tabular numerals, 1px dividers |
| Fintech, health, gov, legal | 3 / 2 / 5 | trust first; Inter/system sans fine; AAA contrast for key copy |
| E-commerce | 5 / 4 / 5 | product photography carries brand; fast filters; sticky add-to-cart on mobile |
| Premium consumer brand | 7 / 6 / 3 | rotate palette families; avoid beige-brass default |
| Agency / creative studio | 9 / 8 / 3 | kinetic type + pinning allowed; content stays readable |
| Designer portfolio | 8 / 7 / 3 | work leads; chrome quiet |
| Developer portfolio / docs | 5 / 3 / 5 | mono accents earned by real code |
| Editorial / blog | 5 / 3 / 3 | serif body fine; measure 60-70ch |
| Kids / games / playful | 7 / 8 / 4 | springs at bounce 0.2 to 0.3 allowed here only |

redesign preserving identity: keep variance + density, motion +1 at most
full overhaul: variance +2, motion +2, density follows content

WORLD + SIGNATURE
starting from category ("fintech = navy + blue") is fastest route to generic
1. name category default + its cliché opposite | keep both off shortlist
2. list 5 to 7 concrete things from audience's world: tools, materials, places, documents, rituals | bakery: flour sacks, proofing baskets, chalk boards, receipt paper | logistics: pallets, labels, route maps, barcode type
3. pick the one best expressing product's mechanism | derive palette, type, signature from it
4. ONE signature move: unusual grid, typographic treatment, custom illustration language, one motion moment | rest quiet | busy is louder, not bolder
5. memory test: what would a visitor describe an hour later | answer is a mood ("clean, modern") = concept not committed

no named look: `taste.md` shapes the choices, the subject still supplies the world | same dark look on every project is its own reflex
vague subject: choose concrete subject, audience, single job | say so
user names a style ("make it brutalist", "riso", "bento") or asks for options: closest entry in `styles-catalog.md`, adapt to brand + this file

existing design system
brief or codebase names one: install official package, use its components | no recreation in custom CSS | never two systems in one tree
| Context | System |
|---|---|
| Microsoft / enterprise | Fluent UI |
| Android / Google-like | Material 3 |
| IBM-style analytics | Carbon |
| Shopify admin apps | Polaris |
| Atlassian ecosystem | Atlaskit |
| Developer tools | Primer |
| UK public sector | GOV.UK Frontend |
| US public sector | USWDS |
| React product with own look | Radix Primitives / shadcn/ui (restyle; never ship default theme untouched) |
| Apple platforms | SwiftUI + HIG (Liquid Glass is Apple-only; web imitations labeled approximations) |

redesign rules
- detect mode first: greenfield | preserve (evolve current look) | overhaul (new visual world)
- audit first: tokens, IA, content blocks, patterns to keep, SEO baseline (titles, headings, slugs, structured data)
- never change silently: URL slugs, primary nav labels, form field names + order, logo, legal + cookie text, analytics event IDs
- levers by impact per effort: typography | spacing + rhythm | color | motion | hero composition | full block replacement

pacing a long page | Persuade
- hero: headline 2 lines max desktop, 3-8 words ideal | one supporting sentence, 20 words max | one primary + at most one secondary CTA | one real visual | fits first viewport | no logo walls, pricing, bullet lists inside
- following sections: headline 8 words or fewer | one paragraph 25 words or fewer | one visual or one action
- at least 4 layout families across 8 sections | never more than 2 image/text zigzags in a row
- alternate dense + quiet | end on real close (CTA, contact, next step), not fade-out
- classic order, drop what content does not earn: hero | proof (real logos/metrics) | problem | how it works | features as outcomes | social proof | pricing | FAQ | final CTA

native
- iOS: SF Pro / system font | 17pt body | 44pt targets | tab bar 2 to 5 items | large titles | sheets + swipe-back | honor Dynamic Type + Reduce Motion
- Android: Material 3 roles | 48dp targets, 8dp gaps | navigation bar on compact width, rail or drawer on expanded | predictive back | honor font scale + "Remove animations"
- Jetpack Compose: Material 3 components | `Modifier.minimumInteractiveComponentSize()` before any size modifiers, reserves 48dp | `sp` for text | `contentDescription` on icons
- React Native: `Pressable` + `hitSlop` | `react-native-safe-area-context` | `accessibilityLabel` | `AccessibilityInfo.isReduceMotionEnabled()`
- Flutter: `SafeArea` | `MediaQuery.textScalerOf` honored | `Semantics` labels | `MediaQuery.disableAnimationsOf`
- never port one platform's controls to other (iOS switches on Android, Material FAB on iOS)
