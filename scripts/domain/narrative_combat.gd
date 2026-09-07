extends RefCounted
## Combat rules version 2. Presentation consumes this output; it never rolls or
## computes damage. Version 1 remains in GameEngine for in-flight legacy fights.

const Legacy = preload("res://scripts/domain/combat_resolver.gd")
const XP = preload("res://scripts/domain/experience_rules.gd")
const VERSION := 2
const BLOCK_ARMOR := [0, 0, 5, 5, 10, 10]
const DODGE_ARMOR := [0, 0, 5, 10, 20, 25]
const ACTIONS := ["attack", "block", "dodge", "use_item", "flee", "opportunity"]


static func probability(value: float, maximum: int = 95) -> int:
	return clampi(roundi(value / 5.0) * 5, 5, maximum)


static func hit_damage(roll: int, chance: int, minimum: int, maximum: int) -> int:
	var target := D20Resolver.required_roll(chance)
	if roll == 1 or roll < target:
		return 0
	if roll == 20:
		return maximum
	return roundi(lerpf(float(minimum), float(maximum), float(roll - target) / float(20 - target)))


static func initialize(game) -> void:
	var state: Dictionary = game.run_state["combat_state"]
	state.merge({"combat_rules_version": VERSION, "move_index": 0, "riposte": false, "opening": false, "interrupt_cooldown": 0, "opportunity_ready": false, "opportunity_used": false, "opportunity_chance": 15, "narration_indices": {}}, true)
	commit_move(game)


static func commit_move(game) -> void:
	var state: Dictionary = game.run_state["combat_state"]
	var enemy: Dictionary = game.content.get_adversary(str(state["adversary_id"]))
	var definition: Dictionary = enemy["narrative_combat"]
	var sequence: Array = definition["sequence"]
	var move_id := str(sequence[int(state["move_index"]) % sequence.size()])
	var move: Dictionary = game.content.combat_data["moves"][move_id].duplicate(true)
	move["id"] = move_id
	move["tell"] = str(definition["tells"][move_id])
	state["committed_move"] = move


static func weapon_profile(game) -> Dictionary:
	var weapon_id := str(game.run_state.get("survivor", {}).get("equipment", {}).get("weapon", ""))
	var item: Dictionary = game.content.get_item(weapon_id)
	var ammo := str(item.get("ammo_type", ""))
	var needed := int(item.get("combat", {}).get("ammo_per_attack", 0))
	var loaded: bool = ammo == "" or game.get_item_quantity(ammo) >= needed
	var result := Legacy.weapon_profile(item, game.combat_effective_stats(), loaded)
	var armed: bool = loaded and not item.get("combat", {}).is_empty()
	result["item_id"] = weapon_id if armed else ""
	result["unloaded"] = not loaded
	result["equipped_name"] = str(item.get("name", "Unarmed"))
	result["family"] = str(item.get("signature", "unarmed")) if armed else "unarmed"
	result["mastered"] = int(game.run_state.get("survivor", {}).get("stats", {}).get(str(result["attack_stat"]), 0)) >= 6
	result["opportunity_name"] = str(item.get("opportunity_name", "Desperate Strike")) if armed else "Desperate Strike"
	var base: Dictionary = item["combat"] if armed else Legacy.UNARMED
	var multiplier := Legacy.stat_damage_multiplier(int(result["stat_value"]))
	result["unrounded_min"] = float(base["damage_min"]) * multiplier
	result["unrounded_max"] = float(base["damage_max"]) * multiplier
	return result


