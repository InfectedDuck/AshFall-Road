extends Control

const SoundServiceScript = preload("res://scripts/services/sound_service.gd")

const COLOR_BG := Color("#0d1416")
const COLOR_PANEL := Color("#172124")
const COLOR_PANEL_ALT := Color("#202d2f")
const COLOR_TEXT := Color("#f0e5d2")
const COLOR_MUTED := Color("#adbaa9")
const COLOR_ACCENT := Color("#d39a4a")
const COLOR_DANGER := Color("#c45d4c")
const COLOR_SUCCESS := Color("#70a879")

var content: ContentRepository
var game: GameEngine
var saves: SaveService
var ads: AdService
var billing: BillingService
var sound: Node
var profile: Dictionary = {}
var entitlements: Dictionary = {}
var candidates: Array = []
var candidate_seed := 1

var background: TextureRect
var background_tint: ColorRect
var page: VBoxContainer
var inventory_popup: PopupPanel
var settings_popup: PopupPanel
var tutorial_popup: PopupPanel
var store_popup: PopupPanel
var toast_label: Label


func _ready() -> void:
	content = ContentRepository.new()
	saves = SaveService.new()
	game = GameEngine.new(content)
	profile = saves.load_profile()
	entitlements = saves.load_entitlements()
	ads = AdService.new()
	ads.configure(entitlements)
	billing = BillingService.new()
	billing.configure(entitlements)
	if str(profile.get("selected_theme", "default")) not in _available_themes():
		profile["selected_theme"] = "default"
		saves.save_profile(profile)
	sound = SoundServiceScript.new()
	add_child(sound)
	sound.configure(profile)
	_build_shell()
	var errors := content.validate_all()
	if not errors.is_empty():
		_show_content_error(errors)
		return
	var saved_run := saves.load_run()
	if not saved_run.is_empty():
		game.restore_run(saved_run)
		if str(game.run_state.get("phase", "")) in ["resolving", "death", "victory"]:
			call_deferred("_render_current")
			return
	_show_main_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_active_run()


func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	background_tint = ColorRect.new()
	background_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_tint.color = Color(0.025, 0.04, 0.045, 0.9)
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_tint)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	page = VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	toast_label = Label.new()
	toast_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	toast_label.position = Vector2(20, -76)
	toast_label.size = Vector2(500, 52)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.visible = false
	add_child(toast_label)
	_apply_theme()


func _apply_theme() -> void:
	var ui_theme := Theme.new()
	var font_scale := float(profile.get("font_scale", 1.0))
	var base_size := int(18 * font_scale)
	var high_contrast := bool(profile.get("high_contrast", false))
	var text_color := Color.WHITE if high_contrast else COLOR_TEXT
	var panel_color := Color("#050708") if high_contrast else COLOR_PANEL
	var accent := _accent_color()
	var panel_alt := _panel_alt_color()
	ui_theme.set_default_font_size(base_size)
	ui_theme.set_color("font_color", "Label", text_color)
	ui_theme.set_color("font_color", "Button", text_color)
	ui_theme.set_color("font_hover_color", "Button", Color.WHITE)
	ui_theme.set_font_size("font_size", "Button", base_size)
	ui_theme.set_font_size("font_size", "Label", base_size)
	ui_theme.set_font_size("font_size", "RichTextLabel", base_size)
	ui_theme.set_constant("outline_size", "Label", 2 if high_contrast else 0)
	ui_theme.set_color("font_outline_color", "Label", Color.BLACK)
	ui_theme.set_stylebox("normal", "Button", _style_box(panel_alt, accent, 10, 1))
	ui_theme.set_stylebox("hover", "Button", _style_box(panel_alt.lightened(0.12), accent.lightened(0.2), 10, 2))
	ui_theme.set_stylebox("pressed", "Button", _style_box(Color("#101719"), accent, 10, 2))
	ui_theme.set_stylebox("disabled", "Button", _style_box(Color("#151a1b"), Color("#3d494b"), 10, 1))
	ui_theme.set_color("font_disabled_color", "Button", Color("#687477"))
	ui_theme.set_stylebox("panel", "PanelContainer", _style_box(panel_color, Color("#39484a"), 12, 1))
	ui_theme.set_stylebox("panel", "PopupPanel", _style_box(panel_color, accent, 12, 2))
	theme = ui_theme
	var theme_name := str(profile.get("selected_theme", "default"))
	var tint := Color(0.02, 0.0, 0.0, 0.86) if theme_name == "rust" else Color(0.0, 0.015, 0.05, 0.88) if theme_name == "night" else Color(0.0, 0.0, 0.0, 0.86)
	background_tint.color = Color(tint.r, tint.g, tint.b, 0.94 if high_contrast else tint.a)


