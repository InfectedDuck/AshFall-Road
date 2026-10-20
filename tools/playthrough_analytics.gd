extends SceneTree
## Whole-run balance analytics. Plays complete runs through the ordinary engine
## entry points under several player models and records where runs go wrong:
## region funnel, arrival vitals, causes of death, every event choice, every
## fight, items gained/used/hoarded, conditions, checkpoint decisions, talents,
## and starting archetypes.
##
## Player models (none of them cheat: every decision is chosen from what the
## engine reports as legal, every roll comes from the run's own seeded RNG):
##   random      uniform legal action, no inventory upkeep (old soak baseline)
##   novice      random event choices, but eats, heals and treats like a person
##               who keeps an eye on the HUD; mostly attacks in combat
##   cautious    highest success chance, avoids fights, flees when it can
##   informed    reads stakes and odds (expected value), reads enemy tells,
##               heals/flees at sensible thresholds, builds toward mastery
##   aggressive  takes every fight offered, reads tells, never flees
##
## Under `random` an event choice is effectively randomized, so comparing
## "reached next region" between choices of the same event is close to a
## controlled comparison of those choices. Under the other models it is not.
##
## None of this is a human completion or retention estimate.
##
## Usage:
##   --headless --path . --script res://tools/playthrough_analytics.gd -- \
##       --policies informed,random --runs 1000 --seed-base 20000 \
##       --output res://builds/playthrough/informed.json

const Rules = preload("res://scripts/domain/narrative_combat.gd")

const ANALYTICS_VERSION := 1
const POLICIES := ["random", "novice", "cautious", "informed", "aggressive"]
const STEP_CAP := 2500
const COMBAT_ROUND_CAP := 80
const HARMFUL_CONDITIONS := ["bleeding", "sprain", "infection", "fever", "shaken", "concussed", "burned", "irradiated", "exhausted", "gutrot", "spore_cough", "mind_static"]
const TALENT_FOR_FAMILY := {"execution": "bloodlust", "precision": "patient_shot", "disruption": "exploit_weakness", "counter": "retaliation", "suppression": "sustained_pressure"}

var content: ContentRepository


func _init() -> void:
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	content = ContentRepository.new()
	var args := OS.get_cmdline_user_args()
	var policies := _argument(args, "--policies", ",".join(POLICIES)).split(",", false)
	var runs := int(_argument(args, "--runs", "500"))
	var seed_base := int(_argument(args, "--seed-base", "20000"))
	var output := _argument(args, "--output", "res://builds/playthrough_analytics.json")
	var report := {
		"analytics_version": ANALYTICS_VERSION, "rules_version": Rules.VERSION,
		"living_road_enabled": content.living_road_enabled, "runs_per_policy": runs,
		"seed_base": seed_base, "policies": {},
		"evidence_class": "simulated player models; not a human completion or retention estimate",
	}
	var started := Time.get_ticks_msec()
	for policy: String in policies:
		assert(policy in POLICIES, "Unknown policy %s" % policy)
		var agg := _new_aggregate()
		for index in range(runs):
			var run := _play(seed_base + index, index % 3, policy)
			_merge_run(agg, run)
			if index % 50 == 0:
				await process_frame
			if index % 250 == 249:
				print("  %s %d/%d (%.0fs)" % [policy, index + 1, runs, (Time.get_ticks_msec() - started) / 1000.0])
		report["policies"][policy] = agg
		print("%s: victories %d / %d, mean regions %.2f, errors %d" % [policy, int(agg["victories"]), runs, float(agg["regions_sum"]) / maxf(1.0, runs), int(agg["errors"])])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
	var file := FileAccess.open(output, FileAccess.WRITE)
	assert(file != null, "Could not open %s" % output)
	file.store_string(JSON.stringify(report))
	file.close()
	print("Wrote %s in %.0fs" % [output, (Time.get_ticks_msec() - started) / 1000.0])
	quit(0)


func _argument(args: PackedStringArray, name: String, fallback: String = "") -> String:
	for index in range(args.size()):
		if str(args[index]) == name and index + 1 < args.size():
			return str(args[index + 1])
	return fallback


# ---------------------------------------------------------------------------
# One run
# ---------------------------------------------------------------------------

