extends SceneTree
const Main = preload("res://scripts/ui/main.gd")
const ActionTests = preload("res://tests/action_transaction_tests.gd")
var failures := 0
var assertions := 0


func _init() -> void:
	call_deferred("_run")


func verify(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		push_error(message)


func _run() -> void:
	var fixtures := ActionTests.new()
	fixtures.content = ContentRepository.new()
	for dimensions: Vector2i in [Vector2i(360,640), Vector2i(540,960), Vector2i(540,1200)]:
		for mode: String in ["allocation", "inventory", "drop", "rest", "event", "combat"]:
			var viewport := SubViewport.new()
			viewport.size = dimensions
			root.add_child(viewport)
			var ui := Main.new()
			ui.bootstrap_on_ready = false
			ui.content = fixtures.content
			ui.game = fixtures.fixture()
			var store := ActionTests.FaultStore.new()
			ui.saves = store
			ui.profile = store.default_profile()
			ui.profile["font_scale"] = 1.2
			ui.profile["reduced_motion"] = true
			ui.ads = AdService.new()
			ui.ads.configure({})
			viewport.add_child(ui)
			ui._build_shell()
			ui._show_event()
			var original_sheet: PopupPanel
			var source_text := ""
			match mode:
				"allocation":
					ui.game.run_state["phase"] = "checkpoint"
					ui.game.run_state["unspent_stat_points"] = 1
					ui._show_level_allocation()
					ui._change_stat_draft("strength", 1)
					original_sheet = ui.level_popup
					source_text = ui.allocation_remaining_label.text
					store.fail_run_at = store.writes + 2
					ui._confirm_level_draft()
				"inventory":
					ui._show_inventory()
					ui._show_item_detail("runner_jacket")
					original_sheet = ui.item_detail_popup
					store.fail_run_at = store.writes + 2
					ui._inventory_action("equip", "runner_jacket")
				"drop":
					ui._show_inventory()
					ui._show_item_detail("cloth_bandage")
					ui._confirm_drop("cloth_bandage", 1)
					original_sheet = ui.confirmation_popup
					store.fail_run_at = store.writes + 2
					ui._perform_drop("cloth_bandage", 1)
				"rest":
					ui.game.run_state["phase"] = "checkpoint"
					ui._show_checkpoint()
					ui._show_rest_food()
					original_sheet = ui.action_popup
					store.fail_run_at = store.writes + 2
					ui._rest("canned_meat")
				"event":
					ui._resolve_choice(0)
					store.fail_run = true
					ui._commit_event_roll(null)
				"combat":
					ui.game.run_state["current_event_id"] = "outskirts_dogs"
					ui._resolve_choice(0)
					ui._prepare_combat_action("attack")
					store.fail_run = true
					ui._commit_combat_roll(ui.active_combat_presentation)
			for frame in range(4): await process_frame
			verify(ui.combat_transaction.is_locked(), mode + ": gameplay locked during failed commit")
			verify(is_instance_valid(ui.save_recovery_popup) and ui.save_recovery_popup.visible, mode + ": Retry is visible")
			var retry: Button = ui.save_recovery_popup.find_child("RetrySave", true, false)
			var retry_rect := retry.get_global_rect()
			verify(retry_rect.size.y >= 44 and retry_rect.end.y <= ui.save_recovery_popup.size.y + 1, mode + ": Retry remains reachable at " + str(dimensions) + " Large text")
			if mode not in ["event", "combat"]:
				verify(original_sheet.visible and not original_sheet.is_queued_for_deletion(), mode + ": originating sheet has not refreshed or closed")
			elif mode == "event":
				verify(ui.active_story == null, "Event result remains hidden until committed")
			else:
				verify(not ui.active_combat_presentation.animating, "Combat result remains hidden until committed")
			if mode == "allocation":
				verify(ui.allocation_remaining_label.text == source_text and not ui.stat_draft.is_empty(), "Failed allocation preserves the displayed draft")
			var resolved: Dictionary = ui.game.run_state.duplicate(true)
			var profile_before: Dictionary = ui.profile.duplicate(true)
			var cancel := InputEventAction.new()
			cancel.action = "ui_cancel"
			cancel.pressed = true
			ui._unhandled_key_input(cancel)
			ui._notification(Main.NOTIFICATION_WM_GO_BACK_REQUEST)
			ui._notification(Main.NOTIFICATION_APPLICATION_PAUSED)
			ui._show_main_menu()
			ui._cancel_level_draft()
			ui._inventory_action("use", "medkit")
			ui._prepare_combat_action("attack")
			ui._dismiss_tutorial()
			ui._toggle_setting(true, "high_contrast")
			verify(ui.profile == profile_before, mode + ": pending receipt cannot be bypassed by tutorial or settings changes")
			verify(ui.save_recovery_popup.visible and resolved == ui.game.run_state and ui.combat_transaction.is_locked(), mode + ": Back/background/other actions cannot bypass recovery")
			store.fail_run = true
			ui._retry_pending_save()
			verify(resolved == ui.game.run_state and ui.save_recovery_popup.visible, mode + ": repeated Retry never reapplies action")
			store.fail_run = false
			ui._retry_pending_save()
			if mode == "combat":
				for frame in range(120):
					await process_frame
					if not ui.combat_committing: break
			for frame in range(4): await process_frame
			verify(not ui.combat_transaction.is_locked() and not is_instance_valid(ui.save_recovery_popup), mode + ": successful Retry releases UI")
			if mode == "allocation":
				verify(ui.stat_draft.is_empty() and not original_sheet.visible and ui.game.run_state["unspent_stat_points"] == 0, "Allocation returns only after commitment")
			elif mode in ["inventory", "drop", "rest"]:
				verify(not is_instance_valid(original_sheet) or not original_sheet.visible, mode + ": committed action closes old details")
			elif mode == "event":
				verify(is_instance_valid(ui.active_story), "Committed event finally displays its result")
			else:
				verify(not ui.combat_committing and ui.game.run_state["combat_state"]["round"] == 1, "Committed combat presents exactly one completed exchange")
			var committed: Dictionary = ui.game.run_state.duplicate(true)
			ui._retry_pending_save()
			verify(ui.game.run_state == committed, mode + ": repeated callback cannot commit twice")
			store.fail_profile = true
			var old_speed := str(ui.profile["story_text_speed"])
			ui._cycle_story_speed()
			verify(str(ui.profile["story_text_speed"]) == old_speed, mode + ": uncommitted preferences remain unchanged on save failure")
			viewport.queue_free()
			await process_frame
			store.cleanup()
	print("Action UI assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures else 0)
