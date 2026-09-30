extends RefCounted
## Combat rules version 3 (Combat+relationships.md Stages 1-2). Presentation
## consumes this output; it never rolls or computes damage. Versions 1 and 2
## remain playable for in-flight legacy fights: v1 uses GameEngine guard math,
## v2 uses the original 0.8+s/(s+5) scaling and no traits. New fights use v3
## scaling (+0.10 per effective point above 5) plus Reed Widow brood, Kilnback
## heat, and Reservoir Maw flood traits, weapon switching, and environmental
## interactions.

const Legacy = preload("res://scripts/domain/combat_resolver.gd")
const XP = preload("res://scripts/domain/experience_rules.gd")
const TalentRules = preload("res://scripts/domain/talent_rules.gd")
const VERSION := 3
const LEGACY_VERSION := 2
## Every unresolved exchange is exertion, including successful defenses and
## waiting through recovery. Long fights must reach the shared strain penalties.
const FATIGUE_PER_EXCHANGE := 3
const BLOCK_ARMOR := [0, 0, 5, 5, 10, 10]
const DODGE_ARMOR := [0, 0, 5, 10, 20, 25]
## Six main buttons stay: attack, block, dodge, use_item (sheet), flee,
## opportunity. switch_weapon and interact are committed through the Item sheet
## and consume a full combat action with the enemy resolving its move.
const ACTIONS := ["attack", "block", "dodge", "use_item", "flee", "opportunity", "switch_weapon", "interact"]
const MAIN_ACTIONS := ["attack", "block", "dodge", "use_item", "flee", "opportunity"]


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
	state.merge({"combat_rules_version": VERSION, "move_index": 0, "riposte": false, "opening": false, "interrupt_cooldown": 0, "opportunity_ready": false, "opportunity_used": false, "opportunity_chance": 15, "narration_indices": {}, "exploit_used": false, "field_medicine_used": false, "suppression_carry": 0.0}, true)
	# Stage 1-2 traits: brood (Reed Widow), heat/shell (Kilnback), flood/drains
	# (Reservoir Maw). Defaults keep every other fight exactly on legacy v2
	# behavior. All keys persist in the saved combat_state, so prepared actions
	# and phase transitions survive restart without duplication.
	var trait_id := trait_id_for(game)
	state["trait_id"] = trait_id
	if not state.has("trait_brood"):
		state["trait_brood"] = 0
	if not state.has("trait_nest_destroyed"):
		state["trait_nest_destroyed"] = false
	if not state.has("trait_heat"):
		state["trait_heat"] = 0
	if not state.has("trait_shell_open"):
		state["trait_shell_open"] = false
	if not state.has("trait_shell_timer"):
		state["trait_shell_timer"] = 0
	if not state.has("trait_flood"):
		state["trait_flood"] = 0
	if not state.has("trait_drain_north"):
		state["trait_drain_north"] = false
	if not state.has("trait_drain_south"):
		state["trait_drain_south"] = false
	# Stage 3 traits: charge (Cable Eater), prediction (Ash Stalker),
	# bleed/regen (Ossuary Hound).
	if not state.has("trait_charge"):
		state["trait_charge"] = 0
	if not state.has("trait_last_action"):
		state["trait_last_action"] = ""
	if not state.has("trait_repeat"):
		state["trait_repeat"] = 0
	if not state.has("trait_regen_blocked"):
		state["trait_regen_blocked"] = 0
	if not state.has("trait_silvered_mark"):
		state["trait_silvered_mark"] = false
	# Stage 3 specializations (base stat 8, once per fight unless noted).
	# All keys persist in the saved combat_state for restart safety.
	if not state.has("spec_str_used"):
		state["spec_str_used"] = false
	if not state.has("spec_str_next"):
		state["spec_str_next"] = false
	if not state.has("spec_agi_used"):
		state["spec_agi_used"] = false
	if not state.has("spec_wits_used"):
		state["spec_wits_used"] = false
	if not state.has("spec_wits_timer"):
		state["spec_wits_timer"] = 0
	if not state.has("spec_ashen_used"):
		state["spec_ashen_used"] = false
	# Presence specialization: Opportunity is available from the opening round,
	# retaining its once-per-fight limit.
	if base_stat(game, "presence") >= 8:
		state["opportunity_ready"] = true
	commit_move(game)


## Base stats unlock mastery and specialization; equipment and temporary
## bonuses only improve ordinary calculations.
static func base_stat(game, stat: String) -> int:
	return maxi(0, int(game.run_state.get("survivor", {}).get("stats", {}).get(stat, 0)))


static func trait_id_for(game) -> String:
	var state: Dictionary = game.run_state.get("combat_state", {})
	var adversary: Dictionary = game.content.get_adversary(str(state.get("adversary_id", "")))
	var traits: Dictionary = adversary.get("narrative_combat", {}).get("traits", {})
	if traits.has("brood"):
		return "brood"
	if traits.has("heat"):
		return "heat"
	if traits.has("flood"):
		return "flood"
	if traits.has("charge"):
		return "charge"
	if traits.has("prediction"):
		return "prediction"
	if traits.has("bleed"):
		return "bleed"
	return ""


static func trait_config_for(game) -> Dictionary:
	var state: Dictionary = game.run_state.get("combat_state", {})
	var adversary: Dictionary = game.content.get_adversary(str(state.get("adversary_id", "")))
	var traits: Dictionary = adversary.get("narrative_combat", {}).get("traits", {})
	var trait_id := str(state.get("trait_id", trait_id_for(game)))
	if trait_id != "" and traits.has(trait_id):
		return traits[trait_id]
	return {}


static func is_legacy_v2_fight(game) -> bool:
	var state: Dictionary = game.run_state.get("combat_state", {})
	return int(state.get("combat_rules_version", VERSION)) <= LEGACY_VERSION


static func brood_count(game) -> int:
	return clampi(int(game.run_state.get("combat_state", {}).get("trait_brood", 0)), 0, 3)


static func heat_count(game) -> int:
	return clampi(int(game.run_state.get("combat_state", {}).get("trait_heat", 0)), 0, 3)


static func shell_open(game) -> bool:
	return bool(game.run_state.get("combat_state", {}).get("trait_shell_open", false))


static func brood_damage_bonus(game) -> float:
	# +25% enemy response per hatched brood, read at round start so a phase
	# change affects the next round rather than the already-previewed attack.
	# A Wits suppression zeroes displayed traits for its duration.
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	var config := trait_config_for(game)
	return float(config.get("damage_per_brood", 0.25)) * float(brood_count(game))


static func heat_danger_bonus(game) -> float:
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	var config := trait_config_for(game)
	if shell_open(game):
		return 0.0
	return float(config.get("danger_per_heat", 0.2)) * float(heat_count(game))


static func shell_damage_taken_bonus(game) -> float:
	if not shell_open(game):
		return 0.0
	var config := trait_config_for(game)
	return float(config.get("exposed_damage_taken", 0.5))


static func flood_count(game) -> int:
	return clampi(int(game.run_state.get("combat_state", {}).get("trait_flood", 0)), 0, 3)


static func drains_operated(game) -> int:
	var state: Dictionary = game.run_state.get("combat_state", {})
	return (1 if bool(state.get("trait_drain_north", false)) else 0) + (1 if bool(state.get("trait_drain_south", false)) else 0)


static func drain_exit_open(game) -> bool:
	var state: Dictionary = game.run_state.get("combat_state", {})
	return bool(state.get("trait_drain_north", false)) and bool(state.get("trait_drain_south", false))


static func flood_damage_bonus(game) -> float:
	# +20% enemy response per flood level, read at round start so a phase
	# change affects the next round rather than the already-previewed attack.
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	var config := trait_config_for(game)
	return float(config.get("danger_per_flood", 0.2)) * float(flood_count(game))


static func charge_count(game) -> int:
	return clampi(int(game.run_state.get("combat_state", {}).get("trait_charge", 0)), 0, 3)


static func charge_damage_bonus(game) -> float:
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	var config := trait_config_for(game)
	return float(config.get("danger_per_charge", 0.25)) * float(charge_count(game))


static func prediction_repeat(game) -> int:
	return maxi(0, int(game.run_state.get("combat_state", {}).get("trait_repeat", 0)))


static func prediction_last(game) -> String:
	return str(game.run_state.get("combat_state", {}).get("trait_last_action", ""))


static func prediction_damage_bonus(game, action: String) -> float:
	# A third consecutive identical action is predicted: the announced counter
	# hits +50%. Anything else breaks the pattern.
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	if action != "" and action == prediction_last(game) and prediction_repeat(game) >= 2:
		return 0.5
	return 0.0


static func bleed_aggression_bonus(game) -> float:
	if int(game.run_state.get("combat_state", {}).get("spec_wits_timer", 0)) > 0:
		return 0.0
	if "bleeding" in game.run_state.get("survivor", {}).get("conditions", []):
		return 0.3
	return 0.0


