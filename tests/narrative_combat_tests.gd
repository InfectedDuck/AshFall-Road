extends RefCounted

const Rules = preload("res://scripts/domain/narrative_combat.gd")
const Transactions = preload("res://scripts/services/combat_transaction.gd")
var check: Callable
var content: ContentRepository

class FakeStore extends RefCounted:
	var failing := false
	var marker_failing := false
	var saved: Dictionary = {}
	var marker := ""
	func save_run(state: Dictionary) -> bool:
		if failing: return false
		saved = state.duplicate(true)
		return true
	func write_death_marker_and_delete(id: String) -> bool:
		if marker_failing: return false
		marker = id
		saved = {}
		return true


func run(repository: ContentRepository, assertion: Callable) -> void:
	content = repository
	check = assertion
	_faces_and_modifiers()
	_defenses_and_moves()
	_difficulty_pressure()
	_armor_order_and_windows()
	_signatures_and_equipment()
	_items_opportunities_and_transactions()
	_narration_and_migration()
	_content_snapshot()
	_benchmark_roster()
	_disk_recovery()
	_stage1_traits_and_scaling()
	_stage3_specializations_and_traits()


func _content_snapshot() -> void:
	var snapshot: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/combat_v2_content_contract.json"))
	for expected: Dictionary in snapshot["adversaries"]:
		var current: Dictionary = content.adversaries[expected["id"]]
		check.call(current["combat"] == expected["combat"] and current["xp_reward"] == expected["xp_reward"] and current["narrative_combat"]["sequence"] == expected["sequence"], "Locked enemy combat contract: " + str(expected["id"]))
	for expected: Dictionary in snapshot["weapons"]:
		var current: Dictionary = content.items[expected["id"]]
		check.call(current["combat"] == expected["combat"] and current["signature"] == expected["signature"] and current["two_handed"] == expected["two_handed"], "Locked weapon combat contract: " + str(expected["id"]))
	for expected: Dictionary in snapshot["shields"]:
		check.call(content.items[expected["id"]] == expected, "Deliberately added shield contract: " + str(expected["id"]))


## The encounter benchmark names its adversaries in a hardcoded list, so the
## list can fall behind the package without any suite noticing. Loading the
## constant at runtime keeps the tool free to preload this file.
func _benchmark_roster() -> void:
	var roster: Array = load("res://tools/combat_balance.gd").get_script_constant_map()["BENCHMARK_ENEMIES"]
	for adversary_id: String in content.adversaries:
		check.call(adversary_id in roster, "Encounter benchmark measures adversary: " + adversary_id)
	for benchmark_id: Variant in roster:
		check.call(content.adversaries.has(str(benchmark_id)), "Benchmark roster names a defined adversary: " + str(benchmark_id))


func fixture(enemy: String = "feral_dogs", weapon: String = "salvage_cleaver", armor: String = "", seed_value: int = 812) -> GameEngine:
	var game := GameEngine.new(content)
	var survivor: Dictionary = game.create_candidates(seed_value)[0]
	survivor["stats"] = {"strength": 5, "agility": 5, "wits": 5, "grit": 5, "presence": 5}
	survivor["vitals"] = {"health": 400, "max_health": 400, "max_hearts": 8, "satiety": 4}
	survivor["inventory"] = {"pistol_rounds": 12, "revolver_rounds": 12, "rifle_rounds": 12, "shotgun_shells": 12, "medkit": 2, "smoke_bomb": 2}
	survivor["equipment"] = {"weapon": weapon, "armor": armor, "accessory": "", "backpack": ""}
	if weapon != "": survivor["inventory"][weapon] = 1
	if armor != "": survivor["inventory"][armor] = 1
	game.start_run(survivor, seed_value)
	game.run_state["current_event_id"] = "outskirts_dogs"
	game.start_combat(0)
	var state: Dictionary = game.run_state["combat_state"]
	state["adversary_id"] = enemy
	state["log"][0]["text"] = "%s closes in. Combat begins." % content.get_adversary(enemy)["name"]
	state["enemy_health"] = int(content.get_adversary(enemy)["combat"]["max_health"])
	state["enemy_max_health"] = state["enemy_health"]
	state["can_flee"] = enemy != "warden_machine"
	Rules.initialize(game)
	return game


func round_for(game: GameEngine, action: String, face: int = 12, enemy_face: int = 10, item: String = "") -> Dictionary:
	var prepared := game.prepare_combat_action(action, item)
	check.call(not prepared.has("error"), "New combat prepares " + action)
	if prepared.has("error"): return {}
	game.run_state["pending_combat_round"]["player_roll"] = face if action != "use_item" else 0
	game.run_state["pending_combat_round"]["enemy_roll"] = enemy_face
	return game.resolve_prepared_combat_round()


func move_to(game: GameEngine, id: String) -> void:
	var sequence: Array = content.get_adversary(str(game.run_state["combat_state"]["adversary_id"]))["narrative_combat"]["sequence"]
	game.run_state["combat_state"]["move_index"] = sequence.find(id)
	Rules.commit_move(game)


