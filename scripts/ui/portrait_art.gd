class_name PortraitArt
extends RefCounted

const PORTRAIT_DIRECTORY := "res://assets/portraits"
const SURVIVOR_IDS := ["survivor_1", "survivor_2", "survivor_3", "survivor_4"]
const ENEMY_IDS := [
	"enemy_bandits",
	"enemy_dogs",
	"enemy_stalker",
	"enemy_toll",
	"enemy_leeches",
	"enemy_raiders",
	"enemy_drones",
	"enemy_scavs",
	"enemy_cult",
	"enemy_hunters",
	"enemy_guard",
	"enemy_warden",
	"enemy_crows",
]


static func expected_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.append_array(SURVIVOR_IDS)
	ids.append_array(ENEMY_IDS)
	return ids


static func texture_path(portrait_id: String) -> String:
	var normalized := portrait_id.strip_edges()
	if normalized.is_empty() or normalized.contains("/") or normalized.contains("\\") or normalized.contains(".."):
		return ""
	var final_path := "%s/%s.png" % [PORTRAIT_DIRECTORY, normalized]
	if ResourceLoader.exists(final_path):
		return final_path
	# A same-ID SVG may provide an intentionally temporary in-game portrait.
	# The final PNG always wins as soon as it is added, so no gameplay or save ID
	# changes are required when placeholder art is replaced.
	var placeholder_path := "%s/%s.svg" % [PORTRAIT_DIRECTORY, normalized]
	if ResourceLoader.exists(placeholder_path):
		return placeholder_path
	return final_path


static func load_texture(portrait_id: String) -> Texture2D:
	var path := texture_path(portrait_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := ResourceLoader.load(path)
	return resource as Texture2D


static func create_view(portrait_id: String, fallback_color: Color, fallback_font_size: int = 9) -> Control:
	var view := Control.new()
	view.name = "PortraitArt"
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.clip_contents = true
	view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var texture := load_texture(portrait_id)
	if texture != null:
		var image := TextureRect.new()
		image.name = "PortraitTexture"
		image.texture = texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		view.add_child(image)
		return view

	var fallback := Label.new()
	fallback.name = "PortraitFallback"
	fallback.text = "PORTRAIT\n%s" % portrait_id.trim_prefix("enemy_").trim_prefix("survivor_").to_upper()
	fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback.add_theme_font_size_override("font_size", fallback_font_size)
	fallback.add_theme_color_override("font_color", fallback_color)
	fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.add_child(fallback)
	return view
