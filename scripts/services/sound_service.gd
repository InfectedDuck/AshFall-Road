class_name SoundService
extends Node

var effects_enabled := true
var haptics_enabled := true
var player: AudioStreamPlayer


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = "Master"
	add_child(player)


func configure(settings: Dictionary) -> void:
	effects_enabled = bool(settings.get("sound_enabled", true))
	haptics_enabled = bool(settings.get("haptics_enabled", true))


func play_resolution(succeeded: bool, critical: bool) -> void:
	if effects_enabled:
		var frequency := 740.0 if succeeded else 185.0
		var duration := 0.22 if critical else 0.12
		_play_tone(frequency, duration, 0.18)
	if haptics_enabled:
		Input.vibrate_handheld(65 if critical else 28)


func play_ui() -> void:
	if effects_enabled:
		_play_tone(420.0, 0.035, 0.08)


func _play_tone(frequency: float, duration: float, amplitude: float) -> void:
	if player == null:
		return
	var sample_rate := 22050
	var sample_count := int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for index in range(sample_count):
		var time := float(index) / sample_rate
		var envelope := 1.0 - float(index) / sample_count
		var sample := int(sin(TAU * frequency * time) * amplitude * envelope * 32767.0)
		if sample < 0:
			sample += 65536
		bytes[index * 2] = sample & 0xff
		bytes[index * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	player.stream = stream
	player.play()
