class_name SoundService
extends Node

const EFFECTS := ["ui", "dice", "success", "critical_success", "failure", "critical_failure", "impact", "block", "evade", "inventory", "rest", "level_up", "victory", "death"]
var effects_enabled := true
var haptics_enabled := true
var players: Array[AudioStreamPlayer] = []
var streams: Dictionary = {}
var next_player := 0

func _ready() -> void:
	for id: String in EFFECTS:
		streams[id] = load("res://assets/audio/%s.wav" % id)
	for index in range(4):
		var voice := AudioStreamPlayer.new()
		voice.bus = "Master"
		add_child(voice)
		players.append(voice)

func configure(settings: Dictionary) -> void:
	effects_enabled = bool(settings.get("sound_enabled", true))
	haptics_enabled = bool(settings.get("haptics_enabled", true))
	if not effects_enabled:
		for voice: AudioStreamPlayer in players:
			voice.stop()

func play_effect(id: String) -> void:
	if not effects_enabled or players.is_empty() or not streams.has(id):
		return
	var voice := players[next_player]
	next_player = (next_player + 1) % players.size()
	voice.stream = streams[id]
	voice.play()

func play_resolution(succeeded: bool, critical: bool) -> void:
	play_effect(("critical_" if critical else "") + ("success" if succeeded else "failure"))
	if haptics_enabled:
		Input.vibrate_handheld(65 if critical else 28)

func play_ui() -> void:
	play_effect("ui")
