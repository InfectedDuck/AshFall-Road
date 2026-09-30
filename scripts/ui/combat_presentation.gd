class_name CombatPresentation
extends VBoxContainer

const PortraitArtWidget = preload("res://scripts/ui/portrait_art.gd")
const DiceWidget = preload("res://scripts/ui/dice_widget.gd")
const CriticalFont = preload("res://assets/fonts/Literata.ttf")
const InterfaceFont = preload("res://assets/fonts/Inter.ttf")
const TouchScrollContainerScript = preload("res://scripts/ui/touch_scroll_container.gd")

signal action_requested(action: String)
signal items_requested
signal status_requested
signal tactics_requested
signal roll_requested
signal animation_finished

var palette: Dictionary = {}
var font_scale := 1.0
var player_art: Control
var enemy_art: Control
var player_flash: ColorRect
var enemy_flash: ColorRect
var player_hp: Label
var enemy_hp: Label
var player_bar: ProgressBar
var enemy_bar: ProgressBar
var player_maximum := 1
var enemy_maximum := 1
var player_die
var enemy_die
var phase_label: Label
var effect_label: Label
var action_buttons: Array[Button] = []
var animating := false
var roll_control: Button
var feed_body: VBoxContainer
var feed_scroll: ScrollContainer
var narrative_rules := false
var compact_mode := false
var player_feedback: Label
var enemy_feedback: Label


func configure(snapshot: Dictionary, theme_palette: Dictionary, scale_value: float, attack_profile: Dictionary, flee_preview: Dictionary, items_available: bool) -> void:
	palette = theme_palette
	font_scale = scale_value
	narrative_rules = int(snapshot.get("combat_rules_version", 1)) >= 2
	compact_mode = bool(snapshot.get("compact", false))
	if narrative_rules:
		_configure_narrative(snapshot, items_available)
		return
	for child: Node in get_children():
		child.queue_free()
	action_buttons.clear()
	add_theme_constant_override("separation", 8)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	add_child(header)
	var round_label := _label("COMBAT  //  ROUND %d" % int(snapshot.get("round", 1)), 14, palette["accent"])
	round_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(round_label)
	var prepared_action := str(snapshot.get("pending_action", ""))
	var state_label := _label("%s PREPARED" % prepared_action.replace("_", " ").to_upper() if prepared_action != "" else "YOUR TURN", 11, palette["critical"] if prepared_action != "" else palette["muted"])
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(state_label)
	var status_button := Button.new()
	status_button.name = "CombatStatusButton"
	status_button.text = "STATUS"
	status_button.tooltip_text = "Review active conditions"
	status_button.accessibility_name = "Review active survivor conditions"
	status_button.custom_minimum_size = Vector2(76, int(44 * font_scale))
	status_button.pressed.connect(func() -> void: status_requested.emit())
	header.add_child(status_button)

	var arena := PanelContainer.new()
	arena.add_theme_stylebox_override("panel", _box(palette["surface_raised"], palette["border"]))
	add_child(arena)
	var arena_body := HBoxContainer.new()
	arena_body.add_theme_constant_override("separation", 6)
	arena.add_child(arena_body)
	var player: Dictionary = snapshot.get("player", {})
	var enemy: Dictionary = snapshot.get("enemy", {})
	arena_body.add_child(_combatant_card(player, true, snapshot))
	arena_body.add_child(_clash_column(snapshot, prepared_action))
	arena_body.add_child(_combatant_card(enemy, false, snapshot))

	var feed_panel := PanelContainer.new()
	feed_panel.custom_minimum_size.y = int(94 * font_scale)
	feed_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feed_panel.add_theme_stylebox_override("panel", _box(palette["surface"], palette["border_subtle"]))
	add_child(feed_panel)
	var feed_scroll := TouchScrollContainerScript.new()
	feed_scroll.name = "CombatFeedScroll"
	feed_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feed_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	feed_panel.add_child(feed_scroll)
	var feed := VBoxContainer.new()
	feed.name = "CombatFeed"
	feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed.add_theme_constant_override("separation", 3)
	for entry: Dictionary in snapshot.get("log", []):
		feed.add_child(_combat_feed_entry(entry))
	feed_scroll.add_child(feed)
	call_deferred("_scroll_feed", feed_scroll)

	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	var disabled := prepared_action != ""
	var attack := _action_button("ATTACK\n%d-%d DAMAGE" % [int(attack_profile.get("damage_min", 0)), int(attack_profile.get("damage_max", 0))], "attack", disabled)
	var guard := _action_button("GUARD\n60% LESS DAMAGE", "guard", disabled)
	var item := _action_button("USE ITEM\nENEMY RESPONDS", "item", disabled or not items_available)
	var flee := _action_button("FLEE\nAGILITY %d%%" % int(flee_preview.get("chance", 0)), "flee", disabled or not bool(snapshot.get("can_flee", true)))
	for button: Button in [attack, guard, item, flee]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(button)
	add_child(actions)


