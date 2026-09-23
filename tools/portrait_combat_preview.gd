extends SceneTree

## Renders one combat screen against a named adversary for visual asset review.
const Main = preload("res://scripts/ui/main.gd")
const Fixtures = preload("res://tests/narrative_combat_tests.gd")
const VIEWPORT_SIZE := Vector2i(393, 852)
const OUTPUT_PATH := "res://builds/preview-marsh-leeches-combat.png"


func _init() -> void:
	call_deferred("_render")


func _render() -> void:
	var factory := Fixtures.new()
	factory.content = ContentRepository.new()
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var ui := Main.new()
	ui.bootstrap_on_ready = false
	ui.content = factory.content
	ui.game = factory.fixture("marsh_leeches", "salvage_cleaver", "scrap_vest")
	ui.profile = SaveService.new().default_profile()
	ui.profile["selected_theme"] = "rust"
	ui.profile["reduced_motion"] = true
	viewport.add_child(ui)
	ui._build_shell()
	ui._show_cinematic_combat()
	for _frame in range(6):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		printerr("Could not write combat preview: ", OUTPUT_PATH)
		quit(1)
		return
	print("Wrote Marsh Leeches combat preview to ", ProjectSettings.globalize_path(OUTPUT_PATH))
	quit()
