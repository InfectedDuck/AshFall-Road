class_name D20Resolver
extends RefCounted


static func resolve(roll: int, stat_value: int, dc: int, modifiers: Array) -> Dictionary:
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
		"roll": roll,
		"stat_value": stat_value,
		"modifier_total": modifier_total,
		"total": total,
		"dc": dc,
		"outcome": outcome,
		"succeeded": succeeded,
		"breakdown": breakdown,
		"success_chance": calculate_success_chance(modifier_total, dc),
	}


static func calculate_success_chance(modifier_total: int, dc: int) -> int:
	var successes := 0
	for roll in range(1, 21):
		if roll == 20 or (roll != 1 and roll + modifier_total >= dc):
			successes += 1
	return successes * 5