## Equipment wards: grounding straps negate Cable Eater charge, the mirror
## shard halves the Stalker's predicted counter, ossuary plates ignore the
## Hound's blood-scent. Returns the factor applied to that trait's bonus.
static func trait_ward_factor(game, ward_trait: String) -> float:
	var factor := 1.0
	for slot: String in ["accessory", "armor"]:
		var item_id := str(game.run_state.get("survivor", {}).get("equipment", {}).get(slot, ""))
		if item_id == "":
			continue
		var effect: Dictionary = game.content.get_item(item_id).get("combat_effect", {})
		var wards: Array = effect.get("ward_traits", [])
		for warded: Variant in wards:
			if str(warded) == ward_trait:
				factor = minf(factor, float(effect.get("ward_factor", 0.0)))
	return factor


## Environmental interactions available through the Item sheet. Every special
## mechanic has at least two responses: traits always offer an item response
## plus a bare-handed interaction, so a missing rare item never makes an
## ordinary encounter unwinnable.
static func available_interactions_for(game) -> Array:
	var interactions: Array = []
	var state: Dictionary = game.run_state.get("combat_state", {})
	if state.is_empty() or str(game.run_state.get("phase", "")) != "combat":
		return interactions
	if is_legacy_v2_fight(game):
		return interactions
	var trait_id := str(state.get("trait_id", ""))
	if trait_id == "brood" and not bool(state.get("trait_nest_destroyed", false)):
		interactions.append({
			"id": "tear_nest",
			"label": "Tear the nest bare-handed",
			"description": "Rip out part of the nest: clears 1 brood without spending an item. Enemy still responds.",
			"cost": "One action; enemy resolves its committed move.",
		})
	if trait_id == "heat" and not shell_open(game) and heat_count(game) > 0:
		interactions.append({
			"id": "vent_heat",
			"label": "Vent the shell heat",
			"description": "Force a vent: reduces heat by 1 without attacking. Enemy still responds.",
			"cost": "One action; enemy resolves its committed move.",
		})
	if trait_id == "flood":
		if not bool(state.get("trait_drain_north", false)):
			interactions.append({
				"id": "operate_drainage_north",
				"label": "Operate the north drainage control",
				"description": "Force the north wheel: lowers flood by 1 and counts toward escape. Enemy still responds.",
				"cost": "One action; enemy resolves its committed move.",
			})
		if not bool(state.get("trait_drain_south", false)):
			interactions.append({
				"id": "operate_drainage_south",
				"label": "Operate the south drainage control",
				"description": "Force the south wheel: lowers flood by 1 and counts toward escape. Enemy still responds.",
				"cost": "One action; enemy resolves its committed move.",
			})
		if drain_exit_open(game):
			interactions.append({
				"id": "escape_through_drain",
				"label": "Escape through the drained channel",
				"description": "Both controls run: slip the chamber through the drained channel for a full win. Enemy still responds first.",
				"cost": "One action; enemy resolves its committed move, then you escape with spoils.",
			})
	# Wits specialization (base 8, once per fight): study the pattern and
	# suppress a displayed enemy trait for two rounds.
	if str(state.get("trait_id", "")) != "" and base_stat(game, "wits") >= 8 and not bool(state.get("spec_wits_used", false)) and int(state.get("spec_wits_timer", 0)) <= 0:
		interactions.append({
			"id": "study_and_suppress",
			"label": "Study and suppress (Wits specialization)",
			"description": "Read the pattern cold: suppress its trait bonuses for 2 rounds. Once per fight. Enemy still responds.",
			"cost": "One action; enemy resolves its committed move.",
		})
	if str(state.get("trait_id", "")) == "charge":
		interactions.append({
			"id": "ground_cable",
			"label": "Ground the cable bare-handed",
			"description": "Throw the load to earth: clears all charge without spending an item. Enemy still responds.",
			"cost": "One action; enemy resolves its committed move.",
		})
	return interactions


static func commit_move(game) -> void:
	var state: Dictionary = game.run_state["combat_state"]
	var enemy: Dictionary = game.content.get_adversary(str(state["adversary_id"]))
	var definition: Dictionary = enemy["narrative_combat"]
	var sequence: Array = definition["sequence"]
	var move_id := str(sequence[int(state["move_index"]) % sequence.size()])
	var move: Dictionary = game.content.combat_data["moves"][move_id].duplicate(true)
	move["id"] = move_id
	var tell := str(definition["tells"][move_id])
	# Show the committed intention with its live counters. Phase changes were
	# already applied during resolve, so this tell describes the next round
	# without replacing the already-previewed attack.
	if str(state.get("trait_id", "")) == "brood" and not is_legacy_v2_fight(game):
		var brood := brood_count(game)
		if bool(state.get("trait_nest_destroyed", false)):
			tell += " The nest is ash; no new brood gathers."
		elif brood > 0:
			tell += " Brood stirs (+%d, +%d%% response). Interrupt its heavy pull, burn the nest, tear it, or finish this quickly." % [brood, roundi(brood_damage_bonus(game) * 100.0)]
		else:
			tell += " Eggs line its back. A heavy pull will hatch brood unless interrupted or burned."
	if str(state.get("trait_id", "")) == "heat" and not is_legacy_v2_fight(game):
		if shell_open(game):
			tell += " Shell OPEN (%d rounds): it takes +50%% damage. Spend your strongest blow now." % int(state.get("trait_shell_timer", 0))
		elif heat_count(game) > 0:
			tell += " Shell heat %d/3 (+%d%% danger). Attacks build heat; coolant or venting cools it." % [heat_count(game), roundi(heat_danger_bonus(game) * 100.0)]
	if str(state.get("trait_id", "")) == "flood" and not is_legacy_v2_fight(game):
		var drains := drains_operated(game)
		if drain_exit_open(game):
			tell += " Both drains run. Escape through the channel now for a full win, or finish it."
		elif flood_count(game) > 0:
			tell += " Water %d/3 (+%d%% danger), drains %d/2. Interrupt its surge, work a wheel, or kill it fast." % [flood_count(game), roundi(flood_damage_bonus(game) * 100.0), drains]
		else:
			tell += " Water still low. Its surge will flood the chamber unless interrupted; two wheels can drain it."
	if str(state.get("trait_id", "")) == "charge" and not is_legacy_v2_fight(game):
		if charge_count(game) > 0:
			tell += " Charge %d/3 (+%d%% retaliation). Disrupt its draw, ground the cable, or wear grounding gear." % [charge_count(game), roundi(charge_damage_bonus(game) * 100.0)]
		else:
			tell += " The run is dark. Its electrical strikes will charge a retaliation unless disrupted or grounded."
	if str(state.get("trait_id", "")) == "prediction" and not is_legacy_v2_fight(game):
		var streak := prediction_repeat(game)
		var last := prediction_last(game)
		if last != "" and streak >= 2:
			tell += " It has your " + last.to_upper() + " measured (" + str(streak) + " in a row). Change tactics or it counters (+50%)."
		elif last != "":
			tell += " It watches your " + last.to_upper() + ", learning. Vary your actions to break its prediction."
		else:
			tell += " It tilts its head toward your breathing, learning your rhythm. Never repeat yourself thrice."
	if str(state.get("trait_id", "")) == "bleed" and not is_legacy_v2_fight(game):
		if "bleeding" in game.run_state.get("survivor", {}).get("conditions", []):
			tell += " It scents your blood (+30%). Treat the bleeding, or end this fast."
		else:
			tell += " Bone plates shift along scarred hide. It recovers quickly; a silvered Riposte or cautery stops the knitting."
	move["tell"] = tell
	state["committed_move"] = move


