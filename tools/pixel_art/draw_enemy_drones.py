"""Security Drones portrait, authored directly on a 64x64 grid from the
ENEMY_PORTRAIT_PROMPTS_V4 brief (section 2, prompt 9).

Each unit is drawn upright on its own layer, tilted with a row or column
shear so pixel rows stay intact, then composited back to front. Every colour
is a named palette entry, so the result never needs quantizing.

Outputs: enemy_drones_64.png (runtime candidate), enemy_drones_source.png
(16x nearest-neighbour source), enemy_drones_preview_6x.png, and a 50px
thumbnail test enlarged 8x."""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
OUT.mkdir(parents=True, exist_ok=True)

W = H = 64
P = {
    "bg": (0x20, 0x27, 0x2B),
    "ink": (0x15, 0x19, 0x1B),      # selective dark outline
    "char": (0x2E, 0x32, 0x36),     # dead disk hull, darkest metal
    "char2": (0x3B, 0x40, 0x45),    # cage ribs, fan shrouds, lift blocks
    "soot": (0x4C, 0x51, 0x55),     # patrol housing
    "soot2": (0x62, 0x68, 0x6D),    # patrol lit panel
    "steel": (0x5D, 0x6D, 0x73),    # oxidized steel
    "steel2": (0x82, 0x92, 0x97),   # steel highlight
    "pale": (0xAC, 0xB7, 0xBB),     # pale replacement steel
    "cream": (0xC9, 0xBF, 0xA3),    # dirty parchment
    "cream2": (0xA5, 0x9B, 0x82),
    "ochre": (0xB1, 0x89, 0x3B),
    "ochre2": (0x7E, 0x61, 0x29),
    "brass": (0x9E, 0x7D, 0x3F),
    "rust": (0x9C, 0x4F, 0x23),
    "rust2": (0x69, 0x34, 0x17),
    "red": (0xC0, 0x39, 0x2B),      # the only red: patrol lens
    "glass": (0x0F, 0x14, 0x16),    # dark glass sensors
    "glass2": (0x36, 0x4A, 0x4F),   # glass reflection
}
assert len(P) <= 20
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

    def arc(self, x0, y0, x1, y1, start, end, fill, width=1):
        self.d.arc([x0, y0, x1, y1], start, end, fill=fill, width=width)

    def poly(self, pts, fill, outline=None):
        self.d.polygon(pts, fill=fill, outline=outline)

    def shear_rows(self, degrees, base_y):
        """Lean the layer: rows above base_y slide right for a clockwise tilt."""
        k = math.tan(math.radians(degrees))
        out = Image.new("RGBA", (W, H), CLEAR)
        for y in range(H):
            dx = round(-k * (y - base_y))
            out.paste(self.im.crop((0, y, W, y + 1)), (dx, y))
        self.im = out

    def shear_cols(self, degrees, base_x):
        """Tilt the layer: columns right of base_x rise for a counterclockwise tilt."""
        k = math.tan(math.radians(degrees))
        out = Image.new("RGBA", (W, H), CLEAR)
        for x in range(W):
            dy = round(-k * (x - base_x))
            out.paste(self.im.crop((x, 0, x + 1, H)), (x, dy))
        self.im = out

    def blit(self, canvas):
        canvas.paste(self.im, (0, 0), self.im)


canvas = Image.new("RGBA", (W, H), P["bg"] + (255,))

# ---------------------------------------------------------------- UNIT 2
# Inspection drone, high-left: thin upright oxidized steel, leaning left so
# its tall dark-glass lens looks past the viewer. The only wandering gaze.
L = Layer()
L.rect(6, 7, 11, 12, P["char2"], P["ink"])            # compact lift duct behind the upper end
L.px(7, 8, P["soot2"])
L.rect(11, 5, 17, 28, P["steel"], P["ink"])           # body
L.rect(16, 6, 16, 27, P["steel2"])                    # lit right edge
L.px(16, 6, P["rust"]); L.px(15, 5, P["rust"])        # rust rim light
L.rect(12, 21, 16, 24, P["rust"])                     # rusty repair band around the lower third
L.rect(12, 24, 16, 24, P["rust2"])
L.px(11, 22, P["rust2"]); L.px(17, 22, P["rust2"])    # band wraps the edges
L.rect(12, 7, 16, 19, P["ink"])                       # lens housing
L.rect(13, 8, 15, 18, P["glass"])                     # tall vertical dark-glass lens
L.rect(13, 9, 13, 12, P["glass2"])                    # reflection sits to one side: attention wanders
L.px(12, 6, P["ink"]); L.px(16, 27, P["ink"])         # bolts
L.shear_rows(-12, base_y=28)                          # lean left
L.blit(canvas)

