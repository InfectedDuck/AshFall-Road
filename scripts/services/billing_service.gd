class_name BillingService
extends RefCounted

const PRODUCTS := {
	"remove_ads": "ashfall_remove_ads",
	"theme_rust": "ashfall_theme_rust",
	"theme_night": "ashfall_theme_night",
	"supporter": "ashfall_supporter_bundle",
}

var available := false
var plugin_detected := false
var feature_enabled := false
var entitlements: Dictionary = {}
var purchase_handler := Callable()


func configure(cached_entitlements: Dictionary, enabled: bool = false) -> void:
	entitlements = cached_entitlements.duplicate(true)
	feature_enabled = enabled
	plugin_detected = feature_enabled and Engine.has_singleton("GodotGooglePlayBilling")
	available = feature_enabled and purchase_handler.is_valid()


func attach_purchase_handler(handler: Callable) -> void:
	purchase_handler = handler
	available = feature_enabled and purchase_handler.is_valid()


func owns(entitlement_id: String) -> bool:
	return bool(entitlements.get(entitlement_id, false))


func store_status() -> String:
	if not feature_enabled:
		return "Purchases are not included in this release"
	if available:
		return "Store ready"
	if plugin_detected:
		return "Google Play detected; purchase adapter is not configured"
	return "Connect to Google Play to open the store"


func product_id(entitlement_id: String) -> String:
	return str(PRODUCTS.get(entitlement_id, ""))


func begin_purchase(entitlement_id: String) -> String:
	if not feature_enabled:
		return "Purchases are not included in this release."
	if owns(entitlement_id):
		return "This item is already owned."
	var play_product_id := product_id(entitlement_id)
	if play_product_id == "":
		return "Unknown store item."
	if not available:
		return "The store is unavailable. The game remains fully playable."
	purchase_handler.call(play_product_id, entitlement_id)
	return "Opening Google Play..."


func merge_verified_entitlements(verification: Dictionary) -> Dictionary:
	if not bool(verification.get("verified", false)):
		return entitlements
	for entitlement_id: String in PRODUCTS:
		if bool(verification.get("entitlements", {}).get(entitlement_id, false)):
			entitlements[entitlement_id] = true
	entitlements["verified_at"] = int(verification.get("verified_at", Time.get_unix_time_from_system()))
	return entitlements.duplicate(true)


func replace_verified_entitlements(verification: Dictionary) -> Dictionary:
	if not bool(verification.get("verified", false)):
		return entitlements
	for entitlement_id: String in PRODUCTS:
		entitlements[entitlement_id] = bool(verification.get("entitlements", {}).get(entitlement_id, false))
	entitlements["verified_at"] = int(verification.get("verified_at", Time.get_unix_time_from_system()))
	return entitlements.duplicate(true)
