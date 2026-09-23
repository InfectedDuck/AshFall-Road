extends SceneTree

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")
const D20ResolverScript = preload("res://scripts/domain/d20_resolver.gd")
const CombatRules = preload("res://scripts/domain/combat_resolver.gd")
const ExperienceRules = preload("res://scripts/domain/experience_rules.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var content = ContentRepositoryScript.new()
	var errors: PackedStringArray = content.validate_all()
	if not errors.is_empty():
		push_error("Balance report stopped because content validation failed:\n%s" % "\n".join(errors))
		quit(1)
		return
	print("# Ashfall Road balance report")
	print("Generated from the current data definitions. Values are deterministic design diagnostics, not player telemetry.\n")
	print("Static damage tables exclude rules-2 misses, signatures and Opportunities. The adversary pressure table also measures enemy sequences, including recovery and charge exchanges. Use tools/combat_balance.gd for encounter balance.\n")
	_print_probability_table()
	_print_weapon_table(content)
	_print_armor_table(content)
	_print_adversary_table(content)
	_print_experience_table(content)
	_print_progression_targets()
	_print_supply_table(content)
	quit(0)


func _print_probability_table() -> void:
	print("## Event success percentages")
	print("| Effective stat | Easy | Favorable | Risky | Hard | Desperate |")
	print("|---:|---:|---:|---:|---:|---:|")
	for stat_value: int in [0, 2, 5, 10, 20, 30]:
		var row: Array[String] = [str(stat_value)]
		for difficulty: String in ["easy", "favorable", "risky", "hard", "desperate"]:
			row.append("%d%%" % D20ResolverScript.calculate_percentage(stat_value, difficulty))
		print("| %s |" % " | ".join(row))
	print("")


func _print_weapon_table(content) -> void:
	print("## Weapon comparison at attack stat 5")
	print("| Weapon | Stat | Damage range | Mean/attack | Ammo | Weight |")
	print("|---|---|---:|---:|---|---:|")
	var weapons: Array = []
	for item: Dictionary in content.items.values():
		if str(item.get("equipment_slot", "")) == "weapon":
			weapons.append(item)
	weapons.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("name", "")) < str(b.get("name", "")))
	for item: Dictionary in weapons:
		var stats := {"strength": 5, "agility": 5, "wits": 5, "grit": 5, "presence": 5}
		var profile: Dictionary = CombatRules.weapon_profile(item, stats, true)
		var total := 0
		for roll in range(1, 21):
			total += CombatRules.damage_for_roll(roll, int(profile["damage_min"]), int(profile["damage_max"]))
		var ammo_type := str(profile.get("ammo_type", ""))
		var ammo_text := "None" if ammo_type == "" else "%s x%d" % [ammo_type, int(profile.get("ammo_per_attack", 0))]
		print("| %s | %s | %d-%d | %.1f | %s | %.1f kg |" % [item.get("name", item.get("id", "Weapon")), str(profile["attack_stat"]).capitalize(), profile["damage_min"], profile["damage_max"], float(total) / 20.0, ammo_text, float(item.get("weight", 0.0))])
	print("")


func _print_armor_table(content) -> void:
	print("## Armor comparison against a 60-damage hit")
	print("| Armor | Rating | Final damage | Blocked | Agility modifier | Weight |")
	print("|---|---:|---:|---:|---:|---:|")
	var armors: Array = []
	for item: Dictionary in content.items.values():
		if str(item.get("equipment_slot", "")) == "armor":
			armors.append(item)
	armors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("name", "")) < str(b.get("name", "")))
	for item: Dictionary in armors:
		var rating := int(item.get("damage_reduction", 0))
		var mitigation: Dictionary = CombatRules.mitigate_damage(60, rating)
		var agility := int(item.get("modifiers", {}).get("stats", {}).get("agility", 0))
		print("| %s | %d | %d | %d | %+d | %.1f kg |" % [item.get("name", item.get("id", "Armor")), rating, mitigation["final"], mitigation["blocked"], agility, float(item.get("weight", 0.0))])
	print("")


