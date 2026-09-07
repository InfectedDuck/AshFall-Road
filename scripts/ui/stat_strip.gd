class_name StatStrip
extends PanelContainer

const STAT_GLYPHS := {
	"strength": "STR",
	"agility": "AGI",
	"wits": "WIT",
	"grit": "GRT",
	"presence": "PRE",
}


func configure(stats: Dictionary, accent: Color, muted: Color, font_scale: float, unspent_points: int = 0) -> void:
	for child: Node in get_children():
		child.queue_free()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	add_child(row)
	for stat: String in STAT_GLYPHS:
		var badge := VBoxContainer.new()
		badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		badge.add_theme_constant_override("separation", 0)
		var glyph := Label.new()
		glyph.text = STAT_GLYPHS[stat]
		glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		glyph.add_theme_font_size_override("font_size", int(9 * font_scale))
		glyph.add_theme_color_override("font_color", accent if unspent_points > 0 else muted)
		badge.add_child(glyph)
		var value := Label.new()
		value.text = str(int(stats.get(stat, 0)))
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.add_theme_font_size_override("font_size", int(15 * font_scale))
		value.add_theme_color_override("font_color", accent)
		badge.add_child(value)
		row.add_child(badge)
