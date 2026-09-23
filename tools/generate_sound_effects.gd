extends SceneTree
## Original procedural audio; fixed local RNG never touches gameplay RNG.
const RATE := 44100
const DESIGNS := {
	"ui": [0.055, [650.0], 0.08, 0.15],
	"dice": [0.38, [1250.0], 0.16, 0.85],
	"success": [0.30, [440.0, 554.37, 659.25], 0.14, 0.02],
	"critical_success": [0.52, [440.0, 659.25, 880.0], 0.17, 0.03],
	"failure": [0.26, [220.0, 174.61], 0.12, 0.06],
	"critical_failure": [0.40, [185.0, 130.81, 98.0], 0.14, 0.10],
	"impact": [0.18, [92.0], 0.22, 0.55],
	"block": [0.23, [720.0, 1113.0], 0.15, 0.28],
	"evade": [0.20, [350.0], 0.12, 0.75],
	"inventory": [0.13, [900.0, 1350.0], 0.10, 0.32],
	"rest": [0.85, [261.63, 329.63, 392.0], 0.12, 0.03],
	"level_up": [0.65, [392.0, 493.88, 587.33, 783.99], 0.15, 0.02],
	"victory": [1.20, [261.63, 392.0, 523.25, 659.25], 0.14, 0.02],
	"death": [0.95, [196.0, 146.83, 98.0], 0.12, 0.08],
}

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	for id: String in DESIGNS:
		var spec: Array = DESIGNS[id]
		var duration := float(spec[0])
		var notes: Array = spec[1]
		var rng := RandomNumberGenerator.new()
		rng.seed = 7300 + id.hash()
		var bytes := PackedByteArray()
		var count := int(RATE * duration)
		bytes.resize(count * 2)
		var smooth_noise := 0.0
		for i: int in range(count):
			var t := float(i) / RATE
			var progress := t / duration
			var segment := mini(int(progress * notes.size()), notes.size() - 1)
			var note_duration := duration / notes.size()
			var local := fmod(t, note_duration)
			var frequency := float(notes[segment])
			var envelope := minf(t / 0.006, 1.0) * pow(1.0 - progress, 2.0)
			var tone := sin(TAU * frequency * local) + 0.2 * sin(TAU * frequency * 2.0 * local)
			envelope *= minf(local / 0.004, 1.0) * minf((note_duration - local) / 0.004, 1.0)
			if id == "dice":
				envelope *= exp(-fmod(t, 0.067) * 100.0)
			if id == "impact":
				tone = sin(TAU * (130.0 * t - 170.0 * t * t))
			smooth_noise = lerpf(smooth_noise, rng.randf_range(-1.0, 1.0), 0.3)
			var sample := (tone * (1.0 - float(spec[3])) + smooth_noise * float(spec[3])) * envelope * float(spec[2])
			bytes.encode_s16(i * 2, int(clampf(sample, -0.9, 0.9) * 32767.0))
		var stream := AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate = RATE
		stream.data = bytes
		if stream.save_to_wav("res://assets/audio/%s.wav" % id) != OK:
			push_error("Cannot write sound: " + id)
			quit(1)
			return
	print("Generated %d original mono PCM sound effects." % DESIGNS.size())
	quit()