func _play(seed_value: int, candidate_index: int, policy: String) -> Dictionary:
	var game := GameEngine.new(content)
	var candidates := game.create_candidates(seed_value)
	var candidate: Dictionary = candidates[candidate_index % candidates.size()]
	game.start_run(candidate, seed_value)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 7919 + POLICIES.find(policy)
	var run := {
		"policy": policy, "seed": seed_value, "archetype": _archetype(candidate),
		"start_weapon": str(candidate["equipment"].get("weapon", "")),
		"start_hearts": int(candidate["vitals"]["max_hearts"]),
		"errors": 0, "steps": 0, "result": "unfinished", "cause_kind": "", "cause_detail": "",
		"region_arrivals": [], "choices": [], "availability": [], "fights": [],
		"combat_actions": {}, "items_gained": {}, "items_spent": {}, "items_used": {},
		"conditions_applied": {}, "checkpoints": [], "starvation_ticks": 0,
		"events_seen": [], "upkeep_uses": 0,
	}
	var region_marker := -1
	var fight: Dictionary = {}
	var steps := 0
	while steps < STEP_CAP:
		steps += 1
		var phase := str(game.run_state.get("phase", ""))
		if phase in ["death", "victory"]:
			break
		var region := int(game.run_state.get("region_index", 0))
		if region != region_marker and phase == "event":
			region_marker = region
			run["region_arrivals"].append(_vitals_snapshot(game))
		var before := _state_snapshot(game)
		var step_kind := ""
		var detail := ""
		match phase:
			"event":
				if policy != "random":
					run["upkeep_uses"] = int(run["upkeep_uses"]) + _upkeep(game, policy, run)
					if str(game.run_state.get("phase", "")) == "death":
						run["cause_kind"] = "item_use"
						break
				_record_availability(game, run)
				var choice_index := _choose_event(game, policy, rng)
				if choice_index < 0:
					run["errors"] = int(run["errors"]) + 1
					break
				var event_id := str(game.run_state.get("current_event_id", ""))
				var choice: Dictionary = game.current_event().get("choices", [])[choice_index]
				var preview := game.get_choice_preview(choice)
				var result := game.resolve_choice(choice_index)
				if result.has("error"):
					run["errors"] = int(run["errors"]) + 1
					break
				step_kind = "event"
				detail = "%s#%d" % [event_id, choice_index]
				var entry := {
					"event": event_id, "choice": choice_index, "region": region,
					"label": str(choice.get("label", "")), "chance": int(preview.get("chance", -1)),
					"kind": "combat" if bool(result.get("combat_started", false)) else ("certain" if choice.get("check", {}).is_empty() else "check"),
					"outcome": str(result.get("resolution", {}).get("outcome", "combat" if bool(result.get("combat_started", false)) else "")),
					"hp_before": int(before["hp"]), "hp_after": -1, "died": false,
				}
				run["choices"].append(entry)
				run["events_seen"].append(event_id)
				if bool(result.get("combat_started", false)):
					var state: Dictionary = game.run_state.get("combat_state", {})
					fight = {"enemy": str(state.get("adversary_id", "")), "event": event_id, "region": region,
						"hp_start": int(before["hp"]), "hp_max": int(before["hp_max"]), "rounds": 0,
						"result": "", "items_used": 0, "fatigue_start": int(before["fatigue"]), "level": int(game.run_state.get("level", 1))}
			"combat":
				var action := _choose_combat(game, policy, rng)
				var prepared := game.prepare_combat_action(str(action["action"]), str(action.get("item", "")))
				if prepared.has("error"):
					prepared = game.prepare_combat_action("attack")
					action = {"action": "attack"}
					if prepared.has("error"):
						run["errors"] = int(run["errors"]) + 1
						break
				var round_result := game.resolve_prepared_combat_round()
				step_kind = "combat"
				detail = str(fight.get("enemy", ""))
				fight["rounds"] = int(fight.get("rounds", 0)) + 1
				var action_name := str(action["action"])
				var bucket: Dictionary = run["combat_actions"].get(action_name, {"used": 0, "success": 0})
				bucket["used"] = int(bucket["used"]) + 1
				if int(round_result.get("required_roll", 99)) > 0 and int(round_result.get("player_roll", 0)) >= int(round_result.get("required_roll", 99)):
					bucket["success"] = int(bucket["success"]) + 1
				run["combat_actions"][action_name] = bucket
				if action_name == "use_item":
					fight["items_used"] = int(fight.get("items_used", 0)) + 1
					var used_id := str(action.get("item", ""))
					run["items_used"][used_id] = int(run["items_used"].get(used_id, 0)) + 1
				var after_phase := str(game.run_state.get("phase", ""))
				if after_phase != "combat" or int(fight["rounds"]) >= COMBAT_ROUND_CAP:
					if after_phase == "death":
						fight["result"] = "died"
					elif after_phase in ["result", "victory"]:
						fight["result"] = "won" if (game.run_state.get("defeated_adversaries", []) as Array).size() > int(before["defeated"]) else "fled"
					else:
						fight["result"] = "stalled"
					fight["hp_end"] = int(game.run_state["survivor"]["vitals"]["health"])
					run["fights"].append(fight)
					if not run["choices"].is_empty():
						(run["choices"].back() as Dictionary)["outcome"] = str(fight["result"])
					if after_phase == "combat":
						run["errors"] = int(run["errors"]) + 1
						break
					fight = {}
			"result":
				game.continue_after_result()
				step_kind = "continue"
				if str(game.run_state.get("last_survival_notice", "")) != "":
					run["starvation_ticks"] = int(run["starvation_ticks"]) + 1
					if str(game.run_state.get("status", "")) != "dead":
						game.run_state.erase("last_survival_notice")
			"checkpoint":
				var checkpoint := _checkpoint(game, policy, rng)
				run["checkpoints"].append(checkpoint)
				step_kind = "checkpoint"
			_:
				run["errors"] = int(run["errors"]) + 1
				break
		_record_deltas(game, before, run, step_kind)
		if step_kind == "event" and not run["choices"].is_empty() and str(game.run_state.get("phase", "")) != "combat":
			(run["choices"].back() as Dictionary)["hp_after"] = int(game.run_state["survivor"]["vitals"]["health"])
		if step_kind == "combat" and fight.is_empty() and not run["choices"].is_empty():
			(run["choices"].back() as Dictionary)["hp_after"] = int(game.run_state["survivor"]["vitals"]["health"])
		if str(game.run_state.get("phase", "")) == "death":
			match step_kind:
				"combat":
					run["cause_kind"] = "combat"
					run["cause_detail"] = detail
				"event":
					run["cause_kind"] = "event"
					run["cause_detail"] = detail
				"continue":
					run["cause_kind"] = "starvation" if int(run["starvation_ticks"]) > 0 and int(before["satiety"]) == 0 else "travel"
					run["cause_detail"] = "region %d" % int(game.run_state.get("region_index", 0))
				_:
					run["cause_kind"] = step_kind
			if not run["choices"].is_empty():
				(run["choices"].back() as Dictionary)["died"] = true
	run["steps"] = steps
	var final_phase := str(game.run_state.get("phase", ""))
	run["result"] = "dead" if final_phase == "death" else ("victory" if final_phase == "victory" else "unfinished")
	run["final_region"] = int(game.run_state.get("region_index", 0))
	run["events_resolved"] = int(game.run_state.get("total_events", 0))
	run["level"] = int(game.run_state.get("level", 1))
	run["talents"] = (game.run_state.get("talents", []) as Array).duplicate()
	run["final_stats"] = (game.run_state["survivor"]["stats"] as Dictionary).duplicate()
	run["final_equipment"] = (game.run_state["survivor"]["equipment"] as Dictionary).duplicate()
	run["final_inventory"] = (game.run_state["survivor"]["inventory"] as Dictionary).duplicate()
	run["final_vitals"] = _vitals_snapshot(game)
	return run


