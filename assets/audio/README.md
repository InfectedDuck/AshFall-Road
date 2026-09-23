# Ashfall Road sound effects

14 original procedural effects created for this project. No third-party samples,
recordings, voices, or licensed music are used. Regenerate with Godot:

`--headless --path . --script res://tools/generate_sound_effects.gd`

44.1 kHz, mono, signed 16-bit PCM WAV. Short fades and conservative levels keep
the effects restrained. The source generator contains the deterministic design
for each clip. Runtime caches the streams and uses four voices; disabling sound
stops playing effects immediately. Haptics retain their independent setting.

Included cues: UI tap, dice, success/failure and their critical versions, impact,
block, evade, inventory, rest, stat allocation, victory, and death. Sounds are
triggered by committed action presentation, rather than opening a saved result.

Desktop loading and mute tests do not establish phone-speaker loudness or listener
preference. Tune the generator amplitudes after a device listening session.