func _accent_color() -> Color:
	match str(profile.get("selected_theme", "default")):
		"rust": return Color("#e17843")
		"night": return Color("#7fb7da")
		_: return COLOR_ACCENT


func _panel_alt_color() -> Color:
	match str(profile.get("selected_theme", "default")):
		"rust": return Color("#38251f")
		"night": return Color("#18283a")
		_: return COLOR_PANEL_ALT


func _style_box(fill: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	return box


func _clear_page() -> void:
	for child: Node in page.get_children():
		page.remove_child(child)
		child.queue_free()
	background.texture = null


func _title(text: String, subtitle: String = "") -> void:
	var heading := _label(text, 34, _accent_color())
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(heading)
	if subtitle != "":
		var sub := _label(subtitle, 15, COLOR_MUTED)
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		page.add_child(sub)


func _label(text: String, size: int = 0, color: Color = COLOR_TEXT) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	if size > 0:
		label.add_theme_font_size_override("font_size", int(size * float(profile.get("font_scale", 1.0))))
	return label


func _button(text: String, callable: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 52
	button.disabled = disabled
	button.pressed.connect(func() -> void:
		if sound != null:
			sound.play_ui()
		callable.call()
	)
	return button


func _panel() -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	panel.add_child(body)
	page.add_child(panel)
	return body


func _show_main_menu() -> void:
	_clear_page()
	_title("ASHFALL ROAD", "A post-apocalyptic D20 journey")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(spacer)
	var intro := _panel()
	var intro_text := _label("Six regions stand between you and the East Citadel. Every risk is visible. Every death is final.", 19)
	intro_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_child(intro_text)
	if not game.run_state.is_empty() and str(game.run_state.get("status", "")) == "active":
		intro.add_child(_button("CONTINUE RUN", _render_current))
		var survivor: Dictionary = game.run_state.get("survivor", {})
		intro.add_child(_label("%s \"%s\" — Region %d of 6" % [survivor.get("name", "Survivor"), survivor.get("callsign", ""), int(game.run_state.get("region_index", 0)) + 1], 14, COLOR_MUTED))
	else:
		intro.add_child(_button("BEGIN NEW RUN", _begin_candidate_selection))
	intro.add_child(_button("SETTINGS", _show_settings))
	intro.add_child(_button("ABOUT & PRIVACY", _show_about))
	var stats_text := "%d runs  |  %d deaths  |  %d victories" % [profile.get("runs_started", 0), profile.get("deaths", 0), profile.get("victories", 0)]
	var stats := _label(stats_text, 14, COLOR_MUTED)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(stats)


func _begin_candidate_selection() -> void:
	candidate_seed = int(Time.get_unix_time_from_system()) + Time.get_ticks_msec()
	candidates = game.create_candidates(candidate_seed)
	_show_candidates()


func _show_candidates() -> void:
	_clear_page()
	_title("CHOOSE A SURVIVOR", "Each candidate has exactly 15 stat points")
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for index in range(candidates.size()):
		var candidate: Dictionary = candidates[index]
		var card := PanelContainer.new()
		var card_body := VBoxContainer.new()
		card_body.add_theme_constant_override("separation", 7)
		card.add_child(card_body)
		card_body.add_child(_label("%s \"%s\"" % [candidate["name"], candidate["callsign"]], 23, _accent_color()))
		var stat_parts: Array[String] = []
		for stat: String in GameEngine.STATS:
			stat_parts.append("%s %d" % [GameEngine.STAT_LABELS[stat].left(3).to_upper(), candidate["stats"][stat]])
		card_body.add_child(_label("  ".join(stat_parts), 14))
		var gear_names: Array[String] = []
		for item_id: String in candidate["inventory"]:
			if str(content.get_item(item_id).get("equipment_slot", "")) != "":
				gear_names.append(str(content.get_item(item_id).get("name", item_id)))
		card_body.add_child(_label("Starting gear: %s" % ", ".join(gear_names), 14, COLOR_MUTED))
		card_body.add_child(_button("CHOOSE %s" % candidate["callsign"].to_upper(), _select_candidate.bind(index)))
		list.add_child(card)
	page.add_child(_button("BACK", _show_main_menu))


func _select_candidate(index: int) -> void:
	if index < 0 or index >= candidates.size():
		return
	saves.clear_death_marker()
	game.start_run(candidates[index], candidate_seed + index * 37)
	profile["runs_started"] = int(profile.get("runs_started", 0)) + 1
	saves.save_profile(profile)
	ads.reset_for_run()
	_save_active_run()
	_render_current()
	if not bool(profile.get("tutorial_seen", false)):
		call_deferred("_show_first_run_tutorial")


func _render_current() -> void:
	if game.run_state.is_empty():
		_show_main_menu()
		return
	match str(game.run_state.get("phase", "event")):
		"event": _show_event()
		"resolving": _resume_prepared_resolution()
		"result": _show_result()
		"checkpoint": _show_checkpoint()
		"death": _finish_run(false)
		"victory": _finish_run(true)
		_: _show_event()


func _set_region_background() -> void:
	var region := game.current_region()
	var is_final := int(game.run_state.get("region_index", 0)) >= content.ordered_regions().size()
	var path := "res://assets/backgrounds/region_7_citadel.png" if is_final else str(region.get("background", ""))
	if path != "" and ResourceLoader.exists(path):
		background.texture = load(path)


func _show_event() -> void:
	_clear_page()
	_set_region_background()
	var region := game.current_region()
	var is_final := int(game.run_state.get("region_index", 0)) >= content.ordered_regions().size()
	var region_name := "EAST CITADEL" if is_final else str(region.get("name", "The Road"))
	var progress := "Final approach" if is_final else "Region %d / 6  •  Event %d / 5" % [int(game.run_state["region_index"]) + 1, int(game.run_state["events_in_region"]) + 1]
	_title(region_name, progress)
	_show_survival_strip()
	var event := game.current_event()
	var event_panel := _panel()
	event_panel.add_child(_label(str(event.get("title", "The Road")), 25, _accent_color()))
	var text_scroll := ScrollContainer.new()
	text_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_scroll.custom_minimum_size.y = 130
	var body := _label(str(event.get("body", "")), 18)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_scroll.add_child(body)
	event_panel.add_child(text_scroll)
	var choices: Array = event.get("choices", [])
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		var preview := game.get_choice_preview(choice)
		var button_text := str(choice.get("label", "Choose"))
		if preview.get("available", false):
			if int(preview.get("chance", -1)) >= 0:
				button_text += "\n%s • %d%%" % [preview.get("description", ""), preview.get("chance", 0)]
		else:
			button_text += "\nLOCKED: %s" % preview.get("reason", "Unavailable")
		var choice_button := _button(button_text, _resolve_choice.bind(index), not preview.get("available", false))
		choice_button.tooltip_text = str(preview.get("reason", ""))
		event_panel.add_child(choice_button)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 10)
	var inventory_button := _button("INVENTORY", _show_inventory)
	inventory_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(inventory_button)
	var settings_button := _button("SETTINGS", _show_settings)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(settings_button)
	page.add_child(nav)


func _show_survival_strip() -> void:
	var panel := PanelContainer.new()
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	panel.add_child(grid)
	var pressures: Dictionary = game.run_state["survivor"]["pressures"]
	for pressure: String in GameEngine.PRESSURES:
		var cell := VBoxContainer.new()
		var value := int(pressures[pressure])
		var display_value := value if pressure == "health" else 100 - value
		var caption := _label("%s\n%d" % [pressure.left(3).to_upper(), value], 12, _pressure_color(pressure, value))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(caption)
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.value = display_value
		bar.custom_minimum_size = Vector2(90, 8)
		cell.add_child(bar)
		grid.add_child(cell)
	page.add_child(panel)


func _pressure_color(pressure: String, value: int) -> Color:
	var dangerous := value <= 25 if pressure == "health" else value >= 75
	var warning := value <= 50 if pressure == "health" else value >= 50
	return COLOR_DANGER if dangerous else _accent_color() if warning else COLOR_SUCCESS


func _resolve_choice(index: int) -> void:
	var prepared := game.prepare_choice(index)
	if prepared.has("error"):
		_show_toast(str(prepared["error"]))
		return
	if not _save_active_run():
		game.run_state["phase"] = "event"
		game.run_state["pending_resolution"] = {}
		_show_toast("The roll was cancelled because the active run could not be saved.")
		return
	var result := game.resolve_prepared_choice()
	if result.has("error"):
		_show_toast(str(result["error"]))
		return
	_save_active_run()
	_play_resolution_feedback(result)
	if str(game.run_state.get("phase", "")) == "death":
		_finish_run(false)
	elif str(game.run_state.get("phase", "")) == "victory":
		_finish_run(true)
	else:
		_show_result()


func _resume_prepared_resolution() -> void:
	var result := game.resolve_prepared_choice()
	if result.has("error"):
		game.run_state["status"] = "dead"
		game.run_state["phase"] = "death"
		_finish_run(false)
		return
	_save_active_run()
	_play_resolution_feedback(result)
	_render_current()


func _play_resolution_feedback(result: Dictionary) -> void:
	var resolution: Dictionary = result.get("resolution", {})
	var outcome := str(resolution.get("outcome", "success"))
	if sound != null:
		sound.play_resolution(bool(resolution.get("succeeded", true)), outcome.begins_with("critical"))


func _show_result() -> void:
	_clear_page()
	_set_region_background()
	var result: Dictionary = game.run_state.get("last_result", {})
	_title("OUTCOME", str(result.get("event_title", "The road answers")))
	var body := _panel()
	var resolution: Dictionary = result.get("resolution", {})
	if int(resolution.get("roll", 0)) > 0:
		var outcome := str(resolution.get("outcome", "failure"))
		var outcome_color := COLOR_SUCCESS if "success" in outcome else COLOR_DANGER
		var dice := _label("D20: %d" % resolution.get("roll", 0), 46, outcome_color)
		dice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(dice)
		if not bool(profile.get("reduced_motion", false)):
			call_deferred("_animate_dice", dice)
		var outcome_label := outcome.replace("_", " ").to_upper()
		var math_text := "%s  •  Total %d vs DC %d" % [outcome_label, resolution.get("total", 0), resolution.get("dc", 0)]
		var math_label := _label(math_text, 17, outcome_color)
		math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(math_label)
		var breakdown_parts: Array[String] = []
		for modifier: Dictionary in resolution.get("breakdown", []):
			breakdown_parts.append("%s %+d" % [modifier.get("label", "Modifier"), modifier.get("value", 0)])
		body.add_child(_label(" • ".join(breakdown_parts), 13, COLOR_MUTED))
	body.add_child(_label(str(result.get("outcome_text", "")), 19))
	var changes: Array = result.get("changes", [])
	if not changes.is_empty():
		body.add_child(_label("\n".join(changes), 15, _accent_color()))
	body.add_child(_button("CONTINUE", _continue_from_result))
	page.add_child(_button("INVENTORY", _show_inventory))


func _animate_dice(dice: Label) -> void:
	if not is_instance_valid(dice):
		return
	dice.pivot_offset = dice.size * 0.5
	dice.scale = Vector2(0.72, 0.72)
	dice.modulate.a = 0.15
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(dice, "scale", Vector2.ONE, 0.32)
	tween.tween_property(dice, "modulate:a", 1.0, 0.2)


func _continue_from_result() -> void:
	game.continue_after_result()
	_save_active_run()
	_render_current()


func _show_checkpoint() -> void:
	_clear_page()
	_set_region_background()
	var region := game.current_region()
	_title("CHECKPOINT", "%s complete" % region.get("name", "Region"))
	_show_survival_strip()
	var body := _panel()
	body.add_child(_label("You find defensible ground. You may manage equipment or spend one food item to rest before continuing.", 19))
	body.add_child(_label("Rest: Hunger -30, Fatigue -35, Health +8", 15, COLOR_MUTED))
	body.add_child(_button("REST (USES 1 FOOD)", _rest))
	body.add_child(_button("INVENTORY", _show_inventory))
	var region_number := int(game.run_state.get("region_index", 0)) + 1
	var next_text := "APPROACH THE EAST CITADEL" if region_number >= 6 else "ENTER REGION %d" % (region_number + 1)
	body.add_child(_button(next_text, _leave_checkpoint))
	if ads.should_attempt(region_number, Time.get_ticks_msec()):
		# The provider adapter owns display callbacks. A failed or unavailable request is skipped here.
		ads.mark_attempted(region_number, false, Time.get_ticks_msec())


func _rest() -> void:
	var result := game.rest_at_checkpoint()
	if result.get("success", false):
		_save_active_run()
		_show_checkpoint()
	_show_toast(str(result.get("text", "")))


func _leave_checkpoint() -> void:
	game.leave_checkpoint()
	_save_active_run()
	_render_current()


func _finish_run(victory: bool) -> void:
	var summary := game.summary()
	var history: Array = profile.get("run_history", [])
	var already_recorded := false
	for old_summary: Variant in history:
		if str(old_summary.get("run_id", "")) == str(summary.get("run_id", "")):
			already_recorded = true
			break
	if not already_recorded:
		history.push_front(summary)
		if history.size() > 20:
			history.resize(20)
		profile["run_history"] = history
		profile["best_region"] = max(int(profile.get("best_region", 0)), int(summary.get("regions_reached", 0)))
		if victory:
			profile["victories"] = int(profile.get("victories", 0)) + 1
		else:
			profile["deaths"] = int(profile.get("deaths", 0)) + 1
		saves.save_profile(profile)
	if victory:
		saves.delete_run_files()
	else:
		saves.write_death_marker_and_delete(str(game.run_state.get("run_id", "")))
	_clear_page()
	_title("THE CITADEL OPENS" if victory else "THE ROAD ENDS", "Victory" if victory else "Permadeath")
	var body := _panel()
	body.add_child(_label("You reached clean air beyond the East Gate." if victory else "This survivor is gone. The active run has been erased.", 21, COLOR_SUCCESS if victory else COLOR_DANGER))
	body.add_child(_label("Survivor: %s \"%s\"\nRegions reached: %d\nEvents resolved: %d" % [summary["survivor"], summary["callsign"], summary["regions_reached"], summary["events_resolved"]], 17))
	body.add_child(_button("BEGIN ANOTHER RUN", _reset_after_run))
	body.add_child(_button("MAIN MENU", _reset_to_menu))


func _reset_after_run() -> void:
	game.run_state = {}
	_begin_candidate_selection()


func _reset_to_menu() -> void:
	game.run_state = {}
	_show_main_menu()


func _show_first_run_tutorial() -> void:
	if is_instance_valid(tutorial_popup):
		tutorial_popup.queue_free()
	tutorial_popup = PopupPanel.new()
	tutorial_popup.exclusive = true
	add_child(tutorial_popup)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	tutorial_popup.add_child(margin)
	var body := VBoxContainer.new()
	body.custom_minimum_size = Vector2(430, 560)
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)
	body.add_child(_label("HOW THE ROAD WORKS", 27, _accent_color()))
	body.add_child(_label("1. Read the odds", 19, _accent_color()))
	body.add_child(_label("Every tested choice shows its D20 modifier, target difficulty, and exact success chance before you commit."))
	body.add_child(_label("2. Prepare between events", 19, _accent_color()))
	body.add_child(_label("Open Inventory to equip gear or use supplies. Rest is only available after each region and consumes food."))
	body.add_child(_label("3. Watch all four pressures", 19, _accent_color()))
	body.add_child(_label("Hunger, Fatigue, and Radiation impose visible penalties as they rise. Health at zero ends the run."))
	body.add_child(_label("4. Death is final", 19, COLOR_DANGER))
	body.add_child(_label("There is one autosaved run. Death erases it; settings, run history, and cosmetic ownership remain."))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	body.add_child(_button("I UNDERSTAND", _dismiss_tutorial))
	tutorial_popup.popup_centered_ratio(0.9)


