taste

sol's design philosophy | default for open choices
look + character are sol's | comprehension belongs to whoever is using it
core ask: intuitive layout + real user experience, not a theme overlay
sol's instincts can read as private to a stranger | keep the look, translate the meaning

when it applies
- new surface, no named look: taste fills the contract
- existing look: keep it | no theme overlay | no restyle as side effect | change only what was asked, finished pages stay
- brief or reference names something else: brief wins
- never lowers a floor in SKILL.md | contrast, targets, focus, reduced motion stay

audience check | first question
- status-bar-sized private tools, sol only: codes + hidden clicks allowed
- sol's own apps + sites: visible controls still preferred | buttons over keybinds | primary action reachable without scrolling
- anyone else: translation table mandatory
- unknown: treat as anyone else

working with sol
- preview before building | large previews, every meaningful change
- show the current default first as the baseline | variants after, judged against it
- tuning a value: grid of two axes (colour x stop, angle x brightness), current one marked
- emulate before applying: drive the live page to every state (each hour, each tilt) and show them together | apply only on sol's word
- numbered versions + real alternates to pick from | sol names the winners, build on those, replace the rest
- suggest first when sol says so | short interview when vision is unclear
- find + cite the actual reference before drawing it | ask for the capture when missing
- keep current as backup | older version can win, list versions on request
- rejected element never returns | check project memory before reintroducing
- do exactly what was named | no bonus animation, no adjacent redesign

world
- new theme or mode starts from the default's own values | adjust its angle, stops, finish | a fresh palette or look beside it gets rejected
- one strong reference, matched 1:1 where sol says so: font, angle, perspective, glyph, animation, light | close is wrong
- world from a real object or era: PS2 + PS3 console menus | Apple editing UI | game creation screens | bone + stress lines
- interactive pieces may feel like a game: controller + direct controls, sound, fun to touch
- gothic, vampiric, bone: integrated, flows with the utility | never literal parts stuck on
- function first | structure earns the form | detail integrates with neighbours, cutouts + patterns flow together

surface
- mono-tonal first, add color last | muted over saturated | white or soft tonal accent, one
- background chosen so the object stands out | dark common, never automatic
- same color across repeated objects | text one color unless the reference differs
- matte over glossy | vanilla-like over reflective | no effect that reads as an effect
- gradient only when reference owns it + renders clean | banding or weird artefacts = remove
- every color from one theme file | no per-part hues
- depth by lit edges + pale outlines | rendered model previews all black on black
- live site models keep their own finish | no pale crease lines or white borders drawn on them
- one light source | field gradient's bright corner, 3D key light, highlights all agree | read the existing light first: angle, tint, brightness say the hour
- time of day: the default's own gradient turns + dims by the hour | as written = the hour it reads | sun + moon one path, only tint + brightness change | separate glows rejected
- light stays at level or above | light from below reads as a torch under the face | night dark (~10%) and cool, not navy
- device tilt: light fixed in the room, tilt shifts it ±20 deg, smoothed | phones only, off under reduced motion | desktop never follows the cursor
- a background that changes: check every state for legibility | dark objects, black controls, bright glows fail at night first
- monotone: no hue anywhere except red on destructive actions
- one resolution across world: pixel text matches pixel model
- pixel look = whole frame at a low line count, text anti-aliased at that size, scaled up hard-edged by an integer | never 1-bit glyphs or big aliased blocks | recipe: weight 500, ~1.5 px round black stroke under, fill, white glow on the selected item only | smallest label ~14 drawn px
- matching an existing look: render with its own code (browser canvas for case), never an imitation in another renderer | compare a zoomed crop, sample pixels to confirm hard blocks
- pixel size per asset follows its shown size | an image the host shrinks needs coarser pixels to read the same
- clean, Apple-like shapes + standard platform idioms outside a named world
- glass deliberate, named per surface, never swept on

hierarchy
- quiet everything, loud selection | thin streak behind the label, crossfaded in place | references/console.md | dull or small highlight fails
- little on screen: too much info, too many options, too many buttons all fail
- not every option available right away | options revealed by context + mode
- menus sorted by meaning, never by order features were added
- obvious object needs no label | item names + actions keep theirs
- key art, store capsules, launcher tiles: title + icon only | no fake commands, no repeated title, no host or URL lines
- precise alignment + proportion: icon aligned to title, logo sized to it, nothing covers controls or selection light
- sibling tools share controls + color scheme + pill shape
- persistent controls stay put across views | fixes keep existing placement unless asked
- natural layouts over mechanical ones: Fibonacci spiral over a plain circle

rejects
- buttons + small parts that look bad inside a fine layout | polish components, not only structure
- spin or rotation on selection | motion nobody asked for, returned after removal
- generic style packs + theme overlays: neon, glitch, stock Tailwind
- literal decoration: anatomy as relief, ornament with no job
- guessed geometry, approximate radii, near 1:1 | measure or use the reference
- yellow or loud accents by default | glossy reflections | dotted glyphs where a straight line is the reference
- near-identical variants | merge them
- extra indicators: signal bars, countdowns, decorative state
- primary content below a scroll with nothing else visible | desktop UI crammed onto touch

translation | sol's move + what keeps it intuitive
| Sol's move | Stranger's problem | Required translation |
|---|---|---|
| Terse codes (`cl 67% 2hr`, `sy na wk`) | meaning unknown | full words on first view; code only after a legend, tooltip or long-press explains it |
| Hidden actions (right, middle click, gestures) | never discovered | every action also on a visible control; gestures + keys are shortcuts, never only path |
| No edit button, direct manipulation | no signifier | platform idiom exactly (long-press, badges, grabber) + one in-place hint on first use |
| Console navigation, button glyphs | unknown input model | command bar shows glyph + word; mouse, touch, keyboard, controller all work; glyphs match detected input |
| Low-res, pixel or canvas text | hard to read, invisible to assistive tech | real text behind it for screen readers + Tab; pixel face for display + short labels; readable size + contrast for long copy |
| Monotone, dark on dark | states + boundaries vanish | controls keep a 3:1 edge; state change carries shape or text, color is second channel |
| Few controls, revealed by mode | missing feature, lost user | current mode always named; way back always visible; next step on screen |
| Unlabeled objects | identity unclear | label appears on selection or focus; accessible name always |
| Nostalgic world | metaphor unfamiliar | plain name beside metaphor ("memory card" + what it holds); first screen states the product |
| Game feel, motion, sound | irritating, blocks work | skippable, never delays input; sound one-tap mute; reduced-motion path |
| Quiet surface | system status unclear | loading, saved, error plainly visible; quiet means few, never none |

stranger test | before shipping to anyone but sol
- first screen: what is this + what do I do, without explanation
- every primary task done with no prior knowledge of codes, gestures, shortcuts, the reference world
- nothing needed lives only in hover, right-click, gesture, sound or color
- sol still recognises it as sol's | fails either side = not done