static func preview(game, action: String, item_id: String = "") -> Dictionary:
	var state: Dictionary = game.run_state.get("combat_state", {})
	var move: Dictionary = state.get("committed_move", {})
	var stats: Dictionary = game.combat_effective_stats()
	var profile := weapon_profile(game)
	var result := {"action": action, "available": true, "reason": "", "chance": 0, "required_roll": 0, "damage_min": 0, "damage_max": 0, "cost": "", "effects": [], "profile": profile}
	if state.is_empty() or str(game.run_state.get("phase", "")) != "combat":
		result.merge({"available": false, "reason": "Resolve the current action first."}, true)
	if action not in ACTIONS:
		result.merge({"available": false, "reason": "Unknown combat action."}, true)
	var effects: Array = result["effects"]
	var tested_stat := "strength" if action == "block" else "agility" if action in ["dodge", "flee"] else str(profile["attack_stat"])
	result["effective_stat"] = int(stats.get(tested_stat, 0))
	result["stat"] = tested_stat
	result["modifiers"] = game._collect_modifiers(tested_stat, "evade" if action == "flee" else "", 0).duplicate(true)
	effects.append("Effective %s: %d (base %d)." % [tested_stat.capitalize(), result["effective_stat"], int(game.run_state["survivor"]["stats"].get(tested_stat, 0))])
	for modifier: Dictionary in result["modifiers"]:
		if int(modifier.get("value", 0)) != 0:
			effects.append("%s: %+d." % [modifier.get("label", modifier.get("source", "Modifier")), int(modifier["value"])])
	if action in ["attack", "opportunity"]:
		var stat_value := float(profile["stat_value"])
		var chance := 55.0 + 35.0 * stat_value / (stat_value + 5.0)
		var bonus := float(move.get("bonus", 0.0))
		var family := str(profile["family"])
		var mastered := bool(profile["mastered"])
		if bool(state.get("riposte", false)):
			chance += 10.0
			bonus += (0.65 if mastered else 0.5) if family == "counter" else 0.25
			effects.append("Riposte: +10 points accuracy and bonus damage; consumed by this action.")
		if bool(state.get("opening", false)):
			chance += 20.0
			if family == "precision":
				bonus += 0.4 if mastered else 0.3
			effects.append("Opening: +20 points accuracy; consumed by this action.")
		if family == "execution" and int(state.get("enemy_health", 1)) * 5 <= int(state.get("enemy_max_health", 1)) * 2:
			bonus += 0.45 if mastered else 0.3
			effects.append("Execution: enemy at or below 40% HP.")
		if action == "opportunity":
			chance += 20.0
			bonus += 0.75
			effects.append("Opportunity: +20 points accuracy, +75% weapon damage; one use.")
			if not bool(state.get("opportunity_ready", false)) or bool(state.get("opportunity_used", false)):
				result.merge({"available": false, "reason": "Opportunity not ready."}, true)
		var defense := float(move.get("incoming", 1.0))
		result["damage_min"] = maxi(1, roundi(float(profile["unrounded_min"]) * (1.0 + bonus) * defense))
		result["damage_max"] = maxi(int(result["damage_min"]), roundi(float(profile["unrounded_max"]) * (1.0 + bonus) * defense))
		result["chance"] = probability(chance)
		if defense < 1.0:
			effects.append("Enemy braced: receives 50% damage this exchange.")
		if float(move.get("bonus", 0.0)) > 0.0:
			effects.append("Enemy recovering: +25% damage this exchange.")
		if str(profile.get("ammo_type", "")) != "":
			result["cost"] = "%d %s" % [int(profile["ammo_per_attack"]), game.content.get_item(str(profile["ammo_type"])).get("name", "rounds")]
	elif action in ["block", "dodge"]:
		var block := action == "block"
		var stat_value := float(stats.get("strength" if block else "agility", 0))
		var chance := 35.0 + (30.0 if block else 50.0) * stat_value / (stat_value + 5.0)
		var rating := clampi(int(game._armor_rating()), 0, 5)
		chance += float(BLOCK_ARMOR[rating] if block else -DODGE_ARMOR[rating])
		effects.append("Armor rating %d: %+d percentage points." % [rating, BLOCK_ARMOR[rating] if block else -DODGE_ARMOR[rating]])
		var equipment: Dictionary = game.run_state["survivor"]["equipment"]
		var shield: Dictionary = game.content.get_item(str(equipment.get("accessory", "")))
		var weapon: Dictionary = game.content.get_item(str(equipment.get("weapon", "")))
		if bool(shield.get("shield", false)) and not bool(weapon.get("two_handed", false)):
			chance += float(shield.get("block_bonus" if block else "dodge_bonus", 0))
			effects.append("%s: %+d percentage points." % [shield["name"], shield.get("block_bonus" if block else "dodge_bonus", 0)])
		if not block and str(equipment.get("armor", "")) in ["runner_jacket", "scout_leathers"]:
			chance += 10.0
			effects.append("Light armor: +10 percentage points Dodge.")
		chance += float(move.get(action, 0))
		result["chance"] = probability(chance, 85)
		effects.append("Enemy movement: %+d percentage points." % int(move.get(action, 0)))
		effects.append("Success prevents damage and conditions; %s next turn." % ("Riposte" if block else "Opening"))
		effects.append("Failure takes %s damage after armor." % ("125%" if block else "normal"))
		if float(move.get("damage", 0.0)) <= 0.0:
			effects.append("No attack to defend: no Riposte or Opening can be earned.")
	elif action == "flee":
		result["chance"] = int(game.get_flee_preview()["chance"])
		result["cost"] = "+5 Fatigue; no combat XP or loot"
		if not bool(state.get("can_flee", false)):
			result.merge({"available": false, "reason": "There is no escape from this encounter."}, true)
	elif action == "use_item":
		if item_id not in game.combat_usable_items():
			result.merge({"available": false, "reason": "Choose an available combat consumable."}, true)
		result["cost"] = "One item; enemy resolves its committed move."
	if int(result["chance"]) > 0:
		result["required_roll"] = D20Resolver.required_roll(int(result["chance"]))
	return result