func play_round(round_result: Dictionary, reduced_motion: bool) -> void:
	if int(round_result.get("combat_rules_version", 1)) >= 2:
		await _play_narrative_round(round_result, reduced_motion)
		return
	animating = true
	_set_actions_disabled(true)
	var display: Dictionary = round_result.get("presentation", {})
	var player_roll := int(display.get("player_roll", round_result.get("player_roll", 0)))
	var enemy_roll := int(display.get("enemy_roll", round_result.get("enemy_roll", 0)))
	var action := str(display.get("action", round_result.get("action", "")))
	if player_roll > 0:
		phase_label.text = "YOU ROLL"
		await _animate_die(player_die, player_roll, reduced_motion)
		if bool(display.get("flee_success", false)):
			await _show_effect("ESCAPED\nFATIGUE +5", palette["success"], reduced_motion)
			animating = false
			animation_finished.emit()
			return
		if int(display.get("player_damage", 0)) > 0:
			var player_critical := player_roll in [1, 20]
			phase_label.text = "CRITICAL SUCCESS" if player_roll == 20 else "CRITICAL FAILURE" if player_roll == 1 else "YOU STRIKE"
			await _strike(player_art, player_flash, enemy_art, enemy_flash, 1.0, player_roll == 20, reduced_motion)
			var player_color: Color = palette["critical"] if player_roll == 20 else palette["danger"]
			var player_text := "-%d" % int(display.get("player_damage", 0))
			if player_critical:
				player_text = ("CRITICAL SUCCESS\n" if player_roll == 20 else "CRITICAL FAILURE\n") + player_text
			await _show_effect(player_text, player_color, reduced_motion)
			await _animate_health(false, int(display.get("enemy_health_before", enemy_bar.value)), int(display.get("enemy_health_after", enemy_bar.value)), reduced_motion)
	elif action == "guard":
		phase_label.text = "GUARD"
		await _pulse(player_art, player_flash, palette["fatigue"], reduced_motion)
		await _show_effect("GUARD\n60% LESS DAMAGE", palette["fatigue"], reduced_motion)
	elif action == "use_item":
		phase_label.text = "ITEM USED"
		if int(display.get("healing", 0)) > 0:
			await _pulse(player_art, player_flash, palette["success"], reduced_motion)
			await _show_effect("+%d HP" % int(display.get("healing", 0)), palette["success"], reduced_motion)
			await _animate_health(true, int(display.get("player_health_before", player_bar.value)), int(display.get("player_health_after_item", player_bar.value)), reduced_motion)
		else:
			await _show_effect("ITEM USED", palette["success"], reduced_motion)

	if bool(display.get("enemy_defeated", false)):
		phase_label.text = "ENEMY DEFEATED"
		await _show_effect("ENEMY DEFEATED", palette["success"], reduced_motion)
		animating = false
		animation_finished.emit()
		return
	if bool(display.get("enemy_staggered", false)):
		phase_label.text = "ENEMY STAGGERED"
		await _show_effect("CRITICAL SUCCESS\nENEMY STAGGERED", palette["critical"], reduced_motion)
		animating = false
		animation_finished.emit()
		return
	if int(display.get("enemy_damage", 0)) > 0:
		phase_label.text = "ENEMY ROLLS"
		await _animate_die(enemy_die, enemy_roll, reduced_motion)
		phase_label.text = "ENEMY STRIKES"
		await _strike(enemy_art, enemy_flash, player_art, player_flash, -1.0, enemy_roll == 20, reduced_motion)
		var incoming_text := "-%d HP" % int(display.get("enemy_damage", 0))
		if enemy_roll == 20:
			incoming_text = "CRITICAL SUCCESS\n" + incoming_text
		elif enemy_roll == 1:
			incoming_text = "CRITICAL FAILURE\n" + incoming_text
		if int(display.get("armor_blocked", 0)) > 0:
			incoming_text += "\nARMOR -%d" % int(display.get("armor_blocked", 0))
		if int(display.get("defense_blocked", 0)) > 0:
			incoming_text += "\nGUARD -%d" % int(display["defense_blocked"])
		await _show_effect(incoming_text, palette["danger"], reduced_motion)
		var player_before_enemy: int = int(display.get("player_health_after_item", display.get("player_health_before", player_bar.value))) if action == "use_item" else int(display.get("player_health_before", player_bar.value))
		await _animate_health(true, player_before_enemy, int(display.get("player_health_after", player_bar.value)), reduced_motion)
		if not str(display.get("critical_condition", "")).is_empty():
			await _show_effect("CONDITION\n%s" % str(display["critical_condition"]), palette["danger"], reduced_motion)
	else:
		phase_label.text = "ROUND COMPLETE"
		await _show_effect("ROUND COMPLETE", palette["muted"], reduced_motion)
	animating = false
	animation_finished.emit()


