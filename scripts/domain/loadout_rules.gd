extends RefCounted
## Loadout synergies (combat rules v5, docs/BUILD_REWORK.md). A synergy links
## two equipped slots — weapon + armor, weapon + accessory, or armor +
## accessory — and switches on while both pieces match. Every number is
## authored in data/loadout_synergies.json. Effects are deterministic bonuses
## to existing combat numbers; nothing here rolls dice, so a prepared round
## stays a pure function of its saved preview.

const SLOTS := ["weapon", "armor", "accessory"]
## One synergy of each pair type makes the whole loadout a single kit.
const FULL_KIT_PAIRS := ["armor+weapon", "accessory+weapon", "accessory+armor"]
const WEIGHTS := ["light", "medium", "heavy"]
## Display and summation order. Values are whole numbers: percent for the
## damage keys, percentage points for accuracy, Block and Dodge.
const EFFECT_KEYS := ["damage", "accuracy", "block", "dodge", "riposte_damage", "opening_damage", "opportunity_damage", "execute_damage", "first_strike_damage", "damage_taken", "momentum_start", "victory_heal"]
const EFFECT_TEXT := {
	"damage": "%+d%% damage",
	"accuracy": "%+d accuracy",
	"block": "%+d Block",
	"dodge": "%+d Dodge",
	"riposte_damage": "Riposte %+d%% damage",
	"opening_damage": "Opening %+d%% damage",
	"opportunity_damage": "Opportunity %+d%% damage",
	"execute_damage": "%+d%% damage to a weakened enemy",
	"first_strike_damage": "first exchange %+d%% damage",
	"damage_taken": "%+d%% damage taken",
	"momentum_start": "start with %d Momentum",
	"victory_heal": "heal %d HP on victory",
}
## Stacked synergies never remove more than this share of a hit.
const DAMAGE_TAKEN_FLOOR := -40


## Armor weight follows protection: rating 1-2 light, 3 medium, 4-5 heavy.
static func weight_class(item: Dictionary) -> String:
	if str(item.get("equipment_slot", "")) != "armor":
		return ""
	var rating := int(item.get("damage_reduction", 0))
	return "light" if rating <= 2 else "medium" if rating == 3 else "heavy"


static func matches(requirement: Dictionary, item: Dictionary) -> bool:
	if item.is_empty():
		return false
	if requirement.has("ids") and str(item.get("id", "")) not in requirement["ids"]:
		return false
	if requirement.has("signature") and str(item.get("signature", "")) not in requirement["signature"]:
		return false
	if requirement.has("two_handed") and bool(item.get("two_handed", false)) != bool(requirement["two_handed"]):
		return false
	if requirement.has("ranged") and (str(item.get("ammo_type", "")) != "") != bool(requirement["ranged"]):
		return false
	if requirement.has("weight") and weight_class(item) not in requirement["weight"]:
		return false
	if requirement.has("shield") and bool(item.get("shield", false)) != bool(requirement["shield"]):
		return false
	return true


## The items a synergy can see. An empty firearm fights as bare hands, so it
## cannot hold a weapon synergy until it is loaded again.
static func equipped_items(content, equipment: Dictionary, weapon_usable: bool = true) -> Dictionary:
	var result := {}
	for slot: String in SLOTS:
		var item_id := str(equipment.get(slot, ""))
		var item: Dictionary = content.get_item(item_id) if item_id != "" else {}
		if slot == "weapon" and not weapon_usable:
			item = {}
		if str(item.get("equipment_slot", "")) != slot:
			item = {}
		result[slot] = item
	return result


static func is_active(synergy: Dictionary, items: Dictionary) -> bool:
	var requires: Dictionary = synergy.get("requires", {})
	if requires.size() < 2:
		return false
	for slot: String in requires:
		if not matches(requires[slot], items.get(slot, {})):
			return false
	return true


static func pair_key(synergy: Dictionary) -> String:
	var slots: Array = synergy.get("requires", {}).keys()
	slots.sort()
	return "+".join(PackedStringArray(slots))


## Everything the equipped loadout switches on: the active synergies in data
## order, whether they form a full kit, and the summed effects.
static func evaluate(content, equipment: Dictionary, weapon_usable: bool = true) -> Dictionary:
	var items := equipped_items(content, equipment, weapon_usable)
	var active: Array = []
	var pairs := {}
	var effects := {}
	for key: String in EFFECT_KEYS:
		effects[key] = 0
	for synergy_id: String in content.synergies:
		var synergy: Dictionary = content.synergies[synergy_id]
		if not is_active(synergy, items):
			continue
		active.append(synergy)
		pairs[pair_key(synergy)] = true
		_add_effects(effects, synergy.get("effects", {}))
	var full_kit: bool = not content.synergy_full_kit.is_empty()
	for pair: String in FULL_KIT_PAIRS:
		if not pairs.has(pair):
			full_kit = false
	if full_kit:
		_add_effects(effects, content.synergy_full_kit.get("effects", {}))
	effects["damage_taken"] = maxi(DAMAGE_TAKEN_FLOOR, int(effects["damage_taken"]))
	var names: Array[String] = []
	for synergy: Dictionary in active:
		names.append(str(synergy.get("name", synergy.get("id", ""))))
	if full_kit:
		names.append(str(content.synergy_full_kit.get("name", "Full kit")))
	return {"active": active, "names": names, "full_kit": full_kit, "effects": effects}


static func _add_effects(total: Dictionary, effects: Dictionary) -> void:
	for key: String in effects:
		total[key] = int(total.get(key, 0)) + int(effects[key])


## "Dodge +5, Opening +25% damage" — one synergy's effects in display order.
static func effects_text(effects: Dictionary) -> String:
	var parts: Array[String] = []
	for key: String in EFFECT_KEYS:
		var value := int(effects.get(key, 0))
		if value != 0:
			parts.append((str(EFFECT_TEXT[key]) % value).replace("-", "−"))
	return ", ".join(PackedStringArray(parts))


## "One-handed weapon + light armor".
static func requirement_text(synergy: Dictionary) -> String:
	var parts: Array[String] = []
	var labels: Dictionary = synergy.get("labels", {})
	for slot: String in SLOTS:
		if labels.has(slot):
			parts.append(str(labels[slot]))
	var text := " + ".join(PackedStringArray(parts))
	return text.substr(0, 1).to_upper() + text.substr(1)


## Every synergy this item can be part of, for the item sheet. `partner` names
## what the other slot needs; `active` reads the loadout as it is worn now.
static func for_item(content, item: Dictionary, equipment: Dictionary, weapon_usable: bool = true) -> Array:
	var result: Array = []
	var slot := str(item.get("equipment_slot", ""))
	if slot not in SLOTS:
		return result
	var worn := equipped_items(content, equipment, weapon_usable)
	var with_item := worn.duplicate()
	with_item[slot] = item
	for synergy_id: String in content.synergies:
		var synergy: Dictionary = content.synergies[synergy_id]
		var requires: Dictionary = synergy.get("requires", {})
		if not requires.has(slot) or not matches(requires[slot], item):
			continue
		var partners: Array[String] = []
		for other: String in SLOTS:
			if other != slot and requires.has(other):
				partners.append(str(synergy.get("labels", {}).get(other, other)))
		result.append({
			"id": synergy_id,
			"name": str(synergy.get("name", synergy_id)),
			"partner": " and ".join(PackedStringArray(partners)),
			"effects_text": effects_text(synergy.get("effects", {})),
			"active": str(worn[slot].get("id", "")) == str(item.get("id", "")) and is_active(synergy, worn),
			"would_activate": is_active(synergy, with_item),
		})
	return result