func _archetype(candidate: Dictionary) -> String:
	var stats: Dictionary = candidate["stats"]
	var best := "strength"
	for stat: String in GameEngine.STATS:
		if int(stats[stat]) > int(stats[best]):
			best = stat
	return best


func _state_snapshot(game: GameEngine) -> Dictionary:
	var survivor: Dictionary = game.run_state["survivor"]
	return {
		"hp": int(survivor["vitals"]["health"]), "hp_max": int(survivor["vitals"]["max_health"]),
		"satiety": int(survivor["vitals"]["satiety"]), "fatigue": int(survivor["pressures"]["fatigue"]),
		"inventory": (survivor["inventory"] as Dictionary).duplicate(),
		"conditions": (survivor["conditions"] as Array).duplicate(),
		"defeated": (game.run_state.get("defeated_adversaries", []) as Array).size(),
	}


func _vitals_snapshot(game: GameEngine) -> Dictionary:
	var survivor: Dictionary = game.run_state["survivor"]
	var food := 0
	var healing := 0
	for item_id: String in survivor["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		var qty := int(survivor["inventory"][item_id])
		if "food" in item.get("tags", []):
			food += qty
		if int(item.get("effects", {}).get("health", 0)) > 0:
			healing += qty
	var profile := game.get_player_weapon_profile()
	var ammo := 0
	if str(profile.get("ammo_type", "")) != "":
		ammo = game.get_item_quantity(str(profile["ammo_type"]))
	return {
		"region": int(game.run_state.get("region_index", 0)),
		"hp": int(survivor["vitals"]["health"]), "hp_max": int(survivor["vitals"]["max_health"]),
		"satiety": int(survivor["vitals"]["satiety"]), "fatigue": int(survivor["pressures"]["fatigue"]),
		"radiation": int(survivor["pressures"]["radiation"]), "level": int(game.run_state.get("level", 1)),
		"food": food, "healing": healing, "ammo": ammo, "conditions": (survivor["conditions"] as Array).size(),
		"weapon": str(survivor["equipment"].get("weapon", "")), "armor": str(survivor["equipment"].get("armor", "")),
		"scrap": int(survivor["inventory"].get("scrap_parts", 0)),
	}


func _record_availability(game: GameEngine, run: Dictionary) -> void:
	var event_id := str(game.run_state.get("current_event_id", ""))
	var choices: Array = game.current_event().get("choices", [])
	var mask: Array = []
	for index in range(choices.size()):
		mask.append(bool(game.get_choice_preview(choices[index]).get("available", false)))
	run["availability"].append({"event": event_id, "mask": mask})


func _record_deltas(game: GameEngine, before: Dictionary, run: Dictionary, source: String) -> void:
	var inventory: Dictionary = game.run_state["survivor"]["inventory"]
	var previous: Dictionary = before["inventory"]
	for item_id: String in inventory:
		var delta := int(inventory[item_id]) - int(previous.get(item_id, 0))
		if delta > 0:
			var key := "%s|%s" % [item_id, source]
			run["items_gained"][key] = int(run["items_gained"].get(key, 0)) + delta
	for item_id: String in previous:
		var delta := int(inventory.get(item_id, 0)) - int(previous[item_id])
		if delta < 0:
			var key := "%s|%s" % [item_id, source]
			run["items_spent"][key] = int(run["items_spent"].get(key, 0)) - delta
	for condition_id: Variant in game.run_state["survivor"]["conditions"]:
		if condition_id not in before["conditions"]:
			var key := "%s|%s" % [str(condition_id), source]
			run["conditions_applied"][key] = int(run["conditions_applied"].get(key, 0)) + 1


# ---------------------------------------------------------------------------
# Inventory upkeep between events (everything but `random`)
# ---------------------------------------------------------------------------

func _upkeep(game: GameEngine, policy: String, run: Dictionary) -> int:
	var uses := 0
	_equip_best(game)
	var survivor: Dictionary = game.run_state["survivor"]
	var hp_ratio := float(survivor["vitals"]["health"]) / maxf(1.0, float(survivor["vitals"]["max_health"]))
	var heal_threshold := 0.5 if policy == "novice" else 0.6
	if policy == "aggressive":
		heal_threshold = 0.5
	# Eat when hungry. Novices eat only once the meter is empty.
	var hungry_at := 0 if policy == "novice" else 1
	if int(survivor["vitals"]["satiety"]) <= hungry_at:
		var food := _best_item(game, "satiety")
		if food != "":
			uses += _use(game, food, run)
	# Heal when low.
	var guard := 0
	while hp_ratio < heal_threshold and guard < 3:
		guard += 1
		var missing := int(survivor["vitals"]["max_health"]) - int(survivor["vitals"]["health"])
		var heal := _best_heal(game, missing)
		if heal == "":
			break
		uses += _use(game, heal, run)
		hp_ratio = float(survivor["vitals"]["health"]) / maxf(1.0, float(survivor["vitals"]["max_health"]))
	if policy == "novice":
		return uses
	# Treat harmful conditions with the item that removes them.
	for condition_id: Variant in (survivor["conditions"] as Array).duplicate():
		if str(condition_id) not in HARMFUL_CONDITIONS:
			continue
		var remedy := _remedy_for(game, str(condition_id))
		if remedy != "" and int(survivor["vitals"]["health"]) > 15:
			uses += _use(game, remedy, run)
	if int(survivor["pressures"]["radiation"]) >= 45 and game.get_item_quantity("rad_tabs") > 0:
		uses += _use(game, "rad_tabs", run)
	if int(survivor["pressures"]["fatigue"]) >= 45 and game.get_item_quantity("clean_water") > 0:
		uses += _use(game, "clean_water", run)
	return uses


func _use(game: GameEngine, item_id: String, run: Dictionary) -> int:
	var used := game.use_item(item_id)
	if bool(used.get("success", false)):
		run["items_used"][item_id] = int(run["items_used"].get(item_id, 0)) + 1
		return 1
	return 0


func _best_item(game: GameEngine, effect: String) -> String:
	var best := ""
	var best_value := 0
	for item_id: String in game.run_state["survivor"]["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		if not bool(item.get("consumable", false)) or game.get_item_quantity(item_id) <= 0:
			continue
		var value := int(item.get("effects", {}).get(effect, 0))
		if value > best_value:
			best_value = value
			best = item_id
	return best


## Smallest heal that covers the gap, else the biggest available.
func _best_heal(game: GameEngine, missing: int) -> String:
	var best := ""
	var best_value := 0
	var cover := ""
	var cover_value := 100000
	for item_id: String in game.run_state["survivor"]["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		if not bool(item.get("consumable", false)) or game.get_item_quantity(item_id) <= 0:
			continue
		var value := int(item.get("effects", {}).get("health", 0))
		if value <= 0:
			continue
		if value > best_value:
			best_value = value
			best = item_id
		if value >= missing and value < cover_value:
			cover_value = value
			cover = item_id
	return cover if cover != "" else best


func _remedy_for(game: GameEngine, condition_id: String) -> String:
	for item_id: String in game.run_state["survivor"]["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		if bool(item.get("consumable", false)) and condition_id in item.get("effects", {}).get("remove_conditions", []):
			return item_id
	return ""


func _weapon_score(game: GameEngine, item_id: String) -> float:
	var equipment: Dictionary = game.run_state["survivor"]["equipment"]
	var previous := str(equipment.get("weapon", ""))
	equipment["weapon"] = item_id
	var profile := game.get_player_weapon_profile()
	equipment["weapon"] = previous
	if bool(profile.get("unloaded", false)) or str(profile.get("family", "unarmed")) == "unarmed":
		return 0.0
	var stat_value := float(profile.get("stat_value", 1))
	var accuracy := 55.0 + 35.0 * stat_value / (stat_value + 5.0)
	return (float(profile.get("unrounded_min", 0)) + float(profile.get("unrounded_max", 0))) * 0.5 * accuracy / 100.0


func _equip_best(game: GameEngine) -> void:
	if not game.run_state.get("combat_state", {}).is_empty():
		return
	var equipment: Dictionary = game.run_state["survivor"]["equipment"]
	var best_weapon := str(equipment.get("weapon", ""))
	var best_score := _weapon_score(game, best_weapon) if best_weapon != "" else 0.0
	var best_armor := str(equipment.get("armor", ""))
	var best_rating := int(content.get_item(best_armor).get("damage_reduction", 0)) if best_armor != "" else -1
	for item_id: String in game.run_state["survivor"]["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		match str(item.get("equipment_slot", "")):
			"weapon":
				var score := _weapon_score(game, item_id)
				if score > best_score * 1.05:
					best_score = score
					best_weapon = item_id
			"armor":
				var rating := int(item.get("damage_reduction", 0))
				if rating > best_rating:
					best_rating = rating
					best_armor = item_id
			"backpack":
				if str(equipment.get("backpack", "")) == "":
					game.equip_item(item_id)
			"accessory":
				if str(equipment.get("accessory", "")) == "":
					game.equip_item(item_id)
	if best_weapon != str(equipment.get("weapon", "")) and best_weapon != "":
		game.equip_item(best_weapon)
	if best_armor != str(equipment.get("armor", "")) and best_armor != "":
		game.equip_item(best_armor)


# ---------------------------------------------------------------------------
# Event choices
# ---------------------------------------------------------------------------

func _choose_event(game: GameEngine, policy: String, rng: RandomNumberGenerator) -> int:
	var choices: Array = game.current_event().get("choices", [])
	var legal: Array = []
	var previews: Array = []
	for index in range(choices.size()):
		var preview := game.get_choice_preview(choices[index])
		previews.append(preview)
		if bool(preview.get("available", false)):
			legal.append(index)
	if legal.is_empty():
		return -1
	if policy in ["random", "novice"]:
		return int(legal[rng.randi_range(0, legal.size() - 1)])
	var survivor: Dictionary = game.run_state["survivor"]
	var hp := float(survivor["vitals"]["health"])
	var best := int(legal[0])
	var best_score := -INF
	for index: int in legal:
		var choice: Dictionary = choices[index]
		var preview: Dictionary = previews[index]
		var score := 0.0
		if bool(preview.get("combat", false)):
			score = _fight_score(game, choice, preview, policy, hp)
		else:
			var chance := float(preview.get("chance", -1))
			var cost := -_outcome_value(game, {"items": choice.get("costs", {}).get("items", {})}, hp) if choice.has("costs") else 0.0
			if chance < 0.0:
				score = _outcome_value(game, choice.get("outcome", {}), hp) - cost
			else:
				var p := chance / 100.0
				var success := _outcome_value(game, choice.get("success", {}), hp)
				var failure := _outcome_value(game, choice.get("failure", {}), hp)
				score = p * success + (1.0 - p) * failure - cost
				if policy == "cautious":
					score = score * 0.5 + chance * 2.0
		score += rng.randf() * 0.01
		if score > best_score:
			best_score = score
			best = index
	return best


func _fight_score(game: GameEngine, choice: Dictionary, preview: Dictionary, policy: String, hp: float) -> float:
	var adversary: Dictionary = content.get_adversary(str(choice.get("combat", {}).get("adversary_id", game.current_event().get("adversary_id", ""))))
	var combat: Dictionary = adversary.get("combat", {})
	var reward := float(adversary.get("xp_reward", 0)) * 3.0 + _outcome_value(game, choice.get("victory", {}), hp)
	if policy == "aggressive":
		return 10000.0 + reward
	# Rough exchanges to kill it versus the hits we can take.
	var profile := game.get_player_weapon_profile()
	var our_hit := maxf(1.0, (float(profile.get("damage_min", 1)) + float(profile.get("damage_max", 1))) * 0.5 * 0.75)
	var exchanges := float(combat.get("max_health", 100)) / our_hit
	var armor := int(content.get_item(str(game.run_state["survivor"]["equipment"].get("armor", ""))).get("damage_reduction", 0))
	var their_hit := (float(combat.get("damage_min", 10)) + float(combat.get("damage_max", 10))) * 0.5 * (1.0 - 0.06 * armor)
	# Reading tells avoids roughly half of the incoming pressure.
	var expected_loss := exchanges * their_hit * 0.45
	var margin := hp - expected_loss
	if policy == "cautious":
		return -500.0 if margin < hp * 0.6 else reward * 0.5 - expected_loss
	if margin < 40.0:
		return -1000.0 + margin
	return reward - expected_loss * 1.0


## Rough value of an outcome dictionary in "HP-equivalent" points.
func _outcome_value(game: GameEngine, outcome: Dictionary, hp: float) -> float:
	if outcome.is_empty():
		return 0.0
	var value := 0.0
	var survivor: Dictionary = game.run_state["survivor"]
	if bool(outcome.get("lethal", false)):
		value -= 3000.0
	if bool(outcome.get("victory", false)):
		value += 5000.0
	var vitals: Dictionary = outcome.get("vitals", {})
	var health := float(vitals.get("health", 0))
	if health < 0.0 and -health >= hp:
		value -= 3000.0
	value += health * (1.0 if health < 0 else 0.7)
	var satiety := float(vitals.get("satiety", 0))
	value += satiety * (45.0 if int(survivor["vitals"]["satiety"]) <= 1 else 25.0)
	var pressures: Dictionary = outcome.get("pressures", {})
	value -= float(pressures.get("fatigue", 0)) * 0.8
	value -= float(pressures.get("radiation", 0)) * 1.2
	if pressures.has("health"):
		value += float(pressures["health"])
	for item_id: Variant in outcome.get("items", {}):
		value += _item_value(game, str(item_id)) * float(outcome["items"][item_id])
	for condition_id: Variant in outcome.get("add_conditions", []):
		value += -40.0 if str(condition_id) in HARMFUL_CONDITIONS else 15.0
	for condition_id: Variant in outcome.get("remove_conditions", []):
		if condition_id in survivor["conditions"]:
			value += 35.0
	return value


func _item_value(game: GameEngine, item_id: String) -> float:
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty():
		return 0.0
	var tags: Array = item.get("tags", [])
	if str(item.get("equipment_slot", "")) != "":
		return 4.0 if game.get_item_quantity(item_id) > 0 else 35.0
	if item_id.ends_with("_rounds"):
		var ammo := str(game.get_player_weapon_profile().get("ammo_type", ""))
		var equipped_ammo := str(content.get_item(str(game.run_state["survivor"]["equipment"].get("weapon", ""))).get("ammo_type", ""))
		return 8.0 if item_id == ammo or item_id == equipped_ammo else 1.5
	if "food" in tags:
		return 30.0
	if "medical" in tags:
		return 30.0
	if item_id == "scrap_parts":
		return 7.0
	return 10.0


# ---------------------------------------------------------------------------
# Combat
# ---------------------------------------------------------------------------

func _choose_combat(game: GameEngine, policy: String, rng: RandomNumberGenerator) -> Dictionary:
	var state: Dictionary = game.run_state.get("combat_state", {})
	if policy == "random":
		var legal: Array = []
		for action: String in Rules.MAIN_ACTIONS:
			if action == "use_item":
				if not game.combat_usable_items().is_empty():
					legal.append(action)
			elif bool(game.combat_action_preview(action).get("available", false)):
				legal.append(action)
		if legal.is_empty():
			return {"action": "attack"}
		var chosen := str(legal[rng.randi_range(0, legal.size() - 1)])
		if chosen == "use_item":
			var usable := game.combat_usable_items()
			return {"action": chosen, "item": str(usable[rng.randi_range(0, usable.size() - 1)])}
		return {"action": chosen}
	var survivor: Dictionary = game.run_state["survivor"]
	var hp := int(survivor["vitals"]["health"])
	var hp_ratio := float(hp) / maxf(1.0, float(survivor["vitals"]["max_health"]))
	var attack := game.combat_action_preview("attack")
	var enemy_hp := int(state.get("enemy_health", 0))
	if policy == "novice":
		if hp_ratio < 0.3:
			var heal := _best_heal(game, 999)
			if heal != "" and heal in game.combat_usable_items():
				return {"action": "use_item", "item": heal}
		var roll := rng.randf()
		if roll < 0.6:
			return {"action": "attack"}
		if roll < 0.75:
			return {"action": "block"}
		if roll < 0.9:
			return {"action": "dodge"}
		if bool(game.combat_action_preview("opportunity").get("available", false)):
			return {"action": "opportunity"}
		return {"action": "attack"}
	var flee := game.combat_action_preview("flee")
	var can_flee := bool(state.get("can_flee", true)) and bool(flee.get("available", false))
	# B6: fighting models spend a full Momentum bar like the benchmark's
	# read_tells policy, so the two harnesses measure the same skilled play.
	if bool(game.combat_action_preview("finisher").get("available", false)):
		return {"action": "finisher"}
	if policy == "cautious" and can_flee and int(flee.get("chance", 0)) >= 50 and enemy_hp > int(attack.get("damage_max", 0)):
		return {"action": "flee"}
	# Kill shot.
	if enemy_hp <= int(attack.get("damage_min", 0)) and int(attack.get("chance", 0)) >= 55:
		return {"action": "attack"}
	# Emergency heal or escape.
	if hp_ratio < 0.3:
		var heal := _best_heal(game, int(survivor["vitals"]["max_health"]) - hp)
		if heal != "" and heal in game.combat_usable_items():
			return {"action": "use_item", "item": heal}
		if policy != "aggressive" and can_flee and int(flee.get("chance", 0)) >= 30:
			return {"action": "flee"}
	var move := str(state.get("committed_move", {}).get("id", ""))
	var block := game.combat_action_preview("block")
	var dodge := game.combat_action_preview("dodge")
	var banked := bool(state.get("riposte", false)) or bool(state.get("opening", false))
	var choice := "attack"
	match move:
		"heavy":
			choice = "attack" if banked else "dodge"
		"sweep":
			choice = "attack" if banked else "block"
		"brace":
			choice = "block" if int(block.get("chance", 0)) >= int(dodge.get("chance", 0)) else "dodge"
		"recover", "charge":
			choice = "attack"
		_:
			choice = "attack"
	if choice == "attack" and bool(state.get("opportunity_ready", false)) and not bool(state.get("opportunity_used", false)) and bool(game.combat_action_preview("opportunity").get("available", false)):
		choice = "opportunity"
	# Prediction trait: never repeat an action three times running.
	if str(state.get("trait_id", "")) == "prediction" and int(state.get("trait_repeat", 0)) >= 2 and str(state.get("trait_last_action", "")) == choice:
		choice = "dodge" if choice != "dodge" else "block"
	return {"action": choice}


# ---------------------------------------------------------------------------
# Checkpoints
# ---------------------------------------------------------------------------

func _checkpoint(game: GameEngine, policy: String, rng: RandomNumberGenerator) -> Dictionary:
	var record := {"region": int(game.run_state.get("region_index", 0)), "allocated": [], "talent": "", "action": "", "trade": ""}
	var guard := 0
	while int(game.run_state.get("unspent_stat_points", 0)) > 0 and guard < 20:
		guard += 1
		var stat := _allocation_stat(game, policy, rng)
		var proposed: Dictionary = game.run_state["survivor"]["stats"].duplicate(true)
		proposed[stat] = int(proposed.get(stat, 1)) + 1
		if bool(game.confirm_stat_allocation(proposed).get("success", false)):
			record["allocated"].append(stat)
		else:
			break
	if game.talent_choice_available():
		var options := game.list_talent_options()
		if not options.is_empty():
			var pick := str(options[rng.randi_range(0, options.size() - 1)].get("id", ""))
			if policy != "random":
				var family := str(game.get_player_weapon_profile().get("family", ""))
				var wanted := str(TALENT_FOR_FAMILY.get(family, "field_medicine"))
				for option: Dictionary in options:
					if str(option.get("id", "")) == wanted:
						pick = wanted
			if policy == "random" and rng.randi_range(0, 1) == 1:
				pick = ""
			if pick != "" and bool(game.select_talent(pick).get("success", false)):
				record["talent"] = pick
	var food := game.available_food_items()
	var offers := game.checkpoint_offers()
	if policy == "random":
		var affordable: Array = []
		for index in range(offers.size()):
			if bool(game.trade_preview(index).get("available", false)):
				affordable.append(index)
		var roll := rng.randi_range(0, 2)
		if not food.is_empty() and roll == 0:
			return _rest(game, record, str(food[rng.randi_range(0, food.size() - 1)]))
		if not affordable.is_empty() and roll <= 1:
			return _trade(game, record, int(affordable[rng.randi_range(0, affordable.size() - 1)]))
		return _press_on(game, record)
	_equip_best(game)
	var survivor: Dictionary = game.run_state["survivor"]
	var hp_ratio := float(survivor["vitals"]["health"]) / maxf(1.0, float(survivor["vitals"]["max_health"]))
	var fatigue := int(survivor["pressures"]["fatigue"])
	var food_count := 0
	for food_id: String in food:
		food_count += game.get_item_quantity(food_id)
	# A trade worth more than a rest?
	var best_trade := -1
	var best_trade_value := 0.0
	for index in range(offers.size()):
		if not bool(game.trade_preview(index).get("available", false)):
			continue
		var offer: Dictionary = offers[index]
		var value := _item_value(game, str(offer.get("item_id", ""))) * float(offer.get("quantity", 1))
		if str(offer.get("kind", "")) == "food" and food_count >= 3:
			value *= 0.3
		for cost_id: String in offer.get("cost", {}):
			value -= _item_value(game, cost_id) * float(offer["cost"][cost_id])
		if value > best_trade_value:
			best_trade_value = value
			best_trade = index
	var rest_value := 0.0
	if not food.is_empty():
		rest_value = minf(25.0, float(survivor["vitals"]["max_health"] - survivor["vitals"]["health"])) + fatigue * 0.9 - 10.0
		if policy == "novice":
			rest_value = 50.0 if hp_ratio < 0.7 or fatigue >= 40 else -1.0
	if policy == "novice":
		if rest_value > 0.0:
			return _rest(game, record, _best_item(game, "satiety"))
		if best_trade >= 0 and rng.randi_range(0, 1) == 0:
			return _trade(game, record, best_trade)
		return _press_on(game, record)
	if rest_value >= best_trade_value and rest_value > 15.0:
		return _rest(game, record, _cheapest_food(game))
	if best_trade >= 0 and best_trade_value > 10.0:
		return _trade(game, record, best_trade)
	return _press_on(game, record)


func _cheapest_food(game: GameEngine) -> String:
	var pick := ""
	var lowest := 1000
	for food_id: String in game.available_food_items():
		var satiety := int(content.get_item(food_id).get("effects", {}).get("satiety", 0))
		if satiety < lowest:
			lowest = satiety
			pick = food_id
	return pick


func _rest(game: GameEngine, record: Dictionary, food_id: String) -> Dictionary:
	var rest := game.rest_at_checkpoint(food_id)
	if bool(rest.get("success", false)):
		game.leave_checkpoint()
		record["action"] = "rest"
		return record
	return _press_on(game, record)


func _trade(game: GameEngine, record: Dictionary, index: int) -> Dictionary:
	var offer: Dictionary = game.checkpoint_offers()[index]
	var deal := game.accept_trade(index)
	if bool(deal.get("success", false)):
		game.leave_checkpoint()
		record["action"] = "trade"
		record["trade"] = "%s:%s" % [str(offer.get("kind", "")), str(offer.get("item_id", ""))]
		_equip_best(game)
		return record
	return _press_on(game, record)


func _press_on(game: GameEngine, record: Dictionary) -> Dictionary:
	var press := game.press_on_from_checkpoint()
	if bool(press.get("success", false)):
		game.leave_checkpoint()
		record["action"] = "press_on"
	return record


func _allocation_stat(game: GameEngine, policy: String, rng: RandomNumberGenerator) -> String:
	var stats: Dictionary = game.run_state["survivor"]["stats"]
	if policy == "random" or policy == "novice":
		return str(GameEngine.STATS[rng.randi_range(0, GameEngine.STATS.size() - 1)])
	var attack_stat := str(game.get_player_weapon_profile().get("attack_stat", "strength"))
	if policy == "cautious":
		if int(stats["grit"]) < 7:
			return "grit"
		return "agility" if int(stats["agility"]) < 6 else attack_stat
	if int(stats.get(attack_stat, 1)) < 6:
		return attack_stat
	if int(stats["grit"]) < 6:
		return "grit"
	if policy == "aggressive":
		return attack_stat
	# Informed: alternate between the weakest of wits/agility (most common
	# event checks and flee) and the attack stat.
	var weakest := "wits" if int(stats["wits"]) <= int(stats["agility"]) else "agility"
	return weakest if int(stats[weakest]) < int(stats.get(attack_stat, 1)) - 2 else attack_stat


# ---------------------------------------------------------------------------
# Aggregation
# ---------------------------------------------------------------------------

func _new_aggregate() -> Dictionary:
	return {
		"runs": 0, "victories": 0, "deaths": 0, "unfinished": 0, "errors": 0, "regions_sum": 0,
		"events_sum": 0, "level_sum": 0, "steps_sum": 0, "upkeep_uses": 0, "starvation_ticks": 0,
		"runs_with_starvation": 0,
		"final_region_hist": {}, "level_hist": {}, "causes": {}, "cause_by_region": {},
		"arrivals": {}, "events": {}, "enemies": {}, "combat_actions": {},
		"items_gained": {}, "items_spent": {}, "items_used": {}, "held_at_end": {},
		"conditions_applied": {}, "checkpoints": {}, "talents": {}, "talent_outcomes": {},
		"archetypes": {}, "start_weapons": {}, "final_weapons": {}, "allocations": {},
		"died_with": {"healing": 0, "food": 0, "both": 0, "deaths_counted": 0},
		"runs_list": [],
	}


func _bump(target: Dictionary, key: Variant, amount: float = 1.0) -> void:
	target[key] = float(target.get(key, 0.0)) + amount


func _merge_run(agg: Dictionary, run: Dictionary) -> void:
	agg["runs"] = int(agg["runs"]) + 1
	agg["errors"] = int(agg["errors"]) + int(run["errors"])
	var result := str(run["result"])
	match result:
		"victory": agg["victories"] = int(agg["victories"]) + 1
		"dead": agg["deaths"] = int(agg["deaths"]) + 1
		_: agg["unfinished"] = int(agg["unfinished"]) + 1
	var final_region := int(run["final_region"])
	var reached := final_region + 1 if result != "victory" else 7
	agg["regions_sum"] = int(agg["regions_sum"]) + mini(reached, 6)
	agg["events_sum"] = int(agg["events_sum"]) + int(run["events_resolved"])
	agg["level_sum"] = int(agg["level_sum"]) + int(run["level"])
	agg["steps_sum"] = int(agg["steps_sum"]) + int(run["steps"])
	agg["upkeep_uses"] = int(agg["upkeep_uses"]) + int(run["upkeep_uses"])
	agg["starvation_ticks"] = int(agg["starvation_ticks"]) + int(run["starvation_ticks"])
	agg["runs_with_starvation"] = int(agg["runs_with_starvation"]) + int(int(run["starvation_ticks"]) > 0)
	_bump(agg["final_region_hist"], str(final_region if result != "victory" else "victory"))
	_bump(agg["level_hist"], str(run["level"]))
	if result == "dead":
		var cause := str(run["cause_kind"])
		var cause_key := cause
		if cause == "combat":
			cause_key = "combat:%s" % str(run["cause_detail"])
		elif cause == "event":
			cause_key = "event:%s" % str(run["cause_detail"])
		_bump(agg["causes"], cause_key)
		_bump(agg["cause_by_region"], "%d|%s" % [final_region, cause])
		var final_vitals: Dictionary = run["final_vitals"]
		var died_with: Dictionary = agg["died_with"]
		died_with["deaths_counted"] = int(died_with["deaths_counted"]) + 1
		died_with["healing"] = int(died_with["healing"]) + int(int(final_vitals["healing"]) > 0)
		died_with["food"] = int(died_with["food"]) + int(int(final_vitals["food"]) > 0)
		died_with["both"] = int(died_with["both"]) + int(int(final_vitals["healing"]) > 0 and int(final_vitals["food"]) > 0)
	# Region arrivals: sums for means.
	for arrival: Dictionary in run["region_arrivals"]:
		var key := str(arrival["region"])
		var bucket: Dictionary = agg["arrivals"].get(key, {})
		for field: String in ["hp", "hp_max", "satiety", "fatigue", "radiation", "level", "food", "healing", "ammo", "conditions", "scrap"]:
			_bump(bucket, field, float(arrival[field]))
		_bump(bucket, "count")
		_bump(bucket, "hp_pct", float(arrival["hp"]) / maxf(1.0, float(arrival["hp_max"])))
		_bump(bucket, "unarmed", float(str(arrival["weapon"]) == ""))
		_bump(bucket, "no_armor", float(str(arrival["armor"]) == ""))
		agg["arrivals"][key] = bucket
	# Event choices with survival-to-next-region attribution.
	for entry: Dictionary in run["choices"]:
		var event_id := str(entry["event"])
		var event: Dictionary = agg["events"].get(event_id, {"seen": 0, "regions": {}, "choices": {}, "offered": {}})
		event["seen"] = int(event["seen"]) + 1
		_bump(event["regions"], str(entry["region"]))
		var choice_key := str(entry["choice"])
		var bucket: Dictionary = event["choices"].get(choice_key, {"label": entry["label"], "kind": entry["kind"], "picked": 0, "outcomes": {}, "died_here": 0, "hp_delta": 0.0, "hp_samples": 0, "next_region": 0, "victory": 0, "chance_sum": 0.0, "chance_n": 0})
		bucket["picked"] = int(bucket["picked"]) + 1
		_bump(bucket["outcomes"], str(entry["outcome"]))
		bucket["died_here"] = int(bucket["died_here"]) + int(bool(entry["died"]))
		if int(entry["hp_after"]) >= 0:
			bucket["hp_delta"] = float(bucket["hp_delta"]) + float(int(entry["hp_after"]) - int(entry["hp_before"]))
			bucket["hp_samples"] = int(bucket["hp_samples"]) + 1
		bucket["next_region"] = int(bucket["next_region"]) + int(result == "victory" or final_region > int(entry["region"]))
		bucket["victory"] = int(bucket["victory"]) + int(result == "victory")
		if int(entry["chance"]) >= 0:
			bucket["chance_sum"] = float(bucket["chance_sum"]) + float(entry["chance"])
			bucket["chance_n"] = int(bucket["chance_n"]) + 1
		event["choices"][choice_key] = bucket
		agg["events"][event_id] = event
	for availability: Dictionary in run["availability"]:
		var event_id := str(availability["event"])
		var event: Dictionary = agg["events"].get(event_id, {"seen": 0, "regions": {}, "choices": {}, "offered": {}})
		var mask: Array = availability["mask"]
		for index in range(mask.size()):
			var key := str(index)
			var offered: Dictionary = event["offered"].get(key, {"shown": 0, "available": 0})
			offered["shown"] = int(offered["shown"]) + 1
			offered["available"] = int(offered["available"]) + int(bool(mask[index]))
			event["offered"][key] = offered
		agg["events"][event_id] = event
	for fight: Dictionary in run["fights"]:
		var enemy := str(fight["enemy"])
		var bucket: Dictionary = agg["enemies"].get(enemy, {"fights": 0, "won": 0, "fled": 0, "died": 0, "stalled": 0, "rounds": 0, "hp_lost": 0.0, "hp_start_pct": 0.0, "items_used": 0, "regions": {}, "level": 0})
		bucket["fights"] = int(bucket["fights"]) + 1
		match str(fight["result"]):
			"won": bucket["won"] = int(bucket["won"]) + 1
			"fled": bucket["fled"] = int(bucket["fled"]) + 1
			"died": bucket["died"] = int(bucket["died"]) + 1
			_: bucket["stalled"] = int(bucket["stalled"]) + 1
		bucket["rounds"] = int(bucket["rounds"]) + int(fight["rounds"])
		bucket["hp_lost"] = float(bucket["hp_lost"]) + float(int(fight["hp_start"]) - int(fight.get("hp_end", 0)))
		bucket["hp_start_pct"] = float(bucket["hp_start_pct"]) + float(fight["hp_start"]) / maxf(1.0, float(fight["hp_max"]))
		bucket["items_used"] = int(bucket["items_used"]) + int(fight["items_used"])
		bucket["level"] = int(bucket["level"]) + int(fight["level"])
		_bump(bucket["regions"], str(fight["region"]))
		agg["enemies"][enemy] = bucket
	for action: String in run["combat_actions"]:
		var src: Dictionary = run["combat_actions"][action]
		var bucket: Dictionary = agg["combat_actions"].get(action, {"used": 0, "success": 0})
		bucket["used"] = int(bucket["used"]) + int(src["used"])
		bucket["success"] = int(bucket["success"]) + int(src["success"])
		agg["combat_actions"][action] = bucket
	for field: String in ["items_gained", "items_spent", "items_used", "conditions_applied"]:
		for key: String in run[field]:
			_bump(agg[field], key, float(run[field][key]))
	for item_id: String in run["final_inventory"]:
		_bump(agg["held_at_end"], item_id, float(run["final_inventory"][item_id]))
	for checkpoint: Dictionary in run["checkpoints"]:
		_bump(agg["checkpoints"], "%d|%s" % [int(checkpoint["region"]), str(checkpoint["action"])])
		if str(checkpoint["trade"]) != "":
			_bump(agg["checkpoints"], "trade|%s" % str(checkpoint["trade"]))
		if str(checkpoint["talent"]) != "":
			_bump(agg["talents"], str(checkpoint["talent"]))
		for stat: String in checkpoint["allocated"]:
			_bump(agg["allocations"], stat)
	for talent: Variant in run["talents"]:
		var bucket: Dictionary = agg["talent_outcomes"].get(str(talent), {"runs": 0, "regions": 0, "victories": 0})
		bucket["runs"] = int(bucket["runs"]) + 1
		bucket["regions"] = int(bucket["regions"]) + mini(reached, 6)
		bucket["victories"] = int(bucket["victories"]) + int(result == "victory")
		agg["talent_outcomes"][str(talent)] = bucket
	for field_pair: Array in [["archetypes", str(run["archetype"])], ["start_weapons", str(run["start_weapon"])], ["final_weapons", str(run["final_equipment"].get("weapon", ""))]]:
		var bucket: Dictionary = agg[field_pair[0]].get(field_pair[1], {"runs": 0, "regions": 0, "victories": 0, "hearts": 0})
		bucket["runs"] = int(bucket["runs"]) + 1
		bucket["regions"] = int(bucket["regions"]) + mini(reached, 6)
		bucket["victories"] = int(bucket["victories"]) + int(result == "victory")
		bucket["hearts"] = int(bucket["hearts"]) + int(run["start_hearts"])
		agg[field_pair[0]][field_pair[1]] = bucket
	agg["runs_list"].append({
		"seed": run["seed"], "archetype": run["archetype"], "hearts": run["start_hearts"], "result": result,
		"region": final_region, "events": run["events_resolved"], "level": run["level"],
		"cause": str(run["cause_kind"]), "detail": str(run["cause_detail"]),
		"fights": (run["fights"] as Array).size(), "starvation": run["starvation_ticks"],
		"talents": run["talents"], "weapon": str(run["final_equipment"].get("weapon", "")),
	})
