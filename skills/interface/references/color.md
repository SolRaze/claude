color

strategy | pick before colors
| Strategy | Meaning | Use for |
|---|---|---|
| Restrained (default) | neutrals + one accent, accent under ~10% of surface | Operate + Read surfaces, trust-first products |
| Committed | one saturated color owns 30 to 60% of surface | brand landings, campaigns |
| Full palette | 3 to 4 named color roles | illustration-heavy, kids, data-rich marketing |
| Drenched | surface is the color | launches, portfolios, single bold statements |

commit at page scale | whole regions owned by a color read intentional | small accents everywhere read as noise

roles, not swatches
semantic tokens only in components | hue 250/255 is an example, take hue from brand
values below pass floor on `--bg` + `--surface` | recheck after changing hue or lightness
```css
:root {
  --bg: oklch(99% 0.003 250);          /* canvas */
  --surface: oklch(97.5% 0.004 250);   /* sidebars, toolbars */
  --raised: oklch(100% 0 0);           /* cards, popovers */
  --border: oklch(91% 0.006 250);      /* decorative dividers only */
  --border-input: oklch(62% 0.01 250); /* input borders, 3:1 */
  --text: oklch(22% 0.01 250);         /* never pure #000 */
  --text-muted: oklch(48% 0.012 250);
  --accent: oklch(55% 0.17 255);       /* primary action only */
  --accent-contrast: oklch(99% 0 0);   /* label on accent, 4.5:1 */
  --focus: oklch(62% 0.19 255);
  --success: oklch(50% 0.13 150);
  --warning: oklch(72% 0.15 75);       /* fill only, pair with --text */
  --warning-text: oklch(50% 0.11 75);  /* warning as text */
  --danger: oklch(56% 0.19 25);
}
```
- primitives (`blue-500`) feed semantic tokens (`--accent`) | components never use raw hex
- accent reserved for primary action, focus, selection | spent on decoration, primary stops standing out (Von Restorff)
- one neutral family per project | no warm + cool gray mix | tint toward brand hue (chroma 0.003 to 0.01) only for cohesion
- avoid pure `#000` text + pure `#fff` huge areas when softer works | pure white ok for cards on tinted canvas if that is the system
- never gray text on colored background | derive muted from background hue or use foreground transparency

OKLCH ramps
- OKLCH for generated scales | equal lightness steps look equal, unlike HSL
- ramp: L steps 97, 93, 86, 76, 65, 56, 47, 38, 29, 21 | reduce chroma near extremes, avoids neon + muddy
- gradients: `linear-gradient(in oklch, a, b)` | avoids gray midpoints
- hue from brand + visual world, not category habit

contrast | WCAG 2.2 AA
| Element | Minimum |
|---|---|
| Body text | 4.5:1 |
| Large text (24px+, or 18.66px+ bold) | 3:1 |
| Icons, input borders, focus indicators, chart marks | 3:1 against neighbors |
| Placeholder text | 4.5:1 if it carries information |
| Disabled controls | exempt, must still look disabled, not invisible |

- check every state: hover, pressed, selected | text over images (scrim or gradient overlay) | both themes
- color never only signal | pair with icon, text, shape, position | no red/green-only distinctions (8% of men have a color vision deficiency)
- semantic color stays semantic | red errors + destructive only | green success
- `@media (forced-colors: active)`: keep borders + focus visible, use system colors, no meaning in background alone
- `@media (prefers-contrast: more)`: raise muted text + borders

dark mode
- design it, do not invert | dark or light from use scene (dim room, long sessions, media), not "tech products are dark"
- values below pass floor on `--bg`, `--surface`, `--raised` | recheck after changing hue or lightness
```css
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    color-scheme: dark;
    --bg: oklch(17% 0.01 250);
    --surface: oklch(21% 0.01 250);
    --raised: oklch(25% 0.01 250);
    --text: oklch(93% 0.01 250);
    --text-muted: oklch(70% 0.012 250);
    --border-input: oklch(60% 0.01 250);
    --accent: oklch(72% 0.14 255);
    --accent-contrast: oklch(17% 0.01 250); /* label on accent is dark */
    --focus: oklch(72% 0.15 255);
    --success: oklch(75% 0.12 150);
    --warning: oklch(82% 0.13 75);          /* fill + text, pair fill with dark label */
    --warning-text: oklch(82% 0.13 75);
    --danger: oklch(72% 0.15 25);           /* pair fill with dark label */
  }
}
```
manual dark override: same declarations under `:root[data-theme="dark"]`
- elevation goes lighter, not shadowier
- accents: desaturate 10 to 20% + raise lightness, stops vibration
- no pure white body on pure black
- borders low-alpha white `oklch(100% 0 0 / 0.08)` | shadows mostly disappear
- follow `prefers-color-scheme` | allow manual override | `color-scheme: dark` so native controls + scrollbars match
- brand color recognizable in both themes

banned habits
- purple-to-blue "AI" gradients | rainbow mesh backgrounds | gradient text on headings
- neon outer glows for importance | use contrast, size, position
- oversaturated accents (chroma near gamut edge on large areas)
- reflex "premium" palette: warm cream + brass/terracotta + espresso text | fine when brief or subject calls for it, wrong as default
- five accents competing in one view
- scaling colours in a linear space (three.js `Color`) to dim a CSS stop | dims far less than it reads | scale lightness in sRGB, HSL or oklch

data visualization
- categorical: up to 6 to 8 distinguishable hues, similar lightness | beyond that group into "Other"
- sequential: one hue, lightness ramp | diverging: two hues, neutral midpoint
- marks 3:1 against background | labels 4.5:1 | gridlines faint
- position + length first, color second | direct labels over legends where possible
