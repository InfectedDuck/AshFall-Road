class_name UiType
extends RefCounted

## The Ashfall Road canvas type scale. Two families carry the whole game: Literata
## for anything the survivor reads as prose, Inter for anything the interface says
## about itself. Roles are the contract — call sites ask for `eyebrow` or `prose`
## rather than picking a number, so a scale change lands everywhere at once.

const INTERFACE_FONT_PATH := "res://assets/fonts/Inter.ttf"
const NARRATIVE_FONT_PATH := "res://assets/fonts/Literata.ttf"

const INTERFACE := "interface"
const NARRATIVE := "narrative"

## size: design pixels at the canvas 393pt width.
## tracking: letter-spacing in em, exactly as the canvas specifies it.
const ROLES := {
	"display": {"size": 34, "family": INTERFACE, "tracking": 0.0},
	"heading": {"size": 28, "family": NARRATIVE, "tracking": 0.0},
	"numeric": {"size": 22, "family": INTERFACE, "tracking": 0.0},
	"lede": {"size": 20, "family": NARRATIVE, "tracking": 0.0},
	"prose": {"size": 17, "family": NARRATIVE, "tracking": 0.0},
	"title": {"size": 17, "family": INTERFACE, "tracking": 0.0},
	"flavour": {"size": 15, "family": NARRATIVE, "tracking": 0.0},
	"action": {"size": 15, "family": INTERFACE, "tracking": 0.14},
	"body": {"size": 13, "family": INTERFACE, "tracking": 0.0},
	"label": {"size": 12, "family": INTERFACE, "tracking": 0.14},
	"eyebrow": {"size": 11, "family": INTERFACE, "tracking": 0.22},
	"caption": {"size": 10, "family": INTERFACE, "tracking": 0.1},
	"wordmark": {"size": 30, "family": INTERFACE, "tracking": 0.42},
}

## Literata sets at 1.6 line height in the canvas; Godot expresses that as extra
## separation on top of the font's own ascent + descent.
const PROSE_LINE_SPACING_RATIO := 0.42

static var _font_cache: Dictionary = {}


static func size(role: String, font_scale: float = 1.0) -> int:
	return maxi(1, roundi(float(_role(role)["size"]) * font_scale))


static func family(role: String) -> String:
	return str(_role(role)["family"])


static func tracking_em(role: String) -> float:
	return float(_role(role)["tracking"])


## Letter-spacing in whole pixels for the rendered size, the unit Godot's glyph
## spacing takes. Tracked roles never round down to zero: losing the spacing turns
## an eyebrow back into ordinary small text.
static func tracking_px(role: String, font_scale: float = 1.0) -> int:
	var em := tracking_em(role)
	if is_zero_approx(em):
		return 0
	return maxi(1, roundi(em * float(size(role, font_scale))))


static func line_spacing(role: String, font_scale: float = 1.0) -> int:
	if family(role) != NARRATIVE:
		return 0
	return roundi(float(size(role, font_scale)) * PROSE_LINE_SPACING_RATIO)


static func base_font(role: String) -> Font:
	var path := NARRATIVE_FONT_PATH if family(role) == NARRATIVE else INTERFACE_FONT_PATH
	return load(path)


## The font a role renders in, tracking baked in. Untracked roles get the plain
## face back so the common path allocates nothing.
static func font(role: String, font_scale: float = 1.0) -> Font:
	var spacing := tracking_px(role, font_scale)
	var base := base_font(role)
	if spacing == 0:
		return base
	var key := "%s:%d" % [family(role), spacing]
	if not _font_cache.has(key):
		var variation := FontVariation.new()
		variation.base_font = base
		variation.set_spacing(TextServer.SPACING_GLYPH, spacing)
		_font_cache[key] = variation
	return _font_cache[key]


## Narrative roles are paragraphs and wrap; interface roles are single-line
## labels. Letting an eyebrow or a verdict wrap sets it one letter per line
## whenever it lands in a container that offers no width.
static func wraps(role: String) -> bool:
	return family(role) == NARRATIVE


## The scale factor that renders `role` at exactly `size` pixels. Lets a caller
## that fitted a size by measurement ask for the matching face, so tracking
## shrinks along with the lettering instead of staying at the nominal size.
static func scale_for_size(role: String, target_size: int) -> float:
	return float(target_size) / float(_role(role)["size"])


static func has_role(role: String) -> bool:
	return ROLES.has(role)


## Apply a role to any control that understands `font`/`font_size` overrides.
static func apply(control: Control, role: String, font_scale: float = 1.0, override: String = "font") -> void:
	control.add_theme_font_override(override, font(role, font_scale))
	control.add_theme_font_size_override("%s_size" % override, size(role, font_scale))


static func _role(role: String) -> Dictionary:
	return ROLES.get(role, ROLES["body"])
