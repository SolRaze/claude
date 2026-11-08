console

Play surfaces | game menus | console UIs | launchers | canvas tools driven by keys, touch or controller
shared numbers live in SKILL.md | values here are starting points, tune by hand on real pad

input model
- every action on visible control | keys + pad are shortcuts, never only path
- one action handler per button | keyboard, pad, touch and click all call it
- current mode named | way back on screen

standard gamepad | `mapping === 'standard'` is by position, not printed letter
| Index | Position | Switch | Xbox | PlayStation |
|---|---|---|---|---|
| 0 | bottom | B | A | ✕ |
| 1 | right | A | B | ○ |
| 2 | left | Y | X | □ |
| 3 | top | X | Y | △ |
| 4, 5 | shoulders | L, R | LB, RB | L1, R1 |
| 6, 7 | triggers | ZL, ZR | LT, RT | L2, R2 |
| 8, 9 | centre | -, + | View, Menu | Share, Options |
| 12 to 15 | d-pad | up, down, left, right | same | same |

- bind by printed letter | detect pad family from `Gamepad.id` | Nintendo: `nintendo`, `joy-con`, `pro controller`, `057e`
- Nintendo swaps pairs 0-1 + 2-3 against Xbox | `i ^ 1` on face indices
- third-party Switch pads carry own vendor | PowerA `20d6` (also on its Xbox pads), `057e` list misses them | match name words from real `Gamepad.id` (`nsw`, `switch`, `spectra`), never vendor alone
- `mapping` empty: button order unknown | offer remap or say pad unsupported
- browsers + OS differ for same pad | test real pad on each target before claiming support

TV layout | sofa distance, pad in hand
- design frame 1280x720 | list text 21px+ | headings 24px+ | 6 to 9 rows in view
- sizes hold per element, not per list | desk rules win on specificity, nested links + chips shrink | compute every card's text, never one sample
- one focus column, centred | nothing beside it competing for the eye
- nav depth 3 max | places on ZL/ZR top right | cards on L/R as centred row | items on d-pad | no column listing cards
- one card at a time | its items one list, not two columns
- pick opens in place | about line + its A/Y actions under the row, list makes room | no detail pane repeating the row
- pick inside a row (button in a pill, link in a cell) opens under the whole row | gap on the row, never on the inline element | scroll the row into view, gap included
- launcher cards (apps, windows) as tiles | opened pick under the grid
- A verb names the act: Turn on, Turn off, Open, Switch, or the button's own word (Sleep, Restart) | Press only when nothing names the act
- every open state closes on B | B unwinds one level, top first: dialog, then opened pick, then place | closed pick: A reopens, moving opens the new row | bar says Close while something is open, Back otherwise
- bar keeps navigation + back + exit | actions of the pick live with the pick, not twice

selection light | reference Bloodborne title streak `MENU_Title_00002` (`menu/title.tpf`)
- thin horizontal line, hot centre, soft body | centred behind the label | added to the black: `BLEND_RGB_ADD` | `mix-blend-mode:screen`
- size: game front 600x47 on 1920 stage, ~12.8:1 | tabs label width + 80 by 36 | web: label width + 5 text heights by 1.7
- no travel | crossfade in place: new pick 1 - (1 - t)^3, old pick 1 - t, 140ms | no spring, no pulse | reduced motion switches at once
- picked text white | game: white over SOFT grey rows | web: + 8px accent glow
- option lists in the game: `row_on` plate from `common.tpf`, navy gradient with gold rim, under the whole row
- palette follows the surface: game gold | web: white core, accent body, grey fade | game textures stay out of published repos
- one light per layer: page, dialog, sheet
- light lives outside the scroller | fade it once its row leaves the visible list: under sticky header, behind tab bar | sticky header opaque
- tiles keep their own face when picked | light marks them, border lifts one grey step

button prompts
- glyphs match last used input | pad family set for pad | key or word for keyboard | no pad glyph implying wrong button
- brief names one set: follow it everywhere + state which pads then mismatch
- glyph + word | unlabeled marks stay on one line with word naming them
- one glyph family | same stroke, disc, size, theme colour
- prompt shows only what works now | no prompt for dead action
- touch: no glyphs, no resting selection | tap opens sheet with real buttons | glyph bar returns once a pad sends input

prompt placement
- confirm + back stay fixed per layout | contextual prompts append after them, never reflow them
- prompt bar reserves its height | content above measures it, never overlaps
- prompt for same button same place on every view
- wrap only between groups | action lists on phone stay above bar

web page launched from Steam | non-Steam shortcut
- Steam Input on for shortcut: pad may arrive as keys + mouse, page sees no gamepad | turn off per shortcut, test
- Steam preloads overlay (`LD_PRELOAD`) into the browser | chromium zygote dies, no window | wrapper `unset LD_PRELOAD`
- test launch with no browser running | live instance only raises, hides a broken launch

keyboard
- face buttons bound to same letters as prompts | plus Enter, Space, Escape, Backspace
- browser chords stay browser's | text entry takes keys first | Tab-focused button keeps own Enter + Space
- key repeat only where stepping makes sense: directions, shoulders

pad timing
- hold repeat 400ms, then every 80ms | directions, shoulders, triggers only | never confirm or back
- stick press threshold 0.5 | deadzone 0.2 on analog driving

hybrid DOM + canvas | real DOM under canvas drawing
- real text + buttons in DOM for layout, Tab, screen reader | canvas paints them
- opacity 0 hides native outline | paint focus ring on canvas: 2px, 3:1, around button box
- two cursors, must look different: game selection (glow, colour) | Tab focus (ring)
- items drawn only on canvas (grids, carousels) need DOM twin: hidden list or `aria-activedescendant` | synced to selection
- `h1` + landmarks still exist | `aria-live` names selection change

build order
- mock 2 to 3 layouts as static HTML at target size before touching live code | user picks or combines
- then build in steps on live code | each step: deploy, screenshot at target size, driven by real keys, shown to user

testing
- run in visible tab | hidden tab pauses `requestAnimationFrame`, stops pad polling + render
- stub pad: `navigator.getGamepads = () => [fake]` with `id`, `connected`, `axes`, `buttons[].pressed` | press, then release | stub proves mapping only
- wait for poses to settle before measuring or screenshotting | mid-tween positions mislead
- synthetic pointer events can make `setPointerCapture` throw | wrap dispatches in try
- overlays shorter than capture: set their state flag by hand, snapshot, clear
- per state, one shot: opened, closed with B, moved after close | a state with no shot of its close is untested
- tool: `scripts/shot.mjs <url> <out.png> <w> <h> [steps]` | headless Chromium (`SHOT_BROWSER`, default Helium), rAF live | steps: key name, `wait<ms>`, `js:<expr>`, `snap:<file>` | one run, every state
- tour: every place x card, one pick opened in each, `snap:` per stop | `magick montage t*.png -tile 3x3 -geometry 640x360+4+4 -background '#333' tour.png` | read one sheet, then zoom the broken frames
- inline picks found by `js:` walking the picked element up to its card | element chain shows which row the gap must sit on
