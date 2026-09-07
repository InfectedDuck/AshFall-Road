"""Blender-only, deterministic portrait sculptures for Ashfall Road.

blender --background --factory-startup --python tools/blender/build_enemy_portraits.py -- --ids all
Geometry is authored here, without downloaded models, textures, or add-ons.
"""
import argparse
import json
import math
import random
import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art_sources" / "blender"
P = {
    "ink": "141C22", "slate": "455660", "steel": "778B91",
    "ash": "A5ABA4", "bone": "CBC6AA", "cream": "DFD2AF",
    "teal": "31585A", "moss": "616C4B", "olive": "747754",
    "ochre": "AD8C4F", "rust": "8D513A", "copper": "A6603B",
    "brown": "665042", "plum": "65505E", "violet": "868091",
    "red": "BC5747", "skin_fair": "C39C82", "skin_olive": "A58C69",
    "skin_tan": "A67A58", "skin_deep": "74503E", "hair": "252A29",
}
M = {}
SCENE = None


def rgba(h):
    c = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return tuple(v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in c) + (1,)


def material(key):
    if key not in M:
        mat = bpy.data.materials.new(key)
        mat.diffuse_color = rgba(P.get(key, key))
        mat.use_nodes = True
        bs = mat.node_tree.nodes.get("Principled BSDF")
        bs.inputs["Base Color"].default_value = mat.diffuse_color
        bs.inputs["Roughness"].default_value = .88
        M[key] = mat
    return M[key]


def finish(obj, name, mat, parent=None):
    obj.name = name
    obj.data.materials.append(material(mat))
    if parent:
        obj.parent = parent
    return obj


def empty(name, loc=(0, 0, 0), scale=1, yaw=0, parent=None):
    obj = bpy.data.objects.new(name, None)
    SCENE.collection.objects.link(obj)
    obj.location = loc
    obj.scale = (scale,) * 3
    obj.rotation_euler.z = math.radians(yaw)
    obj.parent = parent
    return obj


def mesh(name, verts, faces, mat, parent=None):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces)
    data.update()
    return link_mesh(data, name, mat, parent)


def link_mesh(data, name, mat, parent):
    obj = bpy.data.objects.new(name, data)
    SCENE.collection.objects.link(obj)
    return finish(obj, name, mat, parent)


def ell(name, loc, scale, mat, parent=None, seg=12, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings, location=loc)
    obj = bpy.context.object
    obj.scale = scale
    return finish(obj, name, mat, parent)


def box(name, loc, scale, mat, parent=None, bevel=.035, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.rotation_euler = tuple(math.radians(v) for v in rot)
    if bevel:
        mod = obj.modifiers.new("Broad worn edge", "BEVEL")
        mod.width = bevel
        mod.segments = 1
    return finish(obj, name, mat, parent)


def rod(name, a, b, r, mat, parent=None, vertices=8, tip=None):
    a, b = Vector(a), Vector(b)
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r, radius2=r if tip is None else tip,
                                  depth=(b-a).length, location=(a+b)/2)
    obj = bpy.context.object
    obj.rotation_euler = (b-a).to_track_quat("Z", "Y").to_euler()
    return finish(obj, name, mat, parent)