static func prepare(game, action: String, item_id: String = "") -> Dictionary:
	var action_preview := preview(game, action, item_id)
	if not bool(action_preview["available"]):
		return {"error": action_preview["reason"]}
	var state: Dictionary = game.run_state["combat_state"]
	var enemy: Dictionary = game.content.get_adversary(str(state["adversary_id"]))
	game.run_state["pending_combat_round"] = {
		"combat_rules_version": VERSION, "action": action, "item_id": item_id,
		"preview": action_preview.duplicate(true), "move": state["committed_move"].duplicate(true),
		"enemy": enemy.duplicate(true), "armor": game._armor_rating(),
		"enemy_roll": game._random_range(1, 20),
		"player_roll": game._random_range(1, 20) if action != "use_item" else 0,
		"opportunity_roll": game._random_range(1, 100) if action in ["attack", "block", "dodge"] else 0,
		"narration_seed": game._random_range(0, 1000000),
	}
	var pending: Dictionary = game.run_state["pending_combat_round"]
	var profile: Dictionary = action_preview["profile"]
	var categories: Array = game.content.combat_data["narration"].keys()
	categories.append("hit")
	pending["narration"] = {}
	for category: String in categories:
		var family := str(profile["family"])
		var variants: Array = game.content.combat_data["families"][family]["hit"] if category == "hit" else game.content.combat_data["narration"][category]
		if category in ["enemy_hit", "charge", "recover"]:
			variants = state["committed_move"]["narration"]
		var key := family + ":" + category
		var index := posmod(int(pending["narration_seed"]) + key.hash(), variants.size())
		if index == int(state["narration_indices"].get(key, -1)):
			index = (index + 1) % variants.size()
		pending["narration"][category] = {"key": key, "index": index, "text": str(variants[index])}
	game.run_state["phase"] = "combat_roll_pending"
	return {"prepared": true, "requires_roll": true}


