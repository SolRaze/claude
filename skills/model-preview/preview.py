"""Preview tiles in the house style: black parts on a black ground, lit edges, pale outline.

    $B -b --factory-startup scene.blend -P preview.py -- scene <out> [tag]
    $B -b --factory-startup -P preview.py -- parts <out> <stl folder>

`scene` shoots six sides of everything render-visible in the open blend, named <tag>--<view>.png.
`parts` shoots six sides of each STL in the folder, named <stem>--<view>.png.
Nothing is saved back to the blend. A project that needs its own framing imports camera() and shoot().
"""
import sys
from pathlib import Path

import bpy
from mathutils import Vector

BLACK = (0.06, 0.06, 0.07, 1)
SIDES = [("front", (0, 1, 0)), ("back", (0, -1, 0)), ("left", (1, 0, 0)), ("right", (-1, 0, 0)), ("top", (0, 0.001, 1)), ("iso", (0.8, 1.3, 0.7))]


def camera(scene, px):
    cam = bpy.data.objects.new("preview", bpy.data.cameras.new("preview"))
    scene.collection.objects.link(cam)
    scene.camera = cam
    cam.data.type = "ORTHO"
    cam.data.clip_start, cam.data.clip_end = 1, 20000
    scene.render.engine = "BLENDER_WORKBENCH"
    shading = scene.display.shading
    shading.color_type, shading.light = "OBJECT", "STUDIO"
    shading.show_cavity = shading.show_object_outline = True
    # black parts on a black ground read by their lit edges and pale outline alone
    shading.cavity_type, shading.cavity_ridge_factor, shading.curvature_ridge_factor = "BOTH", 2.5, 2.0
    shading.show_specular_highlight, shading.object_outline_color = True, (0.7, 0.7, 0.72)
    shading.background_type, shading.background_color = "VIEWPORT", (0, 0, 0)
    scene.view_settings.view_transform, scene.view_settings.look = "Standard", "Medium High Contrast"
    scene.render.resolution_x = scene.render.resolution_y = px
    return cam


def shoot(scene, cam, mid, span, views, tag, out):
    for name, d in views:
        d = Vector(d).normalized()
        cam.data.ortho_scale = span
        cam.location = Vector(mid) + d * 5000
        cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
        scene.render.filepath = f"{out}/{tag}--{name}.png"
        bpy.ops.render.render(write_still=True)


def frame(objs):
    ps = [o.matrix_world @ Vector(c) for o in objs for c in o.bound_box]
    lo = Vector([min(p[k] for p in ps) for k in range(3)])
    hi = Vector([max(p[k] for p in ps) for k in range(3)])
    return (lo + hi) / 2, (hi - lo).length * 1.05


if __name__ == "__main__":
    mode, out, *rest = sys.argv[sys.argv.index("--") + 1:]
    if mode == "scene":
        scene = bpy.context.scene
        objs = [o for o in scene.objects if o.type in ("MESH", "CURVE") and not o.hide_render and o.visible_get()]
        for o in objs:
            o.color = BLACK
        shoot(scene, camera(scene, 900), *frame(objs), SIDES, rest[0] if rest else Path(bpy.data.filepath).stem, out)
    else:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        scene = bpy.context.scene
        cam = camera(scene, 300)
        for f in sorted(Path(rest[0]).expanduser().glob("*.stl")):
            bpy.ops.wm.stl_import(filepath=str(f))
            o = bpy.context.selected_objects[0]
            o.color = BLACK
            shoot(scene, cam, *frame([o]), SIDES, f.stem, out)
            bpy.data.objects.remove(o)