def tube(name, points, radii, mat, parent=None, sides=10, flatten=1, band=None):
    """A closed ring-loft mesh, with authored path and width at every ring."""
    verts, faces = [], []
    for i, p in enumerate(points):
        p = Vector(p)
        tangent = Vector(points[min(i+1, len(points)-1)]) - Vector(points[max(0, i-1)])
        tangent.normalize()
        normal = Vector((0, -1, 0))
        normal = (normal - tangent * normal.dot(tangent)).normalized()
        side = tangent.cross(normal).normalized()
        for j in range(sides):
            angle = math.tau*j/sides
            verts.append(p + radii[i]*(normal*math.cos(angle)*flatten + side*math.sin(angle)))
    for i in range(len(points)-1):
        for j in range(sides):
            faces.append((i*sides+j, i*sides+(j+1)%sides, (i+1)*sides+(j+1)%sides, (i+1)*sides+j))
    faces.extend([tuple(reversed(range(sides))), tuple((len(points)-1)*sides+j for j in range(sides))])
    obj = mesh(name, verts, faces, mat, parent)
    if band:
        obj.data.materials.append(material(band))
        for f in obj.data.polygons:
            if (f.index // sides) % 4 == 1:
                f.material_index = 1
    return obj


def rim(name, loc, radius, thickness, mat, parent=None, stretch=(1, 1, 1)):
    bpy.ops.mesh.primitive_torus_add(major_segments=16, minor_segments=6,
        location=loc, major_radius=radius, minor_radius=thickness,
        rotation=(math.pi/2, 0, 0))
    obj = bpy.context.object
    obj.scale = stretch
    return finish(obj, name, mat, parent)


def plate(name, outline, y, depth, mat, parent=None):
    n = len(outline)
    verts = [(x, y, z) for x, z in outline] + [(x, y+depth, z) for x, z in outline]
    faces = [tuple(reversed(range(n))), tuple(range(n, 2*n))]
    faces += [(i, (i+1)%n, (i+1)%n+n, i+n) for i in range(n)]
    return mesh(name, verts, faces, mat, parent)


def init_scene(enemy_id):
    global SCENE, M
    bpy.ops.wm.read_factory_settings(use_empty=True)
    M = {}
    SCENE = bpy.context.scene
    SCENE.name = enemy_id
    SCENE["asset_id"] = enemy_id
    SCENE["source_brief"] = "docs/ENEMY_PORTRAIT_PROMPTS_V4.md / enemy-portrait-v4.2"
    SCENE["asset_type"] = "Editable posed portrait sculpture; no animation rig"
    SCENE.render.engine = "CYCLES"
    SCENE.cycles.device = "CPU"
    SCENE.cycles.samples = 32
    SCENE.cycles.use_denoising = True
    SCENE.render.threads_mode = "FIXED"
    SCENE.render.threads = 8
    SCENE.render.resolution_x = SCENE.render.resolution_y = 256
    SCENE.render.resolution_percentage = 100
    SCENE.render.image_settings.file_format = "PNG"
    SCENE.render.image_settings.color_mode = "RGBA"
    SCENE.render.film_transparent = False
    SCENE.view_settings.view_transform = "Standard"
    SCENE.view_settings.look = "None"
    SCENE.world = bpy.data.worlds.new("Flat charcoal #20272B")
    SCENE.world.use_nodes = True
    SCENE.world.node_tree.nodes["Background"].inputs[0].default_value = rgba("20272B")
    cam_data = bpy.data.cameras.new("Portrait camera — locked shared framing")
    camera = bpy.data.objects.new("Portrait camera", cam_data)
    SCENE.collection.objects.link(camera)
    camera.location = (0, -12, .65)
    camera.rotation_euler = (Vector((0, 0, 0))-camera.location).to_track_quat("-Z", "Y").to_euler()
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = 4.8
    SCENE.camera = camera
    for name, pos, power, size, color in [
        ("Warm key", (-3, -5, 6), 650, 4, (1, .85, .69)),
        ("Cool fill", (4, -2, 2), 180, 5, (.62, .77, 1)),
        ("Steel rim", (1, 3, 5), 850, 3, (.68, .82, 1)),
    ]:
        data = bpy.data.lights.new(name, "AREA")
        data.energy, data.shape, data.size, data.color = power, "DISK", size, color
        obj = bpy.data.objects.new(name, data)
        SCENE.collection.objects.link(obj)
        obj.location = pos
        obj.rotation_euler = (-obj.location).to_track_quat("-Z", "Y").to_euler()
    return empty(enemy_id)


def stalker(root):
    tube("Long flexible throat", [(-1, .2, -2),(-.65, .08, -1.5),(-.3, .1, -.8),(.12, 0, -.15),(.35, .08, .6)],
         [.55,.45,.33,.3,.36], "ash", root, sides=12)
    ell("Low shoulder", (-1.1,.1,-1.75),(.95,.48,.48),"violet",root)
    ell("Raised shoulder", (.85,.24,-1.35),(.65,.42,.78),"ash",root)
    for i in range(6):
        z = -1.45+i*.2
        x = -.62+i*.12
        tube("Broad throat fold %02d" % i, [(x-.29,-.22,z+.07),(x,-.34,z),(x+.28,-.21,z+.04)], [.046,.065,.04],"violet",root)
    # Uneven hand-shaped cranial silhouette, distinct cheek and jaw planes.
    tube("Sealed predator skull",[(.34,.07,-.13),(.38,.05,.05),(.39,.02,.34),(.43,.12,.78),(.45,.17,1.2),(.36,.18,1.65),(.26,.18,1.92)],
         [.22,.34,.46,.57,.58,.43,.09],"bone",root,sides=12,flatten=.87)
    for side in (-1,1):
        x = .4 + side*.24
        ell("Sealed raised eyelid",(x,-.397,.96),(.21,.07,.105),"ash",root)
        tube("Permanent eye seam",[(x-.16,-.463,.95),(x,-.48,.925),(x+.15,-.437,.98)],[.018,.024,.014],"violet",root,sides=6)
        for j in range(3):
            dx = (j-1)*.11
            rod("Radial healed crease",(x+dx,-.446,1.01),(x+dx*1.25,-.40,1.14),.016,"violet",root,vertices=5)
        for j in range(2):
            ell("Shallow listening pit",(x+side*.055,-.40,.63-j*.13),(.042,.014,.052),"violet",root,seg=8,rings=6)
    ell("Low nasal ridge",(.39,-.39,.7),(.12,.15,.18),"ash",root)
    for x in (.35,.45):
        ell("Nostril",(x,-.516,.62),(.028,.013,.02),"slate",root,seg=8,rings=6)
    ell("Small listening mouth",(.42,-.367,.33),(.103,.045,.088),"ink",root)
    rim("Closed-lip rim",(.42,-.38,.33),.09,.026,"violet",root,stretch=(1,1,.8))
    tube("Wrist",[(1.38,.1,-2.1),(1.52,-.03,-1.5),(1.49,-.08,-.93)],[.24,.19,.23],"ash",root)
    ell("Palm",(1.49,-.1,-.78),(.25,.17,.37),"bone",root)
    for i in range(4):
        x = 1.21+i*.18
        z = -.61+(1-abs(i-1.5)/2)*.20
        points = [(x,-.13,z),(x+.08,-.15,z+.4),(x+.01,-.23,z+.69),(x-.14,-.31,z+.76)]
        tube("Hooked digit %d"%(i+1),points,[.066,.06,.052,.028],"bone",root,sides=8)
        ell("Blunt nail",points[-1],(.04,.04,.055),"slate",root,seg=8,rings=6)
    tube("Opposed thumb",[(1.24,-.13,-.97),(.99,-.2,-.75),(.88,-.28,-.42),(.93,-.31,-.27)],[.095,.08,.06,.028],"bone",root,sides=8)
    root["subject_count"] = 1
    root["signature"] = "Sealed eye creases, whisper mouth, six throat folds, one five-digit hand"


def warden(root):
    box("Heavy checkpoint hull",(0,.1,-.55),(3.45,1.45,1.32),"slate",root,bevel=.16)
    for side in (-1,1):
        x = side*1.64
        box("Track well",(x,.1,-1.09),(.73,1.72,1.6),"ink",root,bevel=.27)
        for z in [-1.63,-1.3,-.97,-.64]:
            box("Broad front tread",(x,-.83,z),(.7,.26,.24),"hair" if side<0 else "brown",root,bevel=.06)
        for y in [-.55,-.15,.25,.65]:
            box("Top tread",(x,y,-.36),(.74,.28,.22),"slate" if side<0 else "brown",root)
        for z in [-1.45,-.93]:
            rod("Axle",(x-side*.15,-.65,z),(x+side*.41,-.65,z),.20,"steel",root)
    octagon = [(-.82+.68*math.cos(math.tau*i/8+math.pi/8),-.49+.65*math.sin(math.tau*i/8+math.pi/8)) for i in range(8)]
    plate("Blank reused octagonal road sign",octagon,-.81,.12,"bone",root)
    plate("Rust trapezoid replacement",[(-.26,-.83),(.65,-.76),(.54,.1),(-.18,.21)],-.91,.12,"rust",root)
    box("Blue shoulder replacement",(.98,-.65,.13),(.7,.2,.49),"steel",root,rot=(0,12,0))
    for x,z in [(-1.2,-.23),(-.43,-.23),(-1.13,-.8),(-.46,-.87),(.39,-.56),(.29,.01)]:
        rod("Large plate bolt",(x,-.94,z),(x,-1.0,z),.055,"slate",root,vertices=6)
    box("Armored scanner neck",(-.87,.1,.54),(.58,.74,.7),"ink",root)
    box("Scanner hood",(-.9,-.12,1.04),(1.4,.96,.62),"slate",root,bevel=.12,rot=(0,0,-9))
    box("Scanner brow",(-.9,-.65,1.31),(1.51,.33,.17),"steel",root)
    rod("Sensor recess",(-1.09,-.67,1.03),(-1.09,-.75,1.03),.24,"ink",root,vertices=16)
    rod("Single dull red scanner",(-1.09,-.755,1.03),(-1.09,-.78,1.03),.14,"red",root,vertices=12)
    for i in range(3):
        box("Overlapping maintenance hatch",(-.34,-.7,.46-i*.19),(.82,.16,.12),"slate",root)
    box("Cannon mounting block",(.88,-.79,-.62),(.88,.7,.68),"ink",root,bevel=.09)
    rod("Single rotary cannon shroud",(.83,-.96,-.55),(1.13,-1.84,-.8),.45,"slate",root,vertices=12)
    for a in (math.pi/2,math.pi/2+math.tau/3,math.pi/2+2*math.tau/3):
        x,z=1.13+.23*math.cos(a),-.8+.23*math.sin(a)
        rod("Recessed barrel hole",(x,-1.83,z),(x,-1.9,z),.105,"ink",root,vertices=8)
    root["subject_count"] = 1
    root["signature"] = "Blank octagonal road-sign armor; one offset scanner and one three-hole cannon"


def leeches(root):
    # Nine individually posed segmented bodies, plus exactly one fed outlier.
    paths = [
        [(-1.35,-.35,1.38),(-1.08,-.29,1.0),(-.52,-.2,.76),(-.63,-.23,.31),(-.94,-.3,-.13),(-.43,-.32,-.63),(.35,-.31,-1.04)],
        [(-1.65,.1,.5),(-1.94,.0,.01),(-1.6,-.12,-.55),(-1.09,-.16,-.73),(-.81,-.13,-1.31),(-.27,-.2,-1.67)],
        [(-.38,.15,1.55),(.08,.02,1.42),(.22,-.06,.8),(.61,-.04,.53),(.74,-.1,-.1),(1.14,-.06,-.65)],
        [(.6,.16,1.67),(1.03,.14,1.42),(.91,.07,.85),(1.32,.04,.41),(1.32,0,-.06)],
        [(-1.2,.16,-1.5),(-.78,.15,-1.84),(-.19,.05,-1.94),(.4,-.02,-1.69),(.98,-.07,-1.27)],
        [(-1.73,.16,1.42),(-1.96,.13,1.17),(-1.81,.13,.78),(-1.32,.11,.48),(-.99,.02,.08)],
        [(-.52,.32,.69),(-.14,.22,.35),(.33,.13,.0),(.04,.04,-.48),(.61,-.03,-.76)],
        [(-1.8,.31,-.67),(-1.57,.2,-1.04),(-1.09,.1,-1.03),(-.44,.01,-1.4),(.05,-.02,-1.62)],
        [(.0,.33,1.9),(.41,.2,1.94),(.71,.12,1.73),(.53,.1,1.22),(.62,.04,.89)],
    ]
    for i,path in enumerate(paths):
        r = .3 if i==0 else [.16,.21,.15,.22][i%4]
        # Intermediate rings define broad transverse segmentation, no separate heads.
        pts,rs=[],[]
        for j in range(len(path)-1):
            for k in range(4):
                t=k/4
                pts.append(Vector(path[j]).lerp(Vector(path[j+1]),t))
                progress=(j+t)/(len(path)-1)
                rs.append(r*(.45+.55*math.sin(math.pi*(.1+.85*progress)))*(1 if k%2 else .92))
        pts.append(Vector(path[-1])); rs.append(r*.35)
        tube("Hungry leech %02d"%(i+1),pts,rs,["teal","brown","moss","slate"][i%4],root,flatten=.75,band="ink")
    ell("Dominant sucker hollow",(-1.35,-.55,1.4),(.24,.055,.27),"ink",root)
    rim("Muscular toothless sucker",(-1.35,-.59,1.4),.235,.083,"violet",root,stretch=(1,1,1.1))
    fed_path=[(1.58,-.08,-1.17),(1.83,-.1,-.82),(1.81,-.13,-.37),(1.68,-.12,.02),(1.62,-.1,.3),(1.75,-.08,.49)]
    fed_widths=[.07,.29,.34,.27,.13,.05]
    fed_points,fed_radii=[],[]
    for i in range(len(fed_path)-1):
        for j in range(4):
            t=j/4
            fed_points.append(Vector(fed_path[i]).lerp(Vector(fed_path[i+1]),t))
            fed_radii.append((fed_widths[i]*(1-t)+fed_widths[i+1]*t)*(1 if j%2 else .91))
    fed_points.append(fed_path[-1]); fed_radii.append(fed_widths[-1])
    tube("Fed pale outlier — curled away",fed_points,fed_radii,"violet",root,flatten=.7,band="ash")
    root["subject_count"] = 10
    root["signature"] = "Nine hungry bodies, one pale distended outlier curling away"


def crow(parent, name, loc, size, angle, pose, lead=False):
    bird=empty(name,loc,size,parent=parent)
    bird.rotation_euler.y=math.radians(angle)
    ell("Bare corvid breast",(0,0,0),(.25,.24,.5),"slate",bird)
    ell("Folded neck",(.05,-.05,.35),(.19,.2,.3),"brown",bird)
    ell("Narrow corvid skull",(.09,-.08,.6),(.22,.23,.23),"slate",bird)
    plate("Long hooked beak",[(.02,.63),(.47,.56),(.54,.41),(.4,.47),(.08,.47)],-.31,.23,"ink",bird)
    ell("Milky left eye" if lead else "Dark eye",(.14,-.31,.65),(.045,.025,.039),"bone" if lead else "ink",bird,seg=8,rings=6)
    for s in (-1,1):
        reach = (1.1 if pose!=2 else .36)*(1 if not(pose==1 and s==1) else .55)
        lift = [.25,.8,-.18,1.1,.5,-.12,.72][pose]
        outline=[(s*.13,.2),(s*.51,.4),(s*reach,lift),(s*(reach*.9),lift-.31),(s*.53,-.12),(s*.17,-.25)]
        plate("Bare avian wing",outline,.0,.16,"brown" if s<0 else "slate",bird)
        for j in range(3):
            x=s*(.45+j*.19)*reach
            rod("Broken remnant feather shaft",(x,-.025,.03+j*.04),(x+s*.13,-.05,-.25+j*.015),.028,"steel",bird,vertices=5,tip=.01)
        rod("Tucked scaled leg",(s*.1,-.1,-.3),(s*.15,-.3,-.44),.038,"brown",bird)
        for j in range(3):
            rod("Talon",(s*.15,-.3,-.44),(s*.15+(j-1)*.07,-.35,-.55),.018,"ink",bird,vertices=5,tip=.006)
    plate("Short ragged tail",[(-.14,-.35),(-.22,-.72),(0,-.61),(.13,-.77),(.14,-.33)],.08,.1,"slate",bird)
    if lead:
        # Selected Crows generation record uses a ring pull rather than the older key.
        rim("Stolen brass ring pull",(.44,-.35,.29),.11,.029,"ochre",bird)
        box("Ring pull tab",(.42,-.35,.42),(.075,.05,.12),"ochre",bird,bevel=.01)
    return bird


def crows(root):
    crow(root,"01 Lead crow",(-.35,-.45,-.1),1.34,49,0,True)
    for i,(loc,scale,angle,pose) in enumerate([
        ((-1.47,.2,1.05),.48,-35,2), ((-.1,.3,1.53),.51,70,1),
        ((1.3,.2,1.32),.44,152,2), ((1.52,.1,.25),.46,-24,3),
        ((1.28,.4,-1.34),.32,-30,4), ((-1.35,.3,-1.42),.34,25,5)]):
        crow(root,"%02d Supporting crow"%(i+2),loc,scale,angle,pose)
    root["subject_count"]=7
    root["signature"]="Seven corvids in different poses; milky lead eye and stolen brass ring pull"
    SCENE["source_override"]="docs/ENEMY_CROWS_GENERATION.md: selected ring-pull variant"


def drones(root):
    patrol=empty("01 Patrol",(0,-.15,-.77),parent=root,yaw=-7)
    box("Heavy patrol hull",(0,0,0),(1.58,.68,.8),"slate",patrol,bevel=.12)
    box("Cream replacement top",(-.12,-.06,.43),(1.2,.75,.12),"bone",patrol)
    for x in (-1.03,1.03):
        box("Square lift shroud",(x,.1,.04),(.61,.66,.32),"ink",patrol,bevel=.1)
        rim("Lift fan rim",(x,-.25,.07),.2,.055,"steel",patrol)
        rod("Fan crossbar",(x-.15,-.31,.07),(x+.15,-.31,.07),.035,"slate",patrol)
    rod("Sensor socket",(-.44,-.38,.04),(-.44,-.45,.04),.23,"ink",patrol,vertices=12)
    rod("Red sensor",(-.44,-.451,.04),(-.44,-.46,.04),.13,"red",patrol,vertices=12)
    for z in [-.15,0,.15]:
        box("Cracked speaker slot",(.36,-.37,z),(.5,.045,.07),"ink",patrol,bevel=.01)
    box("Scraped blank brass plaque",(-.05,-.4,-.28),(.23,.04,.1),"ochre",patrol,bevel=.01)
    inspect=empty("02 Inspection",(-1.45,.15,1.13),parent=root,yaw=-19)
    box("Upright inspection chassis",(0,0,0),(.46,.53,1.22),"steel",inspect)
    box("Vertical dark glass lens",(-.08,-.28,.1),(.22,.04,.76),"ink",inspect,bevel=.02)
    box("Rust repair band",(0,-.3,-.34),(.5,.06,.13),"rust",inspect)
    rod("Compact lift duct",(.04,.05,.71),(.04,.05,.92),.3,"slate",inspect)
    utility=empty("03 Utility",(.94,.1,1.17),parent=root)
    ell("Round ochre housing",(0,0,0),(.48,.35,.5),"ochre",utility)
    for x in [-.28,0,.28]:
        tube("Broad cage rib",[(x,-.14,.44),(x,-.37,.23),(x,-.4,-.2),(x,-.17,-.43)],[.055]*4,"ink",utility,sides=6)
    box("Replacement cage section",(-.28,-.41,-.03),(.13,.08,.22),"steel",utility)
    box("Recessed utility sensor",(.14,-.4,.12),(.15,.07,.1),"ink",utility,bevel=.01)
    for x in (-.61,.61):
        rod("Short utility lift pod",(x,.03,-.08),(x,.03,.22),.17,"slate",utility)
    tube("Attached broad carrying fork",[(.28,-.21,-.25),(.57,-.26,-.61),(.8,-.27,-.89),(.72,-.28,-1.12),(.22,-.28,-1.12)], [.13]*5,"steel",utility,sides=4)
    alarm=empty("04 Dead alarm — carried",(1.37,-.08,.27),parent=root)
    rod("Warped burnt disk",(0,.15,0),(0,-.16,0),.38,"ink",alarm,vertices=12)
    rim("Rust disk rim",(0,-.16,0),.34,.04,"rust",alarm)
    box("Broken inert beacon",(-.06,.04,.37),(.16,.2,.13),"brown",alarm,rot=(0,22,0))
    for x in (-.14,.02):
        box("Surviving hazard band",(x,-.2,-.2),(.09,.03,.13),"ochre",alarm,bevel=0,rot=(0,-25,0))
    emitter=empty("05 Emitter",(-1.57,-.1,-1.28),parent=root)
    plate("Triangular cream hub",[(-.35,-.21),(.35,-.21),(0,.39)],-.2,.35,"bone",emitter)
    for a,b in [((-.22,-.1,-.12),(-.49,-.1,-.35)),((.21,-.1,-.13),(.48,-.1,-.34)),((0,-.1,.19),(0,-.1,.54))]:
        rod("Blunt steel prong",a,b,.075,"steel",emitter,vertices=6)
    box("Recessed emitter sensor",(0,-.23,0),(.14,.04,.11),"ink",emitter,bevel=.01)
    root["subject_count"]=5
    root["signature"]="Four active chassis; utility fork physically carries the dead alarm disk"


def human(parent, name, loc, size=1, yaw=0, skin="skin_olive", hair="hair", style="crop",
          coat="slate", collar="brown", shape="oval", mask=None, gaze=0, age=35, wear="brown", mood=0):
    """A faceted, fully modelled bust. Facial dimensions and coverings vary by cast."""
    unit=empty(name,loc,size,yaw,parent)
    unit["age"]=age
    unit["character_type"]="Adult portrait bust"
    width,jaw,height={"oval":(.40,.26,1),"square":(.45,.35,.94),"diamond":(.42,.23,1.04),
                      "round":(.44,.30,.92),"long":(.35,.24,1.16),"triangle":(.37,.20,1.02)}[shape]
    tube("Layered work coat",[(0,.12,-1.13),(0,.05,-.89),(0,.05,-.51),(0,.02,-.28)],
         [.78,.80,.68,.37],coat,unit,sides=10,flatten=.48)
    ell("Left shoulder",(-.6,.05,-.58),(.37,.30,.37),coat,unit)
    ell("Right shoulder",(.59,.08,-.58),(.36,.29,.32),coat,unit)
    tube("Neck",[(0,.04,-.37),(0,.05,.1)],[.20,.22],skin,unit,sides=10)
    tube("High practical collar",[(-.32,-.11,-.18),(-.2,-.30,-.4),(0,-.38,-.48),(.26,-.26,-.31),(.35,-.08,-.14)],
         [.12,.12,.13,.12,.12],collar,unit,sides=6)
    # The face is a continuous jaw-to-crown loft, not a sphere with stuck-on eyeballs.
    tube("Authored skull and jaw",[(0,0,-.04),(0,-.018,.09*height),(0,.015,.32*height),
        (0,.03,.53*height),(0,.045,.79*height),(0,.06,.96*height),(0,.07,1.04*height)],
        [jaw*.72,jaw,width*.91,width,width*.88,width*.68,.035],skin,unit,sides=12,flatten=.88)
    for side in (-1,1):
        ell("Ear",(side*width*.97,.02,.42*height),(.077,.075,.15),skin,unit,seg=8,rings=6)
        x=side*width*.43
        eye_z=.58*height + (mood*.025 if side==1 else 0)
        # Narrow eyelid planes leave eyes inset and tired rather than glossy.
        ell("Eye socket",(x,-.323,eye_z),(.123,.019,.058 if mood!=2 else .072),"brown",unit,seg=8,rings=6)
        ell("Matte eye",(x,-.341,eye_z),(.084,.011,.023 if mood!=2 else .038),"ash",unit,seg=8,rings=6)
        ell("Side-looking iris",(x+gaze*.027,-.356,eye_z),(.027,.009,.028),"ink",unit,seg=8,rings=6)
        rod("Uneven brow",(x-.11,-.318,eye_z+.071),(x+.097,-.306,eye_z+.073+side*mood*.018),.028,hair,unit,vertices=5)
        if age>=40:
            rod("Weathered lower lid",(x-.08,-.309,eye_z-.085),(x+.08,-.303,eye_z-.073),.013,"brown",unit,vertices=5)
    verts=[(-.071,-.3,.59*height),(.065,-.3,.59*height),(-.095,-.35,.34*height),
           (.085,-.35,.34*height),(.02,-.48,.39*height),(0,-.29,.27*height)]
    mesh("Asymmetric nose bridge",verts,[(0,1,4),(1,3,4),(0,4,2),(2,4,5),(4,3,5),(0,2,5,3,1)],skin,unit)
    tube("Closed tired mouth",[(-.13,-.276,.18*height),(0,-.318,.163*height),(.12,-.273,(.18+mood*.014)*height)],
         [.012,.022,.012],"brown",unit,sides=6)
    # Dominant survival wear remains a broad, local patch, rather than random noise.
    plate("Old dry cheek wear",[(-.31,.40*height),(-.21,.37*height),(-.19,.27*height),(-.29,.29*height)],-.298,.014,wear,unit)
    box("Coat contact repair",(-.63,-.255,-.53),(.23,.042,.17),collar,unit,bevel=.01,rot=(0,12,0))
    if mask:
        tube("Lower face cloth — stays covered",[(0,-.013,.02),(0,-.045,.16),(0,-.08,.30)],
             [jaw*.91,width*.93,width*.95],mask,unit,sides=10,flatten=1.04)
        for z in (.1,.21):
            tube("Broad cloth fold",[(-.29,-.31,z),(-.03,-.445,z-.025),(.29,-.29,z+.015)], [.015,.019,.013],collar,unit,sides=5)
    if style not in ("bald","hood","wrap"):
        ell("Hair crown",(0,.09,.88*height),(width*1.02,.34,.29),hair,unit,seg=12,rings=6)
        if style in ("bob","long","braid"):
            for side in (-1,1):
                tube("Uneven side hair mass",[(side*.27,.03,.98*height),(side*(width+.015),.03,.63),
                    (side*(width+.035),.03,.18),(side*(width-.02),.06,-.09 if style=="bob" else -.4)],
                    [.14,.15,.13,.07],hair,unit,sides=7)
        if style in ("crop","coils","bun","bob"):
            for i in range(4):
                ell("Rough hair clump",(-.24+i*.15,-.15,.88*height+(i%2)*.065),(.12,.16,.11),hair,unit,seg=7,rings=5)
        if style=="bun":
            ell("Lopsided coiled bun",(.22,.14,1.18),(.23,.23,.22),hair,unit,seg=10,rings=6)
        if style=="knot":
            ell("Compact low hair knot",(.33,.22,.28),(.17,.17,.19),hair,unit,seg=10,rings=6)
        if style=="braid":
            for i in range(6):
                ell("Bound braid clump",(.38+(.023 if i%2 else 0),.09,.22-i*.14),(.10,.1,.12),hair,unit,seg=8,rings=6)
    elif style in ("hood","wrap"):
        tube("Cloth hood border",[(-.37,-.03,-.1),(-.48,.0,.43),(-.34,.01,.94),(0,.01,1.11),(.35,.01,.93),(.48,.03,.43),(.37,.05,-.1)],
             [.16,.15,.16,.17,.16,.15,.14],collar,unit,sides=6)
        ell("Covered back of head",(0,.23,.57),(.45,.28,.56),collar,unit)
        if style=="wrap":
            box("Forehead wrap",(0,-.21,.87),(.77,.16,.17),collar,unit,rot=(0,-7,0))
    return unit


def strap(parent,x,mat="bone",pattern=False):
    rod("Narrow shoulder strap",(x,-.33,-.30),(x*.9,-.4,-1.10),.057,mat,parent,vertices=4)
    if pattern:
        for z in (-.47,-.69,-.92):
            box("Faded child's backpack pattern",(x,-.397,z),(.063,.035,.062),"steel",parent,bevel=0)


def beard(parent,mat="hair",small=False):
    tube("Rough clipped beard",[(-.27,-.1,.17),(0,-.24,-.055),(.27,-.1,.14)], [.065,.12 if not small else .065,.055],mat,parent,sides=6)


def gun(parent,name,a,b,mat="slate"):
    rod(name+" barrel",a,b,.07,mat,parent,vertices=8)
    a,b=Vector(a),Vector(b)
    rod(name+" stock",a,a-(b-a)*.40,.13,"brown",parent,vertices=4)
    p=a.lerp(b,.25)
    rod(name+" grip",p,p+Vector((0,.025,-.24)),.065,"brown",parent,vertices=4)


def goggles(parent,one=False):
    for x in ((-.16,) if one else (-.17,.17)):
        rim("Raised work lens rim",(x,-.31,.87),.105,.028,"steel",parent)
        ell("Dull work lens",(x,-.307,.87),(.085,.015,.081),"slate",parent)


def bandits(root):
    spot=human(root,"02 Spotter — 41",(-1.3,.37,.68),.90,-56,style="crop",coat="slate",collar="ochre",shape="square",age=41,gaze=-1,mood=-1)
    ell("Plum flat cap",(0,.025,1),(.49,.37,.16),"plum",spot)
    box("Cap brim",(0,-.33,.95),(.72,.3,.07),"brown",spot)
    rod("Crossing guard sash",(-.55,-.31,-.35),(.31,-.41,-1.0),.075,"ochre",spot,vertices=4)
    archer=human(root,"04 Archer — 36",(.87,.39,.86),.88,-12,skin="skin_fair",style="crop",coat="olive",collar="brown",shape="long",gaze=-1)
    beard(archer,small=True)
    ell("Short tied ponytail",(.05,.33,.18),(.13,.16,.27),"hair",archer)
    recruit=human(root,"03 Recruit — 23",(1.31,-.12,-.52),.89,26,skin="skin_deep",style="coils",coat="steel",collar="brown",shape="round",mask="plum",gaze=1,age=23,mood=2)
    for x in [-.4,-.15,.1,.35]:
        rod("Moving-blanket quilt channel",(x,-.38,-.5),(x,-.38,-1.0),.027,"slate",recruit,vertices=5)
    leader=human(root,"01 Leader — 27",(-.35,-.61,-.51),1.18,0,skin="skin_fair",hair="copper",style="bob",coat="ochre",collar="ink",shape="diamond",age=27,mood=-1)
    for x in (-.46,.46): strap(leader,x,pattern=True)
    rod("Healed mouth-corner scar",(-.15,-.286,.16),(-.21,-.283,.10),.018,"bone",leader,vertices=5)
    tube("Single hunting bow",[(1.89,.29,1.88),(2.16,.18,1.36),(2.21,.15,.77),(1.96,.13,.25)],[.035]*4,"brown",root,sides=6)
    rod("Bowstring",(1.89,.29,1.88),(1.96,.13,.25),.01,"bone",root,vertices=4)
    box("Machete hilt",(-1.68,-.25,-1.78),(.18,.16,.54),"brown",root,rot=(0,-25,0))


def toll(root):
    heavy=human(root,"02 Bald enforcer — 42",(-1.1,.28,.63),1.22,-9,skin="skin_fair",style="bald",coat="ochre",collar="brown",shape="square",age=42,gaze=1,mood=-1)
    rod("Resting wooden club",(-1.95,-.08,-1.92),(-1.95,-.08,.82),.095,"brown",root,vertices=8)
    leader=human(root,"01 Silver-haired administrator — 56",(.20,-.53,-.25),1.29,0,hair="ash",style="knot",coat="rust",collar="bone",shape="long",age=56,mood=-1)
    box("Invented rank — spring clip",(.36,-.42,-.60),(.22,.1,.25),"steel",leader,bevel=.02)
    box("Empty spring-clip bite",(.36,-.478,-.58),(.12,.02,.09),"ink",leader,bevel=.01)
    look=human(root,"03 Curled lookout — 25",(1.49,-.05,-.69),.88,24,skin="skin_tan",hair="brown",style="coils",coat="brown",collar="rust",shape="diamond",mask="bone",age=25,gaze=1)
    goggles(look)
    gun(root,"Lowered revolver",(.62,-.89,-1.55),(.84,-.98,-2.04))


def raiders(root):
    # Later selected user-directed identity/weathering edits override the v4.2 cast here.
    woman=human(root,"01 Red-haired unmasked raider",(-.8,-.42,-.32),1.38,-43,skin="skin_fair",hair="copper",style="braid",coat="teal",collar="brown",shape="diamond",age=25,gaze=1)
    rod("Old pale eyebrow scar",(-.24,-.33,.65),(-.16,-.35,.54),.021,"bone",woman,vertices=5)
    rod("Old healed cheek scar",(.22,-.31,.42),(.30,-.27,.32),.019,"ash",woman,vertices=5)
    box("Broken cork ear guard",(-.43,-.01,.43),(.15,.18,.32),"ochre",woman,rot=(0,14,0))
    man=human(root,"02 Black-haired heron-mask raider",(.6,.22,.56),1.28,37,skin="skin_fair",style="long",coat="brown",collar="ink",shape="long",age=30,gaze=1)
    plate("Lashed heron mask",[(-.23,.72),(.25,.70),(.31,.26),(.10,-.31),(-.18,.02)],-.42,.24,"ochre",man)
    mesh("Projecting heron beak",[(-.18,-.43,.55),(.21,-.43,.54),(.06,-1.09,-.11),(.0,-.48,.15)],[(0,1,2),(0,2,3),(1,3,2),(0,3,1)],"ochre",man)
    for z in (.28,.47):
        rod("Broad mask joint binding",(-.18,-.52,z),(.23,-.52,z+.045),.035,"bone",man,vertices=5)
    ell("Single non-glowing red eye",(-.18,-.373,.65),(.032,.021,.026),"red",man,seg=8,rings=6)
    for s in (-1,1):
        rod("Crossed rope harness",(s*.56,-.32,-.36),(-s*.36,-.43,-1.06),.045,"ochre",man,vertices=6)
    gun(root,"Patched shotgun",(.42,-.23,-1.23),(1.96,-.19,-.75))
    tube("Short pole-hook",[(-2.01,-.14,-1.91),(-2.01,-.14,.15),(-1.87,-.14,.36),(-1.65,-.14,.27),(-1.66,-.14,.09)],[.05]*5,"steel",root,sides=6)
    SCENE["source_override"]="docs/ENEMY_RAIDERS_GENERATION.md: selected identity and weathering revisions"


def scavs(root):
    elect=human(root,"02 Electrician — 55",(-1.5,.35,.74),.85,17,skin="skin_fair",hair="brown",style="crop",coat="plum",collar="ochre",shape="square",age=55,gaze=1,wear="ash",mood=1)
    tube("Thick silver forelock",[(-.25,-.06,.91),(-.24,-.13,1.13),(-.12,-.17,1.14)],[.1,.09,.05],"ash",elect,sides=6)
    for x in (-.3,.3):
        box("Padded hearing protector at neck",(x,-.25,-.28),(.16,.16,.23),"bone",elect)
    claim=human(root,"01 Claimant — 44",(-.53,-.4,-.24),1.16,0,skin="skin_tan",style="crop",coat="slate",collar="brown",shape="square",age=44)
    beard(claim,small=True)
    look=human(root,"03 Lookout — 24",(1.22,.28,.82),.88,25,skin="skin_fair",style="crop",coat="olive",collar="ink",shape="triangle",age=24,gaze=1,mood=1)
    goggles(look,True)
    mech=human(root,"04 Mechanic — 29",(.85,-.55,-.70),1.07,-13,skin="skin_deep",style="bun",coat="steel",collar="bone",shape="round",age=29,gaze=-1,wear="ink",mood=1)
    for unit,color in [(elect,"steel"),(claim,"ochre"),(look,"rust"),(mech,"plum")]:
        box("Sleeve role tape",(.68,-.23,-.62),(.18,.06,.11),color,unit,bevel=.005)
    gun(root,"Rifle resting flat",(-.73,-.87,-1.75),(1.91,-.87,-1.75))
    rod("Resting work axe handle",(-1.89,-.15,-2.02),(-1.89,-.15,-.6),.05,"brown",root)
    plate("Work axe head at rest",[(-2.17,-.47),(-1.67,-.62),(-1.71,-.83),(-2.13,-.89)],-.17,.13,"steel",root)


def hunters(root):
    man=human(root,"01 Signaler — 43",(-.7,.15,.57),1.25,-27,skin="skin_deep",style="crop",coat="teal",collar="slate",shape="diamond",age=43,gaze=-1,wear="moss",mood=-1)
    for i in range(4):
        tube("Bound loc",[(-.2+i*.12,.05,.97),(-.15+i*.12,.30,.71),(-.12+i*.12,.35,.27)],[.06,.06,.04],"hair",man,sides=6)
    box("Tape over loc binding",(0,.33,.42),(.55,.1,.11),"ink",man)
    box("Cloth-wrapped shuttered lamp",(-.57,-.09,-.08),(.24,.25,.33),"slate",man)
    box("Closed lamp shutter",(-.57,-.232,-.08),(.17,.03,.22),"ink",man)
    woman=human(root,"02 Listener — 26",(.83,-.42,-.61),1.17,-13,skin="skin_fair",hair="bone",style="braid",coat="slate",collar="ink",shape="long",mask="ash",age=26,gaze=-1,wear="moss",mood=2)
    for z in (.8,.96):
        box("Cloth binding across pale hair",(0,-.12,z),(.75,.29,.09),"ink",woman,rot=(0,6,0))
    signal=empty("Partner-directed stop hand",(.25,-.61,-.20),.9,parent=root,yaw=38)
    ell("Raised flat palm",(0,0,.03),(.19,.095,.28),"skin_deep",signal)
    for i in range(4):
        x=-.135+i*.09
        length=.36-abs(i-1.3)*.045
        rod("Together finger %d"%(i+1),(x,0,.20),(x,0,.20+length),.043,"skin_deep",signal,vertices=8,tip=.035)
    rod("Opposed signaling thumb",(-.16,0,-.01),(-.27,0,.19),.055,"skin_deep",signal,tip=.043)
    rod("Raised wrist",(0,0,-.46),(0,0,-.15),.12,"skin_deep",signal)
    plate("Only exposed knife edge",[(-.7,-1.97),(.39,-1.84),(.53,-1.96),(-.71,-2.03)],-.61,.035,"steel",root)


def cult(root):
    elder=human(root,"02 Senior pilgrim — 64",(-1.5,-.04,-.83),.82,-28,skin="skin_deep",hair="ash",style="hood",coat="brown",collar="ochre",shape="round",age=64,gaze=-1,wear="ash")
    human(root,"03 Ascetic — 25",(-1.23,.34,.82),.77,19,skin="skin_fair",hair="copper",style="hood",coat="ink",collar="bone",shape="long",age=25,gaze=1,wear="ash")
    pilgrim=human(root,"04 Cheek-guard pilgrim — 38",(.78,.37,.86),.85,31,skin="skin_tan",hair="brown",style="hood",coat="bone",collar="plum",shape="round",age=38,gaze=1)
    plate("Cracked dull glass cheek guard",[(.16,.43),(.37,.49),(.34,.17),(.2,.13)],-.30,.04,"steel",pilgrim)
    guide=human(root,"01 Solar-film veiled guide — 31",(-.28,-.59,-.21),1.18,-17,skin="skin_deep",style="wrap",coat="ash",collar="plum",shape="oval",mask="steel",age=31,gaze=-1)
    plate("Asymmetric scratched solar-film veil",[(-.36,.47),(.36,.43),(.31,-.22),(-.32,-.04)],-.47,.045,"steel",guide)
    rod("One broad dull veil scratch",(-.16,-.50,.24),(.10,-.50,.1),.018,"ash",guide,vertices=4)
    follower=human(root,"05 Wrapped follower — 47",(1.55,-.2,-.77),.85,-19,style="wrap",coat="ink",collar="brown",shape="long",mask="brown",age=47,gaze=-1)
    plate("Diagonal covering over right eye",[(.02,.90),(.4,.79),(.4,.32),(.14,.41)],-.37,.06,"brown",follower)
    plate("Fused glass blade held flat",[(-1.43,-1.98),(1.32,-1.82),(1.53,-1.97),(-1.45,-2.13)],-.62,.08,"steel",root)


def guard(root):
    older=human(root,"02 Line guard — 46",(-1.04,.39,.77),1.0,-21,style="crop",coat="olive",collar="steel",shape="long",age=46,gaze=-1)
    rod("Short mustache",(-.13,-.31,.26),(.12,-.31,.26),.028,"hair",older,vertices=5)
    young=human(root,"03 Young guard — 24",(1.28,.29,.11),.96,20,skin="skin_deep",style="coils",coat="olive",collar="steel",shape="oval",age=24,gaze=1,mood=2)
    ell("Soft patrol cap",(0,.015,1.0),(.43,.36,.15),"ink",young)
    box("Single ear protector",(.41,.04,.54),(.12,.20,.25),"steel",young)
    command=human(root,"01 Commander — 38",(-.34,-.58,-.53),1.28,12,skin="skin_fair",style="bob",coat="olive",collar="steel",shape="oval",age=38,gaze=-1,mood=-1)
    ell("Maintained open-face helmet",(0,.075,1.02),(.5,.4,.31),"olive",command,seg=12,rings=6)
    box("Helmet brow lip",(0,-.30,.89),(.83,.18,.08),"moss",command)
    for unit in (older,young,command):
        for z in (-.60,-.83,-1.06):
            box("Maintained segmented chest plate",(0,-.37,z),(.9,.10,.17),"olive",unit)
        strap(unit,-.47); strap(unit,.47)
    gun(root,"Lowered service rifle",(-.8,-.81,-1.93),(1.05,-.81,-1.50))
    plate("Compact riot shield edge",[(1.8,-.45),(2.15,-.60),(2.10,-2.08),(1.76,-1.91)],-.53,.14,"slate",root)
    for z in (-.89,-1.19,-1.49):
        box("Separated cream crowd tally",(1.92,-.62,z),(.2,.06,.084),"bone",root,bevel=.003)


def dog(parent,name,loc,size,yaw,kind):
    d=empty(name,loc,size,yaw,parent)
    coat={"shepherd":"slate","mastiff":"ochre","sighthound":"bone","cattle":"ink"}[kind]
    muzzle={"shepherd":(.24,.50,.2),"mastiff":(.36,.31,.21),"sighthound":(.16,.65,.13),"cattle":(.26,.37,.17)}[kind]
    ell("Shoulder front",(0,.2,-.59),(.58,.46,.65),coat,d)
    tube("Canine neck",[(0,.1,-.69),(0,.1,-.13),(0,.07,.30)],[.31,.28 if kind=="sighthound" else .38,.36],coat,d,sides=10)
    ell("Distinct canine skull",(0,0,.34),(.31 if kind=="sighthound" else .44,.39,.44),coat,d)
    ell("Long muzzle" if kind in ("shepherd","sighthound") else "Broad muzzle",(0,-.42,.15),muzzle,"ash" if kind=="shepherd" else ("brown" if kind=="mastiff" else coat),d)
    tip_y=-.42-muzzle[1]
    ell("Black canine nose",(0,tip_y,.18),(.14 if kind!="sighthound" else .09,.1,.09),"ink",d,seg=8,rings=6)
    for s in (-1,1):
        ell("Focused canine eye",(s*.26,-.326,.43),(.067,.03,.048),"ochre",d,seg=8,rings=6)
        ell("Dark canine pupil",(s*.26,-.353,.43),(.024,.009,.039),"ink",d,seg=8,rings=6)
        if kind in ("shepherd","cattle"):
            ztip=1.16 if kind=="shepherd" else (1.02 if s<0 else .75)
            plate("Unequal triangular ear",[(s*.17,.60),(s*.34,ztip),(s*.52,.60)],.06,.19,coat,d)
            plate("Ear inner plane",[(s*.23,.66),(s*.34,ztip-.11),(s*.44,.65)],.045,.025,"brown",d)
        else:
            tube("Folded canine ear",[(s*.27,.07,.63),(s*.48,.03,.54),(s*.43,-.05,.33 if kind=="mastiff" else .61)], [.15,.13,.06],coat,d,sides=6)
        if kind=="cattle":
            ell("Broad rust cheek",(s*.29,-.24,.13),(.16,.19,.16),"rust",d)
    tube("Closed mouth line",[(-muzzle[0]*.88,-.44,.02),(0,tip_y+.05,-.02),(muzzle[0]*.88,-.44,.02)],[.017]*3,"ink",d,sides=5)
    if kind!="shepherd":
        for s in (-1,1) if kind=="mastiff" else (1,):
            rod("Restrained snarl tooth",(s*muzzle[0]*.6,tip_y+.12,.035),(s*muzzle[0]*.6,tip_y+.12,-.075),.043,"bone",d,vertices=5,tip=.005)
    else:
        rod("Dry healed muzzle mark",(-.13,tip_y+.1,.24),(.04,tip_y+.1,.13),.033,"ash",d,vertices=5)
    if kind=="sighthound":
        tube("Only collar in the pack",[(0,.1,-.4),(0,.1,-.27)],[.32,.32],"brown",d,sides=10)
        box("Worn blank collar tag",(0,-.25,-.39),(.15,.055,.15),"steel",d)
    return d


def dogs(root):
    dog(root,"02 Tan mastiff",(-1.04,.29,.73),1.15,-12,"mastiff")
    dog(root,"03 Pale collared sighthound",(1.08,.31,.76),1.08,12,"sighthound")
    dog(root,"01 Still gray shepherd",(-.55,-.5,-.63),1.27,-9,"shepherd")
    dog(root,"04 Black and rust cattle dog",(1.08,-.38,-.79),.98,-22,"cattle")
    root["subject_count"]=4
    root["signature"]="Four distinct dogs; only the pale sighthound wears a collar; shepherd mouth stays closed"


BUILDERS={"enemy_stalker":stalker,"enemy_warden":warden,"enemy_leeches":leeches,"enemy_crows":crows,
    "enemy_drones":drones,"enemy_bandits":bandits,"enemy_toll":toll,"enemy_raiders":raiders,
    "enemy_scavs":scavs,"enemy_hunters":hunters,"enemy_cult":cult,"enemy_guard":guard,"enemy_dogs":dogs}
HUMAN_SIGNATURES={
    "enemy_bandits":(4,"Child-sized patterned backpack straps on copper-haired leader"),
    "enemy_toll":(3,"Empty clipboard spring clip worn as invented rank"),
    "enemy_raiders":(2,"Weathered red-haired woman beside long-black-haired masked man"),
    "enemy_scavs":(4,"Role tape; resting weapons; electrician forelock and mechanic bun"),
    "enemy_hunters":(2,"Partner-directed five-digit stop hand, bound gear and green cheek wear"),
    "enemy_cult":(5,"Five separate pilgrims, averted gaze, asymmetric solar-film veil"),
    "enemy_guard":(3,"Maintained standardized armor and three separated shield tallies"),
}


def build(enemy_id, render=True):
    root=init_scene(enemy_id)
    BUILDERS[enemy_id](root)
    if enemy_id in HUMAN_SIGNATURES:
        root["subject_count"],root["signature"]=HUMAN_SIGNATURES[enemy_id]
    # Ready-to-open camera view with uncluttered material preview.
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    bpy.context.view_layer.objects.active=root
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=="VIEW_3D":
                area.spaces.active.region_3d.view_perspective="CAMERA"
                area.spaces.active.shading.type="MATERIAL"
    SCENE.render.filepath=str(OUT / "renders" / (enemy_id+"_render.png"))
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT / (enemy_id+".blend")),compress=True)
    if render:
        bpy.ops.render.render(write_still=True)
    return {"id":enemy_id,"subjects":root["subject_count"],"signature":root["signature"],
            "objects":len(SCENE.objects),"meshes":sum(o.type=="MESH" for o in SCENE.objects),
            "blend":enemy_id+".blend","render":"renders/"+enemy_id+"_render.png",
            "brief":SCENE["source_brief"],"override":SCENE.get("source_override", ""),
            "rigged":False,"type":"posed 3D portrait sculpture","visual_approval":"pending user review"}


def main():
    args=sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    parser=argparse.ArgumentParser()
    parser.add_argument("--ids",default="all")
    parser.add_argument("--no-render",action="store_true")
    opts=parser.parse_args(args)
    ids=list(BUILDERS) if opts.ids=="all" else opts.ids.split(",")
    if any(i not in BUILDERS for i in ids):
        parser.error("Unknown enemy ID")
    (OUT / "renders").mkdir(parents=True,exist_ok=True)
    bpy.context.preferences.filepaths.save_version=0
    records=[]
    for enemy_id in ids:
        random.seed(enemy_id)
        print("BUILDING "+enemy_id,flush=True)
        records.append(build(enemy_id,not opts.no_render))
        print("COMPLETED "+enemy_id,flush=True)
    manifest_path=OUT / "manifest.json"
    previous=json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    previous.update({r["id"]:r for r in records})
    manifest_path.write_text(json.dumps(previous,indent=2)+"\n",encoding="utf-8")
    print("Completed %d editable Blender scenes" % len(records),flush=True)


if __name__=="__main__":
    main()