func _combatant_card(combatant: Dictionary, player_side: bool, snapshot: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 100 if narrative_rules else int(132 * font_scale)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _box(palette["surface_raised"], palette["accent"] if player_side else palette["danger"]))
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 2 if narrative_rules else 4)
	card.add_child(body)
	var stage := Control.new()
	stage.name = "PortraitStage"
	stage.custom_minimum_size = (Vector2(64, 64) if compact_mode else Vector2(100, 170)) if narrative_rules else Vector2(116, 96) * font_scale
	stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if narrative_rules and compact_mode else Control.SIZE_EXPAND_FILL
	body.add_child(stage)
	var portrait := PortraitArtWidget.create_view(str(combatant.get("portrait_id", "portrait")), palette["muted"], int(11 * font_scale), str(combatant.get("name", "")), str(combatant.get("field_note", "")))
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.add_child(portrait)
	var flash := ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(flash)
	if player_side:
		player_art = portrait
		player_flash = flash
	else:
		enemy_art = portrait
		enemy_flash = flash
	var side_prefix := "YOU  //  " if player_side else "ENEMY  //  "
	var compact_card: bool = narrative_rules and compact_mode
	var name := _label(str(combatant.get("name", "UNKNOWN")) if compact_card else side_prefix + str(combatant.get("name", "UNKNOWN")), 12, palette["accent"] if player_side else palette["danger"])
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.tooltip_text = side_prefix + str(combatant.get("name", "UNKNOWN"))
	body.add_child(name)
	var hp := _label("", 14, palette["text"])
	hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(hp)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maxi(1, int(combatant.get("max_health", 1)))
	bar.value = int(combatant.get("health", 0))
	bar.custom_minimum_size.y = int(11 * font_scale)
	bar.add_theme_stylebox_override("background", _meter_box(palette["meter_track"]))
	bar.add_theme_stylebox_override("fill", _meter_box(palette["text"] if player_side else palette["icon_ink"]))
	body.add_child(bar)
	var weapon := _label(str(combatant.get("weapon", "Unarmed")), 10, palette["muted"])
	weapon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(weapon)
	if narrative_rules:
		var feedback := _label("", 10, palette["text"])
		feedback.name = "PlayerPortraitFeedback" if player_side else "EnemyPortraitFeedback"
		feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		feedback.text = portrait_feedback(snapshot.get("last_exchange", {}), player_side)
		if compact_mode:
			var feedback_scroll := TouchScrollContainerScript.new()
			feedback_scroll.name = "PortraitFeedbackScroll"
			feedback_scroll.custom_minimum_size.y = 32
			feedback_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			feedback_scroll.add_child(feedback)
			body.add_child(feedback_scroll)
		else:
			body.add_child(feedback)
		if player_side:
			player_feedback = feedback
		else:
			enemy_feedback = feedback
	if player_side and not str(combatant.get("ammo", "")).is_empty():
		var ammo := _label(str(combatant.get("ammo", "")), 9, palette["accent"])
		ammo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(ammo)
	if player_side:
		player_hp = hp
		player_bar = bar
		player_maximum = int(bar.max_value)
		_set_hp(player_hp, player_bar, int(combatant.get("health", 0)), player_maximum)
	else:
		enemy_hp = hp
		enemy_bar = bar
		enemy_maximum = int(bar.max_value)
		_set_hp(enemy_hp, enemy_bar, int(combatant.get("health", 0)), enemy_maximum)
	return card


