class_name ItemIcon
extends Control

var icon_id := ""
var category := "utility"
var accent := Color.WHITE
var muted := Color.GRAY
var icon_ink := Color("#c9bfae")
var plate_ink := Color("#111d1e")
var loaded_texture: Texture2D
var atlas_texture: Texture2D
var atlas_columns := 0
var atlas_rows := 0

const ATLAS_CONFIG := {
	"weapons": ["res://assets/items/inventory_weapons_v1.png", 4, 3],
	"gear": ["res://assets/items/inventory_gear_v1.png", 4, 4],
	"supplies": ["res://assets/items/inventory_supplies_v1.png", 4, 3],
	"utilities": ["res://assets/items/inventory_utilities_v1.png", 4, 3],
}

## [atlas, column, row]. The source sheets are kept in the same reading order
## as items.json, so an ID always resolves to one distinct pictured object.
const ATLAS_ITEMS := {
	"item_salvage_cleaver": ["weapons", 0, 0], "item_pipe_pistol": ["weapons", 1, 0], "item_shock_probe": ["weapons", 2, 0], "item_wrecking_bar": ["weapons", 3, 0],
	"item_holdout_revolver": ["weapons", 0, 1], "item_rusted_hatchet": ["weapons", 1, 1], "item_rebar_spear": ["weapons", 2, 1], "item_nail_bat": ["weapons", 3, 1],
	"item_hunting_rifle": ["weapons", 0, 2], "item_scrap_shotgun": ["weapons", 1, 2], "item_stun_baton": ["weapons", 2, 2], "item_flare_gun": ["weapons", 3, 2],
	"item_scrap_vest": ["gear", 0, 0], "item_runner_jacket": ["gear", 1, 0], "item_plated_coat": ["gear", 2, 0], "item_dust_cloak": ["gear", 3, 0],
	"item_tire_armor": ["gear", 0, 1], "item_riot_padding": ["gear", 1, 1], "item_hazmat_wrap": ["gear", 2, 1], "item_scout_leathers": ["gear", 3, 1],
	"item_scrap_buckler": ["gear", 0, 2], "item_road_shield": ["gear", 1, 2], "item_field_scanner": ["gear", 2, 2], "item_trader_token": ["gear", 3, 2],
	"item_lucky_die": ["gear", 0, 3], "item_filter_mask": ["gear", 1, 3], "item_signal_compass": ["gear", 2, 3], "item_mechanic_gloves": ["gear", 3, 3],
	"item_canvas_pack": ["supplies", 0, 0], "item_frame_pack": ["supplies", 1, 0], "item_medic_satchel": ["supplies", 2, 0], "item_scavenger_rig": ["supplies", 3, 0],
	"item_canned_meat": ["supplies", 0, 1], "item_clean_water": ["supplies", 1, 1], "item_cloth_bandage": ["supplies", 2, 1], "item_medkit": ["supplies", 3, 1],
	"item_rad_tabs": ["supplies", 0, 2], "item_stimulant": ["supplies", 1, 2], "item_ration_bar": ["supplies", 2, 2], "item_bitter_tonic": ["supplies", 3, 2],
	"item_purifier_ampoule": ["utilities", 0, 0], "item_painkillers": ["utilities", 1, 0], "item_glow_moss": ["utilities", 2, 0], "item_smoke_bomb": ["utilities", 3, 0],
	"item_pistol_rounds": ["utilities", 0, 1], "item_revolver_rounds": ["utilities", 1, 1], "item_rifle_rounds": ["utilities", 2, 1], "item_shotgun_shells": ["utilities", 3, 1],
	"item_scrap_parts": ["utilities", 0, 2], "item_climbing_rope": ["utilities", 1, 2],
}

