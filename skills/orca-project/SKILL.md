---
name: orca-project
description: Build OrcaSlicer .3mf projects for Solder from STL/OBJ models - plates, scale, orientation, project page, Solder process and filament. Use for Orca projects, plating, clear/hollow settings, print-in-place.
---

orca project

downloaded models | `.3mf` projects for the Solder presets | built by script, never by hand in the gui

where
models `~/Downloads/Save/models` | grouped by what the thing is | `README.md` is the map
every project `models/slicer/` | one folder | `C1_Atlas.3mf` is the template, sol-authored, never overwrite
python `~/Projects/Assets/cad/.venv/bin/python` | trimesh, manifold3d, scipy, numpy
`/usr/bin/python3` stops on the Xcode license prompt | do not use it, do not accept the license
never run python with cwd `/tmp` | a stray `inspect.py` or similar there shadows the stdlib and numpy import fails

scripts
- `armor/pack3mf.py` any folder | globs `files/*.stl` `*.obj` | shelf-packs onto fewest plates | the one to reach for
- `anatomy/spine/build3mf.py` spine + skull | per-plate and packed variants from one mesh set
- `anatomy/spine/build_pip.py` print-in-place spine | exports `resolve_preset` and `TEMPLATE` that `pack3mf.py` imports
moving `anatomy/spine` breaks `pack3mf.py` | its `sys.path` points there relative to itself

pack3mf
```
cd ~/Downloads/Save/models
~/Projects/Assets/cad/.venv/bin/python armor/pack3mf.py "<model folder>" --out slicer/<name>.3mf \
  --title "<title>" [--owner <model author>] --origin <url> --license "CC BY" \
  [--scale 0.89] [--process "Opaque 0.20 @Solder"] [--filament "PETG @Solder"] [--brim 5] [--turn 45] [--set key=value ...] [--orca-supports] [--fins] [--slice] [--send]
```
`<name>` ends in the material, lowercase (`_petg`, `_pla`, `_abs`) | the gcode name is `<name>_<time>`, `filename_format` adds no material
defaults 100% scale | `Opaque 0.20 @Solder` | `PETG @Solder` | each plate's block centred on its bed | `--brim` sets an outer brim on every object
writes `enable_support 0` so Support Fins makes the supports | `--orca-supports` keeps the preset's own supports
`--set` overrides a process key and lists it in `different_settings_to_system` | the support first layer is `raft_first_layer_density`, not `support_base_pattern_spacing`
writes `inherits_group` and `different_settings_to_system` from the presets | Orca resets every key missing from that list to the system parent
keeps supplied orientation | only 90° turns about Z | `--turn` adds one angle about Z to every part, in the item transform, mesh untouched | GAP 6 between parts for support | MARGIN 8 from bed edge
tries 3 sort orders | keeps fewest plates | asserts no overlap | `--each` puts one part per plate instead
description written as `N parts on P plates at X percent scale`

presets
printer `Solder` | bed 235×235×200 | textured PEI sheet, pack3mf writes `curr_bed_type` `Textured PEI Plate`
process `Clear 0.08 Glass Support` | `Clear 0.08 Glass` | `Clear 0.12` | `Clear 0.12 Gloss` | `Opaque 0.12 Fine` | `Opaque 0.20` | `Opaque 0.20 Easy` | `ABS 0.20 Brim` | `ABS 0.20 Raft` | all `@Solder`
filament `PETG` | `PETG Clear` fan 0 | `PLA+` fan 60–100 | `ABS` | all `@Solder`
filament is always `PETG @Solder` | `PETG Clear` for clear presets | never pass `--filament "PLA+ @Solder"` or `ABS` unless sol names that material for this print
support fins
supports are always Support Fins | printfins.com breakaway fins, Orca plugin `~/Library/Application Support/OrcaSlicer/orca_plugins/support_fins_orca.py`
fins go on every object whose `enable_support` is off | Orca supports on = plugin skips it | the per-object support toggle is the switch
settings live in `orca_plugins/config.json` cap `Support Fins` | `coverage 0.5` `tines` `tine_density 0` `bed_pad` `apply_to no-supports`
two ways in | baked by `--fins` or added by the plugin at slice time | never both on one project, fins double
`--fins` | pack3mf runs the plugin's engine in its own V8 (`mini-racer` in the cad venv) | fins written as a second part `<name> fins` per object | visible in Prepare | rotating a part does not move its fins, re-pack instead
plugin | runs only when the process preset names it in Slicing Pipeline Plugin | every `@Solder` process sets `plugins` `slicing_pipeline_plugin` `print_plugin_config_overrides` to Support Fins + Playback capture | GUI only, the Orca CLI never loads plugins
pack3mf copies those three keys from the process into the project | `--fins` drops Support Fins from them, keeps Playback

no-gui path
`--fins --send` | pack, Orca CLI slice to `slicer/<name>_plate<N>.gcode`, upload to the printer not started | check in Mainsail's G-code viewer, start there
`--slice` alone stops before upload | pack3mf adds the system printer to `print_compatible_printers`, without it the CLI fails `process not compatible with printer`
Orca supports only on request | `--orca-supports` or a per-object toggle

orca supports
one piece | `normal(auto)` + `support_style grid` in every supported preset | never tree or organic, trunks peel on the first layer and stick to the nozzle

clear recipe
1 wall | 0 top and bottom shells | 100% `alignedrectilinear` | 250 °C | bed 80 | fan 0 | outer wall 15 mm/s
supports off on every clear preset except `Clear 0.08 Glass Support` | fins still apply, pack3mf writes `enable_support 0`
`brim_type brim_ears` with `brim_width 0` | no brim in effect
check overhangs before sending clear | faces with normal z < -0.7 above first layer, area per part
small contact parts | under ~10 mm² on the bed | flag them, suggest brim or the supported preset

hollow recipe
`wall_loops 4` | 0% infill | top 15 layers 1.2 mm | bottom 10 layers 0.8 mm | `ensure_vertical_shell_thickness ensure_all`

scale
scale to the bed only when a part exceeds it | max factor = `(235 - 2*MARGIN) / longest side` rounded down
packed single plate | scale everything by one factor floored to 0.5%
check source units | some STLs are inches, `× 25.4` | the spine skull parts are
a scaled model changes its stated scale | put the real one in the title | 1/24 at 0.89 is 1/27

orientation
supplied orientation first | authors usually lay parts correctly | test all 6 axis turns before changing
ball-and-socket parts | socket up or the joint prints malformed
flat cut face | rotate onto the bed

credit
Designer always `sol` | every project, own model or downloaded | no Copyright key
model owner named once | in Description only | `--owner` writes `Source: <title>, model by <owner>, <origin>, <license>` | default `sol` | `--designer` still accepted as `--owner`
single source | thing url in Origin | license as published
compilation of several authors | each source with its author and license once in Description

deeper
`${CLAUDE_SKILL_DIR}/references/internals.md` | 3mf structure | preset resolution | support interface | CLI load check | print in place
read it before editing `pack3mf.py` / `build_pip.py`, checking a project load, or any print-in-place work

finish
report file path | plate count | fins or Orca supports | scale | process and filament | parts that need attention
keep earlier variants | a new material or setting is a new `.3mf`, not an overwrite