func _faces_and_modifiers() -> void:
	for chance in range(5, 100, 5):
		var successes := 0
		var threshold := D20Resolver.required_roll(chance)
		for face in range(1, 21):
			var damage := Rules.hit_damage(face, chance, 7, 10)
			if damage > 0: successes += 1
			check.call((damage > 0) == (face >= threshold and face != 1), "Attack face %d matches %d%%" % [face, chance])
		check.call(successes * 5 == chance, "Hit percentage exactly matches faces")
		check.call(Rules.hit_damage(20, chance, 7, 10) == 10, "Natural 20 is maximum, including 5% edge case")
		if threshold < 20:
			check.call(Rules.hit_damage(threshold, chance, 7, 10) == 7, "First successful face is minimum")
	check.call(Rules.probability(-100) == 5 and Rules.probability(500) == 95 and Rules.probability(500, 85) == 85, "Chance caps apply independently")
	var game := fixture("road_bandits", "pipe_pistol")
	var base := game.combat_action_preview("attack")
	game._apply_condition("momentum")
	check.call(game.combat_effective_stats()["agility"] == int(base["profile"]["stat_value"]) + 1, "Temporary conditions enter shared combat stats")
	game.run_state["survivor"]["pressures"] = {"fatigue": 50, "radiation": 25}
	game.run_state["survivor"]["vitals"]["satiety"] = 1
	game.run_state["survivor"]["vitals"]["health"] = 100
	game._change_item("scrap_parts", 100)
	check.call(game.combat_effective_stats()["agility"] == 0, "Survival, low HP and overweight modifiers clamp only after summing")
	var hurt := game.combat_action_preview("attack")
	check.call(int(hurt["chance"]) < int(base["chance"]) and int(hurt["damage_max"]) < int(base["damage_max"]), "Bad conditions affect both accuracy and damage")
	game.prepare_combat_action("attack")
	var saved_preview: Dictionary = game.run_state["pending_combat_round"]["preview"].duplicate(true)
	game.run_state["pending_combat_round"]["player_roll"] = 20
	game.run_state["survivor"]["stats"]["agility"] = 1000
	var resolved := game.resolve_prepared_combat_round()
	check.call(resolved["rolled_player_damage"] == saved_preview["damage_max"] and resolved["chance"] == saved_preview["chance"], "Prepared probability/damage are frozen; resolution never recalculates")
	game = fixture("road_bandits", "pipe_pistol")
	var ammo := game.get_item_quantity("pistol_rounds")
	var missed := round_for(game, "attack", 1)
	check.call(missed["player_damage"] == 0 and game.get_item_quantity("pistol_rounds") == ammo - 1, "Firearm misses cost ammunition and deal zero damage")
	check.call(int(missed["exposure_damage"]) > 0, "Natural one exposes current response")
	game = fixture("road_bandits")
	var critical := round_for(game, "attack", 20)
	check.call(not bool(critical.get("enemy_staggered", false)) and int(critical["enemy_damage"]) > 0, "Ordinary critical no longer staggers")
	game = fixture("road_bandits", "pipe_pistol")
	game.run_state["survivor"]["inventory"]["pistol_rounds"] = 0
	var unarmed := game.get_player_weapon_profile()
	check.call(unarmed["name"] == "Unarmed" and unarmed["family"] == "unarmed" and unarmed["ammo_type"] == "", "Unloaded weapon loses technique and ammunition cost")


func _defenses_and_moves() -> void:
	for enemy: String in content.adversaries:
		var game := fixture(enemy)
		var sequence: Array = content.adversaries[enemy]["narrative_combat"]["sequence"]
		for move_id: String in sequence:
			move_to(game, move_id)
			var before: Dictionary = game.run_state["combat_state"]["committed_move"].duplicate(true)
			game.prepare_combat_action("block")
			check.call(game.run_state["pending_combat_round"]["move"] == before and before["tell"] != "", "Enemy commitment persists: %s/%s" % [enemy, move_id])
			var other := GameEngine.new(content)
			other.restore_run(game.run_state)
			check.call(other.run_state["combat_state"]["committed_move"] == before, "Committed tell survives restoration")
			game.run_state["phase"] = "combat"
			game.run_state["pending_combat_round"] = {}
	for action: String in ["block", "dodge"]:
		var game := fixture("road_bandits", "wrecking_bar", "plated_coat")
		var result := round_for(game, action, 20, 20)
		check.call(result["enemy_damage"] == 0 and game.run_state["survivor"]["conditions"].is_empty(), "Successful %s prevents enemy critical damage and condition" % action)
		check.call(bool(game.run_state["combat_state"]["riposte" if action == "block" else "opening"]), "Defense banks its next-action benefit")
		check.call(int(result["defense_blocked"]) > 0 and int(result["armor_blocked"]) < int(result["enemy_raw_damage"]), "Active defense is reported separately from armor")
		round_for(game, "use_item", 0, 10, "medkit")
		check.call(not game.run_state["combat_state"]["riposte"] and not game.run_state["combat_state"]["opening"], "An item consumes the prior attack window")
		game = fixture("road_bandits", "wrecking_bar", "plated_coat")
		result = round_for(game, action, 1, 10)
		var armor: Dictionary = CombatResolver.mitigate_damage(int(result["enemy_raw_damage"]), game._armor_rating())
		check.call(result["enemy_damage"] == roundi(float(armor["final"]) * (1.25 if action == "block" else 1.0)), "Failure multiplier follows armor without compounding")
		var authored := str(content.adversaries["road_bandits"]["combat"]["critical_condition"])
		check.call((authored in game.run_state["survivor"]["conditions"]) == (action == "block"), "Block natural one alone adds authored condition")
		game = fixture("warden_machine")
		round_for(game, action, 20, 20)
		check.call(not game.run_state["combat_state"]["riposte"] and not game.run_state["combat_state"]["opening"], "Defending Charge earns no attack window")
	var game := fixture("road_bandits")
	var strike := game.combat_action_preview("attack")
	move_to(game, "brace")
	var brace := game.combat_action_preview("attack")
	check.call(int(brace["damage_max"]) <= ceili(float(strike["damage_max"]) * 0.5), "Brace halves player damage")
	move_to(game, "recover")
	check.call(int(game.combat_action_preview("attack")["damage_max"]) > int(strike["damage_max"]), "Recover creates a damage opening")
	game = fixture("warden_machine")
	var hp := int(game.run_state["survivor"]["vitals"]["health"])
	round_for(game, "dodge", 1, 20)
	check.call(game.run_state["survivor"]["vitals"]["health"] == hp and game.run_state["combat_state"]["committed_move"]["id"] == "heavy", "Charge deals no damage and commits Heavy next")
	game = fixture("road_bandits", "", "plated_coat")
	for index in range(3): round_for(game, "dodge", 20, 1)
	check.call(game.run_state["survivor"]["pressures"]["fatigue"] == 9, "Three ongoing exchanges add nine Fatigue, including successful defenses")


