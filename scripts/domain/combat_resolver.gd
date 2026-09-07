class_name CombatResolver
extends RefCounted

const UNARMED := {
	"name": "Unarmed",
	"attack_stat": "strength",
	"damage_min": 7,
	"damage_max": 10,
	"ammo_per_attack": 0,
}

const ARMOR_PERCENT := {
	0: 0.0,
	1: 0.05,
	2: 0.10,
	3: 0.15,
	4: 0.25,
	5: 0.35,
}


static func weapon_profile(item: Dictionary, stats: Dictionary, loaded: bool = true) -> Dictionary:
	var combat: Dictionary = item.get("combat", {}) if not item.is_empty() and loaded else UNARMED
	if combat.is_empty():
		combat = UNARMED
	var stat := str(combat.get("attack_stat", "strength"))
	var stat_value := maxi(0, int(stats.get(stat, 1)))
	var multiplier := stat_damage_multiplier(stat_value)
	var minimum := maxi(1, roundi(float(combat.get("damage_min", 7)) * multiplier))
	var maximum := maxi(minimum, roundi(float(combat.get("damage_max", 10)) * multiplier))
	return {
		"name": str(item.get("name", "Unarmed")) if combat != UNARMED else "Unarmed",
		"attack_stat": stat,
		"stat_value": stat_value,
		"damage_min": minimum,
		"damage_max": maximum,
		"ammo_type": str(item.get("ammo_type", "")) if combat != UNARMED else "",
		"ammo_per_attack": maxi(0, int(combat.get("ammo_per_attack", 0))) if combat != UNARMED else 0,
	}


static func stat_damage_multiplier(stat_value: int) -> float:
	var safe_stat := maxi(0, stat_value)
	return 0.8 + float(safe_stat) / float(safe_stat + 5)


static func damage_for_roll(roll: int, minimum: int, maximum: int, multiplier: float = 1.0) -> int:
	var face := clampi(roll, 1, 20)
	var base := roundi(lerpf(float(minimum), float(maximum), float(face - 1) / 19.0))
	return maxi(1, roundi(base * multiplier))


static func mitigate_damage(raw_damage: int, armor_rating: int, guarded: bool = false, exposed: bool = false) -> Dictionary:
	var rating := clampi(armor_rating, 0, 5)
	var after_flat := maxi(1, raw_damage - rating * 3)
	var after_armor := maxi(1, roundi(float(after_flat) * (1.0 - float(ARMOR_PERCENT.get(rating, 0.0)))))
	var final_damage := after_armor
	if guarded:
		final_damage = maxi(1, roundi(float(final_damage) * 0.4))
	if exposed:
		final_damage = maxi(1, roundi(float(final_damage) * 1.25))
	return {
		"raw": raw_damage,
		"blocked": maxi(0, raw_damage - final_damage),
		"final": final_damage,
	}


static func roll_label(roll: int) -> String:
	if roll == 20:
		return "CRITICAL SUCCESS"
	if roll == 1:
		return "CRITICAL FAILURE"
	return "ROLL %d" % roll
