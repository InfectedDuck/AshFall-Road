extends SceneTree
## Full authoritative engine simulations, not a damage-only approximation.
##
## Fixture data is intentionally named. These builds are controlled comparisons,
## not candidate-generation budgets: the two rifle rows deliberately have 21
## points so the report can distinguish agility from genuine Wits mastery.

const Fixtures = preload("res://tests/narrative_combat_tests.gd")
const Rules = preload("res://scripts/domain/narrative_combat.gd")

const FIXTURE_VERSION := 6
const SEEDS_PER_ROW := 1000
const POLICY_SEED_OFFSET := 1000003
const EXCHANGE_LIMIT := 60
## Every adversary in the package, not a prototype subset.
const BENCHMARK_ENEMIES := ["road_bandits", "feral_dogs", "ash_stalkers", "toll_gang", "marsh_leeches", "bog_raiders", "drone_swarm", "vault_scavs", "glass_cult", "tunnel_hunters", "citadel_guard", "warden_machine", "mutant_crows", "reed_widow", "kilnback", "shutter_skitters", "cable_eater", "pox_dogs", "bile_spewer", "cinder_mauler", "salt_colossus", "reservoir_maw", "ossuary_hound"]
## State variants are extra evidence, so they run against a representative
## subset rather than multiplying the standard comparison.
const SCENARIO_ENEMIES := ["feral_dogs", "road_bandits", "warden_machine"]
const SCENARIO_STRATEGY := "read_tells"
const STATE_SCENARIOS := ["fresh", "injured", "hungry", "unarmed", "dry"]
const STANDARD_STRATEGIES := ["attack_only", "random_actions", "repeat_defense", "read_tells", "read_tells_no_opportunity"]
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
	{
		"id": "chain_grit", "label": "Dredge Chain (grit)", "tier": "early", "family": "counter", "weapon": "wrecking_bar", "armor": "plated_coat", "accessory": "dredge_chain",
		"stats": {"strength": 3, "agility": 2, "wits": 2, "grit": 5, "presence": 3},
		"expected_total": 15, "expected_attack_stat": "grit", "expected_mastered": false,
		"expected_ammo": "", "expected_ammo_per_attack": 0,
	},
	{
		"id": "skirmish", "label": "Fan Guard (skirmisher)", "tier": "early", "family": "precision", "weapon": "pipe_pistol", "armor": "runner_jacket", "shield": "fan_guard",
		"stats": {"strength": 2, "agility": 5, "wits": 3, "grit": 3, "presence": 2},
		"expected_total": 15, "expected_attack_stat": "agility", "expected_mastered": false,
		"expected_ammo": "pistol_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "star_presence", "label": "Brass Star (presence)", "tier": "early", "family": "suppression", "weapon": "holdout_revolver", "armor": "", "accessory": "brass_star",
		"stats": {"strength": 3, "agility": 2, "wits": 2, "grit": 3, "presence": 5},
		"expected_total": 15, "expected_attack_stat": "presence", "expected_mastered": false,
		"expected_ammo": "revolver_rounds", "expected_ammo_per_attack": 1,
	},
	{
		"id": "wraps_agility", "label": "Stalkhide Wraps (agility)", "tier": "early", "family": "precision", "weapon": "pipe_pistol", "armor": "runner_jacket", "accessory": "stalkhide_wraps",
		"stats": {"strength": 2, "agility": 5, "wits": 3, "grit": 3, "presence": 2},
		"expected_total": 15, "expected_attack_stat": "agility", "expected_mastered": false,
		"expected_ammo": "pistol_rounds", "expected_ammo_per_attack": 1,
	},
]