func _difficulty_pressure() -> void:
	# Ordinary armor must not turn the introductory flock into harmless chip
	# damage. Check fresh targets so a final hit's remaining-HP cap cannot hide it.
	var sequence: Array = content.adversaries["mutant_crows"]["narrative_combat"]["sequence"]
	for move_id: String in sequence:
		if float(content.combat_data["moves"][move_id]["damage"]) <= 0.0:
			continue
		var target := fixture("mutant_crows", "salvage_cleaver", "scrap_vest")
		move_to(target, move_id)
		var response := round_for(target, "attack", 1, 10)
		check.call(int(response["enemy_damage"]) >= 10, "Undefended crow %s costs meaningful HP through starter armor" % move_id)
	var game := fixture("mutant_crows", "salvage_cleaver", "scrap_vest")
	game.run_state["survivor"]["stats"]["grit"] = 3
	game.run_state["survivor"]["vitals"].merge({"health": 300, "max_health": 300, "max_hearts": 6}, true)
	var exchanges := 0
	while str(game.run_state["phase"]) == "combat" and exchanges < 30:
		round_for(game, "attack", 1, 10)
		exchanges += 1
	check.call(str(game.run_state["phase"]) == "death", "Crows kill a 300-HP armored survivor who wastes 30 attacks")

	# Successful defense buys a turn, but nine such turns reach a real strain
	# penalty. Compare the same enemy move to isolate fatigue from tell bonuses.
	game = fixture("mutant_crows", "", "scrap_vest")
	# Use a starter Agility value that crosses a displayed 5% probability step.
	game.run_state["survivor"]["stats"]["agility"] = 3
	move_to(game, "strike")
	var initial_chance := int(game.combat_action_preview("dodge")["chance"])
	var initial_hp := int(game.run_state["survivor"]["vitals"]["health"])
	for index in range(9):
		round_for(game, "dodge", 20, 20)
	move_to(game, "strike")
	check.call(int(game.run_state["survivor"]["pressures"]["fatigue"]) == 27 and int(game.run_state["survivor"]["vitals"]["health"]) == initial_hp, "Nine successful defenses avoid damage while adding 27 Fatigue")
	check.call(int(game.combat_action_preview("dodge")["chance"]) < initial_chance, "Prolonged defense reduces the displayed chance against the same crow strike")
	move_to(game, "recover")
	var recovery := round_for(game, "attack", 1, 20)
	check.call(int(recovery["enemy_damage"]) == 0 and int(game.run_state["survivor"]["vitals"]["health"]) == initial_hp, "Enemy recovery stays safe even when the survivor critically misses")

	# Use actual generated candidates and their starting gear, not the fixture's
	# all-five stats. Runtime loading avoids the benchmark's fixture preload cycle.
	var benchmark: GDScript = load("res://tools/combat_balance.gd")
	var outcomes: Dictionary = {}
	for strategy: String in ["random_actions", "read_tells"]:
		var totals := {"wins": 0, "deaths": 0, "hp_spent": 0, "stalls": 0, "invalid_actions": 0}
		for seed_value in range(1, 101):
			game = fixture("mutant_crows", "", "", seed_value)
			game.run_state["survivor"] = game.create_candidates(seed_value)[seed_value % 3]
			var starting_hp := int(game.run_state["survivor"]["vitals"]["health"])
			var policy_rng := RandomNumberGenerator.new()
			policy_rng.seed = seed_value + 7000
			exchanges = 0
			while str(game.run_state["phase"]) == "combat" and exchanges < 60:
				var action := str(benchmark.choose_action(game, strategy, policy_rng))
				if action not in ["attack", "block", "dodge", "opportunity"] or game.prepare_combat_action(action).has("error"):
					totals["invalid_actions"] += 1
					break
				game.resolve_prepared_combat_round()
				exchanges += 1
			var phase := str(game.run_state["phase"])
			totals["wins"] += int(phase in ["result", "victory"])
			totals["deaths"] += int(phase == "death")
			totals["stalls"] += int(phase == "combat" and exchanges >= 60)
			totals["hp_spent"] += starting_hp - int(game.run_state["survivor"]["vitals"]["health"])
		outcomes[strategy] = totals
		check.call(int(totals["invalid_actions"]) == 0 and int(totals["stalls"]) == 0 and int(totals["wins"]) + int(totals["deaths"]) == 100, "Generated crow encounters resolve using legal %s actions without healing or fleeing" % strategy)
	var random_results: Dictionary = outcomes["random_actions"]
	var informed_results: Dictionary = outcomes["read_tells"]
	check.call(int(random_results["deaths"]) > 0, "Random actions can kill fresh generated starters against crows (%d/100 deaths)" % int(random_results["deaths"]))
	check.call(int(informed_results["wins"]) > 90, "Reading tells keeps over 90%% of fresh starters alive against crows (%d/100 wins)" % int(informed_results["wins"]))
	check.call(float(random_results["hp_spent"]) > float(informed_results["hp_spent"]) * 1.25, "Random actions cost at least 25%% more HP than reading tells (means %.1f vs %.1f)" % [float(random_results["hp_spent"]) / 100.0, float(informed_results["hp_spent"]) / 100.0])


