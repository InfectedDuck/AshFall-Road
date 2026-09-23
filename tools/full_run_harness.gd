extends SceneTree
## M11 whole-journey verification.
##
## Two jobs, deliberately separated in the output:
##
##   Replay      A recorded decision list is re-run from its seed and must
##               reproduce the same run byte for byte. This is what makes a
##               tester's session reproducible.
##   Soak        Many seeded runs driven by a legal-action policy. This is
##               robustness evidence only. A random policy is not a person, so
##               its completion rate is NOT a human completion or retention
##               estimate and is labelled as such everywhere it appears.
##
## Nothing here forces a heal, a victory, or a successful roll. Every roll comes
## from the engine's own seeded RNG, and every decision is chosen from what the
## engine reports as legal at that moment.
##
## Usage:
##   --headless --script res://tools/full_run_harness.gd
##   ... -- --soak 1000            robustness soak with N runs
##   ... -- --replay path.json     replay one recorded decision list
##   ... -- --record path.json     write the first soak run as a decision record

const Rules = preload("res://scripts/domain/narrative_combat.gd")

const STEP_CAP := 400
const COMBAT_ACTIONS := ["attack", "block", "dodge", "use_item", "flee", "opportunity"]
const RECOVERY_SAMPLE := 25

var content: ContentRepository


func _init() -> void:
	# Only autostart when Godot is using this class as the main loop. Tests and
	# other tools instantiate it to call one function without running the job.
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	content = ContentRepository.new()
	var args := OS.get_cmdline_user_args()
	var replay_path := _argument(args, "--replay")
	if replay_path != "":
		_run_replay_file(replay_path)
		return
	var soak_runs := int(_argument(args, "--soak", "1000"))
	var record_path := _argument(args, "--record", "res://builds/run_record_sample.json")
	print("Ashfall Road full-run harness")
	print("Replay determinism and recorded-decision reproduction")
	var determinism := _verify_replay_determinism(record_path)
	print("")
	print("Robustness soak: %d seeded legal-action runs" % soak_runs)
	print("NOTE: random-policy results are robustness evidence only. They are not")
	print("      human completion, difficulty, or retention estimates.")
	var soak := await _soak(soak_runs)
	var report := {
		"harness_version": 1,
		"rules_version": Rules.VERSION,
		"determinism": determinism,
		"soak": soak,
		"policy": "uniform choice among engine-reported legal actions",
		"evidence_class": "robustness only; not a human completion or retention estimate",
	}
	var file := FileAccess.open("res://builds/full_run_harness.json", FileAccess.WRITE)
	assert(file != null, "Could not open builds/full_run_harness.json for writing.")
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("")
	_print_soak(soak)
	print("Wrote builds/full_run_harness.json")
	quit(0 if bool(determinism.get("reproduced", false)) and int(soak.get("errors", 1)) == 0 else 1)


func _argument(args: PackedStringArray, name: String, fallback: String = "") -> String:
	for index in range(args.size()):
		if str(args[index]) == name and index + 1 < args.size():
			return str(args[index + 1])
	return fallback


## A recorded run is replayed from its seed and must land on an identical state.
func _verify_replay_determinism(record_path: String) -> Dictionary:
	var recorded := _play(4242, 0, {"mode": "policy", "trace": true, "record": true})
	var record := {"seed": 4242, "candidate": 0, "decisions": recorded["decisions"]}
	var file := FileAccess.open(record_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(record, "\t"))
		file.close()
	var replayed := _play(4242, 0, {"mode": "record", "decisions": record["decisions"], "trace": true})
	var reproduced: bool = _comparable_state(recorded["final_state"]) == _comparable_state(replayed["final_state"])
	print("  recorded %d decisions over %d events" % [(record["decisions"] as Array).size(), int(recorded["trace"]["events"].size())])
	print("  replayed run reproduces the recorded run: %s" % reproduced)
	print("  outcome: %s in %s" % [str(recorded["result"]), str(recorded["trace"].get("final_region", "unknown"))])
	return {
		"seed": 4242,
		"decisions": (record["decisions"] as Array).size(),
		"reproduced": reproduced,
		"record_path": record_path,
		"trace": recorded["trace"],
	}


## `started_at` is a wall clock reading, not gameplay, and `run_id` is stamped
## from the clock too (game_engine.gd:130) and then embedded in every XP award id
## and combat encounter id by `_event_xp_source_id`. A record and its replay that
## straddle a second boundary therefore differ in identity while being identical
## play. Normalize the identity rather than erasing the fields, so the comparison
## still proves the same awards happened in the same order.
func _comparable_state(state: Dictionary) -> Dictionary:
	var copy: Dictionary = _normalize_run_id(state.duplicate(true), str(state.get("run_id", "")))
	copy.erase("started_at")
	copy["run_id"] = "RUN"
	return copy