func _clash_column(snapshot: Dictionary, prepared_action: String) -> VBoxContainer:
	var center := VBoxContainer.new()
	center.custom_minimum_size.x = int(128 * font_scale)
	center.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 5)
	var player_title := _label("YOU", 10, palette["accent"])
	player_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(player_title)
	player_die = DiceWidget.new()
	player_die.custom_minimum_size = Vector2(92, 92) * font_scale
	player_die.set_palette(palette)
	center.add_child(player_die)
	phase_label = _label("ROLL ROUND" if prepared_action != "" else "CHOOSE AN ACTION", 11, palette["critical"] if prepared_action != "" else palette["muted"])
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(phase_label)
	effect_label = _label("", 12, palette["text"])
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.visible = false
	center.add_child(effect_label)
	if prepared_action != "":
		var prepared := _label("AUTOSAVED • RESULTS HIDDEN", 8, palette["muted"])
		prepared.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		center.add_child(prepared)
		var roll := Button.new()
		roll_control = roll
		roll.text = "ROLL ROUND"
		roll.custom_minimum_size = Vector2(0, int(44 * font_scale))
		roll.pressed.connect(func() -> void:
			roll.disabled = true
			roll_requested.emit()
		)
		center.add_child(roll)
	var enemy_title := _label(str(snapshot.get("enemy", {}).get("name", "ENEMY")).to_upper(), 10, palette["danger"])
	enemy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(enemy_title)
	enemy_die = DiceWidget.new()
	enemy_die.custom_minimum_size = Vector2(72, 72) * font_scale
	enemy_die.set_palette(palette)
	center.add_child(enemy_die)
	var chips := VBoxContainer.new()
	chips.add_theme_constant_override("separation", 2)
	var armor: Dictionary = snapshot.get("armor", {})
	chips.add_child(_chip("ARMOR %d  //  -%d FLAT, -%d%%" % [int(armor.get("rating", 0)), int(armor.get("flat", 0)), int(armor.get("percent", 0))], palette["fatigue"]))
	for status: String in snapshot.get("status_labels", []):
		chips.add_child(_chip(status, palette["critical"] if status.begins_with("GUARD") else palette["danger"] if status.begins_with("EXPOSED") else palette["muted"]))
	var condition := str(snapshot.get("enemy", {}).get("critical_condition", ""))
	if condition != "":
		chips.add_child(_chip("ENEMY CRIT: %s" % condition.to_upper(), palette["danger"]))
	center.add_child(chips)
	return center