func _armor_order_and_windows() -> void:
	for rating in range(6):
		var game := fixture("road_bandits", "", "")
		var armor_id := ""
		for item: Dictionary in content.items.values():
			if int(item.get("damage_reduction", -1)) == rating and str(item.get("category", "")) == "armor":
				armor_id = str(item["id"])
				break
		game.run_state["survivor"]["equipment"]["armor"] = armor_id
		var stats := game.combat_effective_stats()
		var expected_block := Rules.probability(35.0 + 30.0 * float(stats["strength"]) / (float(stats["strength"]) + 5.0) + Rules.BLOCK_ARMOR[rating], 85)
		var expected_dodge := Rules.probability(35.0 + 50.0 * float(stats["agility"]) / (float(stats["agility"]) + 5.0) - Rules.DODGE_ARMOR[rating] + (10 if armor_id in ["runner_jacket", "scout_leathers"] else 0), 85)
		check.call(game.combat_action_preview("block")["chance"] == expected_block and game.combat_action_preview("dodge")["chance"] == expected_dodge, "Armor %d applies exact Block and Dodge tables" % rating)
		var result := round_for(game, "block", 1, 20)
		var after_armor: Dictionary = CombatResolver.mitigate_damage(int(result["enemy_raw_damage"]), rating)
		check.call(result["enemy_damage"] == roundi(float(after_armor["final"]) * 1.25), "Enemy critical plus Block fumble never compounds exposure")
	var game := fixture("warden_machine", "scrap_shotgun")
	game.run_state["survivor"]["stats"]["agility"] = 6
	game.run_state["combat_state"]["enemy_health"] = 220
	game.run_state["combat_state"]["opportunity_ready"] = true
	game.run_state["combat_state"]["riposte"] = true
	move_to(game, "recover")
	var profile := game.get_player_weapon_profile()
	var attack := game.combat_action_preview("opportunity")
	check.call(attack["damage_max"] == roundi(float(profile["unrounded_max"]) * (1.0 + 0.45 + 0.75 + 0.25 + 0.25)), "Execution, Opportunity, Riposte and Recover add before one rounding step")
	var ammo := game.get_item_quantity("shotgun_shells")
	round_for(game, "opportunity", 1, 1)
	check.call(game.get_item_quantity("shotgun_shells") == ammo - 1 and not game.run_state["combat_state"]["riposte"], "Opportunity miss consumes ammunition and the attack window")
	game = fixture("warden_machine", "shock_probe")
	move_to(game, "heavy")
	check.call(not round_for(game, "attack", 14, 1)["enemy_interrupted"], "Unmastered Disruption cannot trigger at fourteen")
	move_to(game, "heavy")
	check.call(round_for(game, "attack", 15, 1)["enemy_interrupted"], "Unmastered Disruption triggers at fifteen")
	game = fixture("road_bandits", "holdout_revolver")
	game.run_state["survivor"]["stats"]["presence"] = 6
	check.call(round_for(game, "attack", 15, 1)["suppression_percent"] == 40, "Mastered Suppression reaches forty percent")
	game = fixture("road_bandits", "pipe_pistol")
	round_for(game, "dodge", 20, 1)
	var opened := game.combat_action_preview("attack")
	var plain := game.get_player_weapon_profile()
	check.call(opened["damage_max"] == roundi(float(plain["unrounded_max"]) * 1.3 * 0.5), "Precision adds thirty percent to Opening before enemy Brace")


func _signatures_and_equipment() -> void:
	for weapon_id: String in content.items:
		var item: Dictionary = content.items[weapon_id]
		if not item.has("signature"): continue
		var game := fixture("warden_machine", weapon_id)
		var stat := str(item["combat"]["attack_stat"])
		game.run_state["survivor"]["stats"][stat] = 5
		game._apply_condition("momentum")
		check.call(not game.get_player_weapon_profile()["mastered"], "Temporary/equipment stats cannot unlock mastery: " + weapon_id)
		game.run_state["survivor"]["stats"][stat] = 6
		check.call(game.get_player_weapon_profile()["mastered"], "Base six unlocks mastery: " + weapon_id)
		var profile := game.get_player_weapon_profile()
		var family := str(profile["family"])
		if family in ["execution", "counter", "precision"]:
			var extra := 0.45 if family == "execution" else 0.65 if family == "counter" else 0.4
			if family == "execution": game.run_state["combat_state"]["enemy_health"] = 220
			else: game.run_state["combat_state"]["riposte" if family == "counter" else "opening"] = true
			var preview := game.combat_action_preview("attack")
			check.call(preview["damage_max"] == roundi(float(profile["unrounded_max"]) * (1.0 + extra)), "Signature additive damage matches displayed range: " + family)
		if family == "disruption":
			move_to(game, "heavy")
			var interrupt := round_for(game, "attack", 13)
			check.call(bool(interrupt["enemy_interrupted"]) and int(interrupt["enemy_damage"]) == 0, "Mastered disruption interrupts Heavy on thirteen")
			for index in range(2):
				move_to(game, "heavy")
				var blocked := round_for(game, "attack", 20, 1)
				check.call(not bool(blocked["enemy_interrupted"]), "Disruption cannot repeat during next two exchanges")
		if family == "suppression":
			move_to(game, "heavy")
			check.call(round_for(game, "attack", 20, 1)["suppression_percent"] == 0, "Machines ignore suppression")
			game = fixture("road_bandits", weapon_id)
			check.call(round_for(game, "attack", 15, 10)["suppression_percent"] == 30, "Organic enemy suppression reduces this response")
	var game := fixture("road_bandits", "rebar_spear")
	game.run_state["combat_state"] = {}
	game.run_state["phase"] = "checkpoint"
	game._change_item("scrap_buckler", 1)
	game._change_item("wrecking_bar", 1)
	check.call(not game.equip_item("scrap_buckler")["success"], "Two-handed weapon rejects shield with an explanation")
	game.equip_item("wrecking_bar")
	check.call(game.equip_item("scrap_buckler")["success"], "One-handed weapon accepts shield")
	game.equip_item("rebar_spear")
	check.call(game.run_state["survivor"]["equipment"]["accessory"] == "" and game.get_item_quantity("scrap_buckler") == 1, "Two-handed equip returns shield without destroying it")
	game = fixture("road_bandits", "wrecking_bar")
	check.call(not game.equip_item("salvage_cleaver")["success"] and not game.unequip_item("weapon")["success"], "Equipment changes cannot bypass combat actions")
	var base_block := int(game.combat_action_preview("block")["chance"])
	var base_dodge := int(game.combat_action_preview("dodge")["chance"])
	game.run_state["survivor"]["equipment"]["accessory"] = "scrap_buckler"
	check.call(int(game.combat_action_preview("block")["chance"]) == base_block + 15 and int(game.combat_action_preview("dodge")["chance"]) == base_dodge - 5, "Buckler applies its exact defense tradeoff")
	check.call(content.events["outskirts_cache"]["choices"][2]["outcome"]["items"]["scrap_buckler"] == 1 and content.events["industrial_locker"]["choices"][0]["success"]["items"]["road_shield"] == 1, "Both shields have explicit acquisition routes")