func _dismiss_tutorial() -> void:
	profile["tutorial_seen"] = true
	saves.save_profile(profile)
	if is_instance_valid(tutorial_popup):
		tutorial_popup.hide()


func _show_inventory() -> void:
	if game.run_state.is_empty():
		return
	if is_instance_valid(inventory_popup):
		inventory_popup.queue_free()
	inventory_popup = PopupPanel.new()
	inventory_popup.exclusive = true
	add_child(inventory_popup)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	inventory_popup.add_child(margin)
	var body := VBoxContainer.new()
	body.custom_minimum_size = Vector2(450, 650)
	body.add_theme_constant_override("separation", 9)
	margin.add_child(body)
	body.add_child(_label("INVENTORY", 28, _accent_color()))
	body.add_child(_label("Weight %.1f / %.1f" % [game.get_total_weight(), game.get_carry_capacity()], 16, COLOR_DANGER if game.get_total_weight() > game.get_carry_capacity() else COLOR_MUTED))
	var equipped_parts: Array[String] = []
	for slot: String in game.run_state["survivor"]["equipment"]:
		var item_id := str(game.run_state["survivor"]["equipment"][slot])
		equipped_parts.append("%s: %s" % [slot.capitalize(), "Empty" if item_id == "" else content.get_item(item_id).get("name", item_id)])
	body.add_child(_label("\n".join(equipped_parts), 14, COLOR_MUTED))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	var inventory: Dictionary = game.run_state["survivor"]["inventory"]
	var item_ids: Array = inventory.keys()
	item_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return str(content.get_item(str(a)).get("name", a)) < str(content.get_item(str(b)).get("name", b)))
	for raw_id: Variant in item_ids:
		var item_id := str(raw_id)
		var item: Dictionary = content.get_item(item_id)
		var row := PanelContainer.new()
		var row_body := VBoxContainer.new()
		row.add_child(row_body)
		row_body.add_child(_label("%s ×%d  •  %.1f kg each" % [item.get("name", item_id), inventory[item_id], item.get("weight", 0.0)], 16, _accent_color()))
		row_body.add_child(_label(str(item.get("description", "")), 13, COLOR_MUTED))
		var action_row := HBoxContainer.new()
		var slot := str(item.get("equipment_slot", ""))
		if slot != "":
			var equip_button := _button("EQUIP", _inventory_action.bind("equip", item_id))
			equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			action_row.add_child(equip_button)
		if bool(item.get("consumable", false)) and item_id != "smoke_bomb":
			var use_button := _button("USE", _inventory_action.bind("use", item_id))
			use_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			action_row.add_child(use_button)
		if action_row.get_child_count() > 0:
			row_body.add_child(action_row)
		list.add_child(row)
	body.add_child(_button("CLOSE", inventory_popup.hide))
	inventory_popup.popup_centered_ratio(0.94)