func _action_button(text: String, action: String, disabled: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = int(54 * font_scale)
	button.disabled = disabled
	if narrative_rules:
		_style_compact_control(button)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", int(12 * font_scale))
	if action == "item":
		button.pressed.connect(func() -> void: items_requested.emit())
	else:
		button.pressed.connect(func() -> void: action_requested.emit(action))
	action_buttons.append(button)
	return button


func _configure_narrative(snapshot: Dictionary, items_available: bool) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	action_buttons.clear()
	add_theme_constant_override("separation", 3)
	var pending := str(snapshot.get("pending_action", "")) != ""
	var cards := HBoxContainer.new()
	cards.name = "PortraitsLeftRight"
	cards.add_theme_constant_override("separation", 6)
	cards.add_child(_combatant_card(snapshot["player"], true, snapshot))
	cards.add_child(_combatant_card(snapshot["enemy"], false, snapshot))
	add_child(cards)
	var status := Button.new()
	status.name = "CombatStatusButton"
	_style_compact_control(status)
	var armor: Dictionary = snapshot["armor"]
	status.text = "ARMOR %d • −%d / −%d%% | STATUS ⓘ" % [armor["rating"], armor["flat"], armor["percent"]]
	status.custom_minimum_size.y = 44
	status.text = "STATUS & PROTECTION"
	status.add_theme_font_size_override("font_size", int(11 * font_scale))
	status.tooltip_text = "\n".join(snapshot.get("status_labels", [])) + "\nEnemy critical: " + str(snapshot["enemy"].get("critical_condition", "None"))
	status.pressed.connect(func() -> void: status_requested.emit())
	add_child(status)
	var active: Array = snapshot.get("status_labels", [])
	var windows: Array[String] = []
	if not active.is_empty():
		var conditions := 0
		for status_text: String in active:
			if status_text.begins_with("RIPOSTE"):
				windows.append("Next attack stronger")
			elif status_text.begins_with("OPENING"):
				windows.append("Next attack easier")
			elif status_text.begins_with("INTERRUPT"):
				windows.append(status_text)
			elif status_text.begins_with("SUPPRESSION"):
				windows.append("Suppression carries to next response")
			elif status_text.begins_with("TALENTS"):
				continue
			else:
				conditions += 1
		if conditions > 0:
			windows.append("%d CONDITION%s" % [conditions, "" if conditions == 1 else "S"])
	var clash := HBoxContainer.new()
	clash.add_theme_constant_override("separation", 6)
	player_die = DiceWidget.new()
	player_die.custom_minimum_size = Vector2(48, 48)
	player_die.set_palette(palette)
	clash.add_child(player_die)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_label = _label("ROUND %d • %s" % [int(snapshot["round"]), "PREPARED" if pending else "YOUR TURN"], 11, palette["accent"])
	center.add_child(phase_label)
	effect_label = _label("Choose your response", 11, palette["muted"])
	var prepared: Dictionary = snapshot.get("prepared_preview", {})
	if int(prepared.get("chance", 0)) > 0:
		effect_label.text = "%d%% • ROLL %d+" % [prepared["chance"], prepared["required_roll"]]
	center.add_child(effect_label)
	roll_control = Button.new()
	roll_control.text = "ROLL ROUND"
	_style_compact_control(roll_control)
	if int(prepared.get("chance", 0)) > 0:
		roll_control.text += "\n%d%% • ROLL %d+" % [prepared["chance"], prepared["required_roll"]]
	roll_control.custom_minimum_size.y = 44
	roll_control.add_theme_font_size_override("font_size", int(11 * font_scale))
	roll_control.visible = pending
	phase_label.visible = not pending
	effect_label.visible = not pending
	roll_control.pressed.connect(func() -> void:
		roll_control.disabled = true
		roll_requested.emit()
	)
	center.add_child(roll_control)
	clash.add_child(center)
	enemy_die = DiceWidget.new()
	enemy_die.custom_minimum_size = Vector2(48, 48)
	enemy_die.set_palette(palette)
	clash.add_child(enemy_die)
	add_child(clash)
	# The enemy's clue, the windows it opens, and the consequence it produced are
	# one exchange, so they read as one block instead of straddling the dice.
	var exchange := PanelContainer.new()
	exchange.name = "CombatExchangePanel"
	exchange.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var exchange_box := _box(palette["surface"], palette["border_subtle"])
	exchange_box.content_margin_top = 3
	exchange_box.content_margin_bottom = 3
	exchange.add_theme_stylebox_override("panel", exchange_box)
	add_child(exchange)
	var exchange_body := VBoxContainer.new()
	exchange_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	exchange_body.add_theme_constant_override("separation", 2)
	exchange.add_child(exchange_body)
	var tell := Button.new()
	tell.text = str(snapshot.get("enemy_tell", "")) + " ⓘ"
	tell.flat = true
	_style_compact_control(tell)
	tell.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tell.add_theme_font_size_override("font_size", int(12 * font_scale))
	tell.custom_minimum_size.y = 44
	tell.pressed.connect(func() -> void: tactics_requested.emit())
	tell.name = "CommittedEnemyTell"
	exchange_body.add_child(tell)
	if not windows.is_empty():
		var window_label := _label(" | ".join(windows), 10, palette["accent"])
		window_label.name = "AttackWindowStatus"
		exchange_body.add_child(window_label)
	feed_scroll = TouchScrollContainerScript.new()
	feed_scroll.name = "CombatFeedScroll"
	feed_scroll.custom_minimum_size.y = 44
	feed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feed_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	feed_body = VBoxContainer.new()
	feed_body.name = "CombatFeed"
	feed_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for entry: Dictionary in snapshot.get("log", []):
		feed_body.add_child(_combat_feed_entry(entry))
	feed_scroll.add_child(feed_body)
	exchange_body.add_child(feed_scroll)
	call_deferred("_scroll_feed", feed_scroll)
	var actions := GridContainer.new()
	actions.name = "NarrativeActionGrid"
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 6)
	actions.add_theme_constant_override("v_separation", 3)
	for action: String in ["attack", "block", "dodge", "item", "flee", "opportunity"]:
		var preview: Dictionary = snapshot.get("action_previews", {}).get(action, {})
		var label := action.to_upper()
		if action == "opportunity":
			label = str(preview.get("profile", {}).get("opportunity_name", "Opportunity")).to_upper()
		if int(preview.get("chance", 0)) > 0 and action != "opportunity":
			label += " • %d%%" % preview["chance"]
		if action in ["attack", "opportunity"]:
			label += "\n%d–%d damage" % [preview.get("damage_min", 0), preview.get("damage_max", 0)]
		elif action in ["block", "dodge"]:
			label += "\nStop the attack"
		elif action == "item":
			label += "\nENEMY RESPONDS"
		elif action == "flee":
			label += "\nROLL %d+ • ESCAPE" % preview.get("required_roll", 0)
		var available := items_available if action == "item" else bool(preview.get("available", false))
		if not pending and not available:
			label = action.to_upper() + "\n" + ("NO SUPPLIES" if action == "item" else "NO ESCAPE" if action == "flee" else "NOT READY")
		var button := _action_button(label, action, pending or not available)
		button.name = "Action_" + action
		button.custom_minimum_size.y = 44
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "\n".join(preview.get("effects", [])) + "\n" + str(preview.get("cost", ""))
		button.accessibility_description = button.tooltip_text
		actions.add_child(button)
	add_child(actions)


