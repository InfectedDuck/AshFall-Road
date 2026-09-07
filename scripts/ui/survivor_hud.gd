class_name SurvivorHud
extends PanelContainer

const IconMeterWidget = preload("res://scripts/ui/icon_meter.gd")
const StatsCapsuleWidget = preload("res://scripts/ui/stats_capsule.gd")
const PortraitArtWidget = preload("res://scripts/ui/portrait_art.gd")
const ExperienceRules = preload("res://scripts/domain/experience_rules.gd")
const UiTypeScript = preload("res://scripts/ui/ui_type.gd")

signal inventory_requested
signal settings_requested
signal stats_requested
signal conditions_requested

## Canvas HUD icon sizes: four to seven hearts and four meals have to sit on one
## row beside the stat pill inside a 353pt content width.
const HEART_ICON_SIZE := 14
const MEAL_ICON_SIZE := 12


func configure(survivor: Dictionary, palette: Dictionary, font_scale: float = 1.0, _show_stats: bool = false, progression: Dictionary = {}, show_utilities: bool = true) -> void:
	var accent: Color = palette["accent"]
	var danger: Color = palette["danger"]
	var muted: Color = palette["muted"]
	for child: Node in get_children():
		child.queue_free()
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 5)
	add_child(outer)

	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 8)
	outer.add_child(identity)
	var utility_slot := HBoxContainer.new()
	var portrait := PanelContainer.new()
	portrait.name = "SurvivorPortraitFrame"
	portrait.custom_minimum_size = Vector2(64, 64)
	var portrait_view := PortraitArtWidget.create_view(str(survivor.get("portrait_id", "survivor")), muted, int(8 * font_scale))
	portrait_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.add_child(portrait_view)
	identity.add_child(portrait)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 0)
	identity.add_child(details)
	var name_label := Label.new()
	name_label.text = "%s  \"%s\"" % [survivor.get("name", "Survivor"), survivor.get("callsign", "")]
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.clip_text = true
	UiTypeScript.apply(name_label, "title", font_scale)
	name_label.add_theme_color_override("font_color", accent)
	details.add_child(name_label)
	if not progression.is_empty():
		var level_label := Label.new()
		var unspent := int(progression.get("unspent_stat_points", 0))
		var xp_progress := ExperienceRules.progress(int(progression.get("experience", 0)))
		level_label.text = "LEVEL %d  •  XP MAX" % int(xp_progress["level"]) if bool(xp_progress["at_max_level"]) else "LEVEL %d  •  %d / %d XP" % [int(xp_progress["level"]), int(xp_progress["experience"]), int(xp_progress["next_threshold"])]
		level_label.add_theme_font_size_override("font_size", int(9 * font_scale))
		level_label.add_theme_color_override("font_color", accent if unspent > 0 else muted)
		details.add_child(level_label)
		var xp_bar := ProgressBar.new()
		xp_bar.name = "ExperienceBar"
		xp_bar.custom_minimum_size = Vector2(0, 4)
		xp_bar.max_value = maxf(1.0, float(xp_progress["level_span"]))
		xp_bar.value = float(xp_progress["into_level"])
		xp_bar.show_percentage = false
		var xp_background := StyleBoxFlat.new()
		xp_background.bg_color = palette["meter_track"]
		var xp_fill := xp_background.duplicate()
		xp_fill.bg_color = accent
		xp_bar.add_theme_stylebox_override("background", xp_background)
		xp_bar.add_theme_stylebox_override("fill", xp_fill)
		details.add_child(xp_bar)
		if unspent > 0:
			var point_label := Label.new()
			point_label.text = "%d STAT POINT%s READY" % [unspent, "" if unspent == 1 else "S"]
			point_label.add_theme_font_size_override("font_size", int(9 * font_scale))
			point_label.add_theme_color_override("font_color", accent)
			details.add_child(point_label)

	var information := HBoxContainer.new()
	information.add_theme_constant_override("separation", 5)
	outer.add_child(information)
	var vitals_block := VBoxContainer.new()
	vitals_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vitals_block.add_theme_constant_override("separation", 0)
	information.add_child(vitals_block)
	var vitals: Dictionary = survivor.get("vitals", {})
	var health := int(vitals.get("health", 0))
	var maximum := maxi(1, int(vitals.get("max_health", 1)))
	var hearts := int(vitals.get("max_hearts", ceili(float(maximum) / 50.0)))
	var heart_row := HBoxContainer.new()
	heart_row.add_theme_constant_override("separation", 2)
	var heart_meter = IconMeterWidget.new()
	heart_meter.name = "HeartMeter"
	heart_meter.configure(hearts, health, 50.0, "♥", "♡", danger, muted, int(HEART_ICON_SIZE * font_scale), "Heart")
	heart_row.add_child(heart_meter)
	var hp_label := Label.new()
	hp_label.text = " %d / %d" % [health, maximum]
	UiTypeScript.apply(hp_label, "caption", font_scale)
	hp_label.add_theme_color_override("font_color", palette["icon_ink"])
	heart_row.add_child(hp_label)
	vitals_block.add_child(heart_row)

	var meal_row := HBoxContainer.new()
	meal_row.add_theme_constant_override("separation", 3)
	var meal_title := Label.new()
	meal_title.text = "FOOD"
	meal_title.add_theme_font_size_override("font_size", int(9 * font_scale))
	meal_title.add_theme_color_override("font_color", muted)
	meal_row.add_child(meal_title)
	var satiety := int(vitals.get("satiety", 0))
	var food_meter = IconMeterWidget.new()
	food_meter.name = "FoodMeter"
	food_meter.configure(4, satiety, 1.0, "◆", "◇", accent, muted, int(MEAL_ICON_SIZE * font_scale), "Meal reserve")
	meal_row.add_child(food_meter)
	vitals_block.add_child(meal_row)

	var capsule = StatsCapsuleWidget.new()
	capsule.name = "StatsCapsule"
	capsule.configure(survivor.get("stats", {}), palette, font_scale, int(progression.get("unspent_stat_points", 0)))
	capsule.details_requested.connect(func() -> void: stats_requested.emit())
	information.add_child(capsule)

	if show_utilities:
		utility_slot.add_child(_utility_button("⚙", "Open settings", settings_requested.emit, font_scale))
		identity.add_child(utility_slot)


func make_inventory_link(font_scale: float = 1.0) -> Button:
	var button := Button.new()
	button.text = "▣  INVENTORY"
	button.tooltip_text = "Open inventory"
	button.accessibility_name = "Open inventory"
	button.custom_minimum_size = Vector2(126, 44)
	button.add_theme_font_size_override("font_size", int(11 * font_scale))
	button.pressed.connect(inventory_requested.emit)
	return button


func make_conditions_link(condition_count: int, font_scale: float = 1.0) -> Button:
	var button := Button.new()
	button.name = "ConditionsLink"
	button.text = "◇  STATUS  %d" % condition_count
	button.tooltip_text = "Review helpful and harmful conditions"
	button.accessibility_name = "Open survivor status. %d active conditions" % condition_count
	button.custom_minimum_size = Vector2(126, 44)
	button.add_theme_font_size_override("font_size", int(11 * font_scale))
	button.pressed.connect(conditions_requested.emit)
	return button


func _utility_button(glyph: String, description: String, callback: Callable, font_scale: float) -> Button:
	var button := Button.new()
	button.text = glyph
	button.tooltip_text = description
	button.accessibility_name = description
	button.custom_minimum_size = Vector2(44, 44)
	button.add_theme_font_size_override("font_size", int(18 * font_scale))
	button.pressed.connect(callback)
	return button