static func weapon_profile(game) -> Dictionary:
	var weapon_id := str(game.run_state.get("survivor", {}).get("equipment", {}).get("weapon", ""))
	var item: Dictionary = game.content.get_item(weapon_id)
	var ammo := str(item.get("ammo_type", ""))
	var needed := int(item.get("combat", {}).get("ammo_per_attack", 0))
	var loaded: bool = ammo == "" or game.get_item_quantity(ammo) >= needed
	var base_stats: Dictionary = game.run_state.get("survivor", {}).get("stats", {})
	var result := Legacy.weapon_profile(item, game.combat_effective_stats(), loaded, base_stats)
	var armed: bool = loaded and not item.get("combat", {}).is_empty()
	result["item_id"] = weapon_id if armed else ""
	result["unloaded"] = not loaded
	result["equipped_name"] = str(item.get("name", "Unarmed"))
	result["family"] = str(item.get("signature", "unarmed")) if armed else "unarmed"
	result["mastered"] = int(base_stats.get(str(result["attack_stat"]), 0)) >= 6
	result["opportunity_name"] = str(item.get("opportunity_name", "Desperate Strike")) if armed else "Desperate Strike"
	var base: Dictionary = item["combat"] if armed else Legacy.UNARMED
	# Versioned scaling: legacy v1/v2 fights and the old neutral sandbox keep
	# the launch curve; v3 fights (including the cleared sandbox) use expansion
	# scaling so late-game investment is visible. Through stat 5 both agree.
	var use_v3 := not is_legacy_v2_fight(game)
	# The equipment-comparison sandbox clears combat_state: treat it as v3 so
	# sheets show the rules new runs actually fight under.
	if game.run_state.get("combat_state", {}).is_empty():
		use_v3 = true
	var multiplier := Legacy.stat_damage_multiplier_v3(int(result["stat_value"])) if use_v3 else Legacy.stat_damage_multiplier(int(result["stat_value"]))
	if armed and bool(result.get("affinity", {}).get("required", false)) and not bool(result["affinity"].get("met", true)):
		multiplier *= Legacy.AFFINITY_DAMAGE_FACTOR
	result["unrounded_min"] = float(base["damage_min"]) * multiplier
	result["unrounded_max"] = float(base["damage_max"]) * multiplier
	result["damage_scaling"] = "v3" if use_v3 else "v2"
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
	effects.append("If combat continues: Fatigue +%d (up to 100)." % FATIGUE_PER_EXCHANGE)
	var tested_stat := "strength" if action == "block" else "agility" if action in ["dodge", "flee"] else str(profile["attack_stat"])
	# switch_weapon tests the new weapon's stat so its preview is honest; the
	# enemy still resolves its committed move either way.
	if action == "switch_weapon":
		var switch_item: Dictionary = game.content.get_item(item_id)
		tested_stat = str(switch_item.get("combat", {}).get("attack_stat", profile["attack_stat"]))
		if tested_stat == "":
			tested_stat = str(profile["attack_stat"])
	if action == "interact":
		tested_stat = "wits"
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
		var affinity: Dictionary = profile.get("affinity", {})
		if bool(affinity.get("required", false)) and not bool(affinity.get("met", true)):
			chance -= float(Legacy.AFFINITY_CHANCE_PENALTY)
			effects.append("Unwieldy: needs base %s %d (you have %d) • −%d accuracy, −25%% damage." % [str(affinity.get("stat", "")).capitalize(), int(affinity.get("minimum", 0)), int(affinity.get("have", 0)), Legacy.AFFINITY_CHANCE_PENALTY])
		if bool(state.get("riposte", false)):
			chance += 10.0
			bonus += (0.65 if mastered else 0.5) if family == "counter" else 0.25
			effects.append("Riposte: +10 points accuracy and bonus damage; consumed by this action.")
		if bool(state.get("opening", false)):
			chance += 20.0
			if family == "precision":
				bonus += 0.4 if mastered else 0.3
			effects.append("Opening: +20 points accuracy; consumed by this action.")
		var bloodlust: bool = game.has_method("has_talent") and game.has_talent("bloodlust")
		if family == "execution" and int(state.get("enemy_health", 1)) * 5 <= int(state.get("enemy_max_health", 1)) * (3 if bloodlust else 2):
			bonus += 0.45 if mastered else 0.3
			if bloodlust:
				chance -= TalentRules.BLOODLUST_ACCURACY_PENALTY
				effects.append("Bloodlust: enemy at or below 60% HP; −10 accuracy with this bonus.")
			else:
				effects.append("Execution: enemy at or below 40% HP.")
		if game.has_method("has_talent") and game.has_talent("exploit_weakness") and family == "disruption" and not bool(state.get("exploit_used", false)):
			effects.append("Exploit Weakness: first successful interrupt grants Opening.")
		if game.has_method("has_talent") and game.has_talent("sustained_pressure") and family == "suppression":
			effects.append("Sustained Pressure: suppression carries to the following response.")
		if action == "opportunity":
			chance += 20.0
			bonus += 0.75
			effects.append("Opportunity: +20 points accuracy, +75% weapon damage; one use.")
			if not bool(state.get("opportunity_ready", false)) or bool(state.get("opportunity_used", false)):
				result.merge({"available": false, "reason": "Opportunity not ready."}, true)
		var defense := float(move.get("incoming", 1.0))
		var shell_bonus := shell_damage_taken_bonus(game) if not is_legacy_v2_fight(game) else 0.0
		# Strength specialization (base 8, once per fight): a successful attack
		# breaks Brace or an armored shell through the following player action.
		var spec_break := false
		if not is_legacy_v2_fight(game) and base_stat(game, "strength") >= 8:
			if bool(state.get("spec_str_next", false)):
				spec_break = true
				effects.append("Breach open: Strength specialization ignores its guard through this action.")
			elif not bool(state.get("spec_str_used", false)):
				effects.append("Strength specialization ready: your first successful attack breaks its guard through your next action.")
				spec_break = true
		var defense_effective := 1.0 if spec_break and defense < 1.0 else defense
		result["damage_min"] = maxi(1, roundi(float(profile["unrounded_min"]) * (1.0 + bonus) * defense_effective * (1.0 + shell_bonus)))
		result["damage_max"] = maxi(int(result["damage_min"]), roundi(float(profile["unrounded_max"]) * (1.0 + bonus) * defense_effective * (1.0 + shell_bonus)))
		result["chance"] = probability(chance)
		if defense < 1.0 and not spec_break:
			effects.append("Enemy braced: receives 50% damage this exchange.")
		if defense < 1.0 and spec_break:
			effects.append("Enemy braced: specialization breaks through for full damage.")
		# Agility specialization (base 8, once per fight): an attack preserves
		# the Opening it would normally consume.
		if not is_legacy_v2_fight(game) and base_stat(game, "agility") >= 8 and bool(state.get("opening", false)) and not bool(state.get("spec_agi_used", false)):
			effects.append("Agility specialization ready: this attack preserves Opening once.")
		if float(move.get("bonus", 0.0)) > 0.0:
			effects.append("Enemy recovering: +25% damage this exchange.")
		if not is_legacy_v2_fight(game):
			if str(state.get("trait_id", "")) == "brood":
				var brood := brood_count(game)
				if bool(state.get("trait_nest_destroyed", false)):
					effects.append("Nest destroyed: no new brood will gather.")
				elif brood > 0:
					effects.append("Brood %d/3: its response hits +%d%%. Interrupt its heavy pull, burn the nest, tear it, or end this fast." % [brood, roundi(brood_damage_bonus(game) * 100.0)])
				else:
					effects.append("Brood 0/3: an uninterrupted heavy pull hatches +1 brood (+25% response each).")
				if str(move.get("id", "")) in ["heavy", "charge"] and not bool(state.get("trait_nest_destroyed", false)):
					effects.append("Counter this preparation: disrupt it, burn the nest with an incendiary, or tear it bare-handed.")
			if str(state.get("trait_id", "")) == "heat":
				if shell_open(game):
					effects.append("Shell OPEN (%d rounds): your damage +50%%. Spend Opportunity or your hardest hit now." % int(state.get("trait_shell_timer", 0)))
				else:
					var heat := heat_count(game)
					if heat > 0:
						effects.append("Shell heat %d/3: its response +%d%%. Defending does not build heat; coolant or venting cools it." % [heat, roundi(heat_danger_bonus(game) * 100.0)])
					else:
						effects.append("Shell heat 0/3: your hits build heat and danger. At 3/3 the shell opens for +50% damage.")
					effects.append("This attack builds +1 heat if it lands.")
			if str(state.get("trait_id", "")) == "flood":
				var flood := flood_count(game)
				var drains := drains_operated(game)
				if drain_exit_open(game):
					effects.append("Both drains run: escape through the channel now for a full win, or finish it.")
				elif flood > 0:
					effects.append("Water %d/3: its response +%d%%, drains %d/2. Interrupt its surge, work a wheel, or kill it fast." % [flood, roundi(flood_damage_bonus(game) * 100.0), drains])
				else:
					effects.append("Water 0/3: an uninterrupted surge floods +1 (+20% response each). Two wheels drain it.")
				if str(move.get("id", "")) in ["heavy", "charge"]:
					effects.append("Counter this surge: disrupt it, work a drainage wheel, or race the water.")
			if str(state.get("trait_id", "")) == "charge":
				var charge := charge_count(game)
				if charge > 0:
					effects.append("Charge %d/3: its retaliation +%d%%. Disrupt its draw, ground the cable, or wear grounding straps." % [charge, roundi(charge_damage_bonus(game) * 100.0)])
				else:
					effects.append("Charge 0/3: its electrical strikes charge +1 each (+25% retaliation each).")
				if str(profile.get("family", "")) == "disruption":
					effects.append("Disruption can interrupt its charge draw; the spark lance also clears charge on an interrupt.")
			if str(state.get("trait_id", "")) == "prediction":
				var streak := prediction_repeat(game)
				if action == prediction_last(game) and streak >= 2:
					effects.append("PREDICTED: a third identical action draws its announced counter (+50% response). Break the pattern.")
				elif streak >= 1:
					effects.append("It has learned %d in a row. A different action breaks its prediction." % streak)
				else:
					effects.append("It studies you: three identical actions in a row provoke its counter.")
			if str(state.get("trait_id", "")) == "bleed":
				if "bleeding" in game.run_state.get("survivor", {}).get("conditions", []):
					effects.append("It scents your blood: its response +30%. Treat the bleeding to calm it.")
				else:
					effects.append("No blood in the air. It knits itself on recover; a silvered Riposte or cautery stops that.")
			if str(profile.get("damage_scaling", "v3")) == "v3" and int(result["effective_stat"]) > 5:
				effects.append("V3 scaling: +10%% damage per stat point above 5 (stat %d)." % int(result["effective_stat"]))
		if str(profile.get("ammo_type", "")) != "":
			var patient: bool = action == "attack" and bool(state.get("opening", false)) and game.has_method("has_talent") and game.has_talent("patient_shot") and str(profile.get("item_id", "")) != ""
			if patient:
				result["cost"] = "0 %s (Patient Shot)" % game.content.get_item(str(profile["ammo_type"])).get("name", "rounds")
				effects.append("Patient Shot: Opening attack spends no ammunition.")
			else:
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
		var retaliation: bool = block and game.has_method("has_talent") and game.has_talent("retaliation") and TalentRules.shield_active(game)
		if retaliation:
			effects.append("Retaliation: failed Block still grants Riposte; failure takes 150% damage after armor.")
		else:
			effects.append("Failure takes %s damage after armor." % ("125%" if block else "normal"))
		if float(move.get("damage", 0.0)) <= 0.0:
			effects.append("No attack to defend: no Riposte or Opening can be earned.")
		if not is_legacy_v2_fight(game):
			if str(state.get("trait_id", "")) == "brood" and brood_count(game) > 0:
				effects.append("Defending weathers the brood-boosted response (+%d%%) without hatching more." % roundi(brood_damage_bonus(game) * 100.0))
			if str(state.get("trait_id", "")) == "heat":
				if shell_open(game):
					effects.append("Shell is OPEN: defending wastes %d open rounds. Attack if you can." % int(state.get("trait_shell_timer", 0)))
				else:
					effects.append("Defending builds no heat. Use it to wait out heat %d/3." % heat_count(game))
			if str(state.get("trait_id", "")) == "flood" and flood_count(game) > 0:
				effects.append("Defending weathers the flooded response (+%d%%) without draining." % roundi(flood_damage_bonus(game) * 100.0))
			if str(state.get("trait_id", "")) == "charge" and charge_count(game) > 0:
				effects.append("Defending weathers the charged retaliation (+%d%%) without feeding it." % roundi(charge_damage_bonus(game) * 100.0))
			if str(state.get("trait_id", "")) == "prediction" and action == prediction_last(game) and prediction_repeat(game) >= 1:
				effects.append("A repeated defense still teaches it: vary actions to break prediction.")
			if str(state.get("trait_id", "")) == "bleed" and "bleeding" in game.run_state.get("survivor", {}).get("conditions", []):
				effects.append("Defending while bleeding still smells: treat it when you can.")
	elif action == "flee":
		result["chance"] = int(game.get_flee_preview()["chance"])
		result["cost"] = "+5 Fatigue; no combat XP or loot"
		if not bool(state.get("can_flee", false)):
			result.merge({"available": false, "reason": "There is no escape from this encounter."}, true)
	elif action == "use_item":
		if item_id not in game.combat_usable_items():
			result.merge({"available": false, "reason": "Choose an available combat consumable."}, true)
		result["cost"] = "One item; enemy resolves its committed move."
		if game.has_method("has_talent") and game.has_talent("field_medicine") and not bool(state.get("field_medicine_used", false)) and (bool(state.get("opening", false)) or bool(state.get("riposte", false))):
			effects.append("Field Medicine: first heal preserves Opening/Riposte.")
		if not is_legacy_v2_fight(game):
			var combat_effect: Dictionary = game.content.get_item(item_id).get("combat_effect", {})
			if str(combat_effect.get("vs_trait", "")) == "brood" and str(state.get("trait_id", "")) == "brood":
				if bool(state.get("trait_nest_destroyed", false)):
					effects.append("Nest already destroyed.")
				else:
					effects.append("Incendiary: burns the nest, clears brood %d/3, and stops new brood. Enemy still responds." % brood_count(game))
			if str(combat_effect.get("vs_trait", "")) == "heat" and str(state.get("trait_id", "")) == "heat":
				if shell_open(game):
					effects.append("Shell already open.")
				else:
					effects.append("Coolant: forces the shell OPEN for 2 rounds (+50% damage taken). Enemy still responds.")
			if brood_count(game) > 0 and str(state.get("trait_id", "")) == "brood":
				effects.append("Enemy response is +%d%% while brood %d/3 lives." % [roundi(brood_damage_bonus(game) * 100.0), brood_count(game)])
			if heat_count(game) > 0 and str(state.get("trait_id", "")) == "heat" and not shell_open(game):
				effects.append("Enemy response is +%d%% at heat %d/3." % [roundi(heat_danger_bonus(game) * 100.0), heat_count(game)])
			if flood_count(game) > 0 and str(state.get("trait_id", "")) == "flood":
				effects.append("Enemy response is +%d%% at water %d/3, drains %d/2." % [roundi(flood_damage_bonus(game) * 100.0), flood_count(game), drains_operated(game)])
			if charge_count(game) > 0 and str(state.get("trait_id", "")) == "charge":
				effects.append("Enemy retaliation is +%d%% at charge %d/3." % [roundi(charge_damage_bonus(game) * 100.0), charge_count(game)])
			if str(state.get("trait_id", "")) == "bleed":
				var use_effects: Dictionary = game.content.get_item(item_id).get("effects", {})
				var use_removes: Array = use_effects.get("remove_conditions", [])
				if "bleeding" in use_removes:
					effects.append("Treatment: staunches bleeding and calms its aggression. Enemy still responds.")
				if str(game.content.get_item(item_id).get("combat_effect", {}).get("vs_trait", "")) == "bleed":
					effects.append("Cautery: blocks its knitting for 2 rounds. Enemy still responds.")
	elif action == "switch_weapon":
		var owned_weapons: Array = game.combat_switchable_weapons() if game.has_method("combat_switchable_weapons") else []
		if item_id not in owned_weapons:
			result.merge({"available": false, "reason": "Choose a carried weapon to switch to."}, true)
		result["cost"] = "Switch weapons; enemy resolves its committed move (%s)." % str(move.get("id", "strike"))
		result["chance"] = 100
		effects.append("Switching never resets enemy intention, talent limits, or trait counters.")
		if not is_legacy_v2_fight(game) and brood_count(game) > 0 and str(state.get("trait_id", "")) == "brood":
			effects.append("Enemy response is +%d%% while brood %d/3 lives." % [roundi(brood_damage_bonus(game) * 100.0), brood_count(game)])
		if not is_legacy_v2_fight(game) and str(state.get("trait_id", "")) == "heat" and not shell_open(game) and heat_count(game) > 0:
			effects.append("Enemy response is +%d%% at heat %d/3." % [roundi(heat_danger_bonus(game) * 100.0), heat_count(game)])
		if not is_legacy_v2_fight(game) and str(state.get("trait_id", "")) == "flood" and flood_count(game) > 0:
			effects.append("Enemy response is +%d%% at water %d/3, drains %d/2." % [roundi(flood_damage_bonus(game) * 100.0), flood_count(game), drains_operated(game)])
		if not is_legacy_v2_fight(game) and str(state.get("trait_id", "")) == "charge" and charge_count(game) > 0:
			effects.append("Enemy retaliation is +%d%% at charge %d/3." % [roundi(charge_damage_bonus(game) * 100.0), charge_count(game)])
		if not is_legacy_v2_fight(game) and str(state.get("trait_id", "")) == "prediction" and action == prediction_last(game) and prediction_repeat(game) >= 2:
			effects.append("PREDICTED: switching still costs the round against its counter (+50%).")
		if not is_legacy_v2_fight(game) and str(state.get("trait_id", "")) == "bleed" and "bleeding" in game.run_state.get("survivor", {}).get("conditions", []):
			effects.append("It scents your blood (+30%) while you switch.")
	elif action == "interact":
		var available_interactions := available_interactions_for(game)
		var found := false
		for interaction: Dictionary in available_interactions:
			if str(interaction.get("id", "")) == item_id:
				found = true
				result["cost"] = str(interaction.get("cost", "One action; enemy resolves its committed move."))
				effects.append(str(interaction.get("description", "")))
				break
		if not found:
			result.merge({"available": false, "reason": "No such interaction here."}, true)
		else:
			result["chance"] = 100
	if int(result["chance"]) > 0:
		result["required_roll"] = D20Resolver.required_roll(int(result["chance"]))
	return result


