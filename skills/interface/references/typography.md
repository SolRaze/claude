typography

type is most of the interface | right type makes plain layout look designed

scale
- roles by purpose: `display`, `h1`, `h2`, `title`, `body`, `body-sm`, `label`, `caption`, `mono`
- product UI: fixed rem scale, ratio 1.125 to 1.2 | example 12 / 14 / 16 / 18 / 21 / 24 / 28
- marketing: ratio 1.25 to 1.333 + fluid display | example `font-size: clamp(2.5rem, 5vw + 1rem, 5.5rem)` | body stays fixed
- avoid muddy neighbors (14 / 15 / 16 side by side) | each step clearly different
- display max ~6rem on web | past that a poster, not a page
- hierarchy = size + weight + color + space together | only size reads flat

weights and families
- 2 families max (display + text) or one family in several weights | third only for real code or data (mono)
- 3 to 4 weights max, fixed jobs: 400 body | 500 labels/UI | 600 headings | 700 rare emphasis
- pair real contrast (grotesk + serif, geometric + humanist) | two similar sans look like a mistake
- product UI: one good sans carries everything | marketing earns separate display face
- headline emphasis: italic or heavier weight of same family, never different family

choosing faces
licence required = use only if project already owns it
- body + UI sans: Inter, Geist, IBM Plex Sans, Source Sans 3, Public Sans, system-ui stack
- display sans, free: Satoshi, General Sans, Cabinet Grotesk, Switzer, Manrope, Bricolage Grotesque
- display sans, licence required: PP Neue Montreal, ABC Diatype, GT Walsheim
- serif only when subject is editorial, literary, luxury, heritage
- text serif, free: Newsreader, Source Serif 4, Literata
- display serif, licence required: Tiempos, GT Sectra, Canela, PP Editorial New, Recoleta
- mono for code + numbers, free: Geist Mono, JetBrains Mono, IBM Plex Mono | licence required: Berkeley Mono
- Inter fine default for Operate + trust-first | as brand landing display reads "nobody chose a font", choose with intent
- rotate display faces between projects | current overused: Fraunces, Playfair Display, Instrument Serif, Space Grotesk, Syne
- never Arial/Helvetica/Times by accident | no Comic Sans | max one decorative face

measure and leading
- line length + body + heading line height per SKILL.md | `max-width: 65ch` | mobile 35 to 60 characters
- big display line height 0.95 to 1.1
- longer lines need more leading | light on dark: about +0.05 line-height + slightly heavier weight
- space above heading larger than below, about 2:1 | belongs to what follows
- paragraph spacing OR first-line indent, never both

details
- `text-wrap: balance` on headings + short titles | `text-wrap: pretty` on paragraphs + captions
- tracking: tighten large display -0.01em to -0.04em, never tighter | open uppercase labels +0.04em to +0.1em | body 0
- `font-variant-numeric: tabular-nums` for prices, tables, timers, counters, anything updating
- italic descenders in tight display leading: small bottom padding, stops clipping
- real quotes + apostrophes (" " ' ') | real ellipsis (…) | non-breaking space between number + unit (10 kg)
- no widows in headlines | no single word on last hero line
- sentence case for UI labels + buttons | all caps only short labels with extra tracking
- `-webkit-font-smoothing: antialiased` on macOS for light-on-dark
- theme leftovers: `::selection` | caret color | focus ring | link underline offset (`text-underline-offset: 0.2em`)

loading
- self-host or framework loader (`next/font`, Fontsource) | no render-blocking third-party font CSS in production
- `font-display: swap` | preload only 1 to 2 above-fold files | ship only used weights | subset to needed scripts (Latin Extended for Lithuanian, Polish, etc.)
- metric-matched fallback (`size-adjust` or framework automatic) | avoids layout shift
- `rem` | respect browser zoom + user font settings | never `maximum-scale=1`

stress test
long headings | German/Finnish strings (+30% length) | Lithuanian diacritics (ą č ę ė į š ų ū ž) | narrow containers | missing weights | fallback font | 200% zoom