static func resolve(game) -> Dictionary:
	var pending: Dictionary = game.run_state["pending_combat_round"]
	var state: Dictionary = game.run_state["combat_state"]
	var action := str(pending["action"])
	var move: Dictionary = pending["move"]
	var action_preview: Dictionary = pending["preview"]
	var profile: Dictionary = action_preview["profile"]
	var enemy: Dictionary = pending["enemy"]
	var roll := int(pending["player_roll"])
	var pre_hp := int(game.run_state["survivor"]["vitals"]["health"])
	var pre_enemy := int(state["enemy_health"])
	var result := {"combat_rules_version": VERSION, "action": action, "player_roll": roll, "enemy_roll": int(pending["enemy_roll"]), "chance": int(action_preview["chance"]), "required_roll": int(action_preview["required_roll"]), "move_id": str(move["id"]), "entries": [], "player_damage": 0, "enemy_damage": 0}
	game.run_state["phase"] = "combat"
	state["round"] = int(state["round"]) + 1
	state["riposte"] = false
	state["opening"] = false
	var cooldown_before := int(state.get("interrupt_cooldown", 0))
	state["interrupt_cooldown"] = maxi(0, cooldown_before - 1)
	var attack := action in ["attack", "opportunity"]
	var defense := action in ["block", "dodge"]
	var enemy_attacks := float(move["damage"]) > 0.0
	var success := roll >= int(action_preview["required_roll"]) and roll != 1
	var interrupted := false
	var suppressed := 0.0
	var exposure := 1.0
	if action != "use_item":
		game._tick_temporary_conditions()
	if attack:
		if action == "opportunity":
			state["opportunity_used"] = true
			state["opportunity_ready"] = false
		var ammo := str(profile.get("ammo_type", ""))
		if ammo != "":
			result["ammo_used"] = int(profile["ammo_per_attack"])
			game._change_item(ammo, -int(result["ammo_used"]))
		var damage := hit_damage(roll, int(action_preview["chance"]), int(action_preview["damage_min"]), int(action_preview["damage_max"]))
		result["rolled_player_damage"] = damage
		result["player_damage"] = mini(pre_enemy, damage)
		state["enemy_health"] = maxi(0, pre_enemy - damage)
		var family := str(profile["family"])
		var mastered := bool(profile["mastered"])
		var category := "opportunity" if action == "opportunity" and success else "hit" if success else "critical_failure" if roll == 1 else "miss"
		if success and int(state["enemy_health"]) > 0:
			if family == "disruption" and str(move["id"]) == "heavy" and cooldown_before == 0 and roll >= (13 if mastered else 15):
				category = "interrupt"
			elif family == "suppression" and roll >= 15 and enemy_attacks and bool(enemy["narrative_combat"]["organic"]):
				category = "suppressed"
		if roll == 20:
			category = "critical_success"
		var narration := passage(game, pending, category, profile)
		if roll == 1:
			exposure = 1.25
		var label := "CRITICAL SUCCESS" if roll == 20 else "CRITICAL FAILURE" if roll == 1 else "HIT" if success else "MISS"
		game._add_combat_entry(result, "critical_success" if roll == 20 else "critical_failure" if roll == 1 else "damage" if success else "failure", "%s\n%s • ROLL %d / NEED %d • %d%% • %d DAMAGE" % [narration, label, roll, action_preview["required_roll"], action_preview["chance"], result["player_damage"]], int(result["player_damage"]), "player")
		if int(result.get("ammo_used", 0)) > 0:
			game._add_combat_entry(result, "ammo", "%s −%d" % [game.content.get_item(ammo).get("name", ammo), result["ammo_used"]], 0, "player")
		if success and int(state["enemy_health"]) > 0:
			if family == "disruption" and str(move["id"]) == "heavy" and cooldown_before == 0 and roll >= (13 if mastered else 15):
				interrupted = true
				state["interrupt_cooldown"] = 2
				game._add_combat_entry(result, "success", "INTERRUPTED • HEAVY CANCELLED • RECHARGE 2 EXCHANGES", 0, "player")
			if family == "suppression" and roll >= 15 and enemy_attacks and bool(enemy["narrative_combat"]["organic"]):
				suppressed = 0.4 if mastered else 0.3
				game._add_combat_entry(result, "success", "SUPPRESSED • RESPONSE −%d%%" % roundi(suppressed * 100.0), 0, "player")
	elif defense:
		var category := "%s_%s" % [action, "success" if success else "failure"] if enemy_attacks else "idle_defense"
		if success and enemy_attacks:
			state["riposte" if action == "block" else "opening"] = true
		if action == "block" and not success:
			exposure = 1.25
		var label := action.to_upper() + (" SUCCESS" if success else " FAILURE") if enemy_attacks else "NO ATTACK TO DEFEND"
		if roll in [1, 20]:
			label = ("CRITICAL SUCCESS • " if roll == 20 else "CRITICAL FAILURE • ") + label
		game._add_combat_entry(result, "critical_success" if roll == 20 else "critical_failure" if roll == 1 else "success" if success else "failure", "%s\n%s • ROLL %d / NEED %d • %d%%%s" % [passage(game, pending, category, profile), label, roll, action_preview["required_roll"], action_preview["chance"], " • " + ("RIPOSTE READY" if action == "block" else "OPENING READY") if success and enemy_attacks else ""], 0, "player")
	elif action == "use_item":
		if str(pending["item_id"]) == "smoke_bomb":
			result["chance"] = 100
			game._change_item("smoke_bomb", -1)
			escape(game, result, passage(game, pending, "smoke", profile))
			return finish(game, result, state, pre_hp, pre_enemy)
		var item_result: Dictionary = game._use_item_internal(str(pending["item_id"]))
		result["player_health_after_item"] = int(game.run_state["survivor"]["vitals"]["health"])
		result["healing"] = maxi(0, int(result["player_health_after_item"]) - pre_hp)
		game._add_combat_entry(result, "heal", str(item_result.get("text", "Item used.")), int(result["healing"]), "player")
	elif action == "flee":
		if success:
			escape(game, result, passage(game, pending, "flee", profile))
			return finish(game, result, state, pre_hp, pre_enemy)
		game._add_combat_entry(result, "critical_failure" if roll == 1 else "failure", passage(game, pending, "flee_failure", profile) + ("\nCRITICAL FAILURE • " if roll == 1 else "\n") + "FLEE FAILED • ROLL %d / NEED %d" % [roll, action_preview["required_roll"]], 0, "player")
	result["hit"] = success if attack else false
	result["defense_success"] = defense and success and enemy_attacks
	result["enemy_interrupted"] = interrupted
	result["suppression_percent"] = roundi(suppressed * 100.0)
	if int(state["enemy_health"]) <= 0:
		game._add_combat_entry(result, "success", passage(game, pending, "kill_organic" if bool(enemy["narrative_combat"]["organic"]) else "kill_machine", profile), 0, "player")
		game._complete_combat_victory(roll == 20, result)
	elif str(game.run_state["phase"]) != "death":
		if enemy_attacks and not interrupted:
			resolve_enemy(game, pending, result, bool(result["defense_success"]), suppressed, exposure)
		elif not enemy_attacks:
			game._add_combat_entry(result, "system", passage(game, pending, "charge" if str(move["id"]) == "charge" else "recover", profile), 0, "enemy")
	if str(game.run_state["phase"]) == "combat":
		if int(state["round"]) % 3 == 0:
			game._change_pressure("fatigue", 2)
			game._add_combat_entry(result, "system", "Extended combat • Fatigue +2")
		if not bool(state["opportunity_used"]) and not bool(state["opportunity_ready"]) and (action == "attack" or bool(result["defense_success"])):
			if int(pending["opportunity_roll"]) <= int(state["opportunity_chance"]):
				state["opportunity_ready"] = true
				game._add_combat_entry(result, "success", "OPPORTUNITY READY • %s • use it whenever you choose." % profile["opportunity_name"], 0, "player")
			else:
				state["opportunity_chance"] = mini(45, int(state["opportunity_chance"]) + 10)
		state["move_index"] = int(state["move_index"]) + 1
		commit_move(game)
	return finish(game, result, state, pre_hp, pre_enemy)