func _init() -> void:
	# Only autostart when Godot is using this class as the main loop. Tests and
	# other tools instantiate it to call one function without running the job.
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	if options.has("error"):
		push_error(str(options["error"]))
		quit(2)
		return
	var seeds_per_row := int(options["seeds"])
	var enemies: Array = options["enemies"]
	var build_ids: Array = options["builds"]
	var selected_builds: Array = []
	for build: Dictionary in BUILDS:
		if str(build["id"]) in build_ids:
			selected_builds.append(build)
	var output_path := str(options["output"])
	var content := ContentRepository.new()
	var factory := Fixtures.new()
	factory.content = content
	var rows: Array = []
	var fixture_metadata := _validate_and_collect_fixture_metadata(factory, selected_builds)
	for enemy: String in enemies:
		for build: Dictionary in selected_builds:
			for strategy: String in STANDARD_STRATEGIES:
				var row := _simulate(factory, enemy, build, strategy, "fresh", seeds_per_row)
				rows.append(row)
				print(JSON.stringify(row))
				await process_frame
	var scenario_rows: Array = []
	var scenario_enemies: Array[String] = []
	for enemy: String in SCENARIO_ENEMIES:
		if enemy not in enemies:
			continue
		scenario_enemies.append(enemy)
		for build: Dictionary in selected_builds:
			if str(build["tier"]) != "early":
				continue
			for state: String in STATE_SCENARIOS:
				if state == "dry" and str(build["expected_ammo"]) == "":
					continue
				var scenario_row := _simulate(factory, enemy, build, SCENARIO_STRATEGY, state, seeds_per_row)
				scenario_rows.append(scenario_row)
				print(JSON.stringify(scenario_row))
				await process_frame
	var output := {
		"benchmark_version": 2,
		"rules": Rules.VERSION,
		"fixture_version": FIXTURE_VERSION,
		"seeds_per_row": seeds_per_row,
		"seed_configuration": {"first": 1, "last": seeds_per_row, "policy_seed_offset": POLICY_SEED_OFFSET},
		"exchange_limit": EXCHANGE_LIMIT,
		"enemies": enemies.size(),
		"enemy_ids": enemies,
		"scenario_enemies": scenario_enemies,
		"builds": selected_builds.size(),
		"build_ids": build_ids,
		"strategies": STANDARD_STRATEGIES,
		"encounters": (rows.size() + scenario_rows.size()) * seeds_per_row,
		"fixtures": fixture_metadata,
		"rows": rows,
		"state_rows": scenario_rows,
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open %s for writing." % output_path)
		quit(1)
		return
	file.store_string(JSON.stringify(output, "\t"))
	file.close()
	print("Wrote %s" % output_path)
	quit()


func _parse_options(args: PackedStringArray) -> Dictionary:
	var options := {"seeds": SEEDS_PER_ROW, "enemies": BENCHMARK_ENEMIES.duplicate(), "builds": [], "output": ""}
	for build: Dictionary in BUILDS:
		(options["builds"] as Array).append(str(build["id"]))
	var filtered := false
	var index := 0
	while index < args.size():
		var option := args[index]
		if option == "--controls-only":
			return {"error": "--controls-only is no longer supported: cached rows can mix different tuning. Use --seeds N and --enemies id,id for a complete matched subset."}
		if option not in ["--seeds", "--enemies", "--builds", "--output"]:
			return {"error": "Unknown benchmark option: %s. Supported: --seeds N --enemies id,id --builds id,id --output res://builds/name.json" % option}
		if index + 1 >= args.size():
			return {"error": "Missing value for %s." % option}
		var value := args[index + 1]
		match option:
			"--seeds":
				if not value.is_valid_int() or int(value) <= 0:
					return {"error": "--seeds must be a positive integer."}
				options["seeds"] = int(value)
				filtered = true
			"--enemies":
				var enemies: Array[String] = []
				for entry: String in value.split(",", true):
					var enemy := entry.strip_edges()
					if enemy not in BENCHMARK_ENEMIES:
						return {"error": "Unknown enemy '%s'. Valid enemies: %s" % [enemy, ",".join(BENCHMARK_ENEMIES)]}
					if enemy in enemies:
						return {"error": "Duplicate enemy '%s'." % enemy}
					enemies.append(enemy)
				options["enemies"] = enemies
				filtered = true
			"--builds":
				var builds: Array[String] = []
				var known: Array[String] = []
				for build: Dictionary in BUILDS:
					known.append(str(build["id"]))
				for entry: String in value.split(",", true):
					var build_id := entry.strip_edges()
					if build_id not in known:
						return {"error": "Unknown build '%s'. Valid builds: %s" % [build_id, ",".join(known)]}
					if build_id in builds:
						return {"error": "Duplicate build '%s'." % build_id}
					builds.append(build_id)
				options["builds"] = builds
				filtered = true
			"--output":
				if not value.begins_with("res://builds/") or not value.ends_with(".json") or value != value.simplify_path() or "\\" in value:
					return {"error": "--output must be a .json file inside res://builds/."}
				options["output"] = value
		index += 2
	if str(options["output"]).is_empty():
		options["output"] = "res://builds/combat_balance_subset.json" if filtered else "res://builds/combat_balance.json"
	return options


func _simulate(factory, enemy: String, build: Dictionary, strategy: String, state: String = "fresh", seeds_per_row: int = SEEDS_PER_ROW) -> Dictionary:
	var row := {
		"enemy": enemy, "build": build["id"], "tier": build["tier"], "family": build["family"],
		"budget": build["expected_total"], "strategy": strategy, "state": state, "seeds": seeds_per_row,
		"wins": 0, "hp_spent": 0, "ammo": 0, "conditions": 0, "exchanges": 0,
		"victory_exchanges": 0, "stalls": 0, "deaths": 0, "unarmed_fallbacks": 0,
	}
	for seed_value in range(1, seeds_per_row + 1):
		var game: GameEngine = factory.fixture(enemy, str(build["weapon"]), str(build["armor"]), seed_value)
		# Policy decisions must never consume the engine's encounter RNG.
		var policy_rng := RandomNumberGenerator.new()
		policy_rng.seed = seed_value + POLICY_SEED_OFFSET
		var maximum := _apply_build(game, build)
		_apply_state(game, build, state, maximum)
		var starting_hp := int(game.run_state["survivor"]["vitals"]["health"])
		if str(game.get_player_weapon_profile().get("family", "unarmed")) == "unarmed":
			row["unarmed_fallbacks"] += 1
		if strategy == "read_tells_no_opportunity":
			game.run_state["combat_state"]["opportunity_used"] = true
		var exchanges := 0
		var ammo := 0
		while game.run_state["phase"] == "combat" and exchanges < EXCHANGE_LIMIT:
			var action := choose_action(game, strategy, policy_rng)
			game.prepare_combat_action(action)
			var result := game.resolve_prepared_combat_round()
			ammo += int(result.get("ammo_used", 0))
			exchanges += 1
		var won: bool = game.run_state["phase"] in ["result", "victory"]
		row["wins"] += int(won)
		row["hp_spent"] += starting_hp - int(game.run_state["survivor"]["vitals"]["health"])
		row["ammo"] += ammo
		row["conditions"] += game.run_state["survivor"]["conditions"].size()
		row["exchanges"] += exchanges
		row["victory_exchanges"] += exchanges if won else 0
		row["stalls"] += int(game.run_state["phase"] == "combat" and exchanges >= EXCHANGE_LIMIT)
		row["deaths"] += int(str(game.run_state["phase"]) == "death")
	var seeds := float(seeds_per_row)
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


func _validate_and_collect_fixture_metadata(factory, selected_builds: Array = []) -> Array:
	var metadata: Array = []
	var validated: Array = selected_builds if not selected_builds.is_empty() else BUILDS
	for build: Dictionary in validated:
		_assert_fixture_definition(build)
		var game: GameEngine = factory.fixture("feral_dogs", str(build["weapon"]), str(build["armor"]), 1)
		var maximum := _apply_build(game, build)
		var weapon_id := str(build["weapon"])
		var armor_id := str(build["armor"])
		var shield_id := str(build.get("shield", ""))
		var accessory_id := str(build.get("accessory", shield_id))
		var weapon_definition: Dictionary = game.content.get_item(weapon_id)
		assert(str(weapon_definition.get("equipment_slot", "")) == "weapon", "%s does not name a weapon-slot item." % build["id"])
		assert(str(game.run_state["survivor"]["equipment"].get("weapon", "")) == weapon_id, "%s weapon was not equipped." % build["id"])
		if not armor_id.is_empty():
			assert(str(game.content.get_item(armor_id).get("equipment_slot", "")) == "armor", "%s does not name an armor-slot item." % build["id"])
			assert(str(game.run_state["survivor"]["equipment"].get("armor", "")) == armor_id, "%s armor was not equipped." % build["id"])
		if not accessory_id.is_empty():
			var accessory_definition: Dictionary = game.content.get_item(accessory_id)
			assert(str(accessory_definition.get("equipment_slot", "")) == "accessory", "%s does not name an accessory-slot item." % build["id"])
			assert(str(game.run_state["survivor"]["equipment"].get("accessory", "")) == accessory_id, "%s accessory was not equipped." % build["id"])
		if not shield_id.is_empty():
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
			"shield": shield_id, "accessory": accessory_id, "weapon_attack_stat": attack_stat,
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
	elif build.has("accessory"):
		var accessory_id := str(build["accessory"])
		game.run_state["survivor"]["equipment"]["accessory"] = accessory_id
		game.run_state["survivor"]["inventory"][accessory_id] = 1
	var maximum := GameEngine.max_hearts_for_grit(int(stats["grit"])) * 50
	game.run_state["survivor"]["vitals"]["max_health"] = maximum
	game.run_state["survivor"]["vitals"]["health"] = maximum
	return maximum


static func choose_action(game: GameEngine, strategy: String, policy_rng: RandomNumberGenerator = null) -> String:
	if strategy == "attack_only": return "attack"
	if strategy == "random_actions":
		assert(policy_rng != null, "random_actions requires an independently seeded policy RNG.")
		var actions: Array[String] = ["attack", "block", "dodge"]
		var combat_state: Dictionary = game.run_state["combat_state"]
		if bool(combat_state["opportunity_ready"]) and not bool(combat_state["opportunity_used"]):
			actions.append("opportunity")
		return actions[policy_rng.randi_range(0, actions.size() - 1)]
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