func _inventory_action(action: String, item_id: String) -> void:
	var result := game.equip_item(item_id) if action == "equip" else game.use_item(item_id)
	if result.get("success", false):
		_save_active_run()
	inventory_popup.hide()
	_show_toast(str(result.get("text", "")))
	_render_current()


func _show_settings() -> void:
	if is_instance_valid(settings_popup):
		settings_popup.queue_free()
	settings_popup = PopupPanel.new()
	settings_popup.exclusive = true
	add_child(settings_popup)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	settings_popup.add_child(margin)
	var body := VBoxContainer.new()
	body.custom_minimum_size = Vector2(430, 500)
	body.add_theme_constant_override("separation", 10)
	margin.add_child(body)
	body.add_child(_label("SETTINGS", 28, _accent_color()))
	var font_button := _button("TEXT SIZE: %s" % _font_scale_name(), _cycle_font_scale)
	body.add_child(font_button)
	body.add_child(_check_setting("High contrast", "high_contrast"))
	body.add_child(_check_setting("Reduced motion", "reduced_motion"))
	body.add_child(_check_setting("Music", "music_enabled"))
	body.add_child(_check_setting("Sound effects", "sound_enabled"))
	body.add_child(_check_setting("Haptics", "haptics_enabled"))
	body.add_child(_button("THEME: %s" % str(profile.get("selected_theme", "default")).to_upper(), _cycle_theme, _available_themes().size() <= 1))
	body.add_child(_button("HOW TO PLAY", _show_first_run_tutorial))
	body.add_child(_button("COSMETIC STORE", _show_store))
	body.add_child(_label(ads.status_text(), 13, COLOR_MUTED))
	body.add_child(_button("CLOSE", _close_settings))
	settings_popup.popup_centered_ratio(0.88)