# ---------------------------------------------------------------- UNIT 3
# Utility drone, high-right: round faded ochre housing inside three charcoal
# cage ribs, two short lift pods, one pale replacement rib section, and the
# broad carrying fork that supports the dead alarm disk beneath it.
L = Layer()
L.rect(39, 11, 43, 16, P["soot"], P["ink"])           # left lift pod
L.rect(57, 11, 61, 16, P["soot"], P["ink"])           # right lift pod
L.px(40, 12, P["soot2"]); L.px(58, 12, P["soot2"])
L.ellipse(43, 6, 57, 20, fill=P["ochre2"], outline=P["ink"])   # housing, shadow side
L.ellipse(45, 7, 56, 17, fill=P["ochre"])                       # lit face, upper right
L.px(55, 8, P["rust"]); L.px(56, 9, P["rust"])                  # rust rim light
L.arc(44, 7, 50, 19, 90, 270, P["char"], width=2)              # rib 1: left meridian
L.arc(50, 7, 56, 19, 270, 90, P["char"], width=2)              # rib 2: right meridian
L.arc(43, 11, 57, 19, 0, 180, P["char"], width=2)              # rib 3: low equator
L.rect(54, 10, 56, 12, P["pale"], P["ink"])                     # square replacement section on rib 2
L.rect(48, 10, 52, 13, P["ink"])                                # recessed rectangular sensor
L.rect(49, 11, 51, 12, P["glass"])
L.px(49, 11, P["glass2"])
L.rect(44, 19, 46, 30, P["steel"], P["ink"])                    # fork stem from the lower left
L.px(45, 21, P["steel2"])
L.rect(44, 29, 62, 32, P["steel"], P["ink"])                    # broad flat fork bar
L.rect(45, 30, 61, 30, P["steel2"])                             # lit top of the bar
L.rect(61, 26, 62, 32, P["steel"], P["ink"])                    # upturned tine end
L.blit(canvas)

