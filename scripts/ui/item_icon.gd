class_name ItemIcon
extends Control

var icon_id := ""
var category := "utility"
var accent := Color.WHITE
var muted := Color.GRAY
var icon_ink := Color("#c9bfae")
var plate_ink := Color("#111d1e")
var loaded_texture: Texture2D

const PLACEHOLDER_SYMBOLS := {
	"item_scrap_buckler": "▽", "item_road_shield": "⬡",
	"item_salvage_cleaver": "╱", "item_pipe_pistol": "⌐", "item_shock_probe": "ϟ", "item_wrecking_bar": "┼", "item_holdout_revolver": "◎", "item_rusted_hatchet": "⌑", "item_rebar_spear": "△", "item_nail_bat": "╳", "item_hunting_rifle": "╤", "item_scrap_shotgun": "╫", "item_stun_baton": "│", "item_flare_gun": "⌒",
	"item_scrap_vest": "▰", "item_runner_jacket": "▱", "item_plated_coat": "▣", "item_dust_cloak": "◇", "item_tire_armor": "◒", "item_riot_padding": "⊞", "item_hazmat_wrap": "▧", "item_scout_leathers": "◈",
	"item_field_scanner": "◌", "item_trader_token": "○", "item_lucky_die": "⚄", "item_filter_mask": "◍", "item_signal_compass": "⌖", "item_mechanic_gloves": "✥",
	"item_canvas_pack": "▥", "item_frame_pack": "▤", "item_medic_satchel": "▦", "item_scavenger_rig": "▩",
	"item_canned_meat": "●", "item_clean_water": "◐", "item_cloth_bandage": "≋", "item_medkit": "⊕", "item_rad_tabs": "☷", "item_stimulant": "▯", "item_ration_bar": "▬", "item_bitter_tonic": "≀", "item_purifier_ampoule": "⎈", "item_painkillers": "◓", "item_glow_moss": "✹", "item_smoke_bomb": "☁",
	"item_pistol_rounds": "¦", "item_revolver_rounds": "∶", "item_rifle_rounds": "⋮", "item_shotgun_shells": "⌇", "item_scrap_parts": "∷", "item_climbing_rope": "┄",
}


func _ready() -> void:
	custom_minimum_size = Vector2(42, 42)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configure(requested_icon_id: String, requested_category: String, palette: Dictionary) -> void:
	icon_id = requested_icon_id
	category = requested_category
	accent = palette["accent"]
	muted = palette["muted"]
	icon_ink = palette["icon_ink"]
	plate_ink = palette["surface"]
	var texture_path := "res://assets/items/%s.png" % icon_id
	loaded_texture = load(texture_path) if ResourceLoader.exists(texture_path) else null
	queue_redraw()


static func placeholder_symbol(requested_icon_id: String) -> String:
	return str(PLACEHOLDER_SYMBOLS.get(requested_icon_id, ""))


func _draw() -> void:
	var bounds := Rect2(Vector2(5, 5), size - Vector2(10, 10))
	if loaded_texture != null:
		draw_texture_rect(loaded_texture, bounds, false)
		return
	var center := size * 0.5
	var color := accent
	match category:
		"weapon":
			draw_line(Vector2(10, size.y - 9), Vector2(size.x - 9, 9), color, 5.0)
			draw_line(Vector2(11, size.y - 15), Vector2(17, size.y - 9), muted, 3.0)
		"armor":
			draw_colored_polygon(PackedVector2Array([Vector2(center.x, 7), Vector2(size.x - 8, 14), Vector2(size.x - 12, size.y - 9), Vector2(center.x, size.y - 5), Vector2(12, size.y - 9), Vector2(8, 14)]), color)
			draw_line(Vector2(center.x, 11), Vector2(center.x, size.y - 10), muted, 2.0)
		"accessory":
			draw_circle(center, minf(size.x, size.y) * 0.27, color, false, 5.0)
			draw_circle(center, 3.0, muted)
		"backpack":
			draw_rect(Rect2(Vector2(11, 13), size - Vector2(22, 21)), color, true)
			draw_arc(Vector2(center.x, 14), 8.0, PI, TAU, 12, muted, 3.0)
			draw_line(Vector2(16, center.y), Vector2(size.x - 16, center.y), muted, 2.0)
		"consumable":
			draw_rect(Rect2(Vector2(center.x - 9, 14), Vector2(18, size.y - 22)), color, true)
			draw_rect(Rect2(Vector2(center.x - 5, 8), Vector2(10, 7)), muted, true)
		"ammunition":
			for offset in [-8, 0, 8]:
				draw_rect(Rect2(Vector2(center.x + offset - 3, 12), Vector2(6, size.y - 22)), color, true)
				draw_circle(Vector2(center.x + offset, 12), 3.0, muted)
		"weight":
			draw_arc(Vector2(center.x, 14), 7.0, PI, TAU, 12, color, 4.0)
			draw_colored_polygon(PackedVector2Array([Vector2(12, 18), Vector2(size.x - 12, 18), Vector2(size.x - 8, size.y - 8), Vector2(8, size.y - 8)]), color)
		_:
			draw_circle(center, minf(size.x, size.y) * 0.28, color)
			draw_line(Vector2(center.x - 9, center.y + 9), Vector2(center.x + 9, center.y - 9), muted, 4.0)
	var symbol := placeholder_symbol(icon_id)
	if not symbol.is_empty():
		var font := ThemeDB.fallback_font
		var symbol_size := font.get_string_size(symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		# icon_ink is the light stroke the canvas draws icons in; on a bright fill
		# the symbol flips to the surface tone instead to stay readable.
		draw_string(font, Vector2(center.x - symbol_size.x * 0.5, center.y + 4), symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, plate_ink if color.get_luminance() > 0.45 else icon_ink)
