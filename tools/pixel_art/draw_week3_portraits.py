"""Week 3 portrait batch: survivor_4, enemy_bandits, enemy_crows, enemy_warden.

Hand-authored on the 64x64 grid in the enemy_drones.py style: one Layer per
subject, row/column shears instead of rotation so pixel rows stay intact, a
named palette of at most 20 entries per portrait, flat #20272B corners.

Outputs (OUT defaults to assets/portraits): <id>.png, 64x64 runtime sprites.
Crows follow ENEMY_CROWS_GENERATION (seven birds, ring pull in the lead beak);
bandits follow ENEMY_PORTRAIT_PROMPTS_V4 (three figures, leader plus cap plus
quilted vest); the Warden follows ENEMY_DESIGN_BIBLE (a door that grew armor).
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("assets/portraits")
OUT.mkdir(parents=True, exist_ok=True)

W = H = 64
BG = (0x20, 0x27, 0x2B)
INK = (0x15, 0x19, 0x1B)
CLEAR = (0, 0, 0, 0)


class Layer:
    def __init__(self):
        self.im = Image.new("RGBA", (W, H), CLEAR)
        self.d = ImageDraw.Draw(self.im)

    def rect(self, x0, y0, x1, y1, fill, outline=None):
        self.d.rectangle([x0, y0, x1, y1], fill=fill, outline=outline)

    def px(self, x, y, fill):
        self.d.point((x, y), fill=fill)

    def line(self, x0, y0, x1, y1, fill, width=1):
        self.d.line([(x0, y0), (x1, y1)], fill=fill, width=width)

    def ellipse(self, x0, y0, x1, y1, fill=None, outline=None, width=1):
        self.d.ellipse([x0, y0, x1, y1], fill=fill, outline=outline, width=width)

    def poly(self, pts, fill, outline=None):
        self.d.polygon(pts, fill=fill, outline=outline)

    def arc(self, x0, y0, x1, y1, start, end, fill, width=1):
        self.d.arc([x0, y0, x1, y1], start, end, fill=fill, width=width)

    def shear_rows(self, degrees, base_y):
        k = math.tan(math.radians(degrees))
        out = Image.new("RGBA", (W, H), CLEAR)
        for y in range(H):
            dx = round(-k * (y - base_y))
            out.paste(self.im.crop((0, y, W, y + 1)), (dx, y))
        self.im = out

    def blit(self, canvas):
        canvas.paste(self.im, (0, 0), self.im)


def finish(name, canvas, palette):
    img = canvas.convert("RGB")
    used = {c for _, c in img.getcolors(4096)}
    unknown = used - set(palette.values())
    assert not unknown, f"{name}: off-palette colours: {unknown}"
    assert len(used) <= 20, f"{name}: {len(used)} colours"
    for corner in [(0, 0), (63, 0), (0, 63), (63, 63)]:
        assert img.getpixel(corner) == BG, f"{name}: corner {corner} is not background"
    img.save(OUT / f"{name}.png")
    print(f"{name}.png: {len(used)} colours")


# ------------------------------------------------------- survivor_4: the quiet one
# A hooded fourth survivor: deep cowl, pale guarded face, grey-green wrap.
P = {
    "bg": BG, "ink": INK,
    "cowl": (0x2E, 0x35, 0x33), "cowl2": (0x3E, 0x47, 0x44),
    "wrap": (0x55, 0x5C, 0x50), "wrap2": (0x6B, 0x72, 0x66),
    "skin": (0xC9, 0xA2, 0x7A), "skin2": (0x8A, 0x66, 0x4A),
    "eye": (0x2A, 0x30, 0x2E), "steel": (0x5D, 0x6D, 0x73),
    "rust": (0x9C, 0x4F, 0x23), "strap": (0x4C, 0x3D, 0x2C),
}
canvas = Image.new("RGBA", (W, H), BG + (255,))
L = Layer()
L.poly([(14, 60), (16, 22), (32, 8), (48, 22), (50, 60)], P["cowl"], P["ink"])
L.poly([(22, 58), (24, 24), (32, 14), (40, 24), (42, 58)], P["cowl2"])
L.ellipse(22, 24, 42, 44, fill=P["ink"])                      # face opening shadow
L.ellipse(24, 27, 40, 42, fill=P["skin"])                     # guarded face
L.rect(25, 31, 29, 33, P["eye"]); L.rect(35, 31, 39, 33, P["eye"])
L.px(26, 31, P["steel"]); L.px(36, 31, P["steel"])            # catchlights
L.rect(28, 38, 36, 39, P["skin2"])                            # closed mouth
L.rect(14, 52, 50, 60, P["wrap"], P["ink"])                   # wrapped collar
L.line(14, 55, 50, 55, P["wrap2"])
L.rect(20, 44, 44, 50, P["strap"], P["ink"])                  # satchel strap
L.px(48, 20, P["rust"]); L.px(49, 21, P["rust"])              # rust rim light
L.shear_rows(3, base_y=60)
L.blit(canvas)
finish("survivor_4", canvas, P)

# ------------------------------------------------------- enemy_bandits: three across
# Copper-red-haired leader centre, capped lookout left, quilted archer right
# with a short bow diagonal.
P = {
    "bg": BG, "ink": INK,
    "skin": (0xC9, 0xA2, 0x7A), "skin2": (0x8A, 0x66, 0x4A),
    "skin3": (0x6B, 0x4A, 0x34), "hair": (0x7A, 0x3B, 0x22),
    "cap": (0x4A, 0x4E, 0x44), "vest": (0x5C, 0x54, 0x3E),
    "coat": (0x3E, 0x44, 0x4A), "scarf": (0x9C, 0x4F, 0x23),
    "bow": (0x6E, 0x58, 0x38), "eye": (0x1E, 0x22, 0x24),
    "steel": (0x8A, 0x96, 0x9B),
}
canvas = Image.new("RGBA", (W, H), BG + (255,))
L = Layer()  # lookout, left, cap pulled low
L.rect(4, 26, 16, 30, P["cap"], P["ink"])
L.rect(4, 28, 16, 28, P["skin3"])
L.rect(6, 30, 14, 40, P["skin3"])
L.rect(7, 33, 9, 34, P["eye"]); L.rect(11, 33, 13, 34, P["eye"])
L.rect(3, 40, 17, 60, P["coat"], P["ink"])
L.blit(canvas)
L = Layer()  # leader, centre, copper-red hair and rust scarf
L.poly([(24, 18), (30, 12), (36, 18), (36, 30), (24, 30)], P["hair"], P["ink"])
L.rect(25, 20, 35, 32, P["skin"])
L.rect(26, 24, 29, 26, P["eye"]); L.rect(31, 24, 34, 26, P["eye"])
L.rect(27, 29, 33, 30, P["skin2"])
L.rect(22, 32, 38, 37, P["scarf"], P["ink"])                  # scarf knot
L.rect(28, 37, 32, 44, P["scarf"])
L.rect(20, 37, 40, 60, P["vest"], P["ink"])
L.line(20, 44, 40, 44, P["ink"])
L.blit(canvas)
L = Layer()  # archer, right, quilted vest and short bow diagonal
L.rect(46, 24, 56, 26, P["cap"], P["ink"])
L.rect(47, 26, 55, 36, P["skin2"])
L.rect(48, 29, 50, 30, P["eye"]); L.rect(52, 29, 54, 30, P["eye"])
L.rect(44, 36, 58, 60, P["vest"], P["ink"])
L.line(45, 42, 57, 42, P["ink"]); L.line(45, 50, 57, 50, P["ink"])
L.line(58, 14, 62, 52, P["bow"], width=2)                     # bow stave
L.line(58, 14, 62, 52, P["steel"])                            # string glint
L.shear_rows(-4, base_y=60)
L.blit(canvas)
finish("enemy_bandits", canvas, P)

# ------------------------------------------------------- enemy_crows: seven birds
# One large foreground crow with milky sealed left eye and ring pull, three
# mid birds, three distant silhouettes. Bare skin, finger-like spars.
P = {
    "bg": BG, "ink": INK,
    "hide": (0x3A, 0x36, 0x38), "hide2": (0x55, 0x4E, 0x52),
    "spar": (0x2A, 0x26, 0x2A), "beak": (0x6E, 0x62, 0x52),
    "milk": (0xB9, 0xB4, 0xA4), "eyegood": (0x8A, 0x1E, 0x1E),
    "ring": (0xC9, 0xB4, 0x5A), "far": (0x2E, 0x32, 0x36),
}
canvas = Image.new("RGBA", (W, H), BG + (255,))


def bird(layer, x, y, s, lead=False):
    d = layer.d
    d.ellipse([x, y, x + 3 * s, y + 2 * s], fill=P["hide"], outline=P["ink"])
    d.ellipse([x + s, y - s, x + 2 * s, y], fill=P["hide"], outline=P["ink"])
    d.polygon([(x + 2 * s, y - s), (x + 3 * s, y - s // 2), (x + 2 * s, y)], fill=P["beak"], outline=P["ink"])
    for i in range(3):  # finger-like wing spars, fanned
        d.line([(x, y + s), (x - s - i, y + 2 * s + i)], fill=P["spar"], width=max(1, s // 3))
    if lead:
        d.ellipse([x + s, y - s, x + s + s // 2, y - s // 2], fill=P["milk"], outline=P["ink"])
        d.point((x + 2 * s - 1, y - s // 2), fill=P["eyegood"])
        d.rectangle([x + 2 * s, y - s // 2, x + 2 * s + 2, y], fill=P["ring"])  # the ring pull


L = Layer()  # three distant silhouettes
for (x, y, s) in ((8, 8, 2), (50, 6, 2), (30, 50, 2)):
    L.ellipse(x, y, x + 3 * s, y + 2 * s, fill=P["far"], outline=P["ink"])
L.blit(canvas)
L = Layer()  # three mid birds
bird(L, 6, 30, 3); bird(L, 44, 28, 3); bird(L, 30, 12, 3)
L.blit(canvas)
L = Layer()  # the lead crow, large: hooked beak, milky eye, ring pull
L.poly([(16, 38), (4, 44), (15, 47)], P["hide"], P["ink"])   # tail wedge
L.ellipse(14, 34, 40, 50, fill=P["hide"], outline=P["ink"])   # body
L.ellipse(16, 36, 34, 46, fill=P["hide2"])                    # lit breast
L.arc(18, 34, 38, 48, 200, 340, P["spar"], width=2)           # folded wing
L.line(20, 44, 12, 50, P["spar"], width=2)                    # primary spars
L.line(24, 45, 17, 51, P["spar"], width=2)
L.ellipse(31, 23, 46, 38, fill=P["hide"], outline=P["ink"])   # head
L.poly([(44, 27), (55, 31), (44, 35)], P["beak"], P["ink"])   # hooked beak
L.px(50, 32, P["ink"])                                        # hook notch
L.rect(35, 27, 39, 31, P["milk"], P["ink"])                   # sealed milky eye
L.rect(52, 30, 54, 32, P["ring"])                             # the ring pull
L.px(53, 30, P["milk"])                                       # glint
L.blit(canvas)
finish("enemy_crows", canvas, P)

# ------------------------------------------------------- enemy_warden: the door armoured
# Broad blast-door chassis, central red lens, cannon barrel, riveted plates,
# rust rim light. Insignificance by scale: it fills the frame.
P = {
    "bg": BG, "ink": INK,
    "hull": (0x3B, 0x40, 0x45), "hull2": (0x55, 0x60, 0x66),
    "plate": (0x2E, 0x32, 0x36), "steel": (0x82, 0x92, 0x97),
    "lens": (0xC0, 0x39, 0x2B), "lens2": (0xE8, 0x8A, 0x6A),
    "glass": (0x0F, 0x14, 0x16), "brass": (0x9E, 0x7D, 0x3F),
    "rust": (0x9C, 0x4F, 0x23), "rust2": (0x69, 0x34, 0x17),
    "haz": (0xB1, 0x89, 0x3B),
}
canvas = Image.new("RGBA", (W, H), BG + (255,))
L = Layer()
L.rect(10, 8, 54, 58, P["hull"], P["ink"])                    # door chassis
L.rect(10, 8, 54, 12, P["hull2"])                             # lit crown
L.rect(14, 16, 24, 54, P["plate"], P["ink"])                  # left armour slab
L.rect(40, 16, 50, 54, P["plate"], P["ink"])                  # right armour slab
for (rx, ry) in ((16, 18), (22, 18), (16, 52), (22, 52), (42, 18), (48, 18), (42, 52), (48, 52)):
    L.px(rx, ry, P["steel"])                                   # rivets
L.rect(27, 24, 37, 34, P["ink"])                              # lens housing
L.ellipse(28, 25, 36, 33, fill=P["lens"])                     # the one red lens
L.px(30, 27, P["lens2"])                                      # catchlight
L.rect(29, 36, 35, 58, P["glass"], P["ink"])                  # cannon barrel below the eye
L.rect(30, 56, 34, 58, P["brass"])                            # muzzle ring
for i, x in enumerate(range(12, 52)):                         # hazard band, low
    L.px(x, 60, P["haz"] if (i // 3) % 2 == 0 else P["plate"])
L.rect(52, 10, 54, 14, P["rust"]); L.rect(52, 14, 54, 20, P["rust2"])
L.blit(canvas)
finish("enemy_warden", canvas, P)
print("done")