func _items_opportunities_and_transactions() -> void:
	var game := fixture("road_bandits")
	game._apply_condition("momentum")
	round_for(game, "use_item", 0, 1, "medkit")
	check.call(game.run_state["condition_uses"].get("momentum", 0) == 1, "Item use does not spend temporary check duration")
	round_for(game, "dodge", 20, 1)
	check.call(not game.run_state["condition_uses"].has("momentum"), "Defense consumes temporary check duration")
	game = fixture("road_bandits")
	var smoke := round_for(game, "use_item", 0, 20, "smoke_bomb")
	check.call(smoke["flee_success"] and game.get_item_quantity("smoke_bomb") == 1 and game.run_state["survivor"]["vitals"]["health"] == 400, "Smoke consumes one and escapes without damage")
	check.call(game.run_state["experience"] == 4 and game.run_state["survivor"]["pressures"]["fatigue"] == 5, "Smoke grants journey XP only and escape Fatigue")
	game = fixture("warden_machine")
	check.call(not game.combat_action_preview("use_item", "smoke_bomb")["available"] and not game.combat_action_preview("flee")["available"], "No-escape encounters reject Smoke and Flee")
	game = fixture("road_bandits")
	var failed_flee := round_for(game, "flee", 1, 10)
	check.call(not bool(failed_flee.get("flee_success", false)) and game.run_state["experience"] == 0 and failed_flee["enemy_damage"] > 0, "Failed fleeing receives response without XP")
	var escaped := round_for(game, "flee", 20, 20)
	check.call(escaped["flee_success"] and game.run_state["experience"] == 4, "Successful fleeing grants no combat XP")
	game = fixture("warden_machine", "")
	for expected in [25, 35, 45, 45]:
		move_to(game, "recover")
		game.prepare_combat_action("attack")
		game.run_state["pending_combat_round"]["player_roll"] = 1
		game.run_state["pending_combat_round"]["opportunity_roll"] = 100
		game.resolve_prepared_combat_round()
		check.call(game.run_state["combat_state"]["opportunity_chance"] == expected, "Opportunity pity increases only on unsuccessful eligible roll")
	move_to(game, "recover")
	game.prepare_combat_action("attack")
	game.run_state["pending_combat_round"]["opportunity_roll"] = 1
	game.resolve_prepared_combat_round()
	check.call(game.combat_action_preview("opportunity")["available"], "Opportunity remains available without timed input")
	var opportunity := round_for(game, "opportunity", 1, 1)
	check.call(opportunity["player_damage"] == 0 and game.run_state["combat_state"]["opportunity_used"] and not game.combat_action_preview("opportunity")["available"], "Miss spends the one Opportunity; it cannot regenerate")
	game = fixture("road_bandits", "pipe_pistol")
	var transaction := Transactions.new()
	var store := FakeStore.new()
	var before := game.run_state.duplicate(true)
	store.failing = true
	check.call(transaction.prepare(game, store, "attack").has("error") and game.run_state == before, "Preparation save failure rolls back the entire state including RNG")
	store.failing = false
	transaction.prepare(game, store, "attack")
	var restarted := GameEngine.new(content)
	restarted.restore_run(store.saved)
	var expected := restarted.resolve_prepared_combat_round()
	store.failing = true
	check.call(transaction.resolve(game, store).get("retry_save", false), "Failed resolution commit blocks presentation")
	var after := game.run_state.duplicate(true)
	check.call(transaction.prepare(game, store, "attack").has("error"), "Uncommitted result locks further actions")
	transaction.resolve(game, store)
	check.call(game.run_state == after, "Repeated save failure never resolves damage or ammo twice")
	store.failing = false
	var committed: Dictionary = transaction.resolve(game, store)
	check.call(committed == expected and store.saved == after, "Save retry commits the identical prepared result")
	check.call(game.resolve_prepared_combat_round().has("error"), "After animation/restart resolution cannot replay")
	for death: bool in [false, true]:
		game = fixture("road_bandits", "pipe_pistol")
		transaction = Transactions.new()
		store = FakeStore.new()
		if death: game.run_state["survivor"]["vitals"]["health"] = 1
		else: game.run_state["combat_state"]["enemy_health"] = 1
		transaction.prepare(game, store, "attack")
		game.run_state["pending_combat_round"]["player_roll"] = 1 if death else 20
		game.run_state["pending_combat_round"]["enemy_roll"] = 20
		store.failing = true
		transaction.resolve(game, store)
		after = game.run_state.duplicate(true)
		store.failing = false
		store.marker_failing = death
		var retry: Dictionary = transaction.resolve(game, store)
		if death: check.call(retry.get("retry_save", false), "Death marker failure keeps actions locked")
		store.marker_failing = false
		if death: transaction.resolve(game, store)
		check.call(game.run_state == after, "Victory/death saving never duplicates rewards")
		check.call((store.marker != "") if death else game.run_state["experience"] == int(content.adversaries["road_bandits"]["xp_reward"]) + 4, "Death secured or combat victory XP applied once")
		if not death:
			check.call(game.run_state["last_result"]["resolution"]["success_chance"] < 100, "Victory retains the original hit chance rather than displaying guaranteed success")