const PLACEHOLDER_SYMBOLS := {
	"item_scrap_buckler": "▽", "item_road_shield": "⬡",
	"item_salvage_cleaver": "╱", "item_pipe_pistol": "⌐", "item_shock_probe": "ϟ", "item_wrecking_bar": "┼", "item_holdout_revolver": "◎", "item_rusted_hatchet": "⌑", "item_rebar_spear": "△", "item_nail_bat": "╳", "item_hunting_rifle": "╤", "item_scrap_shotgun": "╫", "item_stun_baton": "│", "item_flare_gun": "⌒",
	"item_scrap_vest": "▰", "item_runner_jacket": "▱", "item_plated_coat": "▣", "item_dust_cloak": "◇", "item_tire_armor": "◒", "item_riot_padding": "⊞", "item_hazmat_wrap": "▧", "item_scout_leathers": "◈",
	"item_field_scanner": "◌", "item_trader_token": "○", "item_lucky_die": "⚄", "item_filter_mask": "◍", "item_signal_compass": "⌖", "item_mechanic_gloves": "✥",
	"item_canvas_pack": "▥", "item_frame_pack": "▤", "item_medic_satchel": "▦", "item_scavenger_rig": "▩",
	"item_canned_meat": "●", "item_clean_water": "◐", "item_cloth_bandage": "≋", "item_medkit": "⊕", "item_rad_tabs": "☷", "item_stimulant": "▯", "item_ration_bar": "▬", "item_bitter_tonic": "≀", "item_purifier_ampoule": "⎈", "item_painkillers": "◓", "item_glow_moss": "✹", "item_smoke_bomb": "☁",
	"item_pistol_rounds": "¦", "item_revolver_rounds": "∶", "item_rifle_rounds": "⋮", "item_shotgun_shells": "⌇", "item_scrap_parts": "∷", "item_climbing_rope": "┄",
	"item_rusted_machete": "▲", "item_bone_cleaver": "■", "item_kiln_sword": "◆", "item_nail_smg": "❖", "item_rail_spike_rifle": "★", "item_officer_revolver": "☆",
	"item_chain_wrench": "⛭", "item_slag_maul": "⬟", "item_wire_rifle": "⌁",
	"item_mutant_hide_vest": "♠", "item_kiln_plates": "♣", "item_stalker_cloak": "♦", "item_wolf_fang_charm": "⌘", "item_gunslinger_holster": "⌗", "item_sniper_scope": "⌙",
	"item_mutant_serum": "⌜", "item_purifier_poultice": "⌞", "item_choir_incense": "⌟",
	"item_dredge_chain": "⛓", "item_fan_guard": "◉", "item_brass_star": "✶", "item_stalkhide_wraps": "❋",
}


func _ready() -> void:
	custom_minimum_size = Vector2(42, 42)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func configure(requested_icon_id: String, requested_category: String, palette: Dictionary) -> void:
	icon_id = requested_icon_id
	category = requested_category
	accent = palette["accent"]
	muted = palette["muted"]
	icon_ink = palette["icon_ink"]
	plate_ink = palette["surface"]
	var texture_path := "res://assets/items/%s.png" % icon_id
	loaded_texture = load(texture_path) if ResourceLoader.exists(texture_path) else null
	var atlas_entry := _atlas_entry()
	if atlas_entry.is_empty():
		atlas_texture = null
		atlas_columns = 0
		atlas_rows = 0
	else:
		var atlas_data: Array = ATLAS_CONFIG[str(atlas_entry[0])]
		atlas_texture = load(str(atlas_data[0]))
		atlas_columns = int(atlas_data[1])
		atlas_rows = int(atlas_data[2])
	queue_redraw()


static func placeholder_symbol(requested_icon_id: String) -> String:
	return str(PLACEHOLDER_SYMBOLS.get(requested_icon_id, ""))


func _draw() -> void:
	var bounds := Rect2(Vector2(5, 5), size - Vector2(10, 10))
	if loaded_texture != null:
		draw_texture_rect(loaded_texture, bounds, false)
		return
	var atlas_cell := _atlas_cell()
	if atlas_texture != null and atlas_cell.x >= 0:
		var atlas_size := atlas_texture.get_size()
		var cell_size := Vector2(atlas_size.x / atlas_columns, atlas_size.y / atlas_rows)
		var source := Rect2(Vector2(atlas_cell.x * cell_size.x, atlas_cell.y * cell_size.y), cell_size)
		draw_texture_rect_region(atlas_texture, bounds, source)
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


## Dedicated individual PNGs still take priority. The generated sheets cover
## every current item ID; a future unknown ID falls back to its stable rune.
func _atlas_entry() -> Array:
	return ATLAS_ITEMS.get(icon_id, [])


func _atlas_cell() -> Vector2i:
	var entry := _atlas_entry()
	return Vector2i(int(entry[1]), int(entry[2])) if not entry.is_empty() else Vector2i(-1, -1)
