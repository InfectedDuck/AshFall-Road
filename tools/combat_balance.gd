extends SceneTree
## Full authoritative engine simulations, not a damage-only approximation.
##
## Fixture data is intentionally named. These builds are controlled comparisons,
## not candidate-generation budgets: the two rifle rows deliberately have 21
## points so the report can distinguish agility from genuine Wits mastery.

const Fixtures = preload("res://tests/narrative_combat_tests.gd")
const Rules = preload("res://scripts/domain/narrative_combat.gd")

const FIXTURE_VERSION := 3
const SEEDS_PER_ROW := 1000
## Every adversary in the package, not a prototype subset.
const BENCHMARK_ENEMIES := ["road_bandits", "feral_dogs", "ash_stalkers", "toll_gang", "marsh_leeches", "bog_raiders", "drone_swarm", "vault_scavs", "glass_cult", "tunnel_hunters", "citadel_guard", "warden_machine", "mutant_crows"]
## State variants are extra evidence, so they run against a representative
## subset rather than multiplying the standard comparison.
const SCENARIO_ENEMIES := ["feral_dogs", "road_bandits", "warden_machine"]
const SCENARIO_STRATEGY := "read_tells"
const STATE_SCENARIOS := ["fresh", "injured", "hungry", "unarmed", "dry"]
const STANDARD_STRATEGIES := ["attack_only", "repeat_defense", "read_tells", "read_tells_no_opportunity"]
const CONTROL_STRATEGIES := ["read_tells_no_opportunity"]
const BUILDS := [
	{
		"id": "cleaver", "label": "Cleaver", "tier": "early", "family": "execution", "weapon": "salvage_cleaver", "armor": "scrap_vest",
		"stats": {"strength": 5, "agility": 3, "wits": 2, "grit": 3, "presence": 2},
		"expected_total": 15, "expected_attack_stat": "strength", "expected_mastered": false,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "pistol", "label": "Pistol", "tier": "early", "family": "precision", "weapon": "pipe_pistol", "armor": "runner_jacket",
		"stats": {"strength": 2, "agility": 5, "wits": 3, "grit": 3, "presence": 2},
		"expected_total": 15, "expected_attack_stat": "agility", "expected_mastered": false,
		"expected_ammo": "pistol_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "probe", "label": "Shock Probe", "tier": "early", "family": "disruption", "weapon": "shock_probe", "armor": "",
		"stats": {"strength": 2, "agility": 3, "wits": 5, "grit": 3, "presence": 2},
		"expected_total": 15, "expected_attack_stat": "wits", "expected_mastered": false,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "buckler_counter", "label": "Buckler Counter", "tier": "early", "family": "counter", "weapon": "wrecking_bar", "armor": "plated_coat", "shield": "scrap_buckler",
		"stats": {"strength": 3, "agility": 2, "wits": 2, "grit": 5, "presence": 3},
		"expected_total": 15, "expected_attack_stat": "grit", "expected_mastered": false,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "revolver", "label": "Revolver", "tier": "early", "family": "suppression", "weapon": "holdout_revolver", "armor": "",
		"stats": {"strength": 3, "agility": 2, "wits": 2, "grit": 3, "presence": 5},
		"expected_total": 15, "expected_attack_stat": "presence", "expected_mastered": false,
		"expected_ammo": "revolver_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "agile_rifle", "label": "Agile Rifle (unmastered)", "tier": "progressed", "family": "precision", "weapon": "hunting_rifle", "armor": "scout_leathers",
		"stats": {"strength": 3, "agility": 8, "wits": 3, "grit": 5, "presence": 2},
		"expected_total": 21, "expected_attack_stat": "wits", "expected_mastered": false,
		"expected_ammo": "rifle_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "mastered_rifle", "label": "Mastered Rifle", "tier": "progressed", "family": "precision", "weapon": "hunting_rifle", "armor": "scout_leathers",
		"stats": {"strength": 3, "agility": 3, "wits": 8, "grit": 5, "presence": 2},
		"expected_total": 21, "expected_attack_stat": "wits", "expected_mastered": true,
		"expected_ammo": "rifle_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "spear_counter", "label": "Rebar Spear (mastered)", "tier": "progressed", "family": "counter", "weapon": "rebar_spear", "armor": "tire_armor",
		"stats": {"strength": 8, "agility": 3, "wits": 2, "grit": 5, "presence": 3},
		"expected_total": 21, "expected_attack_stat": "strength", "expected_mastered": true,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "baton_disruption", "label": "Stun Baton (mastered)", "tier": "progressed", "family": "disruption", "weapon": "stun_baton", "armor": "dust_cloak",
		"stats": {"strength": 3, "agility": 8, "wits": 3, "grit": 5, "presence": 2},
		"expected_total": 21, "expected_attack_stat": "agility", "expected_mastered": true,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "flare_suppression", "label": "Flare Gun (mastered)", "tier": "progressed", "family": "suppression", "weapon": "flare_gun", "armor": "scout_leathers",
		"stats": {"strength": 2, "agility": 3, "wits": 3, "grit": 5, "presence": 8},
		"expected_total": 21, "expected_attack_stat": "presence", "expected_mastered": true,
		"expected_ammo": "shotgun_shells", "expected_ammo_per_attack": 1,
	},
]