func _style_compact_control(button: Button) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var fill: Color = palette["surface_pressed"] if state in ["pressed", "disabled"] else palette["surface"]
		var box := _box(fill, palette["accent"] if state in ["focus", "hover"] else palette["border_subtle"], 2 if state == "focus" else 1)
		box.content_margin_left = 6
		box.content_margin_right = 6
		box.content_margin_top = 4
		box.content_margin_bottom = 4
		button.add_theme_stylebox_override(state, box)


func show_save_retry(message: String) -> void:
	_set_actions_disabled(true)
	phase_label.text = "SAVE REQUIRED • ACTIONS LOCKED"
	effect_label.text = message
	effect_label.visible = true
	phase_label.visible = true
	if is_instance_valid(roll_control):
		roll_control.text = "RETRY SAVE"
		roll_control.visible = true
		roll_control.disabled = false


func _play_narrative_round(result: Dictionary, reduced: bool) -> void:
	animating = true
	_set_actions_disabled(true)
	phase_label.visible = false
	effect_label.visible = true
	if is_instance_valid(roll_control):
		roll_control.visible = false
	# Text is authoritative and instant, never held behind animation.
	for entry: Dictionary in result.get("entries", []):
		feed_body.add_child(_combat_feed_entry(entry))
	call_deferred("_scroll_feed", feed_scroll)
	var display: Dictionary = result["presentation"]
	player_feedback.text = portrait_feedback(display, true)
	enemy_feedback.text = portrait_feedback(display, false)
	var roll := int(display.get("player_roll", 0))
	var action := str(display["action"])
	if roll > 0:
		await _animate_die(player_die, roll, reduced)
	var label := "CRITICAL SUCCESS" if roll == 20 else "CRITICAL FAILURE" if roll == 1 else action.to_upper()
	if bool(display.get("flee_success", false)):
		await _show_effect(("CRITICAL SUCCESS • " if roll == 20 else "") + "ESCAPED • FATIGUE +5", palette["success"], reduced)
	elif action == "flee":
		await _show_effect(label + " • ESCAPE FAILED", palette["danger"], reduced)
	elif action in ["attack", "opportunity"]:
		if bool(display.get("hit", false)):
			await _strike(player_art, player_flash, enemy_art, enemy_flash, 1.0, roll == 20, reduced)
			await _animate_health(false, int(display["enemy_health_before"]), int(display["enemy_health_after"]), reduced)
		await _show_effect(label + (" • −%d HP" % int(display["player_damage"]) if bool(display.get("hit", false)) else " • MISS"), palette["critical"] if roll == 20 else palette["danger"] if roll == 1 else palette["accent"], reduced)
	elif action in ["block", "dodge"]:
		await _show_effect(label + (" • 0 HP LOST" if bool(display.get("defense_success", false)) else " • NO DEFENSE"), palette["success"] if bool(display.get("defense_success", false)) else palette["danger"], reduced)
	elif action == "use_item":
		await _animate_health(true, int(display["player_health_before"]), int(display.get("player_health_after_item", display["player_health_before"])), reduced)
		await _show_effect("ITEM USED • +%d HP" % int(display.get("healing", 0)), palette["success"], reduced)
	if int(display.get("enemy_raw_damage", 0)) > 0:
		var enemy_roll := int(display["enemy_roll"])
		await _animate_die(enemy_die, enemy_roll, reduced)
		if int(display["enemy_damage"]) > 0:
			await _strike(enemy_art, enemy_flash, player_art, player_flash, -1.0, enemy_roll == 20, reduced)
		await _animate_health(true, int(display.get("player_health_after_item", display["player_health_before"])), int(display["player_health_after"]), reduced)
		var incoming := "You lost %d HP" % int(display["enemy_damage"])
		if enemy_roll in [1, 20]:
			incoming = ("CRITICAL SUCCESS" if enemy_roll == 20 else "CRITICAL FAILURE") + " • " + incoming
		await _show_effect(incoming, palette["danger"], reduced)
	elif bool(display.get("enemy_interrupted", false)):
		await _show_effect("HEAVY INTERRUPTED", palette["accent"], reduced)
	animating = false
	animation_finished.emit()


