class_name StatsCapsule
extends Button

const UiTypeScript = preload("res://scripts/ui/ui_type.gd")

signal details_requested

const STAT_ORDER := ["strength", "agility", "wits", "grit", "presence"]
const STAT_SYMBOLS := {
	"strength": "✦",
	"agility": "⌁",
	"wits": "◈",
	"grit": "◆",
	"presence": "◎",
}


func _ready() -> void:
	pressed.connect(func() -> void: details_requested.emit())


func configure(stats: Dictionary, palette: Dictionary, font_scale: float, unspent_points: int = 0) -> void:
	var accent: Color = palette["accent"]
	var muted: Color = palette["muted"]
	for child: Node in get_children():
		child.queue_free()
	text = ""
	# The canvas stat pill is five badges and a chevron in a 36pt-tall rounded
	# row; 130 is the narrowest that keeps every value legible at artboard width.
	custom_minimum_size = Vector2(130, 44)
	tooltip_text = "Open stat explanations"
	accessibility_name = _accessibility_text(stats, unspent_points)
	var normal := StyleBoxFlat.new()
	normal.bg_color = palette["surface_raised"]
	normal.border_color = palette["border_subtle"]
	normal.set_border_width_all(1)
	normal.content_margin_left = 4
	normal.content_margin_right = 4
	normal.content_margin_top = 3
	normal.content_margin_bottom = 3
	add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.border_color = palette["accent"]
	hover.bg_color = palette["surface_raised"]
	add_theme_stylebox_override("hover", hover)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4)
	row.add_theme_constant_override("separation", 1)
	for stat: String in STAT_ORDER:
		var badge := VBoxContainer.new()
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		badge.add_theme_constant_override("separation", -2)
		var symbol := Label.new()
		symbol.text = stat_symbol(stat)
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		symbol.add_theme_font_size_override("font_size", int(11 * font_scale))
		symbol.add_theme_color_override("font_color", accent if unspent_points > 0 else muted)
		badge.add_child(symbol)
		var value := Label.new()
		value.text = str(int(stats.get(stat, 0)))
		value.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiTypeScript.apply(value, "body", font_scale)
		value.add_theme_color_override("font_color", accent)
		badge.add_child(value)
		row.add_child(badge)
	add_child(row)


static func stat_symbol(stat: String) -> String:
	return str(STAT_SYMBOLS.get(stat, "•"))


static func stat_symbols() -> Dictionary:
	return STAT_SYMBOLS.duplicate()


func _accessibility_text(stats: Dictionary, unspent_points: int) -> String:
	var parts: Array[String] = ["Open stat explanations"]
	for stat: String in STAT_ORDER:
		parts.append("%s %d" % [stat.capitalize(), int(stats.get(stat, 0))])
	if unspent_points > 0:
		parts.append("%d unspent point%s" % [unspent_points, "" if unspent_points == 1 else "s"])
	return ". ".join(parts)
