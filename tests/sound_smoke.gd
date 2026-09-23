extends SceneTree
const Sound = preload("res://scripts/services/sound_service.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sound := Sound.new()
	root.add_child(sound)
	var failures := 0
	for id: String in Sound.EFFECTS:
		var stream = sound.streams.get(id)
		if not stream is AudioStreamWAV or stream.get_length() <= 0.0:
			push_error("Missing sound: " + id)
			failures += 1
			continue
		var nonzero := false
		for offset in range(0, stream.data.size(), 2):
			var sample: int = stream.data.decode_s16(offset)
			nonzero = nonzero or sample != 0
			if abs(sample) >= 32767:
				failures += 1
				push_error("Clipped sound: " + id)
				break
		if not nonzero:
			failures += 1
		sound.play_effect(id)
	sound.configure({"sound_enabled": false, "haptics_enabled": false})
	sound.play_ui()
	sound.play_resolution(true, true)
	for voice: AudioStreamPlayer in sound.players:
		if voice.playing:
			push_error("Mute must stop existing and new sounds")
			failures += 1
	sound.queue_free()
	await process_frame
	print("Sound smoke: 14 clips, PCM peak/silence and mute checks; failures: %d" % failures)
	quit(1 if failures else 0)