static func resolve_enemy(game, pending: Dictionary, result: Dictionary, defended: bool, suppression: float, exposure: float) -> void:
	var enemy: Dictionary = pending["enemy"]
	var combat: Dictionary = enemy["combat"]
	var multiplier := float(pending["move"]["damage"])
	var minimum := maxi(1, roundi(float(combat["damage_min"]) * multiplier))
	var maximum := maxi(minimum, roundi(float(combat["damage_max"]) * multiplier))
	var roll := int(pending["enemy_roll"])
	var raw := Legacy.damage_for_roll(roll, minimum, maximum)
	var mitigation := Legacy.mitigate_damage(raw, int(pending["armor"]))
	var after_armor := int(mitigation["final"])
	var after_suppression := maxi(1, roundi(float(after_armor) * (1.0 - suppression)))
	var exposed := maxi(1, roundi(float(after_suppression) * exposure))
	var damage := 0 if defended else exposed
	result["enemy_raw_damage"] = raw
	result["armor_blocked"] = int(mitigation["blocked"])
	result["suppression_blocked"] = after_armor - after_suppression
	result["exposure_damage"] = exposed - after_suppression
	result["defense_blocked"] = exposed if defended else 0
	result["enemy_damage"] = mini(int(game.run_state["survivor"]["vitals"]["health"]), damage)
	game._change_health(-damage)
	var kind := "critical_success" if roll == 20 else "critical_failure" if roll == 1 else "damage"
	var narration := passage(game, pending, "enemy_hit", pending["preview"]["profile"])
	if defended:
		narration = passage(game, pending, "defended", pending["preview"]["profile"])
	elif roll in [1, 20]:
		narration = passage(game, pending, "enemy_critical" if roll == 20 else "enemy_fumble", pending["preview"]["profile"])
	var label := "CRITICAL SUCCESS" if roll == 20 else "CRITICAL FAILURE" if roll == 1 else "ENEMY ATTACK"
	game._add_combat_entry(result, kind, "%s\n%s • ROLL %d • RAW %d • ARMOR −%d • SUPPRESSION −%d • EXPOSURE +%d • DEFENSE −%d • HP −%d" % [narration, label, roll, raw, result["armor_blocked"], result["suppression_blocked"], result["exposure_damage"], result["defense_blocked"], result["enemy_damage"]], int(result["enemy_damage"]), "enemy")
	var block_fumble := str(pending["action"]) == "block" and int(pending["player_roll"]) == 1
	if not defended and (roll == 20 or block_fumble) and int(game.run_state["survivor"]["vitals"]["health"]) > 0:
		var condition_id := str(combat.get("critical_condition", ""))
		if condition_id != "":
			game._apply_condition(condition_id)
			result["critical_condition"] = str(game.content.get_condition(condition_id).get("name", condition_id))
			game._add_combat_entry(result, "condition", "%s • %s" % [result["critical_condition"], game.content.get_condition(condition_id).get("description", "")], 0, "enemy")
	game._update_death_state()


