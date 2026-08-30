class_name AdService
extends RefCounted

const MINIMUM_INTERVAL_MSEC := 600000
const ELIGIBLE_REGIONS := [2, 4]

var provider_ready := false
var remove_ads := false
var shown_this_run := 0
var last_shown_msec := -MINIMUM_INTERVAL_MSEC
var attempted_regions: Array = []


func configure(entitlements: Dictionary) -> void:
	remove_ads = bool(entitlements.get("remove_ads", false))
	provider_ready = Engine.has_singleton("AdMob")


func reset_for_run() -> void:
	shown_this_run = 0
	last_shown_msec = -MINIMUM_INTERVAL_MSEC
	attempted_regions.clear()


func should_attempt(region_number: int, now_msec: int) -> bool:
	if remove_ads or not provider_ready or shown_this_run >= 2:
		return false
	if region_number not in ELIGIBLE_REGIONS or region_number in attempted_regions:
		return false
	return now_msec - last_shown_msec >= MINIMUM_INTERVAL_MSEC


func mark_attempted(region_number: int, displayed: bool, now_msec: int) -> void:
	if region_number not in attempted_regions:
		attempted_regions.append(region_number)
	if displayed:
		shown_this_run += 1
		last_shown_msec = now_msec


func status_text() -> String:
	if remove_ads:
		return "Ads removed"
	if not provider_ready:
		return "Ads unavailable offline"
	return "Ads ready"

