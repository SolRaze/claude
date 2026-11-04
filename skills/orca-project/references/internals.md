orca project internals

3mf structure
- `3D/3dmodel.model` metadata Title | Designer, always sol | Description | License | Origin | dates | components by `p:path` | build items
- `3D/Objects/*.model` meshes
- `Metadata/model_settings.config` plates | `plater_id` | `plater_name` | `model_instance` `object_id`
- `Metadata/project_settings.config` json | full resolved settings
- `Metadata/slice_info.config` | `_rels` | `[Content_Types].xml`
item transform is row-vector 4x3 | write transpose of R, then translation
plate pitch `235 * 1.2 = 282` | plates in `ceil(sqrt(n))` columns | each item placed inside its plate's cell

preset resolution
resolve by `inherits` chain | user dir, then system, then app profiles, then `~/Projects/Code/upstream/orcaslicer-profiles` | merge base first
Orca 2.5 packs system presets into unreadable `.opc` | the sparse upstream clone supplies them | `git -C ~/Projects/Code/upstream/orcaslicer-profiles pull` to refresh
a missing parent asserts | never fall back to template values, they leak 0.08 layer height and 0.5 line widths
overlay only keys already in template `project_settings` | skip `name inherits from setting_id filament_id instantiation version type compatible_*`
filament scalars wrap to one-element lists | set `print_settings_id` and filament id to the preset names

support interface
Orca has it | `support_interface_top_layers` | `support_interface_spacing` | `support_top_z_distance`
same idea as the dense roof layer another slicer adds under a part

verify
Orca CLI loads a project but will not slice or export Solder presets | `process not compatible with printer`, `profiles/BBL/machine_full` missing | happens with sol's own files too
load check only:
```
/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer --debug 3 --logfile /tmp/o.log \
  --arrange 0 --orient 0 --export-3mf x.3mf --outputdir /tmp slicer/<name>.3mf
rg 'got plate count|Title' /tmp/o.log
```
`got plate count N` with the right N is a good load | the export error after it is expected
read settings back with `unzip -p <3mf> Metadata/project_settings.config` through the venv python

print in place
`build_pip.py` is the worked example | ball-and-socket spine as one print
GAP 0.40 printed clearance | WALL 0.90 | measured with exact `manifold3d` `min_gap`, never sampled points
assert narrowest gap ≥ GAP − 0.02 over every part pair within 3 mm
ball neck must reach main body | probe the largest component, a fragment elsewhere passes a naive check
rim opening depends on joint tilt | compute per joint, not once
relief cut | normal offset up to +0.4 first | exact Minkowski crop as fallback for facet contact
keep a joint keep-out sphere | relief must not eat the joint
bowed chain lays tall | level the chord by tilt before packing
cache the slow stage | `PIP_CACHE=<file>` pickles post-relief state
render cutaways with headless Blender | `BLENDER_USER_RESOURCES` set, see Assets/blender