static func _normalize_run_id(value: Variant, run_id: String) -> Variant:
	if run_id == "":
		return value
	match typeof(value):
		TYPE_STRING:
			return str(value).replace(run_id, "RUN")
		TYPE_ARRAY:
			var list: Array = []
			for entry: Variant in value:
				list.append(_normalize_run_id(entry, run_id))
			return list
		TYPE_DICTIONARY:
			var mapped: Dictionary = {}
			for key: Variant in value:
				mapped[_normalize_run_id(key, run_id)] = _normalize_run_id(value[key], run_id)
			return mapped
	return value


func _soak(count: int) -> Dictionary:
	var totals := {
		"runs": count, "deaths": 0, "victories": 0, "unfinished": 0, "errors": 0,
		"regions_reached": 0, "events_resolved": 0, "levels": 0, "combats": 0,
		"equipment_found": 0, "recovery_checked": 0, "recovery_mismatches": 0,
		"causes": {}, "region_deaths": {},
	}
	for index in range(count):
		var options := {"mode": "policy", "trace": false}
		if index % maxi(1, count / RECOVERY_SAMPLE) == 0:
			options["recovery"] = true
		var outcome := _play(9000 + index, index % 3, options)
		totals["errors"] += int(outcome["errors"])
		totals["combats"] += int(outcome["combats"])
		totals["equipment_found"] += int(outcome["equipment_found"])
		totals["regions_reached"] += int(outcome["regions_reached"])
		totals["events_resolved"] += int(outcome["events_resolved"])
		totals["levels"] += int(outcome["level"])
		if bool(outcome.get("recovery_checked", false)):
			totals["recovery_checked"] += 1
			totals["recovery_mismatches"] += int(not bool(outcome.get("recovery_matched", true)))
		match str(outcome["result"]):
			"dead":
				totals["deaths"] += 1
				var cause := str(outcome["cause"])
				totals["causes"][cause] = int(totals["causes"].get(cause, 0)) + 1
				var region := str(outcome["final_region"])
				totals["region_deaths"][region] = int(totals["region_deaths"].get(region, 0)) + 1
			"victory":
				totals["victories"] += 1
			_:
				totals["unfinished"] += 1
		if index % 100 == 0:
			await process_frame
	var runs := maxf(1.0, float(count))
	totals["death_rate"] = snappedf(float(totals["deaths"]) / runs, 0.001)
	totals["victory_rate"] = snappedf(float(totals["victories"]) / runs, 0.001)
	totals["mean_regions_reached"] = snappedf(float(totals["regions_reached"]) / runs, 0.01)
	totals["mean_events_resolved"] = snappedf(float(totals["events_resolved"]) / runs, 0.01)
	totals["mean_level"] = snappedf(float(totals["levels"]) / runs, 0.01)
	totals["mean_combats"] = snappedf(float(totals["combats"]) / runs, 0.01)
	totals["mean_equipment_found"] = snappedf(float(totals["equipment_found"]) / runs, 0.01)
	return totals


