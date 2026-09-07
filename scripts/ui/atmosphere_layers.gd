class_name AtmosphereLayers
extends Control

## The canvas builds every screen out of the same stack over the region backdrop:
## a scrim to hold the prose, firelight from the bottom edge, a vignette, and a
## breath of grain. Each layer is weak on its own — the canvas caps grain at 6% —
## and screens differ only in how hard they lean on each one.

const GRAIN_TEXTURE_SIZE := 192

## Per-screen mixes, lifted from the artboards. Missing keys mean "layer off".
const PRESETS := {
	"title": {"scrim": 0.45, "vignette": 0.50, "grain": 0.05},
	"survivor": {"vignette": 0.45, "firelight": 0.10, "grain": 0.05},
	"event": {"scrim": 0.72, "vignette": 0.50, "firelight": 0.12, "grain": 0.05},
	"reveal": {"scrim": 0.86, "vignette": 0.60, "bloom": 0.10, "grain": 0.05},
	"combat": {"scrim": 0.72, "vignette": 0.50, "grain": 0.05},
	"inventory": {"vignette": 0.45, "grain": 0.05},
	"checkpoint": {"scrim": 0.55, "vignette": 0.45, "firelight": 0.22, "grain": 0.06},
	"death": {"vignette": 0.60, "grain": 0.04},
	"plain": {"grain": 0.05},
}

var scrim: ColorRect
var bloom: TextureRect
var firelight: TextureRect
var vignette: TextureRect
var grain: TextureRect

var _palette: Dictionary = {}
var _preset := "plain"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if scrim == null:
		_build_layers()


func configure(palette: Dictionary, preset: String = "plain") -> void:
	_palette = palette
	_preset = preset if PRESETS.has(preset) else "plain"
	if scrim == null:
		_build_layers()
	_apply()


func preset_name() -> String:
	return _preset


func mix() -> Dictionary:
	return PRESETS.get(_preset, PRESETS["plain"])


## Firelight is warmer than the accent it sits beside: the canvas paints the fire
## a red-orange, so pull the theme accent toward its own danger tone.
static func ember_color(palette: Dictionary) -> Color:
	var accent: Color = palette["accent"]
	return accent.lerp(palette["danger"], 0.45)


func _build_layers() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	scrim = ColorRect.new()
	scrim.name = "Scrim"
	_stretch(scrim)
	add_child(scrim)

	bloom = TextureRect.new()
	bloom.name = "Bloom"
	bloom.texture = _radial_texture(Color.WHITE, 0.0, 0.40)
	_stretch(bloom)
	add_child(bloom)

	firelight = TextureRect.new()
	firelight.name = "Firelight"
	firelight.texture = _vertical_texture()
	_stretch(firelight)
	add_child(firelight)

	vignette = TextureRect.new()
	vignette.name = "Vignette"
	vignette.texture = _radial_texture(Color.BLACK, 0.5, 1.0)
	_stretch(vignette)
	add_child(vignette)

	grain = TextureRect.new()
	grain.name = "Grain"
	grain.texture = _grain_texture()
	grain.stretch_mode = TextureRect.STRETCH_TILE
	_stretch(grain)
	add_child(grain)


func _apply() -> void:
	var settings := mix()
	var scrim_color: Color = _palette.get("surface_overlay", Color("#0b1415b8"))
	scrim_color.a = float(settings.get("scrim", 0.0))
	scrim.color = scrim_color
	scrim.visible = scrim_color.a > 0.0

	bloom.modulate = Color(_palette.get("accent", Color.WHITE), float(settings.get("bloom", 0.0)))
	bloom.visible = bloom.modulate.a > 0.0

	firelight.modulate = Color(ember_color(_palette), float(settings.get("firelight", 0.0)))
	firelight.visible = firelight.modulate.a > 0.0

	vignette.modulate = Color(1.0, 1.0, 1.0, float(settings.get("vignette", 0.0)))
	vignette.visible = vignette.modulate.a > 0.0

	grain.modulate = Color(1.0, 1.0, 1.0, float(settings.get("grain", 0.0)))
	grain.visible = grain.modulate.a > 0.0


func _stretch(node: Control) -> void:
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Transparent at the centre, `edge_alpha` at the corners — the canvas vignette.
## Reused inverted for the reveal screen's accent bloom.
func _radial_texture(tone: Color, centre_alpha: float, edge_alpha: float) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_offset(0, 0.45)
	gradient.set_color(0, Color(tone, centre_alpha))
	gradient.set_offset(1, 1.0)
	gradient.set_color(1, Color(tone, edge_alpha))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256
	return texture


## Full strength along the bottom edge, gone by 70% of the way up.
func _vertical_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_offset(0, 0.0)
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_offset(1, 0.7)
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 1.0)
	texture.fill_to = Vector2(0.5, 0.0)
	texture.width = 8
	texture.height = 256
	return texture


func _grain_texture() -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	# Value noise near the Nyquist limit gives per-pixel film grain; lower
	# frequencies read as cloud and start competing with the vignette.
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 1.9
	noise.seed = 41
	var texture := NoiseTexture2D.new()
	texture.width = GRAIN_TEXTURE_SIZE
	texture.height = GRAIN_TEXTURE_SIZE
	texture.seamless = true
	texture.noise = noise
	return texture
