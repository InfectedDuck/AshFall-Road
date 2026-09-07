class_name PressureStrip
extends PanelContainer

const UiTypeScript = preload("res://scripts/ui/ui_type.gd")

var meter_track := Color("#252b2e")


func configure(pressures: Dictionary, palette: Dictionary, font_scale: float) -> void:
	var fatigue_color: Color = palette["fatigue"]
	var radiation_color: Color = palette["radiation"]
	var danger: Color = palette["danger"]
	var muted: Color = palette["muted"]
	meter_track = palette["meter_track"]
	var panel := StyleBoxFlat.new()
	panel.bg_color = palette["surface"]
	panel.content_margin_left = 8
	panel.content_margin_right = 8
	panel.content_margin_top = 4
	panel.content_margin_bottom = 4
	add_theme_stylebox_override("panel", panel)
	for child: Node in get_children():
		child.queue_free()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)
	_add_pressure(row, "◉", "FATIGUE", int(pressures.get("fatigue", 0)), fatigue_color, danger, muted, font_scale)
	_add_pressure(row, "☢", "RADIATION", int(pressures.get("radiation", 0)), radiation_color, danger, muted, font_scale)


func _add_pressure(parent: HBoxContainer, glyph: String, title: String, value: int, normal_color: Color, danger: Color, muted: Color, font_scale: float) -> void:
	var group := VBoxContainer.new()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 3)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 5)
	group.add_child(heading)
	var icon := Label.new()
	icon.text = glyph
	icon.add_theme_font_size_override("font_size", int(14 * font_scale))
	icon.add_theme_color_override("font_color", danger if value >= 75 else normal_color)
	heading.add_child(icon)
	var label := Label.new()
	label.text = "%s  %d" % [title, value]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiTypeScript.apply(label, "caption", font_scale)
	label.add_theme_color_override("font_color", danger if value >= 75 else muted)
	heading.add_child(label)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = value
	# The canvas runs these pressure meters as 3px rules, not capsules.
	bar.custom_minimum_size = Vector2(10, 3)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("background", _meter_box(meter_track))
	bar.add_theme_stylebox_override("fill", _meter_box(danger if value >= 75 else normal_color))
	group.add_child(bar)
	parent.add_child(group)


func _meter_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	return box
