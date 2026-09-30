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

## Soft weapon affinity: an optional `affinity_min` on a weapon names the base
## value its attack stat needs for full power. Below that the weapon stays
## usable but unwieldy: −15 accuracy and −25% damage. Starting-kit weapons
## carry no requirement, so no build ever starts weak.
const AFFINITY_CHANCE_PENALTY := 15
const AFFINITY_DAMAGE_FACTOR := 0.75


## Build identity is base stats, never gear or temporary conditions — the same
## rule mastery uses. An empty base map means "unknown": report met so old
## callers keep their exact numbers.
static func affinity_status(item: Dictionary, base_stats: Dictionary) -> Dictionary:
	var combat: Dictionary = item.get("combat", {})
	if combat.is_empty():
		return {"required": false, "met": true, "stat": "", "minimum": 0, "have": 0}
	var minimum := int(item.get("affinity_min", 0))
	if minimum <= 0:
		return {"required": false, "met": true, "stat": str(combat.get("attack_stat", "strength")), "minimum": 0, "have": 0}
	var stat := str(combat.get("attack_stat", "strength"))
	if base_stats.is_empty():
		return {"required": true, "met": true, "stat": stat, "minimum": minimum, "have": minimum}
	var have := maxi(0, int(base_stats.get(stat, 0)))
	return {"required": true, "met": have >= minimum, "stat": stat, "minimum": minimum, "have": have}


static func weapon_profile(item: Dictionary, stats: Dictionary, loaded: bool = true, base_stats: Dictionary = {}) -> Dictionary:
	var combat: Dictionary = item.get("combat", {}) if not item.is_empty() and loaded else UNARMED
	if combat.is_empty():
		combat = UNARMED
	var stat := str(combat.get("attack_stat", "strength"))
	var stat_value := maxi(0, int(stats.get(stat, 1)))
	var multiplier := stat_damage_multiplier(stat_value)
	var affinity := affinity_status(item, base_stats if not base_stats.is_empty() else stats)
	if combat != UNARMED and bool(affinity.get("required", false)) and not bool(affinity.get("met", true)):
		multiplier *= AFFINITY_DAMAGE_FACTOR
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
		"affinity": affinity,
	}


static func stat_damage_multiplier(stat_value: int) -> float:
	var safe_stat := maxi(0, stat_value)
	return 0.8 + float(safe_stat) / float(safe_stat + 5)


## Expansion scaling (Combat+relationships.md §2): preserve the launch curve
## through stat 5, then add +0.10 per effective point above 5. Stat 5 → 10 is
## 1.30 → 1.80, approximately a 38% increase, so late-game investment stays
## noticeable without changing early fights. Legacy fights (rules v1/v2) keep
## using stat_damage_multiplier; new fights (rules v3) use this.
static func stat_damage_multiplier_v3(stat_value: int) -> float:
	var safe_stat := maxi(0, stat_value)
	if safe_stat <= 5:
		return 0.8 + float(safe_stat) / float(safe_stat + 5)
	return 1.3 + 0.10 * float(safe_stat - 5)


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