func _animate_die(die, final_roll: int, reduced_motion: bool) -> void:
	if die == null:
		return
	if reduced_motion:
		die.set_face(final_roll)
		await get_tree().create_timer(0.06).timeout
		return
	var cosmetic := RandomNumberGenerator.new()
	cosmetic.randomize()
	for _index in range(7):
		die.set_face(cosmetic.randi_range(1, 20))
		await get_tree().create_timer(0.035).timeout
	die.set_face(final_roll)
	await get_tree().create_timer(0.10).timeout


func _strike(attacker: Control, attacker_flash: ColorRect, defender: Control, defender_flash: ColorRect, direction: float, critical: bool, reduced_motion: bool) -> void:
	if reduced_motion:
		return
	var start := attacker.position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(attacker, "position", start + Vector2(direction * 14.0, 0), 0.09)
	tween.tween_property(attacker, "scale", Vector2(1.08, 1.08), 0.09)
	tween.tween_property(defender, "scale", Vector2(0.92, 0.92), 0.09)
	await tween.finished
	var impact_color: Color = palette["critical"] if critical else palette["danger"]
	impact_color.a = 0.62
	defender_flash.color = impact_color
	var impact := create_tween()
	impact.set_parallel(true)
	impact.tween_property(attacker, "position", start, 0.12)
	impact.tween_property(attacker, "scale", Vector2.ONE, 0.12)
	impact.tween_property(defender, "scale", Vector2.ONE, 0.12)
	impact.tween_property(defender_flash, "color:a", 0.0, 0.12)
	await impact.finished


func _pulse(target: Control, flash: ColorRect, color: Color, reduced_motion: bool) -> void:
	if reduced_motion:
		return
	var pulse_color := color
	pulse_color.a = 0.52
	flash.color = pulse_color
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2(1.08, 1.08), 0.11)
	tween.tween_property(flash, "color:a", 0.0, 0.22)
	await tween.finished
	target.scale = Vector2.ONE


func _show_effect(text: String, color: Color, reduced_motion: bool) -> void:
	effect_label.text = text
	effect_label.add_theme_color_override("font_color", color)
	var is_critical := "CRITICAL SUCCESS" in text or "CRITICAL FAILURE" in text or "CRITICAL HIT" in text
	effect_label.add_theme_font_override("font", CriticalFont if is_critical else InterfaceFont)
	effect_label.add_theme_font_size_override("font_size", int(((14 if is_critical else 11) if narrative_rules else (18 if is_critical else 12)) * font_scale))
	if narrative_rules:
		effect_label.max_lines_visible = 2
	effect_label.add_theme_constant_override("outline_size", 3 if is_critical else 0)
	effect_label.add_theme_color_override("font_outline_color", palette["background"])
	effect_label.visible = true
	if reduced_motion:
		effect_label.modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(0.10).timeout
		return
	effect_label.modulate = Color(1, 1, 1, 0)
	effect_label.scale = Vector2(0.86, 0.86)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect_label, "modulate:a", 1.0, 0.08)
	tween.tween_property(effect_label, "scale", Vector2.ONE, 0.12)
	await tween.finished
	await get_tree().create_timer(0.08).timeout


func _animate_health(player_side: bool, from: int, to: int, reduced_motion: bool) -> void:
	var label: Label = player_hp if player_side else enemy_hp
	var bar: ProgressBar = player_bar if player_side else enemy_bar
	var maximum := player_maximum if player_side else enemy_maximum
	if reduced_motion or from == to:
		_set_hp(label, bar, to, maximum)
		await get_tree().create_timer(0.06).timeout
		return
	var tween := create_tween()
	tween.tween_method(func(value: float) -> void: _set_hp(label, bar, roundi(value), maximum), float(from), float(to), 0.22)
	await tween.finished


func _set_hp(label: Label, bar: ProgressBar, health: int, maximum: int) -> void:
	bar.max_value = maxi(1, maximum)
	bar.value = clampi(health, 0, maximum)
	label.text = "%d / %d HP" % [clampi(health, 0, maximum), maximum]
	label.add_theme_color_override("font_color", palette["danger"] if health * 4 <= maximum else palette["text"])


func _set_actions_disabled(disabled: bool) -> void:
	for button: Button in action_buttons:
		button.disabled = disabled


func _chip(text: String, color: Color) -> Label:
	var chip := _label(text, 8, color)
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return chip


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", int(size * font_scale))
	label.add_theme_color_override("font_color", color)
	return label


