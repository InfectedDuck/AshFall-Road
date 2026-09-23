extends SceneTree
## M07 compact-screen layout checks.
##
## Every screen M07 touches is built at 360x640, 540x960, and tall 540x1200 in
## both the normal and the largest text setting. The rule under test is the same
## everywhere: long content scrolls, and the controls that leave a screen never
## do.

const Main = preload("res://scripts/ui/main.gd")
const ActionTests = preload("res://tests/action_transaction_tests.gd")
const ResponsiveRules = preload("res://scripts/ui/responsive_rules.gd")

var failures := 0
var assertions := 0


func _init() -> void:
	call_deferred("_run")


func verify(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		push_error(message)


func _descendants(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_descendants(child))
	return found


func _buttons(node: Node) -> Array[Button]:
	var found: Array[Button] = []
	for candidate: Node in _descendants(node):
		if candidate is Button and (candidate as Button).visible:
			found.append(candidate)
	return found


func _inside_scroll(node: Node) -> bool:
	var walker := node.get_parent()
	while walker != null:
		if walker is ScrollContainer:
			return true
		walker = walker.get_parent()
	return false


func _label_texts(node: Node) -> Array[String]:
	var texts: Array[String] = []
	for candidate: Node in _descendants(node):
		if candidate is Label:
			texts.append(str((candidate as Label).text))
		elif candidate is Button:
			texts.append(str((candidate as Button).text))
	return texts


func _label_with(node: Node, fragment: String) -> Label:
	for candidate: Node in _descendants(node):
		if candidate is Label and fragment.to_lower() in str((candidate as Label).text).to_lower():
			return candidate
	return null


func _button_with(node: Node, fragment: String) -> Button:
	for candidate: Button in _buttons(node):
		if fragment.to_lower() in str(candidate.text).to_lower():
			return candidate
	return null


## Controls that leave a screen must sit outside the scroll, keep a 44px target,
## and finish inside the sheet rather than below its bottom edge.
func _verify_pinned(control: Control, sheet_height: float, context: String) -> void:
	verify(control != null, "Control exists " + context)
	if control == null:
		return
	var rect := control.get_global_rect()
	verify(not _inside_scroll(control), "Stays outside the scroll " + context)
	verify(rect.size.y >= 44.0, "Keeps a 44px target " + context + " " + str(rect.size))
	verify(rect.end.y <= sheet_height + 1.0, "Finishes inside the sheet " + context + " " + str(rect) + " of " + str(sheet_height))


func _run() -> void:
	_verify_safe_area_rules()
	var fixtures := ActionTests.new()
	fixtures.content = ContentRepository.new()
	for dimensions: Vector2i in [Vector2i(320, 568), Vector2i(360, 640), Vector2i(393, 852), Vector2i(540, 1200)]:
		for scale_value: float in [1.0, 1.2]:
			var context := "%s scale %.1f" % [dimensions, scale_value]
			var viewport := SubViewport.new()
			viewport.size = dimensions
			viewport.gui_embed_subwindows = true
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(viewport)
			var ui := Main.new()
			ui.bootstrap_on_ready = false
			ui.content = fixtures.content
			ui.game = fixtures.fixture()
			var store := ActionTests.FaultStore.new()
			ui.saves = store
			ui.profile = store.default_profile()
			ui.profile["font_scale"] = scale_value
			ui.profile["reduced_motion"] = true
			ui.ads = AdService.new()
			ui.ads.configure({})
			ui.billing = BillingService.new()
			ui.billing.configure({})
			viewport.add_child(ui)
			ui._build_shell()
			ui._show_event()
			for item_id: String in ["runner_jacket", "scrap_vest", "wrecking_bar", "plated_coat", "scrap_buckler", "canned_meat", "clean_water", "cloth_bandage", "medkit", "rad_tabs", "scrap_parts", "ration_bar", "stimulant", "painkillers"]:
				ui.game.run_state["survivor"]["inventory"][item_id] = 2
			await _settle()

			await _verify_phone_pages(ui, context)
			await _verify_item_sheet(ui, context)
			await _verify_inventory_memory(ui, context)
			await _verify_allocation(ui, context)
			await _verify_event_roll(ui, context)
			await _verify_reveal_screen(ui, context)
			await _verify_run_summary(ui, context)
			await _verify_contextual_tips(ui, context)
			await _verify_road_chronicle(ui, context)

			viewport.queue_free()
			await process_frame
	print("Layout assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func _verify_safe_area_rules() -> void:
	var viewport := Vector2(393, 852)
	var safe := ResponsiveRules.logical_safe_rect(viewport, Vector2(1179, 2556), Rect2(30, 120, 1119, 2316))
	verify(safe.is_equal_approx(Rect2(18, 48, 357, 756)), "Physical cutout insets convert to logical pixels with an eight-pixel gap")
	verify(ResponsiveRules.logical_safe_rect(viewport, Vector2.ZERO, Rect2()).is_equal_approx(Rect2(Vector2.ZERO, viewport)), "An unavailable safe-area report keeps the usable viewport")
	for bottom: bool in [false, true]:
		var sheet := Rect2(ResponsiveRules.overlay_rect(safe, 0.98, 0.98, bottom))
		verify(safe.encloses(sheet), "Large centered and bottom sheets stay inside asymmetric device cutouts")
	var short_safe := Rect2(8, 40, 304, 250)
	verify(short_safe.encloses(Rect2(ResponsiveRules.overlay_rect(short_safe))), "Minimum sheet height cannot outrun a reduced safe area")


func _settle() -> void:
	for frame in range(4):
		await process_frame


func _capture(ui, screen_name: String) -> void:
	if "--screenshots" not in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	var dimensions: Vector2 = ui.get_viewport_rect().size
	ui.get_viewport().get_texture().get_image().save_png("res://builds/phone-%dx%d-%.1f-%s.png" % [dimensions.x, dimensions.y, ui.profile["font_scale"], screen_name])


func _verify_page_bounds(ui, context: String) -> void:
	var rect: Rect2 = ui.page.get_global_rect()
	var dimensions: Vector2 = ui.get_viewport_rect().size
	verify(rect.position.x >= 0 and rect.end.x <= dimensions.x + 1, "Page fits phone width " + context + " " + str(rect))
	verify(rect.end.y <= dimensions.y + 1, "Page fits phone height " + context + " " + str(rect))


func _verify_phone_pages(ui, context: String) -> void:
	ui._show_main_menu()
	await _settle()
	_verify_page_bounds(ui, "main menu " + context)
	verify(not ui.tip_banner.visible, "Journey tips do not take space from the main menu " + context)
	await _capture(ui, "menu")
	ui.candidates = ui.game.create_candidates(4401)
	ui._show_candidates()
	await _settle()
	_verify_page_bounds(ui, "survivor selection " + context)
	verify(not ui.tip_banner.visible, "Journey tips do not take space from survivor selection " + context)
	await _capture(ui, "candidates")
	ui._show_event()
	await _settle()
	_verify_page_bounds(ui, "event " + context)
	await _capture(ui, "event")
	ui.game.run_state["phase"] = "checkpoint"
	ui.game.run_state["checkpoint_action"] = "rest"
	ui.game.run_state["unspent_stat_points"] = 0
	ui._show_checkpoint()
	await _settle()
	var rest_departure := ui.page.find_child("CheckpointDeparture", true, false) as Button
	_verify_pinned(rest_departure, ui.get_viewport_rect().size.y, "leave after resting " + context)
	if rest_departure != null:
		var departure_rect := rest_departure.get_global_rect()
		verify(departure_rect.position.x >= 0 and departure_rect.end.x <= ui.get_viewport_rect().size.x + 1, "Rest departure fits phone width " + context + " " + str(departure_rect))
	await _capture(ui, "checkpoint-rested")
	ui.game.run_state["phase"] = "event"
	ui.game.run_state["checkpoint_action"] = ""
	ui.game.run_state["survivor"]["conditions"] = ["shaken"]
	ui._show_stat_details()
	await _settle()
	var stat_sheet: PopupPanel = ui.stat_details_popup
	verify(stat_sheet != null and stat_sheet.visible, "Stat reference opens " + context)
	if stat_sheet != null:
		var stat_copy := "\n".join(_label_texts(stat_sheet))
		verify(stat_sheet.find_child("StatDetailsScroll", true, false) != null, "Stat reference scrolls its five abilities " + context)
		verify("STRENGTH" in stat_copy and "EQUIPPED:" in stat_copy, "Stat reference names practical abilities and equipped bonuses " + context)
		verify("ACTIVE CONDITIONS" not in stat_copy and "SHAKEN" not in stat_copy, "Stat reference keeps conditions out of the stat sheet " + context)
		_verify_pinned(_button_with(stat_sheet, "×"), stat_sheet.size.y, "close stat reference " + context)
	await _capture(ui, "stats")
	ui._close_stat_details()
	await _settle()
	ui.game.run_state["survivor"]["conditions"] = []
	ui._show_settings()
	await _settle()
	verify(ui.settings_popup.size.x <= ui.get_viewport_rect().size.x, "Settings fit phone width " + context)
	verify(ui.settings_popup.size.y <= ui.get_viewport_rect().size.y, "Settings fit phone height " + context)
	_verify_pinned(_button_with(ui.settings_popup, "×"), ui.settings_popup.size.y, "close settings " + context)
	await _capture(ui, "settings")
	for section: String in ["Reading", "Sound", "Display", "Help"]:
		ui._select_settings_section(section)
		await _settle()
		var settings_sheet: PopupPanel = ui.settings_popup
		_verify_pinned(_button_with(settings_sheet, "DONE"), settings_sheet.size.y, "finish settings " + section + " " + context)
		var categories := settings_sheet.find_child("SettingsCategories", true, false)
		verify(categories != null and not _inside_scroll(categories), "Settings categories stay reachable " + context)
		for control: Button in _buttons(settings_sheet):
			verify(control.get_global_rect().end.x <= settings_sheet.size.x + 1, "Settings control fits sheet: " + control.text + " " + context)
		await _capture(ui, "settings-" + section.to_lower())
	ui._select_settings_section("Reading")
	await _settle()
	var speed := ui.settings_popup.find_child("Setting_story_text_speed", true, false) as OptionButton
	verify(speed != null, "Story speed offers explicit choices " + context)
	if speed != null:
		speed.select(3)
		speed.item_selected.emit(3)
		verify(ui.profile.get("story_text_speed") == "instant" and ui.saves.load_profile().get("story_text_speed") == "instant", "Selecting Instant persists directly " + context)
	ui._close_settings()
	await _settle()


func _verify_item_sheet(ui, context: String) -> void:
	ui._show_inventory()
	await _settle()
	var viewport_rect := Rect2(Vector2.ZERO, ui.get_viewport_rect().size)
	verify(viewport_rect.encloses(Rect2(ui.inventory_popup.position, ui.inventory_popup.size)), "Inventory sheet fits the phone " + context + " " + str(ui.inventory_popup.size))
	var weight := ui.inventory_popup.find_child("InventoryWeightFooter", true, false) as Control
	verify(weight != null and float(ui.inventory_popup.position.y) + weight.get_global_rect().end.y <= viewport_rect.end.y, "Inventory weight stays visible below its scrolling list " + context)
	_verify_no_force_broken_labels(ui.inventory_popup, "in the inventory " + context)
	await _capture(ui, "inventory")
	ui._show_item_detail("wrecking_bar")
	await _settle()
	var sheet: PopupPanel = ui.item_detail_popup
	verify(sheet != null and sheet.visible, "Item sheet opens " + context)
	if sheet == null:
		return
	var scroll: ScrollContainer = sheet.find_child("ItemDetailScroll", true, false)
	verify(scroll != null, "Item sheet scrolls its description and modifiers " + context)
	var description := _label_with(sheet, str(ui.content.get_item("wrecking_bar").get("description", "")))
	verify(description != null and _inside_scroll(description), "Item description scrolls " + context)
	var comparison := _label_with(sheet, "Neutral values")
	verify(comparison != null and _inside_scroll(comparison), "Detailed modifiers scroll " + context)
	_verify_no_force_broken_labels(sheet, "in the item sheet " + context)
	for button: Button in _buttons(sheet):
		_verify_pinned(button, sheet.size.y, "%s in the item sheet %s" % [button.text.replace("\n", " "), context])
	await _capture(ui, "item")
	ui._close_item_detail()
	await process_frame


## Wrapped text must break at word boundaries, never mid-word: a wrapping label
## showing more visible lines than words is rendering one letter per line
## inside a container that offers it no width.
func _verify_no_force_broken_labels(node: Node, context: String) -> void:
	for candidate: Node in _descendants(node):
		if candidate is Label and (candidate as Label).visible:
			var label := candidate as Label
			if label.autowrap_mode == TextServer.AUTOWRAP_OFF:
				continue
			var words := str(label.text).strip_edges().split(" ", false).size()
			if words < 2:
				continue
			verify(label.get_visible_line_count() <= words, "Text wraps at word boundaries %s '%s'" % [context, str(label.text).substr(0, 60)])


func _verify_inventory_memory(ui, context: String) -> void:
	ui._show_inventory()
	await _settle()
	var scroll: ScrollContainer = ui.inventory_popup.find_child("InventoryScroll", true, false)
	verify(scroll != null, "Inventory list scrolls " + context)
	if scroll == null:
		return
	ui._set_inventory_filter("gear")
	await _settle()
	scroll = ui.inventory_popup.find_child("InventoryScroll", true, false)
	scroll.scroll_vertical = 24
	await process_frame
	var remembered := scroll.scroll_vertical
	ui._show_item_detail("runner_jacket")
	await _settle()
	_verify_no_force_broken_labels(ui.item_detail_popup, "in the armor sheet " + context)
	ui._close_item_detail()
	ui._show_inventory(false)
	await _settle()
	var restored: ScrollContainer = ui.inventory_popup.find_child("InventoryScroll", true, false)
	verify(ui.inventory_filter == "gear", "Returning from an item sheet keeps the inventory filter " + context)
	verify(restored != null and restored.scroll_vertical == remembered, "Returning from an item sheet keeps the scroll position " + context)
	ui._close_inventory()
	await process_frame


func _verify_allocation(ui, context: String) -> void:
	ui.game.run_state["phase"] = "checkpoint"
	ui.game.run_state["unspent_stat_points"] = 2
	ui._show_level_allocation()
	await _settle()
	var sheet: PopupPanel = ui.level_popup
	verify(sheet != null and sheet.visible, "Allocation opens " + context)
	if sheet == null:
		return
	_verify_pinned(_button_with(sheet, "APPLY POINTS"), sheet.size.y, "apply allocation " + context)
	_verify_pinned(_button_with(sheet, "RETURN WITHOUT SPENDING"), sheet.size.y, "leave allocation " + context)
	ui._cancel_level_draft()
	await process_frame


func _verify_event_roll(ui, context: String) -> void:
	ui.game.run_state["phase"] = "roll_pending"
	ui.game.run_state["pending_resolution"] = {"choice_index": 0, "stat": "wits", "stat_label": "Wits", "success_chance": 60, "required_roll": 9}
	ui._show_event_roll()
	await _settle()
	verify(_label_with(ui.page, "ROLL 9+") != null, "The event roll names its target as ROLL N+ " + context)
	_verify_page_bounds(ui, "event roll " + context)
	verify(ui.page.find_child("EventRollScroll", true, false) != null, "The event roll scrolls its description and die " + context)
	_verify_pinned(_button_with(ui.page, "ROLL D20"), float(ui.get_viewport_rect().size.y), "roll the event die " + context)
	ui.game.run_state["phase"] = "event"


## A heavy result — consequences, experience, a level-up and a condition — used
## to push Continue off the bottom of the screen, where nothing could scroll to
## reach it. The reading scrolls; the way out stays pinned.
func _verify_reveal_screen(ui, context: String) -> void:
	var phase_before := str(ui.game.run_state.get("phase", "event"))
	ui.game.run_state["last_result"] = {
		"event_id": "layout_probe",
		"outcome_text": "The bottom number was thirty. Then twenty. Now it says ask. Somebody in there is losing an argument about you, and the argument is not going their way.",
		"changes": ["Ration Bar +2", "Clean Water +1", "Fatigue +6", "Scrap Parts +3"],
		"xp_awards": [{"source": "Favorable success", "awarded": 12, "levels_gained": 1}],
		"condition_changes": [{"id": "shaken", "change": "added"}],
		"resolution": {"roll": 15, "outcome": "success", "succeeded": true, "success_chance": 65, "required_roll": 8, "difficulty": "steady", "rules_version": 3},
	}
	ui._show_result()
	await _settle()
	var scroll: ScrollContainer = ui.page.find_child("RevealScroll", true, false)
	verify(scroll != null, "The reveal scrolls its reading " + context)
	var consequence := _label_with(ui.page, "Ration Bar +2")
	verify(consequence != null and _inside_scroll(consequence), "Consequences scroll with the reading " + context)
	_verify_pinned(_button_with(ui.page, "continue"), float(ui.get_viewport_rect().size.y), "leave the reveal " + context)
	await _capture(ui, "result")
	ui.game.run_state["phase"] = phase_before


func _verify_run_summary(ui, context: String) -> void:
	ui.game.run_state["finalized"] = true
	ui.game.run_state["phase"] = "death"
	ui._finish_run(false)
	await _settle()
	var scroll: ScrollContainer = ui.page.find_child("RunSummaryScroll", true, false)
	verify(scroll != null, "The run summary scrolls its record " + context)
	# Anchored on the record itself rather than one heading, so a copy restyle
	# does not read as a layout failure.
	var record := _label_with(ui.page, "Regions reached")
	verify(record != null and _inside_scroll(record), "Death detail scrolls " + context)
	var viewport_height := float(ui.get_viewport_rect().size.y)
	_verify_pinned(_button_with(ui.page, "new run"), viewport_height, "restart after death " + context)
	ui.game.run_state["phase"] = "victory"
	ui._finish_run(true)
	await _settle()
	verify(ui.page.find_child("RunSummaryScroll", true, false) != null, "The victory summary scrolls its record " + context)
	_verify_pinned(_button_with(ui.page, "new run"), viewport_height, "restart after victory " + context)
	_verify_pinned(_button_with(ui.page, "main menu"), viewport_height, "navigate after victory " + context)
	_verify_pinned(_button_with(ui.page, "main menu"), viewport_height, "navigate after death " + context)
## M08: guidance is non-blocking. It shortens the page instead of covering it,
## it never opens over a resolving die, and it changes nothing in the run.
func _verify_contextual_tips(ui, context: String) -> void:
	ui.game.run_state["phase"] = "event"
	ui.game.run_state["current_event_id"] = "outskirts_bus"
	ui.profile["contextual_tips_enabled"] = true
	ui.profile["contextual_tips_seen"] = []
	ui._hide_contextual_tip()

	# a resolving die outranks guidance
	ui.event_committing = true
	ui._show_event()
	await _settle()
	verify(not ui.tip_banner.visible, "No tip opens while a die is resolving " + context)
	ui.event_committing = false

	var before: Dictionary = ui.game.run_state.duplicate(true)
	ui._show_event()
	await _settle()
	verify(ui.tip_banner.visible and ui.active_tip_id == "checked_choice", "A checked choice offers its tip " + context)
	verify(ui.game.run_state == before, "Showing a tip changes no run value " + context)
	var banner: PanelContainer = ui.tip_banner
	var banner_rect: Rect2 = banner.get_global_rect()
	var page_controls := _buttons(ui.page)
	verify(page_controls.size() > 0, "The event still renders its choices " + context)
	for control: Button in page_controls:
		if _inside_scroll(control):
			continue
		var rect := control.get_global_rect()
		verify(not rect.intersects(banner_rect), "Guidance never covers %s %s %s vs banner %s" % [control.name, context, rect, banner_rect])
		verify(rect.end.y <= float(ui.get_viewport_rect().size.y) + 1.0, "Page controls stay on screen beside guidance %s %s" % [context, rect])
	for scroller: Node in _descendants(ui.page):
		if scroller is ScrollContainer:
			var scroll_rect: Rect2 = (scroller as ScrollContainer).get_global_rect()
			verify(not scroll_rect.intersects(banner_rect), "Guidance never covers a scrollable region " + context)
			verify(scroll_rect.end.y <= float(ui.get_viewport_rect().size.y) + 1.0, "Scrollable regions stay on screen beside guidance " + context)
	var strip := _button_with(ui.tip_banner, "exact odds")
	verify(strip != null and strip.get_global_rect().size.y >= 44.0, "The tip states the odds and the roll on one dismissible strip " + context)
	verify(strip != null and strip.get_global_rect().end.y <= float(ui.get_viewport_rect().size.y) + 1.0, "Guidance stays on screen " + context)

	ui._dismiss_contextual_tip()
	await _settle()
	verify(not ui.tip_banner.visible and ui.active_tip_id == "", "Dismissing closes the tip " + context)
	verify("checked_choice" in ui.profile["contextual_tips_seen"], "Dismissal is recorded in the profile " + context)
	verify(ui.game.run_state == before, "Dismissing a tip changes no run value " + context)
	ui._show_event()
	await _settle()
	verify(not ui.tip_banner.visible, "A dismissed tip does not repeat " + context)
	verify(ui.saves.load_profile().get("contextual_tips_seen", []).has("checked_choice"), "Tip progress persists to the stored profile " + context)

	# turning tips off silences the remaining moments
	ui.game.run_state["phase"] = "checkpoint"
	ui.game.run_state["unspent_stat_points"] = 2
	ui._show_checkpoint()
	await _settle()
	verify(ui.tip_banner.visible and ui.active_tip_id == "checkpoint_allocation", "A checkpoint with points offers its tip " + context)
	ui._toggle_setting(false, "contextual_tips_enabled")
	await _settle()
	verify(not ui.tip_banner.visible and not bool(ui.profile["contextual_tips_enabled"]), "Settings can switch every tip off " + context)
	ui._show_checkpoint()
	await _settle()
	verify(not ui.tip_banner.visible, "Switched-off tips stay closed " + context)

	# settings can start them over
	ui._reset_contextual_tips()
	verify(bool(ui.profile["contextual_tips_enabled"]) and (ui.profile["contextual_tips_seen"] as Array).is_empty(), "Resetting clears tip progress " + context)
	ui._show_checkpoint()
	await _settle()
	verify(ui.tip_banner.visible, "Reset tips appear again " + context)
	ui._hide_contextual_tip()
	ui.game.run_state["phase"] = "event"
## M09: the Chronicle reports what was recorded and nothing else, and the resume
## recap is offered only when the player chooses to continue.
func _verify_road_chronicle(ui, context: String) -> void:
	ui.profile["run_history"] = [
		{"run_id": "recent", "result": "dead", "survivor": "Nia Cross", "callsign": "Sparrow", "region": "Drowned Marches", "level": 3, "equipment": ["Wrecking Bar", "Plated Coat"], "strongest_enemy": "Bog Raiders", "cause": "Bled out in the reeds"},
		{"run_id": "legacy", "result": "dead", "survivor": "Older Survivor"},
	]
	ui.profile["discovered_story_nodes"] = ["ledger_b41_signal"]

	ui._show_road_chronicle("runs")
	await _settle()
	var runs_copy := "
".join(_label_texts(ui.page))
	verify(_button_with(ui.page, "RUNS") != null and _button_with(ui.page, "DISCOVERIES") != null, "The Chronicle offers both tabs " + context)
	verify("Nia Cross" in runs_copy and "Drowned Marches" in runs_copy and "Wrecking Bar" in runs_copy and "Bog Raiders" in runs_copy and "Bled out in the reeds" in runs_copy, "A recorded run shows survivor, region, equipment, strongest enemy, and cause " + context)
	verify("Not recorded" in runs_copy, "An older summary reports its missing fields instead of inventing them " + context)
	verify(ui.page.find_child("ChronicleRunsScroll", true, false) != null, "The run list scrolls " + context)
	_verify_pinned(_button_with(ui.page, "BACK"), float(ui.get_viewport_rect().size.y), "leave the Chronicle " + context)

	ui._show_road_chronicle("discoveries")
	await _settle()
	var discoveries_copy := "
".join(_label_texts(ui.page))
	verify("1 / 29 chapters" in discoveries_copy, "Discovery progress counts every chapter the default build can reach " + context)
	verify("1 recorded account" in discoveries_copy, "Accounts are counted apart from chapters " + context)
	verify("BUNKER FORTY-ONE" in discoveries_copy and "Family on Channel Nine".to_upper() in discoveries_copy, "The default Chronicle advertises its Living Road chapters with spoiler-safe hints " + context)
	verify(ui.page.find_child("ChronicleDiscoveriesScroll", true, false) != null, "The discovery list scrolls " + context)
	_verify_pinned(_button_with(ui.page, "BACK"), float(ui.get_viewport_rect().size.y), "leave the discoveries tab " + context)

	# The recap appears only on Continue Run, and dismissing it resumes the run.
	ui.game.run_state["phase"] = "event"
	ui.game.run_state["status"] = "active"
	ui.game.run_state["survivor"]["conditions"] = ["shaken"]
	ui.game.run_state["last_result"] = {"choice": "Trace the emergency release", "outcome_text": "The doors fold inward without disturbing the photographs."}
	ui._show_main_menu()
	await _settle()
	verify(_button_with(ui.page, "road chronicle") != null, "The title menu carries one Chronicle entry " + context)
	verify(not is_instance_valid(ui.recap_popup) or not ui.recap_popup.visible, "No recap appears before the player continues " + context)
	ui._continue_run()
	await _settle()
	var recap: PopupPanel = ui.recap_popup
	verify(recap != null and recap.visible, "Continuing a run offers a recap " + context)
	var recap_copy := "
".join(_label_texts(recap))
	verify("region" in recap_copy and "Trace the emergency release" in recap_copy and "Shaken" in recap_copy, "The recap is derived from location, the last choice, and current conditions " + context)
	verify(recap.find_child("ResumeRecapScroll", true, false) != null, "The recap scrolls its detail " + context)
	_verify_pinned(_button_with(recap, "RESUME"), recap.size.y, "resume from the recap " + context)
	ui._dismiss_recap()
	await _settle()
	verify(not ui.recap_popup.visible, "The recap is dismissible " + context)
	ui._hide_contextual_tip()