## One run. `mode` is "policy" for a legal-action run or "record" to replay a
## decision list. Illegal or unavailable recorded decisions are skipped and
## counted; they are never forced onto the engine.
func _play(seed_value: int, candidate_index: int, options: Dictionary) -> Dictionary:
	var game := GameEngine.new(content)
	var candidates := game.create_candidates(seed_value)
	game.start_run(candidates[candidate_index % candidates.size()], seed_value)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var decisions: Array = options.get("decisions", [])
	var recording: Array = []
	var record_mode: bool = str(options.get("mode", "policy")) == "record"
	var trace_enabled: bool = bool(options.get("trace", false))
	var trace := {"regions": [], "events": [], "equipment": [], "experience": [], "death": {}}
	var decision_index := 0
	var steps := 0
	var errors := 0
	var combats := 0
	var equipment_found := 0
	var skipped := 0
	var recovery_checked := false
	var recovery_matched := true
	var owned_equipment := _equipment_ids(game)
	var region_marker := -1

	while steps < STEP_CAP:
		steps += 1
		var phase := str(game.run_state.get("phase", ""))
		if phase in ["death", "victory"]:
			break
		if trace_enabled and int(game.run_state.get("region_index", 0)) != region_marker:
			region_marker = int(game.run_state.get("region_index", 0))
			trace["regions"].append(_region_snapshot(game))
		var decision: Dictionary = {}
		if record_mode:
			if decision_index >= decisions.size():
				break
			decision = decisions[decision_index]
			decision_index += 1
		else:
			decision = _policy_decision(game, rng)
		var applied := _apply_decision(game, decision, phase)
		if not bool(applied.get("legal", false)):
			skipped += 1
			if record_mode:
				continue
			errors += int(bool(applied.get("error", false)))
			continue
		if bool(options.get("record", false)):
			recording.append(decision)
		if applied.has("event") and str(applied["event"].get("outcome", "")) == "combat":
			combats += 1
		if trace_enabled and applied.has("event"):
			trace["events"].append(applied["event"])
		var owned_now := _equipment_ids(game)
		for item_id: String in owned_now:
			if item_id not in owned_equipment:
				equipment_found += 1
				if trace_enabled:
					trace["equipment"].append({"item": item_id, "region": int(game.run_state.get("region_index", 0))})
		owned_equipment = owned_now
		if bool(options.get("recovery", false)) and not recovery_checked and steps > 12:
			recovery_checked = true
			var restored := GameEngine.new(content)
			restored.restore_run(game.run_state)
			recovery_matched = restored.run_state == game.run_state

	var summary := game.summary()
	if trace_enabled:
		trace["final_region"] = str(summary.get("region", ""))
		trace["experience"] = {"level": int(summary.get("level", 1)), "experience": int(summary.get("experience", 0))}
		if str(game.run_state.get("phase", "")) == "death":
			trace["death"] = {"cause": str(summary.get("cause", "")), "region": str(summary.get("region", "")), "events": int(summary.get("events_resolved", 0))}
	return {
		"result": "dead" if str(game.run_state.get("phase", "")) == "death" else ("victory" if str(game.run_state.get("phase", "")) == "victory" else "unfinished"),
		"cause": str(summary.get("cause", "")),
		"final_region": str(summary.get("region", "")),
		"regions_reached": int(summary.get("regions_reached", 0)),
		"events_resolved": int(summary.get("events_resolved", 0)),
		"level": int(summary.get("level", 1)),
		"combats": combats,
		"equipment_found": equipment_found,
		"errors": errors,
		"skipped": skipped,
		"steps": steps,
		"decisions": recording,
		"trace": trace,
		"final_state": game.run_state,
		"recovery_checked": recovery_checked,
		"recovery_matched": recovery_matched,
	}


## Uniform choice among what the engine reports as legal right now.
func _policy_decision(game: GameEngine, rng: RandomNumberGenerator) -> Dictionary:
	var phase := str(game.run_state.get("phase", ""))
	match phase:
		"event":
			var legal: Array = []
			var choices: Array = game.current_event().get("choices", [])
			for index in range(choices.size()):
				if bool(game.get_choice_preview(choices[index]).get("available", false)):
					legal.append(index)
			if legal.is_empty():
				return {"type": "noop"}
			return {"type": "choice", "index": int(legal[rng.randi_range(0, legal.size() - 1)])}
		"result":
			return {"type": "continue"}
		"combat":
			var legal_actions: Array = []
			for action: String in COMBAT_ACTIONS:
				var preview := game.combat_action_preview(action)
				if action == "use_item":
					if not game.combat_usable_items().is_empty():
						legal_actions.append(action)
				elif bool(preview.get("available", false)):
					legal_actions.append(action)
			if legal_actions.is_empty():
				legal_actions.append("attack")
			var chosen := str(legal_actions[rng.randi_range(0, legal_actions.size() - 1)])
			if chosen == "use_item":
				var usable := game.combat_usable_items()
				return {"type": "combat", "action": chosen, "item": str(usable[rng.randi_range(0, usable.size() - 1)])}
			return {"type": "combat", "action": chosen}
		"checkpoint":
			if int(game.run_state.get("unspent_stat_points", 0)) > 0:
				var stat := str(GameEngine.STATS[rng.randi_range(0, GameEngine.STATS.size() - 1)])
				return {"type": "allocate", "stat": stat}
			var food := game.available_food_items()
			if not food.is_empty() and rng.randi_range(0, 1) == 0:
				return {"type": "checkpoint", "action": "rest", "food": str(food[rng.randi_range(0, food.size() - 1)])}
			return {"type": "checkpoint", "action": "press_on"}
	return {"type": "noop"}