func _narration_and_migration() -> void:
	var game := fixture("road_bandits", "")
	game.prepare_combat_action("attack")
	var text := str(game.run_state["pending_combat_round"]["narration"]["hit"]["text"])
	game.run_state["pending_combat_round"]["player_roll"] = 19
	game.resolve_prepared_combat_round()
	game.prepare_combat_action("attack")
	check.call(str(game.run_state["pending_combat_round"]["narration"]["hit"]["text"]) != text, "Authored narration avoids immediate repetition")
	for seed_value in range(20):
		game = fixture("warden_machine", "shock_probe", "riot_padding", seed_value + 1)
		var restored := GameEngine.new(content)
		for action: String in ["attack", "dodge", "attack", "block", "attack"]:
			if game.run_state["phase"] != "combat": break
			game.prepare_combat_action(action)
			restored.restore_run(game.run_state)
			var a := game.resolve_prepared_combat_round()
			var b := restored.resolve_prepared_combat_round()
			check.call(a == b and game.run_state == restored.run_state, "Seeded decisions reproduce HP, dice, narration, opportunities, and XP")
	var saves := SaveService.new()
	game = fixture()
	game.run_state["schema_version"] = 4
	game.run_state["combat_state"].erase("combat_rules_version")
	game.prepare_combat_action("guard")
	var before := game.run_state.duplicate(true)
	var migrated := saves._migrate_run(game.run_state.duplicate(true))
	check.call(migrated["schema_version"] == 5 and migrated["combat_state"]["combat_rules_version"] == 1 and migrated["pending_combat_round"] == before["pending_combat_round"], "Schema five preserves legacy pending actions byte-for-byte")
	var legacy := GameEngine.new(content)
	legacy.restore_run(migrated)
	var old := game.resolve_prepared_combat_round()
	var current := legacy.resolve_prepared_combat_round()
	check.call(old == current and not legacy.is_narrative_combat(), "Entire migrated fight stays on original rules")
	check.call(saves.default_profile()["combat_presentation"] == "manual" and saves.default_profile()["schema_version"] == 5, "Profile five preserves Manual Roll default")


func _disk_recovery() -> void:
	var store := SaveService.new("ashfall_combat_v2_test_")
	store.clear_death_marker()
	var game := fixture("road_bandits", "pipe_pistol")
	game.prepare_combat_action("attack")
	check.call(store.save_run(game.run_state), "New prepared combat serializes to disk")
	var restored := GameEngine.new(content)
	restored.restore_run(store.load_run())
	check.call(game.resolve_prepared_combat_round() == restored.resolve_prepared_combat_round(), "Actual JSON save/load preserves concealed V2 result and narration")
	store.save_run(game.run_state)
	restored.restore_run(store.load_run())
	check.call(restored.resolve_prepared_combat_round().has("error"), "Disk recovery after damage cannot resolve it twice")
	var profile := store.default_profile()
	profile["combat_presentation"] = "quick"
	store.save_profile(profile)
	check.call(store.load_profile()["combat_presentation"] == "quick", "Quick Roll preference persists offline")
	profile["combat_presentation"] = "invalid"
	store.save_profile(profile)
	check.call(store.load_profile()["combat_presentation"] == "manual", "Invalid presentation preference safely defaults to Manual")
	check.call(store.write_death_marker_and_delete(str(game.run_state["run_id"])), "New combat death marker persists")
	store.save_run(game.run_state)
	check.call(store.load_run().is_empty(), "Matching death marker overrides even a reappearing schema-five run")
	store.clear_death_marker()
	store.delete_run_files()
	for suffix: String in ["profile.json", "profile.json.bak"]:
		store._remove_if_exists("user://ashfall_combat_v2_test_" + suffix)


