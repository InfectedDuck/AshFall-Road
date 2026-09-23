class_name UiIcon
extends Control

## Generated UI marks live in one small 4 by 4 pixel-art atlas. Keeping their
## stable names here lets controls retain readable text and accessibility names
## while the visual mark can change independently.
const ATLAS_PATH := "res://assets/ui/ui_symbols_v1.png"
const ATLAS_COLUMNS := 4
const ATLAS_ROWS := 4
const SYMBOLS := {
	"health": Vector2i(0, 0),
	"food": Vector2i(1, 0),
	"fatigue": Vector2i(2, 0),
	"radiation": Vector2i(3, 0),
	"strength": Vector2i(0, 1),
	"agility": Vector2i(1, 1),
	"wits": Vector2i(2, 1),
	"grit": Vector2i(3, 1),
	"presence": Vector2i(0, 2),
	"navigation": Vector2i(1, 2),
	"chronicle": Vector2i(2, 2),
	"settings": Vector2i(3, 2),
	"inventory": Vector2i(0, 3),
	"status": Vector2i(1, 3),
	"rest": Vector2i(2, 3),
	"press_on": Vector2i(3, 3),
}

var icon_id := ""
var icon_tint := Color.WHITE
var atlas_texture: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func configure(requested_icon_id: String, requested_size: int, requested_tint: Color = Color.WHITE) -> void:
	icon_id = requested_icon_id
	icon_tint = requested_tint
	custom_minimum_size = Vector2(maxi(1, requested_size), maxi(1, requested_size))
	atlas_texture = load(ATLAS_PATH) as Texture2D
	queue_redraw()


func _draw() -> void:
	if atlas_texture == null or not SYMBOLS.has(icon_id):
		return
	var atlas_size := atlas_texture.get_size()
	var cell_size := Vector2(atlas_size.x / ATLAS_COLUMNS, atlas_size.y / ATLAS_ROWS)
	var cell: Vector2i = SYMBOLS[icon_id]
	var source := Rect2(Vector2(cell.x * cell_size.x, cell.y * cell_size.y), cell_size)
	draw_texture_rect_region(atlas_texture, Rect2(Vector2.ZERO, size), source, icon_tint)


static func symbol_ids() -> Dictionary:
	return SYMBOLS.duplicate()