static func escape(game, result: Dictionary, narration: String) -> void:
	var state: Dictionary = game.run_state["combat_state"]
	game._change_pressure("fatigue", 5)
	var critical := int(result.get("player_roll", 0)) == 20
	game._add_combat_entry(result, "critical_success" if critical else "success", narration + ("\nCRITICAL SUCCESS • " if critical else "\n") + "ESCAPED • FATIGUE +5 • NO COMBAT XP OR LOOT", 0, "player")
	var event: Dictionary = game.current_event()
	var awards: Array = []
	if int(game.run_state.get("region_index", 0)) < game.content.ordered_regions().size():
		game._append_xp_award(awards, game.award_experience(XP.JOURNEY_XP, "Journey survived", "%s:journey" % str(state["encounter_id"])))
	game._record_event(event)
	game.run_state["last_result"] = {"event_id": str(event["id"]), "event_title": str(event.get("title", "")), "choice": str(event["choices"][int(state["choice_index"])]["label"]), "resolution": {"rules_version": D20Resolver.RULES_VERSION, "roll": int(result.get("player_roll", 0)), "succeeded": true, "outcome": "success", "success_chance": int(result.get("chance", 100)), "required_roll": int(result.get("required_roll", 0))}, "outcome_text": narration, "changes": ["Fatigue +5", "No combat XP or loot"], "xp_awards": awards, "combat_log": state["log"].duplicate(true)}
	game.run_state["combat_state"] = {}
	game.run_state["phase"] = "result"
	result["flee_success"] = true


static func passage(game, pending: Dictionary, category: String, profile: Dictionary) -> String:
	var selected: Dictionary = pending["narration"][category]
	var state: Dictionary = game.run_state["combat_state"]
	state["narration_indices"][selected["key"]] = selected["index"]
	return str(selected["text"]).replace("{weapon}", str(profile.get("name", "bare hands"))).replace("{enemy}", str(pending["enemy"].get("name", "The enemy"))).replace("{enemy_weapon}", str(pending["enemy"].get("combat", {}).get("weapon_name", "its weapon")).to_lower())


static func finish(game, result: Dictionary, state: Dictionary, pre_hp: int, pre_enemy: int) -> Dictionary:
	if not result.has("player_health_after_item"):
		result["player_health_after_item"] = pre_hp
	game._capture_round_presentation(result, state, pre_hp, pre_enemy)
	for key: String in ["combat_rules_version", "hit", "chance", "required_roll", "defense_success", "enemy_interrupted", "suppression_percent", "enemy_raw_damage", "defense_blocked", "suppression_blocked", "exposure_damage", "move_id"]:
		result["presentation"][key] = result.get(key, 0)
	return game._finish_combat_round(result)