func _init() -> void:
	# Only autostart when Godot is using this class as the main loop. Tests and
	# other tools instantiate it to call one function without running the job.
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	var content := ContentRepository.new()
	var factory := Fixtures.new()
	factory.content = content
	var controls_only := "--controls-only" in OS.get_cmdline_user_args()
	var rows: Array = _load_non_control_rows() if controls_only else []
	var fixture_metadata := _validate_and_collect_fixture_metadata(factory)
	var strategies: Array = CONTROL_STRATEGIES if controls_only else STANDARD_STRATEGIES
	for enemy: String in BENCHMARK_ENEMIES:
		for build: Dictionary in BUILDS:
			for strategy: String in strategies:
				var row := _simulate(factory, enemy, build, strategy, "fresh")
				rows.append(row)
				print(JSON.stringify(row))
				await process_frame
	var scenario_rows: Array = []
	if not controls_only:
		for enemy: String in SCENARIO_ENEMIES:
			for build: Dictionary in BUILDS:
				if str(build["tier"]) != "early":
					continue
				for state: String in STATE_SCENARIOS:
					if state == "dry" and str(build["expected_ammo"]) == "":
						continue
					var scenario_row := _simulate(factory, enemy, build, SCENARIO_STRATEGY, state)
					scenario_rows.append(scenario_row)
					print(JSON.stringify(scenario_row))
					await process_frame
	var output := {
		"rules": Rules.VERSION,
		"fixture_version": FIXTURE_VERSION,
		"seeds_per_row": SEEDS_PER_ROW,
		"enemies": BENCHMARK_ENEMIES.size(),
		"builds": BUILDS.size(),
		"strategies": STANDARD_STRATEGIES,
		"encounters": (rows.size() + scenario_rows.size()) * SEEDS_PER_ROW,
		"fixtures": fixture_metadata,
		"rows": rows,
		"state_rows": scenario_rows,
	}
	var file := FileAccess.open("res://builds/combat_balance.json", FileAccess.WRITE)
	assert(file != null, "Could not open builds/combat_balance.json for writing.")
	file.store_string(JSON.stringify(output, "\t"))
	file.close()
	quit()