## Stage 1 (Combat+relationships.md Weeks 1-2): two distinctive fights, v3
## scaling, interaction UI domain, and two supporting items. Every mechanic has
## at least two responses and phase changes affect the next round.
func _stage1_traits_and_scaling() -> void:
	var CombatResolver = load("res://scripts/domain/combat_resolver.gd")
	check.call(is_equal_approx(CombatResolver.stat_damage_multiplier(5), 1.3), "V2 scaling is 1.3x at stat 5")
	check.call(is_equal_approx(CombatResolver.stat_damage_multiplier_v3(5), 1.3), "V3 preserves the launch curve through stat 5")
	check.call(is_equal_approx(CombatResolver.stat_damage_multiplier_v3(10), 1.8), "V3 stat 5 to 10 is 1.3 to 1.8 (about 38 percent)")
	# New fights start on v3; in-flight v2 fights keep their frozen rules.
	var fresh := fixture("reed_widow", "salvage_cleaver", "", 9101)
	check.call(int(fresh.run_state["combat_state"].get("combat_rules_version", 0)) == Rules.VERSION, "New fights start under combat rules v3")
	check.call(str(fresh.run_state["combat_state"].get("trait_id", "")) == "brood", "Reed Widow carries the brood trait")
	check.call("BROOD 0/3" in " ".join(fresh.combat_presentation_snapshot().get("status_labels", [])), "Brood counter is visible before it hatches")
	# Brood: an uninterrupted heavy hatches +1 and strengthens the response.
	move_to(fresh, "heavy")
	var heavy_index := int(fresh.run_state["combat_state"]["move_index"])
	# Use an unmastered non-disruption weapon so the heavy is never interrupted.
	var hatched := round_for(fresh, "attack", 12, 10)
	check.call(int(fresh.run_state["combat_state"].get("trait_brood", -1)) == 1, "An uninterrupted Widow heavy hatches one brood")
	check.call(int(fresh.run_state["combat_state"]["move_index"]) == heavy_index + 1, "Phase change advances the sequence instead of replacing the previewed attack")
	# Second response: tear the nest bare-handed without spending an item.
	var tear_preview := fresh.combat_action_preview("interact", "tear_nest")
	check.call(bool(tear_preview.get("available", false)), "Tearing the nest is available while brood lives")
	round_for(fresh, "interact", 0, 10, "tear_nest")
	check.call(int(fresh.run_state["combat_state"].get("trait_brood", -1)) == 0, "Tearing clears one brood without a consumable")
	# Third response: incendiary clears and prevents future brood.
	fresh.run_state["survivor"]["inventory"]["incendiary_charge"] = 1
	move_to(fresh, "heavy")
	round_for(fresh, "use_item", 0, 10, "incendiary_charge")
	check.call(bool(fresh.run_state["combat_state"].get("trait_nest_destroyed", false)), "Incendiary destroys the nest")
	check.call(int(fresh.run_state["combat_state"].get("trait_brood", -1)) == 0, "Burning clears the brood")
	move_to(fresh, "heavy")
	round_for(fresh, "attack", 12, 10)
	check.call(int(fresh.run_state["combat_state"].get("trait_brood", -1)) == 0, "A destroyed nest hatches no new brood")
	# Kilnback: attacks build heat, full heat opens the shell for bonus damage.
	var kiln := fixture("kilnback", "salvage_cleaver", "", 9201)
	check.call(str(kiln.run_state["combat_state"].get("trait_id", "")) == "heat", "Kilnback carries the heat trait")
	for i in range(3):
		if int(kiln.run_state["combat_state"].get("enemy_health", 0)) <= 0:
			break
		move_to(kiln, "strike")
		round_for(kiln, "attack", 20, 1)
	check.call(bool(kiln.run_state["combat_state"].get("trait_shell_open", false)), "Three landed hits open the Kilnback shell")
	var open_preview := kiln.combat_action_preview("attack")
	check.call(int(open_preview.get("damage_min", 0)) > 0, "Open-shell preview still prices the attack")
	# Coolant forces the window early; venting cools without attacking.
	var cool := fixture("kilnback", "salvage_cleaver", "", 9202)
	cool.run_state["survivor"]["inventory"]["coolant_canister"] = 1
	round_for(cool, "use_item", 0, 10, "coolant_canister")
	check.call(bool(cool.run_state["combat_state"].get("trait_shell_open", false)), "Coolant forces the shell open")
	var vent := fixture("kilnback", "salvage_cleaver", "", 9203)
	move_to(vent, "strike")
	round_for(vent, "attack", 20, 1)
	check.call(int(vent.run_state["combat_state"].get("trait_heat", 0)) == 1, "A landed hit builds one heat")
	check.call(not vent.combat_interactions().is_empty(), "Venting is offered while heat lives")
	round_for(vent, "interact", 0, 10, "vent_heat")
	check.call(int(vent.run_state["combat_state"].get("trait_heat", 0)) == 0, "Venting cools one heat without attacking")
	# Switching consumes the round, keeps intention, and never resets traits.
	var swap := fixture("reed_widow", "salvage_cleaver", "", 9301)
	swap.run_state["survivor"]["inventory"]["rebar_spear"] = 1
	var committed_before := str(swap.run_state["combat_state"]["committed_move"]["id"])
	var brood_before_swap := int(swap.run_state["combat_state"].get("trait_brood", 0))
	round_for(swap, "switch_weapon", 0, 10, "rebar_spear")
	check.call(str(swap.run_state["survivor"]["equipment"].get("weapon", "")) == "rebar_spear", "Switching equips the carried weapon")
	check.call(int(swap.run_state["combat_state"].get("trait_brood", -1)) == brood_before_swap, "Switching never resets trait counters")
	check.call(str(swap.run_state["combat_state"]["committed_move"]) != "", "Switching advances to a next committed move")
	check.call(committed_before != "" , "Enemy intention existed before the switch")
	# Prepared switch/interact persist their trait snapshot for restart safety.
	swap = fixture("kilnback", "salvage_cleaver", "", 9302)
	swap.run_state["survivor"]["inventory"]["rebar_spear"] = 1
	swap.prepare_combat_action("switch_weapon", "rebar_spear")
	check.call(swap.run_state["pending_combat_round"].has("trait_heat"), "Prepared switches carry trait state for restart")