func _check_setting(label_text: String, key: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = label_text
	check.button_pressed = bool(profile.get(key, false))
	check.toggled.connect(_toggle_setting.bind(key))
	return check


func _toggle_setting(value: bool, key: String) -> void:
	profile[key] = value
	saves.save_profile(profile)
	if key in ["sound_enabled", "haptics_enabled"] and sound != null:
		sound.configure(profile)
	if key == "high_contrast":
		_apply_theme()


func _cycle_font_scale() -> void:
	var scale := float(profile.get("font_scale", 1.0))
	profile["font_scale"] = 1.2 if scale < 1.1 else 0.9 if scale > 1.1 else 1.0
	saves.save_profile(profile)
	_apply_theme()
	settings_popup.hide()
	_render_current() if not game.run_state.is_empty() else _show_main_menu()
	_show_settings()


func _font_scale_name() -> String:
	var scale := float(profile.get("font_scale", 1.0))
	return "SMALL" if scale < 1.0 else "LARGE" if scale > 1.0 else "NORMAL"


func _available_themes() -> Array[String]:
	var themes: Array[String] = ["default"]
	if billing.owns("theme_rust") or billing.owns("supporter"):
		themes.append("rust")
	if billing.owns("theme_night") or billing.owns("supporter"):
		themes.append("night")
	return themes


func _cycle_theme() -> void:
	var themes := _available_themes()
	var current_index := themes.find(str(profile.get("selected_theme", "default")))
	profile["selected_theme"] = themes[(max(current_index, 0) + 1) % themes.size()]
	saves.save_profile(profile)
	_apply_theme()
	if is_instance_valid(settings_popup):
		settings_popup.hide()
	_render_current() if not game.run_state.is_empty() else _show_main_menu()
	_show_settings()


func _close_settings() -> void:
	settings_popup.hide()
	_render_current() if not game.run_state.is_empty() else _show_main_menu()


func _show_store() -> void:
	if is_instance_valid(store_popup):
		store_popup.queue_free()
	store_popup = PopupPanel.new()
	store_popup.exclusive = true
	add_child(store_popup)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	store_popup.add_child(margin)
	var body := VBoxContainer.new()
	body.custom_minimum_size = Vector2(430, 560)
	body.add_theme_constant_override("separation", 10)
	margin.add_child(body)
	body.add_child(_label("COSMETIC STORE", 27, _accent_color()))
	body.add_child(_label("Purchases are non-consumable and never affect a D20 roll. Previously verified ownership remains usable offline.", 14, COLOR_MUTED))
	var offers := [
		["remove_ads", "Remove Ads"],
		["theme_rust", "Rust Theme Pack"],
		["theme_night", "Night Theme Pack"],
		["supporter", "Supporter Theme Bundle"],
	]
	for offer: Array in offers:
		var entitlement_id := str(offer[0])
		var owned := billing.owns(entitlement_id)
		var suffix := "OWNED" if owned else "UNAVAILABLE OFFLINE" if not billing.available else "OPEN GOOGLE PLAY"
		body.add_child(_button("%s - %s" % [offer[1], suffix], _request_purchase.bind(entitlement_id), owned or not billing.available))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	body.add_child(_label(billing.store_status(), 13, COLOR_MUTED))
	body.add_child(_button("CLOSE", store_popup.hide))
	store_popup.popup_centered_ratio(0.9)


func _request_purchase(entitlement_id: String) -> void:
	_show_toast(billing.begin_purchase(entitlement_id))


func _show_about() -> void:
	_clear_page()
	_title("ABOUT ASHFALL ROAD", "Offline by design")
	var body := _panel()
	body.add_child(_label("Ashfall Road is a mechanics-first D20 roguelike. The active run is stored only on this device and is erased when the survivor dies.", 18))
	body.add_child(_label("The core game requires no connection. Optional Google Play purchases and advertisements are unavailable while offline and never block play.", 16, COLOR_MUTED))
	body.add_child(_label("No account, cloud save, multiplayer, or external analytics service is used in version 1.", 16, COLOR_MUTED))
	body.add_child(_button("BACK", _show_main_menu))


func _show_content_error(errors: PackedStringArray) -> void:
	_clear_page()
	_title("CONTENT ERROR", "The game cannot safely start")
	var body := _panel()
	body.add_child(_label("\n".join(errors), 15, COLOR_DANGER))


func _show_toast(text: String) -> void:
	if text == "":
		return
	toast_label.text = text
	toast_label.visible = true
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(func() -> void: toast_label.visible = false)


func _save_active_run() -> bool:
	if game != null and not game.run_state.is_empty() and str(game.run_state.get("status", "")) == "active":
		return saves.save_run(game.run_state)
	return true


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(tutorial_popup) and tutorial_popup.visible:
			tutorial_popup.hide()
		elif is_instance_valid(store_popup) and store_popup.visible:
			store_popup.hide()
		elif is_instance_valid(inventory_popup) and inventory_popup.visible:
			inventory_popup.hide()
		elif is_instance_valid(settings_popup) and settings_popup.visible:
			settings_popup.hide()
		elif not game.run_state.is_empty():
			_save_active_run()
			_show_main_menu()