func _simulate(factory, enemy: String, build: Dictionary, strategy: String, state: String = "fresh") -> Dictionary:
	var row := {
		"enemy": enemy, "build": build["id"], "tier": build["tier"], "family": build["family"],
		"budget": build["expected_total"], "strategy": strategy, "state": state, "seeds": SEEDS_PER_ROW,
		"wins": 0, "hp_spent": 0, "ammo": 0, "conditions": 0, "exchanges": 0,
		"victory_exchanges": 0, "stalls": 0, "deaths": 0, "unarmed_fallbacks": 0,
	}
	for seed_value in range(1, SEEDS_PER_ROW + 1):
		var game: GameEngine = factory.fixture(enemy, str(build["weapon"]), str(build["armor"]), seed_value)
		var maximum := _apply_build(game, build)
		_apply_state(game, build, state, maximum)
		if str(game.get_player_weapon_profile().get("family", "unarmed")) == "unarmed":
			row["unarmed_fallbacks"] += 1
		if strategy == "read_tells_no_opportunity":
			game.run_state["combat_state"]["opportunity_used"] = true
		var exchanges := 0
		var ammo := 0
		while game.run_state["phase"] == "combat" and exchanges < 60:
			var action := choose_action(game, strategy)
			game.prepare_combat_action(action)
			var result := game.resolve_prepared_combat_round()
			ammo += int(result.get("ammo_used", 0))
			exchanges += 1
		var won: bool = game.run_state["phase"] in ["result", "victory"]
		row["wins"] += int(won)
		row["hp_spent"] += maximum - int(game.run_state["survivor"]["vitals"]["health"])
		row["ammo"] += ammo
		row["conditions"] += game.run_state["survivor"]["conditions"].size()
		row["exchanges"] += exchanges
		row["victory_exchanges"] += exchanges if won else 0
		row["stalls"] += int(exchanges >= 60)
		row["deaths"] += int(str(game.run_state["phase"]) == "death")
	var seeds := float(SEEDS_PER_ROW)
	row["win_rate"] = snappedf(float(row["wins"]) / seeds, 0.001)
	row["mean_hp_spent"] = snappedf(float(row["hp_spent"]) / seeds, 0.1)
	row["mean_ammo"] = snappedf(float(row["ammo"]) / seeds, 0.01)
	row["mean_conditions"] = snappedf(float(row["conditions"]) / seeds, 0.01)
	row["mean_exchanges"] = snappedf(float(row["exchanges"]) / seeds, 0.01)
	row["mean_victory_exchanges"] = snappedf(float(row["victory_exchanges"]) / maxf(1.0, float(row["wins"])), 0.01)
	row["stall_rate"] = snappedf(float(row["stalls"]) / seeds, 0.001)
	return row


## Hungry, injured, disarmed, and out of ammunition are ordinary road states, so
## the benchmark measures them instead of only measuring a fresh survivor.
func _apply_state(game: GameEngine, build: Dictionary, state: String, maximum: int) -> void:
	match state:
		"injured":
			game.run_state["survivor"]["vitals"]["health"] = maxi(1, roundi(float(maximum) * 0.4))
		"hungry":
			game.run_state["survivor"]["vitals"]["satiety"] = 0
			game.run_state["survivor"]["pressures"]["fatigue"] = 40
		"unarmed":
			game.run_state["survivor"]["equipment"]["weapon"] = ""
		"dry":
			var ammo_type := str(build["expected_ammo"])
			if ammo_type != "":
				game.run_state["survivor"]["inventory"].erase(ammo_type)


func _validate_and_collect_fixture_metadata(factory) -> Array:
	var metadata: Array = []
	for build: Dictionary in BUILDS:
		_assert_fixture_definition(build)
		var game: GameEngine = factory.fixture("feral_dogs", str(build["weapon"]), str(build["armor"]), 1)
		var maximum := _apply_build(game, build)
		var weapon_id := str(build["weapon"])
		var armor_id := str(build["armor"])
		var shield_id := str(build.get("shield", ""))
		var weapon_definition: Dictionary = game.content.get_item(weapon_id)
		assert(str(weapon_definition.get("equipment_slot", "")) == "weapon", "%s does not name a weapon-slot item." % build["id"])
		assert(str(game.run_state["survivor"]["equipment"].get("weapon", "")) == weapon_id, "%s weapon was not equipped." % build["id"])
		if not armor_id.is_empty():
			assert(str(game.content.get_item(armor_id).get("equipment_slot", "")) == "armor", "%s does not name an armor-slot item." % build["id"])
			assert(str(game.run_state["survivor"]["equipment"].get("armor", "")) == armor_id, "%s armor was not equipped." % build["id"])
		if not shield_id.is_empty():
			assert(str(game.content.get_item(shield_id).get("equipment_slot", "")) == "accessory", "%s does not name an accessory-slot shield." % build["id"])
			assert(bool(game.content.get_item(shield_id).get("shield", false)), "%s accessory is not a shield." % build["id"])
			assert(not bool(weapon_definition.get("two_handed", false)), "%s equips a shield with a two-handed weapon." % build["id"])
			assert(str(game.run_state["survivor"]["equipment"].get("accessory", "")) == shield_id, "%s shield was not equipped." % build["id"])
		var profile := game.get_player_weapon_profile()
		var attack_stat := str(profile["attack_stat"])
		var ammo_type := str(profile["ammo_type"])
		var ammo_per_attack := int(profile["ammo_per_attack"])
		assert(attack_stat == str(build["expected_attack_stat"]), "%s expected %s attack stat, got %s." % [build["id"], build["expected_attack_stat"], attack_stat])
		assert(bool(profile["mastered"]) == bool(build["expected_mastered"]), "%s mastery assertion failed." % build["id"])
		assert(ammo_type == str(build["expected_ammo"]), "%s expected %s ammunition, got %s." % [build["id"], build["expected_ammo"], ammo_type])
		assert(ammo_per_attack == int(build["expected_ammo_per_attack"]), "%s ammunition cost assertion failed." % build["id"])
		assert(not bool(profile.get("unloaded", false)), "%s starts with an unloaded weapon." % build["id"])
		if not ammo_type.is_empty():
			assert(game.get_item_quantity(ammo_type) >= ammo_per_attack, "%s lacks starting ammunition." % build["id"])
		assert(int(game.run_state["survivor"]["vitals"]["health"]) == maximum, "%s does not start at full HP." % build["id"])
		metadata.append({
			"id": build["id"], "label": build["label"], "stats": build["stats"].duplicate(true),
			"stat_total": build["expected_total"], "weapon": weapon_id, "armor": armor_id,
			"shield": shield_id, "weapon_attack_stat": attack_stat,
			"base_attack_stat_value": int(build["stats"][attack_stat]), "mastered": bool(profile["mastered"]),
			"ammo_type": ammo_type, "ammo_per_attack": ammo_per_attack,
			"starting_ammunition": game.get_item_quantity(ammo_type) if not ammo_type.is_empty() else 0,
			"starting_hp": maximum, "equipment_compatible": true,
		})
	return metadata


