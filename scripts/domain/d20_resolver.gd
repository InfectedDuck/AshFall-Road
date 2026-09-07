class_name D20Resolver
extends RefCounted

const RULES_VERSION := 3
const MIN_CHANCE := 5
const MAX_CHANCE := 95
const DIFFICULTY_SHIFTS := {
	"easy": 35.0,
	"favorable": 25.0,
	"risky": 15.0,
	"hard": 5.0,
	"desperate": -10.0,
}


static func raw_stat_chance(effective_stat: int) -> float:
	var safe_stat := maxi(0, effective_stat)
	return 20.0 + 75.0 * (1.0 - exp(-float(safe_stat) / 12.0))


static func calculate_percentage(effective_stat: int, difficulty: String) -> int:
	var shift := float(DIFFICULTY_SHIFTS.get(difficulty, DIFFICULTY_SHIFTS["risky"]))
	return normalize_percentage(raw_stat_chance(effective_stat) + shift)


static func normalize_percentage(value: float) -> int:
	var rounded := roundi(value / 5.0) * 5
	return clampi(rounded, MIN_CHANCE, MAX_CHANCE)


static func required_roll(success_chance: int) -> int:
	var successful_faces := clampi(roundi(float(success_chance) / 5.0), 1, 19)
	return 21 - successful_faces


static func resolve_percentage(
	roll: int,
	stat_value: int,
	effective_stat: int,
	difficulty: String,
	modifiers: Array,
	prepared_chance: int = -1
) -> Dictionary:
	var chance := prepared_chance if prepared_chance >= MIN_CHANCE else calculate_percentage(effective_stat, difficulty)
	chance = normalize_percentage(float(chance))
	var threshold := required_roll(chance)
	var outcome := "failure"
	var succeeded := false
	if roll == 20:
		outcome = "critical_success"
		succeeded = true
	elif roll == 1:
		outcome = "critical_failure"
	elif roll >= threshold:
		outcome = "success"
		succeeded = true
	return {
		"rules_version": RULES_VERSION,
		"roll": roll,
		"stat_value": stat_value,
		"effective_stat": maxi(0, effective_stat),
		"difficulty": difficulty,
		"required_roll": threshold,
		"outcome": outcome,
		"succeeded": succeeded,
		"breakdown": modifiers.duplicate(true),
		"success_chance": chance,
	}


static func resolve_legacy(roll: int, stat_value: int, dc: int, modifiers: Array) -> Dictionary:
	var modifier_total := stat_value
	var breakdown: Array = [{"label": "Stat", "value": stat_value}]
	for modifier: Variant in modifiers:
		var value := int(modifier.get("value", 0))
		modifier_total += value
		breakdown.append({"label": str(modifier.get("label", "Modifier")), "value": value})
	var total := roll + modifier_total
	var outcome := "failure"
	var succeeded := false
	if roll == 20:
		outcome = "critical_success"
		succeeded = true
	elif roll == 1:
		outcome = "critical_failure"
	elif total >= dc:
		outcome = "success"
		succeeded = true
	return {
		"rules_version": 2,
		"roll": roll,
		"stat_value": stat_value,
		"effective_stat": modifier_total,
		"total": total,
		"dc": dc,
		"outcome": outcome,
		"succeeded": succeeded,
		"breakdown": breakdown,
		"success_chance": calculate_legacy_success_chance(modifier_total, dc),
	}


static func calculate_legacy_success_chance(modifier_total: int, dc: int) -> int:
	var successes := 0
	for roll in range(1, 21):
		if roll == 20 or (roll != 1 and roll + modifier_total >= dc):
			successes += 1
	return successes * 5