## Applies one decision through the ordinary engine entry points.
func _apply_decision(game: GameEngine, decision: Dictionary, phase: String) -> Dictionary:
	match str(decision.get("type", "")):
		"choice":
			if phase != "event":
				return {"legal": false}
			var index := int(decision.get("index", -1))
			var choices: Array = game.current_event().get("choices", [])
			if index < 0 or index >= choices.size():
				return {"legal": false}
			if not bool(game.get_choice_preview(choices[index]).get("available", false)):
				return {"legal": false}
			var event_id := str(game.run_state.get("current_event_id", ""))
			var result := game.resolve_choice(index)
			if result.has("error"):
				return {"legal": false, "error": true}
			if bool(result.get("combat_started", false)):
				return {"legal": true, "event": {"event": event_id, "choice": index, "outcome": "combat"}}
			return {"legal": true, "event": {"event": event_id, "choice": index, "outcome": str(result.get("resolution", {}).get("outcome", "outcome"))}}
		"combat":
			if phase != "combat":
				return {"legal": false}
			var action := str(decision.get("action", "attack"))
			var prepared := game.prepare_combat_action(action, str(decision.get("item", "")))
			if prepared.has("error"):
				return {"legal": false, "error": true}
			game.resolve_prepared_combat_round()
			return {"legal": true}
		"continue":
			if phase != "result":
				return {"legal": false}
			game.continue_after_result()
			return {"legal": true}
		"allocate":
			if phase != "checkpoint" or int(game.run_state.get("unspent_stat_points", 0)) <= 0:
				return {"legal": false}
			var proposed: Dictionary = game.run_state["survivor"]["stats"].duplicate(true)
			var stat := str(decision.get("stat", "grit"))
			proposed[stat] = int(proposed.get(stat, 1)) + 1
			var allocation := game.confirm_stat_allocation(proposed)
			return {"legal": bool(allocation.get("success", false))}
		"checkpoint":
			if phase != "checkpoint":
				return {"legal": false}
			if str(decision.get("action", "")) == "rest":
				var rest := game.rest_at_checkpoint(str(decision.get("food", "")))
				if not bool(rest.get("success", false)):
					return {"legal": false}
				game.leave_checkpoint()
				return {"legal": true}
			var press := game.press_on_from_checkpoint()
			if not bool(press.get("success", false)):
				return {"legal": false}
			game.leave_checkpoint()
			return {"legal": true}
		"equip":
			var equip := game.equip_item(str(decision.get("item", "")))
			return {"legal": bool(equip.get("success", false))}
		"use":
			var used := game.use_item(str(decision.get("item", "")))
			return {"legal": bool(used.get("success", false))}
	return {"legal": false}


func _region_snapshot(game: GameEngine) -> Dictionary:
	var survivor: Dictionary = game.run_state.get("survivor", {})
	return {
		"region": str(game.current_region().get("name", "East Citadel")),
		"region_index": int(game.run_state.get("region_index", 0)),
		"health": int(survivor.get("vitals", {}).get("health", 0)),
		"satiety": int(survivor.get("vitals", {}).get("satiety", 0)),
		"fatigue": int(survivor.get("pressures", {}).get("fatigue", 0)),
		"radiation": int(survivor.get("pressures", {}).get("radiation", 0)),
		"level": int(game.run_state.get("level", 1)),
		"experience": int(game.run_state.get("experience", 0)),
		"conditions": (survivor.get("conditions", []) as Array).duplicate(),
	}


func _equipment_ids(game: GameEngine) -> Array:
	var owned: Array = []
	for item_id: String in game.run_state.get("survivor", {}).get("inventory", {}):
		if str(content.get_item(item_id).get("equipment_slot", "")) != "":
			owned.append(item_id)
	return owned


func _print_soak(soak: Dictionary) -> void:
	print("  runs %d | deaths %d (%.1f%%) | victories %d (%.1f%%) | unfinished %d" % [
		int(soak["runs"]), int(soak["deaths"]), float(soak["death_rate"]) * 100.0,
		int(soak["victories"]), float(soak["victory_rate"]) * 100.0, int(soak["unfinished"])])
	print("  mean regions reached %.2f | mean events %.2f | mean level %.2f" % [
		float(soak["mean_regions_reached"]), float(soak["mean_events_resolved"]), float(soak["mean_level"])])
	print("  mean combats %.2f | mean equipment found %.2f" % [float(soak["mean_combats"]), float(soak["mean_equipment_found"])])
	print("  engine errors %d | recovery checks %d | recovery mismatches %d" % [
		int(soak["errors"]), int(soak["recovery_checked"]), int(soak["recovery_mismatches"])])


func _run_replay_file(path: String) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		print("Could not read a decision record from %s" % path)
		quit(1)
		return
	var record: Dictionary = parsed
	var outcome := _play(int(record.get("seed", 0)), int(record.get("candidate", 0)), {"mode": "record", "decisions": record.get("decisions", []), "trace": true})
	print("Replay of %s" % path)
	print(JSON.stringify(outcome["trace"], "\t"))
	quit(0)
