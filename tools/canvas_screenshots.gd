extends SceneTree

## Boots the real UI at the canvas artboard size and captures each screen so the
## implementation can be compared against the design canvas side by side.

const SHOT_SIZE := Vector2i(393, 852)
const OUT_DIR := "user://canvas_shots"


func _initialize() -> void:
	DisplayServer.window_set_size(SHOT_SIZE)
	root.content_scale_size = SHOT_SIZE
	var scene: PackedScene = load("res://scenes/main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute(OUT_DIR)

	var shots: Array = [
		["01_title", func() -> void: ui._show_main_menu()],
		["02_survivor", func() -> void: ui._begin_candidate_selection()],
	]
	for shot: Array in shots:
		await _capture(ui, str(shot[0]), shot[1])

	# Everything past character selection needs a live run.
	ui._select_candidate(0)
	await _capture(ui, "03_event", func() -> void: ui._show_event())
	# The choice rows only exist once the typewriter finishes.
	await _capture(ui, "03b_choices", func() -> void:
		ui._show_event()
		if is_instance_valid(ui.active_story):
			ui.active_story.reveal_all()
	)
	ui.game.run_state["last_result"] = {
		"event_id": str(ui.game.run_state.get("current_event_id", "")),
		"outcome_text": "The bottom number was thirty. Then twenty. Now it says ask. Somebody in there is losing an argument about you.",
		"changes": ["Fatigue +4"],
		"resolution": {"roll": 14, "outcome": "success", "succeeded": true, "success_chance": 65, "required_roll": 11, "difficulty": "steady", "rules_version": 3},
	}
	await _capture(ui, "04_reveal", func() -> void: ui._show_result())
	await _capture(ui, "05_checkpoint", func() -> void: ui._show_checkpoint())
	await _capture(ui, "06_inventory", func() -> void: ui._show_inventory())
	ui._close_inventory()
	ui.game.run_state["status"] = "dead"
	ui.game.run_state["death_cause"] = "Killed by a Citadel Guard's baton, three steps from the wall."
	await _capture(ui, "07_death", func() -> void: ui._finish_run(false))
	print("Wrote captures to ", ProjectSettings.globalize_path(OUT_DIR))
	quit()


func _capture(ui: Control, shot_name: String, build: Callable) -> void:
	build.call()
	for _index in range(6):
		await process_frame
	var image := root.get_texture().get_image()
	image.save_png("%s/%s.png" % [OUT_DIR, shot_name])


func _process(_delta: float) -> bool:
	return false
