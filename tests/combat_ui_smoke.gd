extends SceneTree
const Main = preload("res://scripts/ui/main.gd")
const Fixtures = preload("res://tests/narrative_combat_tests.gd")
var failures := 0

class MemorySaves extends SaveService:
	var fail_write := false
	var snapshot: Dictionary = {}
	func save_run(state: Dictionary) -> bool:
		if fail_write: return false
		snapshot = state.duplicate(true)
		return true

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var factory := Fixtures.new()
	factory.content = ContentRepository.new()
	for dimensions: Vector2i in [Vector2i(360,640), Vector2i(393,852), Vector2i(540,1200)]:
		for scale_value: float in [0.9, 1.0, 1.2]:
			for prepared: bool in [false, true]:
				var viewport := SubViewport.new()
				viewport.size = dimensions
				viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
				root.add_child(viewport)
				var ui := Main.new()
				ui.bootstrap_on_ready = false
				ui.content = factory.content
				ui.game = factory.fixture("warden_machine", "wrecking_bar", "plated_coat")
				ui.game.run_state["combat_state"]["riposte"] = true
				ui.game._apply_condition("shaken")
				ui.profile = SaveService.new().default_profile()
				ui.profile["font_scale"] = scale_value
				ui.profile["selected_theme"] = "default" if dimensions.x == 360 else "rust" if dimensions.y == 960 else "night"
				ui.profile["high_contrast"] = scale_value == 1.2
				ui.profile["reduced_motion"] = true
				viewport.add_child(ui)
				ui._build_shell()
				if prepared: ui.game.prepare_combat_action("attack")
				var pre_guidance: Dictionary = ui.game.run_state.duplicate(true)
				ui._show_cinematic_combat()
				for i in range(5): await process_frame
				var presentation = ui.active_combat_presentation
				var grid: GridContainer = presentation.find_child("NarrativeActionGrid", true, false)
				var context := "%s scale %.1f prepared %s" % [dimensions, scale_value, prepared]
				verify(grid != null and grid.get_child_count() == 6 and grid.columns == 2, "Six stable actions " + context)
				for button: Button in grid.get_children():
					var rect := button.get_global_rect()
					verify(rect.size.y >= 44 and rect.position.x >= 0 and rect.end.x <= dimensions.x + 1 and rect.end.y <= dimensions.y + 1, "Action fits " + str(button.name) + " " + context + " " + str(rect))
					if prepared: verify(button.disabled, "Prepared actions locked")
				verify(presentation.player_art.get_global_rect().position.x < presentation.enemy_art.get_global_rect().position.x, "Player left, enemy right")
				var exchange: Node = presentation.find_child("CombatExchangePanel", true, false)
				verify(exchange != null and exchange.find_child("CommittedEnemyTell", true, false) != null and exchange.find_child("AttackWindowStatus", true, false) != null and exchange.find_child("CombatFeedScroll", true, false) != null, "Clue, attack windows, and the latest consequence share one block " + context)
				for button: Button in grid.get_children():
					var lines := str(button.text).split("
")
					if lines.size() > 1 and "+" in lines[1]:
						verify(lines[1].begins_with("ROLL "), "Dice targets are named ROLL N+ " + str(button.name) + " " + context)
				verify(presentation.feed_scroll.size.x > 100, "Full-width horizontal combat text")
				verify(ui.game.run_state == pre_guidance, "Rendering combat with guidance changes no committed move, roll, or result " + context)
				if prepared:
					verify(not ui.tip_banner.visible, "No tip opens while a saved roll waits to be revealed " + context)
				else:
					verify(ui.tip_banner.visible and ui.active_tip_id != "", "Combat offers its contextual guidance " + context)
					verify(ui.tip_banner.get_global_rect().end.y <= dimensions.y + 1, "Guidance stays on screen in combat " + context + " " + str(ui.tip_banner.get_global_rect()))
				if prepared and dimensions == Vector2i(393,852) and scale_value == 1.0:
					var result := ui.game.resolve_prepared_combat_round()
					await presentation.play_round(result, true)
					verify(not presentation.animating and presentation.player_bar.value == result["presentation"]["player_health_after"], "Reduced motion ends at authoritative HP")
				if "--screenshots" in OS.get_cmdline_user_args() and (scale_value == 1.0 or (dimensions.x == 360 and scale_value == 1.2)):
					await RenderingServer.frame_post_draw
					viewport.get_texture().get_image().save_png("res://builds/combat-%dx%d-%.1f-%s.png" % [dimensions.x, dimensions.y, scale_value, "prepared" if prepared else "ready"])
				viewport.queue_free()
				await process_frame
	await _test_roll_modes(factory)
	print("Combat layout/input failures: %d" % failures)
	quit(1 if failures > 0 else 0)

func verify(valid: bool, message: String) -> void:
	if not valid:
		failures += 1
		push_error(message)


func _test_roll_modes(factory) -> void:
	var initial: Dictionary = factory.fixture("warden_machine").run_state.duplicate(true)
	var manual_result: Dictionary = {}
	for mode: String in ["manual", "quick"]:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(393,852)
		root.add_child(viewport)
		var ui := Main.new()
		ui.bootstrap_on_ready = false
		ui.content = factory.content
		ui.game = GameEngine.new(factory.content)
		ui.game.restore_run(initial)
		var saves := MemorySaves.new()
		ui.saves = saves
		ui.profile = SaveService.new().default_profile()
		ui.profile["combat_presentation"] = mode
		ui.profile["reduced_motion"] = true
		viewport.add_child(ui)
		ui._build_shell()
		ui._show_cinematic_combat()
		ui._prepare_combat_action("attack")
		if mode == "manual":
			verify(ui.game.run_state["phase"] == "combat_roll_pending", "Manual Roll waits with a concealed saved roll")
			var presentation = ui.active_combat_presentation
			saves.fail_write = true
			ui.call_deferred("_commit_combat_roll", presentation)
			await process_frame
			await process_frame
			verify(not ui.combat_transaction.pending_result.is_empty() and is_instance_valid(ui.save_recovery_popup) and ui.save_recovery_popup.visible and not presentation.animating, "Failed combat UI save offers shared Retry without displaying a result")
			var key := InputEventAction.new()
			key.action = "ui_cancel"
			key.pressed = true
			ui._unhandled_key_input(key)
			verify(ui.active_combat_presentation == presentation, "Back cannot bypass the save-recovery lock")
			saves.fail_write = false
			ui.call_deferred("_retry_pending_save")
		for frame in range(80):
			await process_frame
			if ui.combat_committing:
				var before: Dictionary = ui.game.run_state.duplicate(true)
				ui._prepare_combat_action("attack")
				verify(ui.game.run_state == before, "Animation rejects duplicate action input")
			if frame > 5 and not ui.combat_committing and ui.game.run_state["phase"] == "combat": break
		verify(ui.game.run_state["phase"] == "combat" and not ui.combat_committing, mode + " completes exactly one exchange")
		if mode == "manual": manual_result = ui.game.run_state.duplicate(true)
		else: verify(ui.game.run_state == manual_result, "Manual and Quick Roll produce identical authoritative state")
		viewport.queue_free()
		await process_frame