func _assert_fixture_definition(build: Dictionary) -> void:
	var stats: Dictionary = build.get("stats", {})
	assert(stats.size() == GameEngine.STATS.size(), "%s must define every base stat by name." % build.get("id", "unknown"))
	var total := 0
	for stat: String in GameEngine.STATS:
		assert(stats.has(stat), "%s is missing %s." % [build.get("id", "unknown"), stat])
		assert(int(stats[stat]) >= 0, "%s has a negative %s value." % [build.get("id", "unknown"), stat])
		total += int(stats[stat])
	assert(total == int(build["expected_total"]), "%s expected a %d-point budget, got %d." % [build["id"], build["expected_total"], total])


func _apply_build(game: GameEngine, build: Dictionary) -> int:
	var stats: Dictionary = build["stats"]
	for stat: String in GameEngine.STATS:
		game.run_state["survivor"]["stats"][stat] = int(stats[stat])
	if build.has("shield"):
		var shield_id := str(build["shield"])
		game.run_state["survivor"]["equipment"]["accessory"] = shield_id
		game.run_state["survivor"]["inventory"][shield_id] = 1
	var maximum := GameEngine.max_hearts_for_grit(int(stats["grit"])) * 50
	game.run_state["survivor"]["vitals"]["max_health"] = maximum
	game.run_state["survivor"]["vitals"]["health"] = maximum
	return maximum


func _load_non_control_rows() -> Array:
	var path := "res://builds/combat_balance.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return []
	var valid_builds: Array[String] = []
	for build: Dictionary in BUILDS:
		valid_builds.append(str(build["id"]))
	var rows: Array = []
	for row: Dictionary in parsed.get("rows", []):
		if str(row.get("strategy", "")) != "read_tells_no_opportunity" and str(row.get("build", "")) in valid_builds:
			rows.append(row)
	return rows


static func choose_action(game: GameEngine, strategy: String) -> String:
	if strategy == "attack_only": return "attack"
	var block := game.combat_action_preview("block")
	var dodge := game.combat_action_preview("dodge")
	var best_defense := "block" if (100 - int(block["chance"])) * 1.25 <= 100 - int(dodge["chance"]) else "dodge"
	if strategy == "repeat_defense": return best_defense
	var state: Dictionary = game.run_state["combat_state"]
	var move := str(state["committed_move"]["id"])
	var attack := game.combat_action_preview("attack")
	# Take a likely killing blow; exploit recovery/charge, defend heavy/sweep
	# when no attack window is already banked, use the saved opportunity freely.
	if int(state["enemy_health"]) <= int(attack["damage_min"]): return "attack"
	if move in ["heavy", "sweep"] and not bool(state["riposte"]) and not bool(state["opening"]): return best_defense
	if bool(state["opportunity_ready"]) and not bool(state["opportunity_used"]): return "opportunity"
	return "attack"
