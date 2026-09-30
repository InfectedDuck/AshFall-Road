extends SceneTree

## Capture real UI states for the README from a deterministic test run.
## Run with the Godot console executable, without --headless, from the project root:
##   godot --path . --script res://tools/readme_showcase.gd

const Main = preload("res://scripts/ui/main.gd")
const SIZE := Vector2i(540, 960)
const OUTPUT_DIR := "res://docs/screenshots"


func _init() -> void:
	call_deferred("_capture_showcase")


func _capture_showcase() -> void:
	var viewport := SubViewport.new()
	viewport.size = SIZE
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var ui := Main.new()
	ui.bootstrap_on_ready = false
	ui.content = ContentRepository.new()
	ui.game = GameEngine.new(ui.content)
	ui.game.start_run(ui.game.create_candidates(4401)[0], 4401)
	ui.profile = SaveService.new().default_profile()
	ui.profile["selected_theme"] = "rust"
	ui.profile["reduced_motion"] = true
	ui.profile["contextual_tips_enabled"] = false
	viewport.add_child(ui)
	ui._build_shell()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

	# One genuine checked decision, followed by its engine-resolved outcome.
	_set_event(ui, "outskirts_bus", 0)
	await _capture_event(ui, viewport, "01-sealed-bus-choice")
	var bus_result := ui.game.resolve_choice(1, 15)
	if bus_result.has("error"):
		_fail("The Sealed Bus choice failed: " + str(bus_result["error"]))
		return
	ui._show_result()
	if is_instance_valid(ui.active_story):
		ui.active_story.reveal_all()
	await _save(viewport, "02-checked-choice-result")

	# The same survivor meets Rhea, then encounters her again later in the run.
	_set_event(ui, "rhea_meeting", 1)
	await _capture_event(ui, viewport, "03-meet-rhea")
	var meeting_result := ui.game.resolve_choice(0)
	if meeting_result.has("error"):
		_fail("Rhea meeting choice failed: " + str(meeting_result["error"]))
		return
	_set_event(ui, "rhea_disagreement", 3)
	await _capture_event(ui, viewport, "04-rhea-returns")

	# The authored dog encounter leads into a fight with damage on both sides.
	_set_event(ui, "outskirts_dogs", 0)
	var combat_start := ui.game.start_combat(0)
	if combat_start.has("error"):
		_fail("Dog combat failed to start: " + str(combat_start["error"]))
		return
	for face in [13, 12]:
		var prepared := ui.game.prepare_combat_action("attack")
		if prepared.has("error"):
			_fail("Dog combat action failed: " + str(prepared["error"]))
			return
		ui.game.run_state["pending_combat_round"]["player_roll"] = face
		ui.game.run_state["pending_combat_round"]["enemy_roll"] = 17
		var round_result := ui.game.resolve_prepared_combat_round()
		if round_result.has("error"):
			_fail("Dog combat round failed: " + str(round_result["error"]))
			return
	var combat: Dictionary = ui.game.run_state.get("combat_state", {})
	var survivor: Dictionary = ui.game.run_state.get("survivor", {})
	if str(ui.game.run_state.get("phase", "")) != "combat" or int(combat.get("enemy_health", 0)) >= int(combat.get("enemy_max_health", 0)) or int(survivor.get("vitals", {}).get("health", 0)) >= int(survivor.get("vitals", {}).get("max_health", 0)):
		_fail("Dog showcase must show an ongoing fight with damage on both sides")
		return
	print("Dog fight: player HP ", survivor["vitals"]["health"], "/", survivor["vitals"]["max_health"], "; dogs HP ", combat["enemy_health"], "/", combat["enemy_max_health"])
	ui._show_cinematic_combat()
	await _save(viewport, "05-feral-dogs-combat")

	# One person against the safety of a whole column. Let the difficult rescue
	# fail, then verify that this branch leads to the next checkpoint.
	_set_event(ui, "lr_bellkeepers_son", 2)
	ui.game.run_state["events_in_region"] = 4
	await _capture_event(ui, viewport, "06-bellkeepers-son-choice")
	var rescue_result := ui.game.resolve_choice(0, 1)
	if rescue_result.has("error"):
		_fail("Perrin rescue choice failed: " + str(rescue_result["error"]))
		return
	if "lr_perrin_saved_column_scattered" not in ui.game.run_state.get("flags", []):
		_fail("The failed rescue did not scatter the column")
		return
	ui._show_result()
	if is_instance_valid(ui.active_story):
		ui.active_story.reveal_all()
	await _save(viewport, "07-bellkeepers-son-result")
	ui.game.continue_after_result()
	if str(ui.game.run_state.get("phase", "")) != "checkpoint":
		_fail("The dilemma did not lead to a checkpoint")
		return

	# Show the later Bunker Forty-One story without revealing its outcome.
	_set_event(ui, "bunker41_last_evacuation", 5)
	await _capture_event(ui, viewport, "08-last-evacuation")
	print("README showcase captured in ", ProjectSettings.globalize_path(OUTPUT_DIR))
	quit()


func _set_event(ui: Control, event_id: String, region_index: int) -> void:
	ui.game.run_state["phase"] = "event"
	ui.game.run_state["current_event_id"] = event_id
	ui.game.run_state["region_index"] = region_index
	ui.game.run_state["events_in_region"] = 0


func _capture_event(ui: Control, viewport: SubViewport, shot_name: String) -> void:
	ui._show_event()
	if is_instance_valid(ui.active_story):
		ui.active_story.reveal_all()
	await _save(viewport, shot_name)


func _save(viewport: SubViewport, shot_name: String) -> void:
	for _frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s/%s.png" % [OUTPUT_DIR, shot_name]
	var error := viewport.get_texture().get_image().save_png(path)
	if error != OK:
		_fail("Could not save " + path + ": " + str(error))
		return
	print("Captured ", path)


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