static func prepare(game, action: String, item_id: String = "") -> Dictionary:
	var action_preview := preview(game, action, item_id)
	if not bool(action_preview["available"]):
		return {"error": action_preview["reason"]}
	var state: Dictionary = game.run_state["combat_state"]
	var enemy: Dictionary = game.content.get_adversary(str(state["adversary_id"]))
	# Preserve the rules version the fight started under: in-flight v2 fights
	# keep resolving with v2 math even after the expansion ships.
	var pending_version := int(state.get("combat_rules_version", VERSION))
	game.run_state["pending_combat_round"] = {
		"combat_rules_version": pending_version, "action": action, "item_id": item_id,
		"talents": game.run_state.get("talents", []).duplicate(true) if game.run_state.has("talents") else [],
		"preview": action_preview.duplicate(true), "move": state["committed_move"].duplicate(true),
		"enemy": enemy.duplicate(true), "armor": game._armor_rating(),
		"trait_brood": int(state.get("trait_brood", 0)),
		"trait_nest_destroyed": bool(state.get("trait_nest_destroyed", false)),
		"trait_heat": int(state.get("trait_heat", 0)),
		"trait_shell_open": bool(state.get("trait_shell_open", false)),
		"trait_shell_timer": int(state.get("trait_shell_timer", 0)),
		"trait_flood": int(state.get("trait_flood", 0)),
		"trait_drain_north": bool(state.get("trait_drain_north", false)),
		"trait_drain_south": bool(state.get("trait_drain_south", false)),
		"trait_charge": int(state.get("trait_charge", 0)),
		"trait_last_action": str(state.get("trait_last_action", "")),
		"trait_repeat": int(state.get("trait_repeat", 0)),
		"trait_regen_blocked": int(state.get("trait_regen_blocked", 0)),
		"trait_silvered_mark": bool(state.get("trait_silvered_mark", false)),
		"enemy_roll": game._random_range(1, 20),
		"player_roll": game._random_range(1, 20) if action in ["attack", "block", "dodge", "flee", "opportunity"] else 0,
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
	var pending_version := int(pending.get("combat_rules_version", VERSION))
	var legacy_fight := pending_version <= LEGACY_VERSION
	var result := {"combat_rules_version": pending_version, "action": action, "player_roll": roll, "enemy_roll": int(pending["enemy_roll"]), "chance": int(action_preview["chance"]), "required_roll": int(action_preview["required_roll"]), "move_id": str(move["id"]), "entries": [], "player_damage": 0, "enemy_damage": 0}
	game.run_state["phase"] = "combat"
	state["round"] = int(state["round"]) + 1
	# Prepared actions stay authoritative: fights prepared before talents use
	# previous build rules; newer ones use the snapshot taken at prepare time.
	var active_talents: Array = pending.get("talents", []).duplicate(true) if pending.has("talents") else []
	var has = func(talent_id: String) -> bool: return talent_id in active_talents
	var opening_before := bool(state.get("opening", false))
	var riposte_before := bool(state.get("riposte", false))
	var carry_before := float(state.get("suppression_carry", 0.0))
	state["riposte"] = false
	state["opening"] = false
	state["suppression_carry"] = 0.0
	var cooldown_before := int(state.get("interrupt_cooldown", 0))
	state["interrupt_cooldown"] = maxi(0, cooldown_before - 1)
	var attack := action in ["attack", "opportunity"]
	var defense := action in ["block", "dodge"]
	var enemy_attacks := float(move["damage"]) > 0.0
	var success := roll >= int(action_preview["required_roll"]) and roll != 1
	# switch_weapon and interact always succeed (chance 100, roll 0): they cost
	# the round and let the enemy respond, but never whiff.
	if action in ["switch_weapon", "interact"]:
		success = true
	var interrupted := false
	var suppressed := carry_before
	var exposure := 1.0
	# Read trait counters at round start so phase changes apply next round.
	var brood_before := int(pending.get("trait_brood", int(state.get("trait_brood", 0))))
	var nest_destroyed_before := bool(pending.get("trait_nest_destroyed", bool(state.get("trait_nest_destroyed", false))))
	var heat_before := int(pending.get("trait_heat", int(state.get("trait_heat", 0))))
	var shell_open_before := bool(pending.get("trait_shell_open", bool(state.get("trait_shell_open", false))))
	var flood_before := int(pending.get("trait_flood", int(state.get("trait_flood", 0))))
	var charge_before := int(pending.get("trait_charge", int(state.get("trait_charge", 0))))
	var brood_bonus_before := 0.0
	var heat_bonus_before := 0.0
	var flood_bonus_before := 0.0
	var charge_bonus_before := 0.0
	var prediction_bonus_before := 0.0
	var bleed_bonus_before := 0.0
	if not legacy_fight:
		var cfg_before: Dictionary = trait_config_for(game)
		if str(state.get("trait_id", "")) == "brood" and not nest_destroyed_before:
			brood_bonus_before = float(cfg_before.get("damage_per_brood", 0.25)) * float(brood_before)
		if str(state.get("trait_id", "")) == "heat" and not shell_open_before:
			heat_bonus_before = float(cfg_before.get("danger_per_heat", 0.2)) * float(heat_before)
		if str(state.get("trait_id", "")) == "flood":
			flood_bonus_before = float(cfg_before.get("danger_per_flood", 0.2)) * float(flood_before)
		if str(state.get("trait_id", "")) == "charge":
			charge_bonus_before = float(cfg_before.get("danger_per_charge", 0.25)) * float(charge_before)
		if str(state.get("trait_id", "")) == "prediction":
			prediction_bonus_before = prediction_damage_bonus(game, action)
		if str(state.get("trait_id", "")) == "bleed":
			bleed_bonus_before = bleed_aggression_bonus(game)
		# Equipment wards blunt the matching trait while worn.
		var ward_trait := str(state.get("trait_id", ""))
		if ward_trait in ["charge", "prediction", "bleed"]:
			var ward_factor := trait_ward_factor(game, ward_trait)
			if ward_factor < 1.0:
				if ward_trait == "charge":
					charge_bonus_before *= ward_factor
				elif ward_trait == "prediction":
					prediction_bonus_before *= ward_factor
				elif ward_trait == "bleed":
					bleed_bonus_before *= ward_factor
				if ward_factor <= 0.0:
					game._add_combat_entry(result, "success", "WARDED • %s BONUS NEGATED BY YOUR GEAR" % ward_trait.to_upper(), 0, "player")
				else:
					game._add_combat_entry(result, "success", "PARTLY WARDED • %s BONUS HALVED BY YOUR GEAR" % ward_trait.to_upper(), 0, "player")
	result["trait_brood_before"] = brood_before
	result["trait_heat_before"] = heat_before
	result["trait_flood_before"] = flood_before
	result["trait_charge_before"] = charge_before
	if action in ["attack", "opportunity", "block", "dodge", "flee"]:
		game._tick_temporary_conditions()
	if attack:
		if action == "opportunity":
			state["opportunity_used"] = true
			state["opportunity_ready"] = false
		var ammo := str(profile.get("ammo_type", ""))
		if ammo != "":
			var patient: bool = has.call("patient_shot") and action == "attack" and opening_before and str(profile.get("item_id", "")) != ""
			if patient:
				result["ammo_used"] = 0
				game._add_combat_entry(result, "success", "PATIENT SHOT • NO AMMUNITION SPENT", 0, "player")
			else:
				result["ammo_used"] = int(profile["ammo_per_attack"])
				game._change_item(ammo, -int(result["ammo_used"]))
		var damage := hit_damage(roll, int(action_preview["chance"]), int(action_preview["damage_min"]), int(action_preview["damage_max"]))
		result["rolled_player_damage"] = damage
		result["player_damage"] = mini(pre_enemy, damage)
		state["enemy_health"] = maxi(0, pre_enemy - damage)
		var family := str(profile["family"])
		var mastered := bool(profile["mastered"])
		var category := "opportunity" if action == "opportunity" and success else "hit" if success else "critical_failure" if roll == 1 else "miss"
		# Disruption interrupts Heavy preparations; against a charging Cable
		# Eater it also interrupts the charge draw.
		var interruptible := str(move["id"]) == "heavy"
		if str(move["id"]) == "charge" and str(state.get("trait_id", "")) == "charge":
			interruptible = true
		if success and int(state["enemy_health"]) > 0:
			if family == "disruption" and interruptible and cooldown_before == 0 and roll >= (13 if mastered else 15):
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
			if family == "disruption" and interruptible and cooldown_before == 0 and roll >= (13 if mastered else 15):
				interrupted = true
				state["interrupt_cooldown"] = 2
				if str(move["id"]) == "charge":
					game._add_combat_entry(result, "success", "INTERRUPTED • CHARGE DRAW BROKEN • RECHARGE 2 EXCHANGES", 0, "player")
				else:
					game._add_combat_entry(result, "success", "INTERRUPTED • HEAVY CANCELLED • RECHARGE 2 EXCHANGES", 0, "player")
				# The spark lance grounds what it interrupts: a Cable Eater
				# charge draw it breaks also clears the built charge.
				if not legacy_fight and str(state.get("trait_id", "")) == "charge" and str(profile.get("item_id", "")) == "spark_lance":
					state["trait_charge"] = 0
					result["trait_charge"] = 0
					game._add_combat_entry(result, "success", "SPARK LANCE • CHARGE GROUNDED THROUGH THE HAFT", 0, "player")
				if has.call("exploit_weakness") and not bool(state.get("exploit_used", false)):
					state["exploit_used"] = true
					state["opening"] = true
					game._add_combat_entry(result, "success", "EXPLOIT WEAKNESS • OPENING READY", 0, "player")
			if family == "suppression" and roll >= 15 and enemy_attacks and bool(enemy["narrative_combat"]["organic"]):
				suppressed = maxf(suppressed, 0.4 if mastered else 0.3)
				game._add_combat_entry(result, "success", "SUPPRESSED • RESPONSE −%d%%" % roundi(suppressed * 100.0), 0, "player")
				if has.call("sustained_pressure"):
					state["suppression_carry"] = suppressed
		# Stage 3 specializations: Strength breaks guard through the next action;
		# Agility preserves a consumed Opening. Both trigger once per fight.
		if not legacy_fight and success:
			if base_stat(game, "strength") >= 8 and not bool(state.get("spec_str_used", false)):
				state["spec_str_used"] = true
				state["spec_str_next"] = true
				game._add_combat_entry(result, "success", "STRENGTH SPECIALIZATION • GUARD BROKEN THROUGH YOUR NEXT ACTION", 0, "player")
			elif bool(state.get("spec_str_next", false)):
				state["spec_str_next"] = false
			if base_stat(game, "agility") >= 8 and not bool(state.get("spec_agi_used", false)) and opening_before:
				state["spec_agi_used"] = true
				state["opening"] = true
				game._add_combat_entry(result, "success", "AGILITY SPECIALIZATION • OPENING PRESERVED", 0, "player")
			# A silvered Riposte marks the Ossuary Hound so its next knitting fails.
			if str(state.get("trait_id", "")) == "bleed" and riposte_before and str(profile.get("family", "")) == "counter" and str(profile.get("item_id", "")) == "silvered_cleaver":
				state["trait_silvered_mark"] = true
				game._add_combat_entry(result, "success", "SILVERED RIPOSTE • ITS WOUNDS WILL NOT KNIT", 0, "player")
	elif defense:
		var category := "%s_%s" % [action, "success" if success else "failure"] if enemy_attacks else "idle_defense"
		if success and enemy_attacks:
			state["riposte" if action == "block" else "opening"] = true
		# Ashen Wrap (heat-resistant armor): the first prevented burn becomes an
		# Opening as well, once per fight.
		if not legacy_fight and success and enemy_attacks and not bool(state.get("spec_ashen_used", false)):
			var foe_crit := str(pending.get("enemy", {}).get("combat", {}).get("critical_condition", ""))
			var armor_id := str(game.run_state.get("survivor", {}).get("equipment", {}).get("armor", ""))
			if foe_crit == "burned" and armor_id == "ashen_wrap":
				state["spec_ashen_used"] = true
				state["opening"] = true
				game._add_combat_entry(result, "success", "ASHEN WRAP • PREVENTED BURN BECOMES OPENING", 0, "player")
		if action == "block" and not success:
			if has.call("retaliation") and TalentRules.shield_active(game) and enemy_attacks:
				state["riposte"] = true
				exposure = TalentRules.RETALIATION_EXPOSURE
				game._add_combat_entry(result, "success", "RETALIATION • RIPOSTE READY • INCOMING x1.5", 0, "player")
			else:
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
		var used_id := str(pending["item_id"])
		var combat_effect: Dictionary = game.content.get_item(used_id).get("combat_effect", {})
		# Stage 1 tactical consumables resolve before the ordinary heal so the
		# enemy still answers the round. They are never a dead end: missing the
		# rare item still leaves interrupt / defend / race responses.
		if not legacy_fight and str(combat_effect.get("vs_trait", "")) == "brood" and str(state.get("trait_id", "")) == "brood":
			if not bool(state.get("trait_nest_destroyed", false)):
				state["trait_brood"] = 0
				state["trait_nest_destroyed"] = true
				result["trait_nest_burned"] = true
				game._change_item(used_id, -1)
				game._add_combat_entry(result, "success", "INCENDIARY • NEST BURNED • BROOD CLEARED • NO NEW BROOD WILL GATHER", 0, "player")
			else:
				var item_result_nest: Dictionary = game._use_item_internal(used_id)
				result["player_health_after_item"] = int(game.run_state["survivor"]["vitals"]["health"])
				result["healing"] = maxi(0, int(result["player_health_after_item"]) - pre_hp)
				game._add_combat_entry(result, "heal", str(item_result_nest.get("text", "Item used.")), int(result["healing"]), "player")
		elif not legacy_fight and str(combat_effect.get("vs_trait", "")) == "heat" and str(state.get("trait_id", "")) == "heat":
			if not bool(state.get("trait_shell_open", false)):
				state["trait_heat"] = 3
				state["trait_shell_open"] = true
				state["trait_shell_timer"] = 2
				result["trait_shell_forced"] = true
				game._change_item(used_id, -1)
				game._add_combat_entry(result, "success", "COOLANT • SHELL FORCED OPEN • +50% DAMAGE TAKEN FOR 2 ROUNDS", 0, "player")
			else:
				var item_result_shell: Dictionary = game._use_item_internal(used_id)
				result["player_health_after_item"] = int(game.run_state["survivor"]["vitals"]["health"])
				result["healing"] = maxi(0, int(result["player_health_after_item"]) - pre_hp)
				game._add_combat_entry(result, "heal", str(item_result_shell.get("text", "Item used.")), int(result["healing"]), "player")
		elif not legacy_fight and str(combat_effect.get("vs_trait", "")) == "bleed" and str(state.get("trait_id", "")) == "bleed":
			state["trait_regen_blocked"] = 2
			result["trait_regen_blocked"] = 2
			game._change_item(used_id, -1)
			game._add_combat_entry(result, "success", "CAUTERY • ITS WOUNDS WILL NOT KNIT FOR 2 ROUNDS", 0, "player")
		else:
			var item_result: Dictionary = game._use_item_internal(used_id)
			result["player_health_after_item"] = int(game.run_state["survivor"]["vitals"]["health"])
			result["healing"] = maxi(0, int(result["player_health_after_item"]) - pre_hp)
			game._add_combat_entry(result, "heal", str(item_result.get("text", "Item used.")), int(result["healing"]), "player")
			if has.call("field_medicine") and not bool(state.get("field_medicine_used", false)) and int(result["healing"]) > 0 and (opening_before or riposte_before):
				state["opening"] = opening_before
				state["riposte"] = riposte_before
				state["field_medicine_used"] = true
				game._add_combat_entry(result, "success", "FIELD MEDICINE • STANCE PRESERVED", 0, "player")
	elif action == "switch_weapon":
		var new_weapon := str(pending["item_id"])
		var old_weapon := str(game.run_state["survivor"]["equipment"].get("weapon", ""))
		# Switching consumes the round but never resets intention or limits.
		# Bypass the out-of-combat equipment lock: this is the one legal path.
		if game.get_item_quantity(new_weapon) > 0 and not game.content.get_item(new_weapon).get("combat", {}).is_empty():
			game.run_state["survivor"]["equipment"]["weapon"] = new_weapon
			result["switched_from"] = old_weapon
			result["switched_to"] = new_weapon
			game._add_combat_entry(result, "success", "SWITCHED • %s → %s • ENEMY STILL RESPONDS" % [game.content.get_item(old_weapon).get("name", "Unarmed") if old_weapon != "" else "Unarmed", game.content.get_item(new_weapon).get("name", new_weapon)], 0, "player")
		else:
			game._add_combat_entry(result, "failure", "SWITCH FAILED • WEAPON NOT CARRIED • ENEMY STILL RESPONDS", 0, "player")
	elif action == "interact":
		var interaction_id := str(pending["item_id"])
		if not legacy_fight and interaction_id == "tear_nest" and str(state.get("trait_id", "")) == "brood":
			if brood_before > 0:
				state["trait_brood"] = maxi(0, brood_before - 1)
				game._add_combat_entry(result, "success", "TORE THE NEST • BROOD %d→%d • ENEMY STILL RESPONDS" % [brood_before, int(state["trait_brood"])], 0, "player")
			else:
				game._add_combat_entry(result, "system", "NEST ALREADY QUIET • NOTHING TO TEAR • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "vent_heat" and str(state.get("trait_id", "")) == "heat":
			if heat_before > 0 and not shell_open_before:
				state["trait_heat"] = maxi(0, heat_before - 1)
				game._add_combat_entry(result, "success", "VENTED HEAT • %d→%d • ENEMY STILL RESPONDS" % [heat_before, int(state["trait_heat"])], 0, "player")
			else:
				game._add_combat_entry(result, "system", "NO HEAT TO VENT • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "operate_drainage_north" and str(state.get("trait_id", "")) == "flood":
			if not bool(state.get("trait_drain_north", false)):
				state["trait_drain_north"] = true
				state["trait_flood"] = maxi(0, int(state.get("trait_flood", flood_before)) - 1)
				game._add_combat_entry(result, "success", "NORTH WHEEL TURNS • DRAINS %d/2 • WATER %d/3 • ENEMY STILL RESPONDS" % [drains_operated(game), int(state["trait_flood"])], 0, "player")
			else:
				game._add_combat_entry(result, "system", "NORTH WHEEL ALREADY RUNS • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "operate_drainage_south" and str(state.get("trait_id", "")) == "flood":
			if not bool(state.get("trait_drain_south", false)):
				state["trait_drain_south"] = true
				state["trait_flood"] = maxi(0, int(state.get("trait_flood", flood_before)) - 1)
				game._add_combat_entry(result, "success", "SOUTH WHEEL TURNS • DRAINS %d/2 • WATER %d/3 • ENEMY STILL RESPONDS" % [drains_operated(game), int(state["trait_flood"])], 0, "player")
			else:
				game._add_combat_entry(result, "system", "SOUTH WHEEL ALREADY RUNS • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "escape_through_drain" and str(state.get("trait_id", "")) == "flood":
			if drain_exit_open(game):
				game._add_combat_entry(result, "success", "BOTH DRAINS RUN • YOU SLIP THE FLOODED CHAMBER WITH SPOILS", 0, "player")
				result["drain_escape"] = true
			else:
				game._add_combat_entry(result, "system", "THE CHANNEL STILL HOLDS WATER • WORK BOTH WHEELS FIRST • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "study_and_suppress":
			if str(state.get("trait_id", "")) != "" and base_stat(game, "wits") >= 8 and not bool(state.get("spec_wits_used", false)):
				state["spec_wits_used"] = true
				state["spec_wits_timer"] = 2
				game._add_combat_entry(result, "success", "STUDIED • TRAIT SUPPRESSED FOR 2 ROUNDS • ENEMY STILL RESPONDS", 0, "player")
			else:
				game._add_combat_entry(result, "system", "NOTHING TO SUPPRESS • ENEMY STILL RESPONDS", 0, "player")
		elif not legacy_fight and interaction_id == "ground_cable" and str(state.get("trait_id", "")) == "charge":
			if charge_before > 0:
				state["trait_charge"] = 0
				game._add_combat_entry(result, "success", "GROUNDED • CHARGE %d→0 • ENEMY STILL RESPONDS" % charge_before, 0, "player")
			else:
				game._add_combat_entry(result, "system", "THE RUN IS ALREADY DARK • NOTHING TO GROUND • ENEMY STILL RESPONDS", 0, "player")
		else:
			game._add_combat_entry(result, "system", "NOTHING TO OPERATE HERE • ENEMY STILL RESPONDS", 0, "player")
	elif action == "flee":
		if success:
			escape(game, result, passage(game, pending, "flee", profile))
			return finish(game, result, state, pre_hp, pre_enemy)
		game._add_combat_entry(result, "critical_failure" if roll == 1 else "failure", passage(game, pending, "flee_failure", profile) + ("\nCRITICAL FAILURE • " if roll == 1 else "\n") + "FLEE FAILED • ROLL %d / NEED %d" % [roll, action_preview["required_roll"]], 0, "player")
	if has.call("sustained_pressure") and carry_before > 0.0 and suppressed >= carry_before and not interrupted and enemy_attacks and int(state["enemy_health"]) > 0:
		var carried := roundi(carry_before * 100.0)
		var already_noted := false
		for entry: Dictionary in result["entries"]:
			if str(entry.get("text", "")).begins_with("SUPPRESSED"):
				already_noted = true
				break
		if not already_noted:
			game._add_combat_entry(result, "success", "SUSTAINED PRESSURE • CARRY −%d%%" % carried, 0, "player")
	result["hit"] = success if attack else false
	result["defense_success"] = defense and success and enemy_attacks
	result["enemy_interrupted"] = interrupted
	result["suppression_percent"] = roundi(suppressed * 100.0)
	result["trait_brood"] = int(state.get("trait_brood", 0))
	result["trait_heat"] = int(state.get("trait_heat", 0))
	result["trait_shell_open"] = bool(state.get("trait_shell_open", false))
	result["trait_flood"] = int(state.get("trait_flood", 0))
	result["trait_drains"] = drains_operated(game)
	result["trait_charge"] = int(state.get("trait_charge", 0))
	# Drain escape wins immediately with full spoils once the enemy has answered.
	# It resolves after the committed response so switching/operating machinery
	# never dodges the previewed attack.
	if bool(result.get("drain_escape", false)) and int(state.get("enemy_health", 0)) > 0 and str(game.run_state.get("phase", "")) != "death":
		if enemy_attacks and not interrupted:
			resolve_enemy(game, pending, result, bool(result["defense_success"]), suppressed, exposure, brood_bonus_before, heat_bonus_before, flood_bonus_before, charge_bonus_before, prediction_bonus_before, bleed_bonus_before)
		elif not enemy_attacks:
			game._add_combat_entry(result, "system", passage(game, pending, "charge" if str(move["id"]) == "charge" else "recover", profile), 0, "enemy")
		if str(game.run_state.get("phase", "")) != "death":
			game._add_combat_entry(result, "success", passage(game, pending, "kill_organic" if bool(enemy["narrative_combat"]["organic"]) else "kill_machine", profile), 0, "player")
			game._complete_combat_victory(false, result)
		return finish(game, result, state, pre_hp, pre_enemy)
	if int(state["enemy_health"]) <= 0:
		game._add_combat_entry(result, "success", passage(game, pending, "kill_organic" if bool(enemy["narrative_combat"]["organic"]) else "kill_machine", profile), 0, "player")
		game._complete_combat_victory(roll == 20, result)
	elif str(game.run_state["phase"]) != "death":
		if enemy_attacks and not interrupted:
			resolve_enemy(game, pending, result, bool(result["defense_success"]), suppressed, exposure, brood_bonus_before, heat_bonus_before, flood_bonus_before, charge_bonus_before, prediction_bonus_before, bleed_bonus_before)
		elif not enemy_attacks:
			game._add_combat_entry(result, "system", passage(game, pending, "charge" if str(move["id"]) == "charge" else "recover", profile), 0, "enemy")
			# The Ossuary Hound knits itself on recover unless a silvered
			# Riposte marked it or cautery still holds.
			if not legacy_fight and str(state.get("trait_id", "")) == "bleed" and int(state.get("enemy_health", 0)) > 0 and int(state.get("enemy_max_health", 0)) > 0:
				if int(state.get("trait_regen_blocked", 0)) > 0 or bool(state.get("trait_silvered_mark", false)):
					state["trait_silvered_mark"] = false
					game._add_combat_entry(result, "system", "ITS WOUNDS DO NOT KNIT • REGENERATION PREVENTED", 0, "enemy")
				else:
					state["enemy_health"] = mini(int(state.get("enemy_max_health", 0)), int(state.get("enemy_health", 0)) + 12)
					game._add_combat_entry(result, "system", "IT KNITS • +12 ENEMY HP • STOP IT WITH SILVER OR CAUTERY", 0, "enemy")
		# Phase transitions apply to the next round, never to the previewed hit.
		if not legacy_fight and int(state.get("enemy_health", 0)) > 0:
			_apply_trait_transitions(game, result, action, success, interrupted, brood_before, nest_destroyed_before, heat_before, shell_open_before, flood_before, charge_before)
	if str(game.run_state["phase"]) == "combat":
		var fatigue_before := int(game.run_state["survivor"]["pressures"].get("fatigue", 0))
		game._change_pressure("fatigue", FATIGUE_PER_EXCHANGE)
		var fatigue_gained := int(game.run_state["survivor"]["pressures"]["fatigue"]) - fatigue_before
		if fatigue_gained > 0:
			game._add_combat_entry(result, "system", "Combat exertion • Fatigue +%d" % fatigue_gained)
		if not bool(state["opportunity_used"]) and not bool(state["opportunity_ready"]) and (action == "attack" or bool(result["defense_success"])):
			if int(pending["opportunity_roll"]) <= int(state["opportunity_chance"]):
				state["opportunity_ready"] = true
				game._add_combat_entry(result, "success", "OPPORTUNITY READY • %s • use it whenever you choose." % profile["opportunity_name"], 0, "player")
			else:
				state["opportunity_chance"] = mini(45, int(state["opportunity_chance"]) + 10)
		state["move_index"] = int(state["move_index"]) + 1
		commit_move(game)
	return finish(game, result, state, pre_hp, pre_enemy)


static func _apply_trait_transitions(game, result: Dictionary, action: String, success: bool, interrupted: bool, brood_before: int, nest_destroyed_before: bool, heat_before: int, shell_open_before: bool, flood_before: int = 0, charge_before: int = 0) -> void:
	var state: Dictionary = game.run_state["combat_state"]
	var trait_id := str(state.get("trait_id", ""))
	var move_id := str(result.get("move_id", ""))
	# Wits suppression counts down every round regardless of trait.
	if int(state.get("spec_wits_timer", 0)) > 0:
		state["spec_wits_timer"] = maxi(0, int(state.get("spec_wits_timer", 0)) - 1)
		result["spec_wits_timer"] = int(state["spec_wits_timer"])
		if int(state["spec_wits_timer"]) == 0:
			game._add_combat_entry(result, "system", "SUPPRESSION FADES • ITS PATTERN RETURNS", 0, "enemy")
	if trait_id == "brood":
		# A heavy pull that is not interrupted hatches +1 brood for next round,
		# unless the nest was destroyed this round or earlier. Burning takes
		# precedence over the same round's preparation.
		if bool(state.get("trait_nest_destroyed", false)):
			state["trait_brood"] = 0
			result["trait_brood"] = 0
		elif move_id in ["heavy", "charge"] and not interrupted and not nest_destroyed_before:
			var config := trait_config_for(game)
			var maximum := int(config.get("max", 3))
			if brood_before < maximum:
				state["trait_brood"] = brood_before + 1
				result["trait_brood"] = int(state["trait_brood"])
				game._add_combat_entry(result, "system", "BROOD HATCHES • %d/%d • RESPONSE +%d%% • INTERRUPT, BURN, TEAR, OR END THIS" % [int(state["trait_brood"]), maximum, roundi(brood_damage_bonus(game) * 100.0)], 0, "enemy")
	if trait_id == "heat":
		if shell_open_before:
			# Count down the open window; closing resets heat so the next build
			# is a fresh decision rather than a permanent burn.
			var timer := int(state.get("trait_shell_timer", 0)) - 1
			state["trait_shell_timer"] = maxi(0, timer)
			result["trait_shell_timer"] = int(state["trait_shell_timer"])
			if int(state["trait_shell_timer"]) <= 0:
				state["trait_shell_open"] = false
				state["trait_heat"] = 0
				result["trait_shell_open"] = false
				result["trait_heat"] = 0
				game._add_combat_entry(result, "system", "SHELL SEALS • HEAT RESETS • BUILD IT AGAIN OR PRESS ON", 0, "enemy")
		else:
			# Successful attacks build +1 heat. At max the shell opens next round.
			if action in ["attack", "opportunity"] and success and int(state.get("enemy_health", 0)) > 0:
				var config_heat := trait_config_for(game)
				var maximum_heat := int(config_heat.get("max", 3))
				if heat_before < maximum_heat:
					state["trait_heat"] = heat_before + 1
					result["trait_heat"] = int(state["trait_heat"])
					if int(state["trait_heat"]) >= maximum_heat:
						state["trait_shell_open"] = true
						state["trait_shell_timer"] = int(config_heat.get("exposed_rounds", 2))
						result["trait_shell_open"] = true
						result["trait_shell_timer"] = int(state["trait_shell_timer"])
						game._add_combat_entry(result, "success", "SHELL OPENS • +50%% DAMAGE TAKEN FOR %d ROUNDS • SPEND YOUR STRONGEST BLOW" % int(state["trait_shell_timer"]), 0, "player")
					else:
						game._add_combat_entry(result, "system", "SHELL HEATS • %d/%d • DANGER +%d%%" % [int(state["trait_heat"]), maximum_heat, roundi(heat_danger_bonus(game) * 100.0)], 0, "enemy")
	if trait_id == "flood":
		# An uninterrupted surge floods +1 for next round. Working a wheel
		# already lowered the water during the player half, so it is excluded
		# from rising on the same round.
		var worked_wheel := action == "interact" and str(pending_action_id(game)) in ["operate_drainage_north", "operate_drainage_south"]
		if move_id in ["heavy", "charge"] and not interrupted and not worked_wheel:
			var config_flood := trait_config_for(game)
			var maximum_flood := int(config_flood.get("max", 3))
			var current_flood := int(state.get("trait_flood", flood_before))
			if current_flood < maximum_flood:
				state["trait_flood"] = current_flood + 1
				result["trait_flood"] = int(state["trait_flood"])
				game._add_combat_entry(result, "system", "WATER RISES • %d/%d • RESPONSE +%d%% • INTERRUPT, DRAIN, OR END THIS" % [int(state["trait_flood"]), maximum_flood, roundi(flood_damage_bonus(game) * 100.0)], 0, "enemy")
		result["trait_drains"] = drains_operated(game)
	if trait_id == "charge":
		# Its electrical strikes and an uninterrupted draw each feed +1 charge.
		# Grounding already cleared it during the player half and holds through
		# the committed response; a disrupt that broke the draw prevents growth.
		var grounded := action == "interact" and str(pending_action_id(game)) == "ground_cable"
		var fed := false
		if not grounded:
			if move_id in ["strike", "sweep"]:
				fed = true
			if move_id == "charge" and not interrupted:
				fed = true
		if fed:
			var config_charge := trait_config_for(game)
			var maximum_charge := int(config_charge.get("max", 3))
			var current_charge := int(state.get("trait_charge", charge_before))
			if current_charge < maximum_charge:
				state["trait_charge"] = current_charge + 1
				result["trait_charge"] = int(state["trait_charge"])
				game._add_combat_entry(result, "system", "CHARGE BUILDS • %d/%d • RETALIATION +%d%% • DISRUPT, GROUND, OR END THIS" % [int(state["trait_charge"]), maximum_charge, roundi(charge_damage_bonus(game) * 100.0)], 0, "enemy")
	if trait_id == "prediction":
		# Every committed action teaches it: three identical in a row provokes
		# the announced counter, anything else breaks the pattern.
		var last := str(state.get("trait_last_action", ""))
		var streak := int(state.get("trait_repeat", 0))
		if action == last and last != "":
			streak += 1
		else:
			streak = 1
		state["trait_last_action"] = action
		state["trait_repeat"] = streak
		result["trait_repeat"] = streak
		result["trait_last_action"] = action
		if streak == 2:
			game._add_combat_entry(result, "system", "IT IS LEARNING YOUR %s • CHANGE TACTICS" % action.to_upper(), 0, "enemy")
		elif streak >= 3:
			game._add_combat_entry(result, "system", "PREDICTED • IT COUNTERS YOUR REPETITION", 0, "enemy")
	if trait_id == "bleed":
		# Cautery burns out round by round.
		if int(state.get("trait_regen_blocked", 0)) > 0:
			state["trait_regen_blocked"] = maxi(0, int(state.get("trait_regen_blocked", 0)) - 1)
			result["trait_regen_blocked"] = int(state["trait_regen_blocked"])


static func pending_action_id(game) -> String:
	return str(game.run_state.get("pending_combat_round", {}).get("item_id", ""))


static func resolve_enemy(game, pending: Dictionary, result: Dictionary, defended: bool, suppression: float, exposure: float, brood_bonus: float = 0.0, heat_bonus: float = 0.0, flood_bonus: float = 0.0, charge_bonus: float = 0.0, prediction_bonus: float = 0.0, bleed_bonus: float = 0.0) -> void:
	var enemy: Dictionary = pending["enemy"]
	var combat: Dictionary = enemy["combat"]
	var multiplier := float(pending["move"]["damage"])
	var minimum := maxi(1, roundi(float(combat["damage_min"]) * multiplier * (1.0 + brood_bonus + heat_bonus + flood_bonus + charge_bonus + prediction_bonus + bleed_bonus)))
	var maximum := maxi(minimum, roundi(float(combat["damage_max"]) * multiplier * (1.0 + brood_bonus + heat_bonus + flood_bonus + charge_bonus + prediction_bonus + bleed_bonus)))
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
	# Grit specialization (base 8, once per run): survive a lethal combat hit
	# at 1 HP. This guards combat damage only, never starvation or scripted
	# environmental death, which resolve elsewhere.
	var current_hp := int(game.run_state["survivor"]["vitals"]["health"])
	if damage >= current_hp and not defended and base_stat(game, "grit") >= 8 and not bool(game.run_state.get("spec_grit_used", false)) and int(pending.get("combat_rules_version", VERSION)) > LEGACY_VERSION:
		game.run_state["spec_grit_used"] = true
		result["grit_survived"] = true
		damage = maxi(0, current_hp - 1)
		game._add_combat_entry(result, "success", "GRIT SPECIALIZATION • LETHAL BLOW WEATHERED • 1 HP • ONCE PER RUN SPENT", 0, "player")
	result["enemy_damage"] = mini(current_hp, damage)
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