func _print_adversary_table(content) -> void:
	print("## Adversary pressure")
	print("Strike columns show the base attack. Sequence damage averages every d20 face across the full move cycle, including exchanges without an attack.")
	print("Nominal unanswered exchanges = 300 HP / mean sequence damage after armor 3; excludes active defenses, healing, weapon effects and player killing blows. This is a pressure diagnostic, not a predicted fight duration.\n")
	print("| Adversary | HP | Raw strike | Mean raw strike | Mean strike vs armor 3 | Mean/exchange vs armor 3 | Unanswered exchanges / 300 HP | Flee |")
	print("|---|---:|---:|---:|---:|---:|---:|---|")
	var adversaries: Array = content.adversaries.values()
	adversaries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("threat", 0)) < int(b.get("threat", 0)))
	for adversary: Dictionary in adversaries:
		var combat: Dictionary = adversary.get("combat", {})
		var raw_total := 0
		var armored_total := 0
		for roll in range(1, 21):
			var raw: int = CombatRules.damage_for_roll(roll, int(combat.get("damage_min", 1)), int(combat.get("damage_max", 1)))
			raw_total += raw
			armored_total += int(CombatRules.mitigate_damage(raw, 3)["final"])
		var sequence_mean := _sequence_damage_per_exchange(content, adversary, 3)
		var unanswered := "%.1f" % (300.0 / sequence_mean) if sequence_mean > 0.0 else "Never"
		print("| %s | %d | %d-%d | %.1f | %.1f | %.1f | %s | %s |" % [adversary.get("name", adversary.get("id", "Enemy")), int(combat.get("max_health", 0)), int(combat.get("damage_min", 0)), int(combat.get("damage_max", 0)), float(raw_total) / 20.0, float(armored_total) / 20.0, sequence_mean, unanswered, str(combat.get("flee_difficulty", "risky")).capitalize()])
	print("")


func _sequence_damage_per_exchange(content, adversary: Dictionary, armor_rating: int) -> float:
	var combat: Dictionary = adversary.get("combat", {})
	var sequence: Array = adversary.get("narrative_combat", {}).get("sequence", [])
	if sequence.is_empty():
		return 0.0
	var total := 0
	for move_id: String in sequence:
		var multiplier := float(content.combat_data["moves"][move_id]["damage"])
		if multiplier <= 0.0:
			continue
		# Match NarrativeCombat.resolve_enemy: scale and round the endpoints
		# before interpolating the roll, then apply armor to the rolled damage.
		var minimum := maxi(1, roundi(float(combat["damage_min"]) * multiplier))
		var maximum := maxi(minimum, roundi(float(combat["damage_max"]) * multiplier))
		for roll in range(1, 21):
			var raw: int = CombatRules.damage_for_roll(roll, minimum, maximum)
			total += int(CombatRules.mitigate_damage(raw, armor_rating)["final"])
	return float(total) / (20.0 * float(sequence.size()))


func _print_experience_table(content) -> void:
	print("## Combat experience rewards")
	print("| Adversary | Threat | Victory XP | Mean raw damage |")
	print("|---|---:|---:|---:|")
	var adversaries: Array = content.adversaries.values()
	adversaries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("threat", 0)) < int(b.get("threat", 0)))
	for adversary: Dictionary in adversaries:
		var combat: Dictionary = adversary.get("combat", {})
		var mean_damage := (float(combat.get("damage_min", 0)) + float(combat.get("damage_max", 0))) / 2.0
		print("| %s | %d | %d | %.1f |" % [adversary.get("name", adversary.get("id", "Enemy")), int(adversary.get("threat", 0)), int(adversary.get("xp_reward", 0)), mean_damage])
	print("")


func _print_progression_targets() -> void:
	print("## Run-only XP targets")
	print("| Strategy | Projected XP | Level | Stat points |")
	print("|---|---:|---:|---:|")
	var base_xp := 30 * ExperienceRules.JOURNEY_XP + 6 * ExperienceRules.CHECKPOINT_XP
	var projections := {
		"Cautious": base_xp,
		"Selective fighter": base_xp + 22 + 24 + 30 + 36 + 46 + 3 * ExperienceRules.check_bonus("hard"),
		"Exceptional aggressive survivor": base_xp + 22 + 24 + 30 + 44 + 46 + 62 + 52 + 36,
	}
	for strategy: String in projections:
		var xp := int(projections[strategy])
		var level := ExperienceRules.level_for_xp(xp)
		print("| %s | %d | %d | %d |" % [strategy, xp, level, level - ExperienceRules.STARTING_LEVEL])
	print("")


func _print_supply_table(content) -> void:
	print("## Regional supply coverage")
	print("| Region | Supply events | Best authored satiety route |")
	print("|---|---:|---:|")
	for region: Dictionary in content.ordered_regions():
		var count := 0
		var best := 0
		for event_id: Variant in region.get("event_pool", []):
			var event: Dictionary = content.get_event(str(event_id))
			if "supply_opportunity" not in event.get("tags", []):
				continue
			count += 1
			for choice: Dictionary in event.get("choices", []):
				for outcome_key: String in ["outcome", "success", "critical_success", "victory", "critical_victory"]:
					if choice.has(outcome_key):
						best = maxi(best, _satiety_value(choice[outcome_key], content))
		print("| %s | %d | %d |" % [region.get("name", region.get("id", "Region")), count, best])


func _satiety_value(outcome: Dictionary, content) -> int:
	var total := int(outcome.get("vitals", {}).get("satiety", 0))
	for item_id: Variant in outcome.get("items", {}):
		var quantity := maxi(0, int(outcome.get("items", {}).get(item_id, 0)))
		total += quantity * int(content.get_item(str(item_id)).get("effects", {}).get("satiety", 0))
	return total
