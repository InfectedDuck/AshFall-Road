class_name DiceWidget
extends Control

const UiTypeScript = preload("res://scripts/ui/ui_type.gd")

## Canvas d20, drawn on the artboard's 100x100 grid: a hexagon silhouette, the
## near face as an inset triangle, and five spokes running out to the corners.
const OUTLINE := [
	Vector2(50, 4), Vector2(90, 27), Vector2(90, 73),
	Vector2(50, 96), Vector2(10, 73), Vector2(10, 27),
]
const FACE := [Vector2(50, 22), Vector2(76, 66), Vector2(24, 66)]
const SPOKES := [
	[Vector2(50, 4), Vector2(50, 22)],
	[Vector2(90, 27), Vector2(76, 66)],
	[Vector2(10, 27), Vector2(24, 66)],
	[Vector2(50, 96), Vector2(24, 66)],
	[Vector2(50, 96), Vector2(76, 66)],
]
const GRID := 100.0
## Stroke weights and the numeral's baseline, as fractions of the artboard grid.
const OUTLINE_WEIGHT := 1.2 / GRID
const FACE_WEIGHT := 0.9 / GRID
const NUMERAL_SIZE := 30.0 / GRID
const NUMERAL_BASELINE := 59.0 / GRID

var face := 0
var accent := Color("#d9a458")
var danger := Color("#d9695b")
var success := Color("#f2d27a")
var die_surface := Color("#1a2829")
var die_line := Color("#d9a458")
var prose := Color("#f4ebdd")
var number_label: Label


func _ready() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(126, 126)
	number_label = Label.new()
	number_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	number_label.add_theme_font_override("font", UiTypeScript.base_font("display"))
	add_child(number_label)
	resized.connect(_resize_numeral)
	_resize_numeral()
	set_face(face)


func set_palette(palette: Dictionary) -> void:
	accent = palette["accent"]
	danger = palette["danger"]
	success = palette["critical"]
	die_surface = palette["die_surface"]
	die_line = palette["die_line"]
	prose = palette["text"]
	set_face(face)
	queue_redraw()


func set_face(value: int) -> void:
	face = value
	if number_label != null:
		number_label.text = "?" if face <= 0 else str(face)
		# An ordinary roll reads as prose; only a 20 or a 1 colours the numeral,
		# which is what makes those two faces land without a word of explanation.
		number_label.add_theme_color_override("font_color", stroke_color() if _is_extreme() else prose)
	queue_redraw()


## The die's line colour for the current face: critical gold on a 20, danger on a
## 1, and the die_line ochre for everything in between.
func stroke_color() -> Color:
	if face == 20:
		return success
	if face == 1:
		return danger
	return die_line


func _is_extreme() -> bool:
	return face == 20 or face == 1


func _resize_numeral() -> void:
	if number_label == null:
		return
	number_label.add_theme_font_size_override("font_size", maxi(8, roundi(_span() * NUMERAL_SIZE)))
	# The canvas sets the numeral on the face's own centre line, which sits above
	# the die's midpoint. Nudge the label down by the same fraction.
	number_label.offset_top = _span() * (NUMERAL_BASELINE - 0.5)


func _span() -> float:
	return minf(size.x, size.y)


## Map a point on the artboard's 100x100 grid into the widget, keeping the die
## square and centred however the surrounding layout stretches.
func _place(point: Vector2) -> Vector2:
	var span := _span()
	return (size - Vector2(span, span)) * 0.5 + point / GRID * span


func _points(source: Array) -> PackedVector2Array:
	var mapped := PackedVector2Array()
	for point: Vector2 in source:
		mapped.append(_place(point))
	return mapped


func _draw() -> void:
	var span := _span()
	if span <= 0.0:
		return
	var line := stroke_color()
	# A 20 and a 1 both thicken the outline: the die itself reacts, not just the
	# number, so the result is legible before anyone reads the digits.
	var outline_weight := maxf(1.0, span * OUTLINE_WEIGHT * (1.6 if _is_extreme() else 1.0))
	var face_weight := maxf(1.0, span * FACE_WEIGHT * (1.4 if _is_extreme() else 1.0))
	var silhouette := _points(OUTLINE)
	draw_colored_polygon(silhouette, die_surface)
	draw_polyline(silhouette + PackedVector2Array([silhouette[0]]), line, outline_weight, true)
	var near_face := _points(FACE)
	draw_polyline(near_face + PackedVector2Array([near_face[0]]), line, face_weight, true)
	for spoke: Array in SPOKES:
		draw_line(_place(spoke[0]), _place(spoke[1]), line, face_weight, true)