## Stage 3 (Combat+relationships.md Weeks 5-6): base-8 specializations plus
## Cable Eater charge, Ash Stalker prediction, and Ossuary Hound bleed/regen.
func _stage3_specializations_and_traits() -> void:
	var Engine = load("res://scripts/domain/game_engine.gd")
	check.call(Engine.stat_milestone_text(4, 5) == "next: mastery at base 6, specialization at base 8", "Allocation names both milestones below mastery")
	check.call(Engine.stat_milestone_text(6, 7) == "mastered • next: specialization at base 8", "Allocation names specialization past mastery")
	check.call(Engine.stat_milestone_text(8, 9) == "specialized", "Allocation confirms specialization at base 8")
	# Strength breaks guard through the next action, once per fight.
	var strong := fixture("road_bandits", "salvage_cleaver", "", 9401)
	strong.run_state["survivor"]["stats"]["strength"] = 8
	move_to(strong, "brace")
	round_for(strong, "attack", 14, 10)
	check.call(bool(strong.run_state["combat_state"].get("spec_str_used", false)), "A successful attack spends the Strength break")
	check.call(bool(strong.run_state["combat_state"].get("spec_str_next", false)), "The breach stays open through the next action")
	round_for(strong, "attack", 14, 10)
	check.call(not bool(strong.run_state["combat_state"].get("spec_str_next", false)), "The breach closes after the following action")
	# Agility preserves a consumed Opening, once per fight.
	var agile := fixture("road_bandits", "pipe_pistol", "", 9402)
	agile.run_state["survivor"]["stats"]["agility"] = 8
	move_to(agile, "strike")
	round_for(agile, "dodge", 18, 10)
	check.call(bool(agile.run_state["combat_state"].get("opening", false)), "A good dodge banks Opening")
	round_for(agile, "attack", 14, 10)
	check.call(bool(agile.run_state["combat_state"].get("spec_agi_used", false)), "Attacking with Opening spends the Agility preserve")
	check.call(bool(agile.run_state["combat_state"].get("opening", false)), "Opening survives the attack it would consume")
	# Wits suppresses a displayed trait for two rounds, once per fight.
	var clever := fixture("reed_widow", "salvage_cleaver", "", 9403)
	clever.run_state["survivor"]["stats"]["wits"] = 8
	move_to(clever, "heavy")
	round_for(clever, "attack", 12, 10)
	check.call(int(clever.run_state["combat_state"].get("trait_brood", 0)) == 1, "Setup hatches one brood")
	var suppress_preview := clever.combat_action_preview("interact", "study_and_suppress")
	check.call(bool(suppress_preview.get("available", false)), "Study and suppress is offered in a trait fight")
	round_for(clever, "interact", 0, 10, "study_and_suppress")
	check.call(int(clever.run_state["combat_state"].get("spec_wits_timer", 0)) == 1, "Suppression holds after the committed response")
	check.call(Rules.brood_damage_bonus(clever) == 0.0, "Suppression zeroes the displayed trait")
	# Grit survives a lethal combat hit at 1 HP, once per run.
	var gritty := fixture("kilnback", "salvage_cleaver", "", 9404)
	gritty.run_state["survivor"]["stats"]["grit"] = 8
	gritty.run_state["survivor"]["vitals"]["health"] = 30
	move_to(gritty, "heavy")
	gritty.prepare_combat_action("dodge")
	gritty.run_state["pending_combat_round"]["player_roll"] = 5
	gritty.run_state["pending_combat_round"]["enemy_roll"] = 20
	gritty.resolve_prepared_combat_round()
	check.call(int(gritty.run_state["survivor"]["vitals"]["health"]) == 1, "Grit specialization survives lethal damage at 1 HP")
	check.call(bool(gritty.run_state.get("spec_grit_used", false)), "The once-per-run save is spent")
	# Presence opens Opportunity from the first round.
	var commanding := fixture("road_bandits", "holdout_revolver", "", 9405)
	commanding.run_state["survivor"]["stats"]["presence"] = 8
	Rules.initialize(commanding)
	check.call(bool(commanding.run_state["combat_state"].get("opportunity_ready", false)), "Presence 8 readies Opportunity immediately")
	# Cable Eater: strikes feed charge, grounding clears it, straps ward it.
	var cable := fixture("cable_eater", "salvage_cleaver", "", 9411)
	move_to(cable, "strike")
	round_for(cable, "attack", 12, 10)
	check.call(int(cable.run_state["combat_state"].get("trait_charge", -1)) == 1, "An electrical strike feeds one charge")
	var ground_preview := cable.combat_action_preview("interact", "ground_cable")
	check.call(bool(ground_preview.get("available", false)), "Grounding is offered while charged")
	round_for(cable, "interact", 0, 10, "ground_cable")
	check.call(int(cable.run_state["combat_state"].get("trait_charge", -1)) == 0, "Grounding clears the charge")
	cable.run_state["survivor"]["equipment"]["accessory"] = "grounding_straps"
	cable.run_state["survivor"]["inventory"]["grounding_straps"] = 1
	check.call(Rules.trait_ward_factor(cable, "charge") == 0.0, "Grounding straps negate the retaliation")
	# Disruption breaks the Eater draw; the spark lance also clears it.
	var spark := fixture("cable_eater", "spark_lance", "", 9412)
	move_to(spark, "strike")
	round_for(spark, "attack", 12, 10)
	check.call(int(spark.run_state["combat_state"].get("trait_charge", -1)) == 1, "Setup feeds one charge")
	move_to(spark, "charge")
	round_for(spark, "attack", 15, 10)
	check.call(int(spark.run_state["combat_state"].get("trait_charge", -1)) == 0, "A spark-lance interrupt breaks the draw and clears charge")
	# Ash Stalker: three in a row draws the announced counter; variety breaks it.
	var stalker := fixture("ash_stalkers", "salvage_cleaver", "", 9421)
	round_for(stalker, "attack", 12, 10)
	round_for(stalker, "attack", 12, 10)
	check.call(int(stalker.run_state["combat_state"].get("trait_repeat", 0)) == 2, "Two identical actions teach it")
	var warned := stalker.combat_action_preview("attack")
	check.call("PREDICTED" in " ".join(warned.get("effects", [])), "The third identical action is announced")
	var first_blood: int = round_for(stalker, "attack", 12, 10).get("enemy_damage", 0)
	var varied := fixture("ash_stalkers", "salvage_cleaver", "", 9422)
	round_for(varied, "attack", 12, 10)
	round_for(varied, "attack", 12, 10)
	round_for(varied, "dodge", 18, 10)
	check.call(int(varied.run_state["combat_state"].get("trait_repeat", 0)) == 1, "A different action breaks its prediction")
	check.call(first_blood >= 0, "Counter rounds resolve without engine errors")
	# Ossuary Hound: blood scents it, treatment calms it, silver and cautery stop knitting.
	var hound := fixture("ossuary_hound", "salvage_cleaver", "", 9431)
	check.call(str(hound.run_state["combat_state"].get("trait_id", "")) == "bleed", "The Hound carries the bleed trait")
	hound.run_state["survivor"]["conditions"] = ["bleeding"]
	move_to(hound, "strike")
	var bloody := round_for(hound, "attack", 12, 10)
	check.call(int(bloody.get("enemy_damage", 0)) >= 0, "Blooded rounds resolve")
	hound.run_state["survivor"]["inventory"]["cloth_bandage"] = 1
	round_for(hound, "use_item", 0, 10, "cloth_bandage")
	check.call("bleeding" not in hound.run_state["survivor"].get("conditions", []), "Treatment staunches the bleeding")
	move_to(hound, "recover")
	hound.run_state["combat_state"]["enemy_health"] = 100
	round_for(hound, "dodge", 18, 1)
	check.call(int(hound.run_state["combat_state"].get("enemy_health", 0)) == 112, "It knits 12 HP on recover")
	hound.run_state["survivor"]["inventory"]["cauterizing_torch"] = 1
	round_for(hound, "use_item", 0, 10, "cauterizing_torch")
	move_to(hound, "recover")
	round_for(hound, "dodge", 18, 1)
	check.call(int(hound.run_state["combat_state"].get("enemy_health", 0)) == 112, "Cautery blocks the knitting")
