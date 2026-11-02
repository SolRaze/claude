---
name: model-preview
description: Render preview images of a 3D model, part, STL or blend in the one house style - all black on a black ground, lit edges, pale outline. Use for any model preview, part sheet, README or doc image of CAD, Blender or printed parts, in any project.
---

model preview

one look for every model image | every project | black parts, black ground, lit edges, pale outline
never per-part hues | never a white, grey or gradient ground | never a second style beside it

tool
`preview.py` beside this file | headless Blender, Workbench, orthographic | saves nothing back to the blend
```sh
B=/Applications/Blender-cad.app/Contents/MacOS/Blender
P=${CLAUDE_SKILL_DIR}/preview.py
T=/tmp/tiles; mkdir -p $T
$B -b --factory-startup scene.blend -P $P -- scene $T name    # six sides of the open blend
$B -b --factory-startup -P $P -- parts $T folder-of-stl       # six sides per STL
```
tiles `<tag>--<view>.png` | views front, back, left, right, top, iso | scene 900 px, parts 300 px
`scene` frames everything render-visible | a ground plane or prop widens the frame, set its `hide_render` first or frame by hand
run from a directory with no stray `.py` | a local `re.py` or `json.py` shadows the stdlib

style, set in `camera()`
| setting | value |
|---|---|
| engine | `BLENDER_WORKBENCH`, ortho camera |
| colour | object colour, every object `(0.06, 0.06, 0.07, 1)` |
| light | `STUDIO`, specular on |
| cavity | `BOTH`, ridge 2.5, curvature ridge 2.0 |
| outline | on, `(0.7, 0.7, 0.72)` |
| ground | viewport colour `(0, 0, 0)` |
| colour management | `Standard`, look `Medium High Contrast` |

sheets
```sh
M=(montage -font /System/Library/Fonts/Supplemental/Arial.ttf -background '#000000' -fill white -label '%t')
$M $T/name--{front,back,left,right,top,iso}.png -tile 3x2 -geometry 600x600+3+3 name.png
magick name.png -colors 96 -strip PNG8:name.png
```
part sheets `-tile 6x -geometry 220x220+2+2` | eight parts a sheet, six views a row
PNG8 at 96 colours keeps a sheet near 100 KB

custom framing
close-ups and odd angles | project script imports `camera()` and `shoot(scene, cam, mid, span, views, tag, out)` | style stays in `camera()`, never restyled per project
worked example `~/Projects/Devices/solder/devices/printer/model-preview.py` | sheets in `hardware/model/`

real colours
preview black is object colour only | materials untouched | a blend that wants its real colours kept stores them as materials, not object colour

where images go
beside the doc that shows them | embed as `![what it shows](path.png)` under the label it illustrates
regenerate command recorded in that doc

check
open one sheet after building | black ground, parts readable by edges | labels white
