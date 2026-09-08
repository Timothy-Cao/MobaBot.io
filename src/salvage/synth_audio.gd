extends Node
## Small original synthesized cues; no external audio files or licenses needed.

var muted := false
var players: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var cooldowns: Dictionary = {}
var cursor := 0
var important_cursor := 0
const IMPORTANT := ["hurt", "lost", "win", "demo_boss", "boss_phase", "boss_windup", "boss_down", "stage_clear", "milestone"]
var sound_rng := RandomNumberGenerator.new()
var pickup_chain := 0
var pickup_gap := 0.0
var channel_voice: AudioStreamPlayer

func _ready() -> void:
	sound_rng.seed = 934
	for i in range(12):
		var player := AudioStreamPlayer.new()
		player.volume_db = -14
		add_child(player)
		players.append(player)
	sounds.shot = _tone(380, 110, 0.065, 0.15)
	sounds.hit = _tone(180, 80, 0.055, 0.35)
	sounds.kill = _tone(260, 65, 0.14, 0.45)
	sounds.pickup = _tone(760, 1200, 0.075, 0.0)
	sounds.hurt = _tone(140, 55, 0.3, 0.25)
	sounds.upgrade = _tone(500, 1050, 0.4, 0.0)
	sounds.equipped = _tone(720, 380, 0.16, 0.05)
	sounds.pulse = _tone(95, 40, 0.4, 0.15)
	sounds.win = _tone(620, 1240, 0.65, 0.0)
	sounds.boss = _tone(170, 100, 0.45, 0.15)
	sounds.lost = _tone(240, 60, 0.55, 0.05)
	sounds.boss_down = sounds.win
	sounds.loot = _tone(450, 1450, 0.28, 0.05)
	sounds.cast = _tone(220, 590, 0.11, 0.1)
	sounds.nuke_impact = _tone(75, 32, 0.55, 0.25)
	sounds.unlock = sounds.upgrade
	sounds.supply = sounds.loot
	sounds.blink = _tone(700, 160, 0.12, 0.08)
	sounds.beam = _tone(120, 45, 0.35, 0.2)
	sounds.demo_boss = sounds.boss
	sounds.boss_phase = _tone(140, 340, 0.5, 0.1)
	sounds.boss_windup = _tone(400, 750, 0.22, 0)
	sounds.stage_clear = sounds.win
	sounds.milestone = sounds.upgrade
	sounds.rocket = _tone(120, 650, 0.19, 0.2)
	sounds.rocket_impact = _tone(105, 40, 0.24, 0.25)
	sounds.lightning = _tone(1000, 160, 0.12, 0.35)
	sounds.boss_summon = sounds.boss
	channel_voice = AudioStreamPlayer.new()
	channel_voice.volume_db = -18
	channel_voice.stream = _channel_hum()
	add_child(channel_voice)

func _process(delta: float) -> void:
	pickup_gap = maxf(0, pickup_gap - delta)
	if pickup_gap <= 0:
		pickup_chain = 0
	for key in cooldowns:
		cooldowns[key] = maxf(0, float(cooldowns[key]) - delta)

func receive(event: Dictionary) -> void:
	var kind: String = event.kind
	if kind == "cast" and event.get("ability", "") == "rocket": kind = "rocket"
	if muted or not sounds.has(kind) or cooldowns.get(kind, 0.0) > 0 or players.is_empty():
		return
	cooldowns[kind] = 0.065 if kind in ["pickup", "hit", "kill"] else 0.03
	# Crowd hits/pickups cannot cut off threat, damage or milestone cues.
	var player: AudioStreamPlayer
	if kind in IMPORTANT:
		player = players[9 + important_cursor]
		important_cursor = (important_cursor + 1) % 3
	else:
		player = players[cursor]
		cursor = (cursor + 1) % 9
	player.stream = sounds[kind]
	player.pitch_scale = sound_rng.randf_range(0.94, 1.06) if kind in ["shot", "pickup", "kill"] else 1.0
	if kind == "pickup":
		player.pitch_scale = pow(2.0, mini(pickup_chain, 12) / 24.0)
		pickup_chain += 1
		pickup_gap = 0.5
	player.volume_db = -22 if kind in ["shot", "hit"] else -14
	player.play()

func set_muted(value: bool) -> void:
	muted = value
	if muted:
		if channel_voice != null: channel_voice.stop()
		for player in players:
			player.stop()

func _exit_tree() -> void:
	if channel_voice != null:
		channel_voice.stop()
		channel_voice.stream = null
	for player in players:
		player.stop()
		player.stream = null
	sounds.clear()

func set_channel(active: bool) -> void:
	if channel_voice == null: return
	if active and not muted:
		if not channel_voice.playing: channel_voice.play()
	elif channel_voice.playing: channel_voice.stop()

func _channel_hum() -> AudioStreamWAV:
	var bytes := PackedByteArray()
	var frames := 11025 # Half a second; integer cycles make a seamless loop.
	bytes.resize(frames * 2)
	for i in range(frames):
		var t := i / 22050.0
		var value := (sin(TAU * 110 * t) + sin(TAU * 330 * t) * 0.25) * 0.18
		var pcm := int(value * 32767)
		bytes[i * 2] = pcm & 255
		bytes[i * 2 + 1] = (pcm >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = frames
	return stream

func _tone(start_hz: float, end_hz: float, seconds: float, noise_mix: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var count := int(seconds * sample_rate)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = int(start_hz)
	for i in range(count):
		var t := float(i) / float(count)
		phase += TAU * lerpf(start_hz, end_hz, t) / float(sample_rate)
		var envelope := minf(1.0, t * 40) * pow(1 - t, 2)
		var sample := (sin(phase) * (1 - noise_mix) + rng.randf_range(-1, 1) * noise_mix) * envelope * 0.55
		var pcm := int(clampf(sample, -1, 1) * 32767)
		bytes[i * 2] = pcm & 255
		bytes[i * 2 + 1] = (pcm >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = bytes
	return stream
