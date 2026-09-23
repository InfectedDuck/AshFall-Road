class_name IconMeter
extends HBoxContainer

const UiIconWidget = preload("res://scripts/ui/ui_icon.gd")

func configure(
	icon_count: int,
	fill_units: float,
	units_per_icon: float,
	filled_glyph: String,
	empty_glyph: String,
	active_color: Color,
	empty_color: Color,
	icon_size: int,
	tooltip_prefix: String,
	atlas_icon_id: String = ""
) -> void:
	for child: Node in get_children():
		child.queue_free()
	add_theme_constant_override("separation", 2)
	var safe_units := maxf(0.001, units_per_icon)
	for index in range(maxi(0, icon_count)):
		var ratio := clampf((fill_units - float(index) * safe_units) / safe_units, 0.0, 1.0)
		var icon := Control.new()
		icon.custom_minimum_size = Vector2(icon_size + 2, icon_size + 4)
		icon.set_meta("fill_ratio", ratio)
		icon.tooltip_text = "%s %d: %d%%" % [tooltip_prefix, index + 1, roundi(ratio * 100.0)]

		var empty_mark: Control = _atlas_icon(atlas_icon_id, empty_color, icon_size) if atlas_icon_id != "" else _glyph_label(empty_glyph, empty_color, icon_size)
		empty_mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.add_child(empty_mark)

		if ratio > 0.0:
			var clip := Control.new()
			clip.clip_contents = true
			clip.position = Vector2.ZERO
			clip.size = Vector2(float(icon_size + 2) * ratio, icon_size + 4)
			var filled_mark: Control = _atlas_icon(atlas_icon_id, active_color, icon_size) if atlas_icon_id != "" else _glyph_label(filled_glyph, active_color, icon_size)
			filled_mark.position = Vector2.ZERO
			filled_mark.size = Vector2(icon_size + 2, icon_size + 4)
			clip.add_child(filled_mark)
			icon.add_child(clip)
		add_child(icon)


func fill_ratios() -> Array[float]:
	var ratios: Array[float] = []
	for child: Node in get_children():
		ratios.append(float(child.get_meta("fill_ratio", 0.0)))
	return ratios


func _glyph_label(glyph: String, color: Color, icon_size: int) -> Label:
	var label := Label.new()
	label.text = glyph
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", icon_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _atlas_icon(atlas_icon_id: String, color: Color, icon_size: int) -> Control:
	var icon := UiIconWidget.new()
	icon.configure(atlas_icon_id, icon_size, color)
	return icon