func _combat_feed_entry(entry: Dictionary) -> HBoxContainer:
	var actor := str(entry.get("actor", "system"))
	var kind := str(entry.get("kind", "system"))
	var message := str(entry.get("text", ""))
	var original_message := message
	if narrative_rules:
		message = readable_log(entry)
	var critical := kind in ["critical_success", "critical_failure"]
	if critical and "CRITICAL" not in message:
		message = ("CRITICAL SUCCESS — " if kind == "critical_success" else "CRITICAL FAILURE — ") + message

	var row := HBoxContainer.new()
	row.name = "EnemyCombatEntry" if actor == "enemy" else "PlayerCombatEntry" if actor == "player" else "SystemCombatEntry"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var label_color: Color = _actor_log_color(actor, kind)
	var prefix := "YOU  ›  " if actor == "player" else "‹  ENEMY  " if actor == "enemy" else ""
	var label := _label(prefix + message, 14 if critical else 11, label_color)
	label.name = "CombatFeedText"
	if narrative_rules:
		label.text = ("You: " if actor == "player" else "Enemy: " if actor == "enemy" else "") + message
	label.tooltip_text = original_message
	label.custom_minimum_size.x = 0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if actor == "enemy" else HORIZONTAL_ALIGNMENT_LEFT if actor == "player" else HORIZONTAL_ALIGNMENT_CENTER
	if critical:
		label.add_theme_font_override("font", CriticalFont)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", palette["background"])
	else:
		label.add_theme_font_override("font", InterfaceFont)
	row.add_child(label)
	if narrative_rules:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return row


static func portrait_feedback(display: Dictionary, player_side: bool) -> String:
	if display.is_empty():
		return "You" if player_side else "Enemy"
	var lines: Array[String] = []
	if not player_side:
		if bool(display.get("hit", false)):
			lines.append("Lost %d HP" % int(display.get("player_damage", 0)))
		elif str(display.get("action", "")) in ["attack", "opportunity"]:
			lines.append("Your attack missed")
		if bool(display.get("enemy_interrupted", false)):
			lines.append("Heavy attack cancelled")
		return "\n".join(lines)
	lines.append("Lost %d HP" % int(display.get("enemy_damage", 0)))
	if int(display.get("healing", 0)) > 0:
		lines.append("Healed %d HP" % int(display["healing"]))
	if int(display.get("armor_blocked", 0)) > 0:
		lines.append("Armor blocked %d" % int(display["armor_blocked"]))
	if bool(display.get("defense_success", false)):
		lines.append("Stopped the attack")
	elif int(display.get("exposure_damage", 0)) > 0:
		lines.append("Off balance: %d extra damage" % int(display["exposure_damage"]))
	return "\n".join(lines)


static func readable_log(entry: Dictionary) -> String:
	var message := str(entry.get("text", ""))
	var amount := int(entry.get("amount", 0))
	if "\n" in message and "ROLL " in message:
		var story := message.get_slice("\n", 0)
		if str(entry.get("actor", "")) == "enemy":
			return "%s\nYou lost %d HP." % [story, amount]
		if "DAMAGE" in message:
			return story + ("\nEnemy lost %d HP." % amount if amount > 0 else "\nYour attack missed.")
		return story
	if message.begins_with("INTERRUPTED"):
		return "Enemy's heavy attack cancelled. Interrupt recharges in two exchanges."
	if message.begins_with("SUPPRESSED"):
		return message.replace("SUPPRESSED", "Enemy attack weakened").replace("RESPONSE", "Damage")
	return message.replace("OPPORTUNITY READY", "SPECIAL ATTACK READY")


func _actor_log_color(actor: String, kind: String) -> Color:
	if actor == "enemy":
		return palette["danger"]
	if actor == "player":
		if kind == "critical_success":
			return palette["critical"]
		if kind in ["critical_failure", "failure", "condition"]:
			return palette["danger"]
		if kind in ["heal", "success"]:
			return palette["success"]
		if kind == "guard":
			return palette["fatigue"]
		return palette["accent"]
	return _log_color(kind)


## Every plate in the canvas is square-cornered, so radius is not a parameter.
func _box(fill: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 7
	box.content_margin_bottom = 7
	return box


func _meter_box(fill: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	return box


func _log_color(kind: String) -> Color:
	if kind in ["damage", "critical_failure", "failure", "condition"]:
		return palette["danger"]
	if kind in ["heal", "success"]:
		return palette["success"]
	if kind == "critical_success":
		return palette["critical"]
	if kind == "guard":
		return palette["fatigue"]
	return palette["muted"]


func _scroll_feed(scroll: ScrollContainer) -> void:
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