# ---------------------------------------------------------------- UNIT 4
# Dead alarm disk, mid-right: flat charcoal-black, warped rust-brown rim,
# broken beacon stump, blank sensor slot, the only hazard band. No light,
# no fan, and a background gap keeps its hull separate from the fork.
L = Layer()
L.ellipse(48, 21, 60, 27, fill=P["char"], outline=P["rust2"])   # disk with rust rim
L.px(60, 23, P["rust"]); L.px(61, 24, P["rust"]); L.px(59, 22, P["rust"])   # warped rim bulge
L.px(49, 26, P["rust"]); L.px(48, 24, P["rust"])
L.rect(53, 17, 55, 20, P["char2"], P["ink"])                    # beacon stump
L.px(53, 17, CLEAR); L.px(54, 17, P["ink"])                     # broken, jagged top
for i, x in enumerate(range(50, 59)):                           # two-colour hazard band, this disk only
    L.px(x, 25, P["ochre"] if (i // 2) % 2 == 0 else P["char2"])
L.rect(50, 22, 54, 24, P["ink"])                                # blank sensor slot, completely dark
L.rect(51, 23, 53, 23, P["glass"])
L.blit(canvas)

# ---------------------------------------------------------------- UNIT 1
# Patrol drone, large, below centre, tilted slightly counterclockwise. Wide
# soot-gray housing, heavy blunt front, red sensor offset left, cracked
# grille right, two square-shrouded fans, crushed left corner, cream
# replacement panel, blank brass nameplate.
L = Layer()
for fx in (23, 42):                                             # two square-shrouded lift fans
    L.rect(fx, 34, fx + 7, 40, P["char2"], P["ink"])
    L.rect(fx + 1, 35, fx + 6, 39, P["steel"])
    for dx, dy in ((1, 35), (2, 36), (5, 38), (6, 39), (6, 35), (5, 36), (2, 38), (1, 39)):
        L.px(fx + dx, dy, P["ink"])                             # blade diagonals
    L.rect(fx + 3, 37, fx + 4, 37, P["glass"])                  # hub
    L.px(fx + 4, 36, P["steel2"])
L.poly([(21, 57), (21, 44), (23, 42), (26, 40), (52, 40), (52, 57)], P["soot"], P["ink"])   # body, crushed corner
L.rect(22, 45, 30, 51, P["soot2"])                              # lighter mismatched panel, left
L.line(22, 44, 25, 41, P["ink"])                                # crush creases
L.line(23, 46, 26, 43, P["char2"])
L.rect(21, 54, 52, 56, P["char2"])                              # heavy blunt front band
L.rect(21, 57, 52, 57, P["ink"])
L.rect(32, 41, 45, 45, P["cream"], P["ink"])                    # dirty cream replacement panel on top
L.rect(33, 44, 44, 44, P["cream2"])
L.px(33, 42, P["ink"]); L.px(44, 42, P["ink"])                  # panel bolts
L.line(31, 46, 31, 53, P["ink"])                                # panel seam
L.px(31, 47, P["steel2"]); L.px(31, 51, P["steel2"])            # seam bolts
L.ellipse(22, 44, 29, 51, fill=P["ink"])                        # sensor ring
L.ellipse(23, 45, 28, 50, fill=P["red"])                        # the one red lens, offset left
L.px(25, 46, P["cream"])                                        # catchlight
L.rect(37, 46, 47, 51, P["soot2"], P["ink"])                    # speaker grille
L.rect(38, 48, 46, 48, P["ink"]); L.rect(38, 50, 46, 50, P["ink"])   # slits
L.line(41, 46, 43, 51, P["ink"])                                # the crack
L.px(42, 49, P["char"])
L.rect(40, 52, 47, 53, P["brass"])                              # brass nameplate, scraped blank
L.px(42, 52, P["steel2"]); L.px(45, 53, P["steel2"])            # scrape marks
L.rect(46, 40, 51, 40, P["rust"]); L.rect(52, 41, 52, 46, P["rust"])   # rust rim light, top right
L.shear_cols(4, base_x=36)                                      # counterclockwise tilt
L.blit(canvas)

# ---------------------------------------------------------------- UNIT 5
# Emitter drone, low-left: dirty-cream triangular hub, three blunt steel
# prongs (the right one broken short), a small dark sensor between them,
# rear lift block cropped by the frame. Tilted clockwise.
L = Layer()
L.rect(-4, 49, 4, 60, P["char2"], P["ink"])                     # rear lift block, cropped at the left edge
L.px(1, 50, P["soot2"])
L.rect(3, 35, 5, 39, P["steel"])                                # prong 1, full length, up
L.rect(3, 35, 3, 39, P["ink"]); L.rect(3, 35, 5, 35, P["ink"])
L.rect(7, 57, 9, 62, P["steel"])                                # prong 3, full length, down
L.rect(7, 57, 7, 62, P["ink"]); L.rect(7, 62, 9, 62, P["ink"])
L.poly([(4, 40), (16, 47), (8, 57)], P["cream"], P["ink"])      # triangular hub
L.poly([(5, 42), (9, 46), (8, 55)], P["cream2"])                # shadow wedge
L.rect(17, 46, 18, 48, P["steel"])                              # prong 2, broken short, right
L.px(18, 46, P["ink"]); L.px(18, 48, P["ink"])                  # jagged old break, dry and inert
L.px(12, 45, P["rust"]); L.px(14, 46, P["rust"])                # rust rim light
L.rect(8, 46, 11, 49, P["ink"])                                 # recessed dark sensor between the prongs
L.rect(9, 47, 10, 48, P["glass"])
L.px(9, 47, P["glass2"])
L.px(6, 42, P["ink"]); L.px(12, 50, P["ink"])                   # bolts
L.shear_rows(10, base_y=50)                                     # clockwise tilt
L.blit(canvas)

# ---------------------------------------------------------------- checks
img = canvas.convert("RGB")
used = {c for _, c in img.getcolors(4096)}
unknown = used - set(P.values())
assert not unknown, f"off-palette colours: {unknown}"
for corner in [(0, 0), (63, 0), (0, 63), (63, 63)]:
    assert img.getpixel(corner) == P["bg"], f"corner {corner} is not background"
print(f"{len(used)} colours used; corners flat #20272B")

img.save(OUT / "enemy_drones_64.png")
img.resize((1024, 1024), Image.NEAREST).save(OUT / "enemy_drones_source.png")
img.resize((384, 384), Image.NEAREST).save(OUT / "enemy_drones_preview_6x.png")
img.resize((50, 50), Image.NEAREST).resize((400, 400), Image.NEAREST).save(OUT / "enemy_drones_thumb50_8x.png")
print("written to", OUT)
