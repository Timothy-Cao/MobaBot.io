extends Node
## Small original synthesized cues; no external audio files or licenses needed.

var muted := false
var players: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var cooldowns: Dictionary = {}
var cursor := 0
var important_cursor := 0
const IMPORTANT := ["hurt", "hurt_low", "hurt_critical", "energy_empty", "lost", "win", "demo_boss", "boss_phase", "boss_windup", "boss_down", "stage_clear", "milestone", "enemy_windup"]
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
	sounds.auto_shot = _tone(510,190,0.035,0.13)
	sounds.heavy_shot = _tone(180,55,0.14,0.3)
	sounds.hit = _tone(180, 80, 0.055, 0.35)
	sounds.kill = _tone(260, 65, 0.14, 0.45)
	sounds.pickup = _tone(760, 1200, 0.075, 0.0)
	sounds.pickup_big = _sequence([760,1140],[1050,1500],0.055,0.0)
	sounds.hurt = _tone(140, 55, 0.3, 0.25)
	sounds.hurt_low = _sequence([155,85],[85,45],0.13,0.30)
	sounds.hurt_critical = _sequence([180,65,110],[55,40,45],0.12,0.38)
	sounds.energy_empty = _sequence([420,240],[240,140],0.10,0.03)
	sounds.cast_unready = _tone(240,210,0.065,0.0)
	sounds.mode_switch = _tone(580,830,0.085,0.02)
	sounds.repair_pickup = _sequence([520,780],[700,960],0.085,0.0)
	sounds.energy_pickup = _tone(1050,1550,0.17,0.07)
	sounds.credit_pickup = _sequence([950,1250],[1150,1450],0.06,0.08)
	sounds.boost_pickup = _sequence([400,650,900],[600,850,1200],0.07,0.0)
	sounds.chest_contents = _sequence([170,680,1020],[70,900,1400],0.12,0.06)
	sounds.enemy_windup = _tone(310,690,0.20,0.06)
	sounds.enemy_shot = _tone(150,60,0.16,0.36)
	sounds.enemy_repair = _tone(400,600,0.20,0.05)
	sounds.deploy = _sequence([160,450],[70,600],0.09,0.15)
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
	sounds.v_blink = _tone(1100,120,0.18,0.16)
	sounds.v_drive = _tone(150,600,0.24,0.12)
	sounds.v_slam = _tone(380,100,0.16,0.25)
	sounds.v_impact = _tone(85,30,0.27,0.35)
	sounds.v_hammer = _tone(130,38,0.19,0.32)
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
	sounds.ui_focus = _tone(740, 820, 0.025, 0.0)
	sounds.ui_confirm = _tone(480, 620, 0.065, 0.0)
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

func cue_for(event: Dictionary) -> String:
	var kind: String = event.kind
	if kind=="hurt":
		var ratio: float=event.get("health_fraction",1.0)
		return "hurt_critical" if ratio<0.25 else "hurt_low" if ratio<0.5 else "hurt"
	if kind=="supply": return {"repair":"repair_pickup","energy":"energy_pickup","coins":"credit_pickup","speed":"boost_pickup","reset":"boost_pickup"}.get(event.get("supply",""),"supply")
	if kind=="pickup" and event.get("value",0)>=8: return "pickup_big"
	if kind=="cast" and event.get("ability","") in ["guard_bot","reserve_totem","medic_sentry","recovery_totem"]: return "deploy"
	if kind=="miniboss_down": return "boss_down"
	if kind=="surge": return "enemy_windup"
	if kind=="skill_cut": kind="pulse" if event.get("style","")=="reap" else "beam"
	if kind == "cast" and event.get("ability", "") == "rocket": kind = "rocket"
	return kind

func receive(event: Dictionary) -> void:
	if event.get("silent_audio",false): return
	var kind:=cue_for(event)
	if muted or not sounds.has(kind) or cooldowns.get(kind, 0.0) > 0 or players.is_empty():
		return
	cooldowns[kind] = 0.065 if kind in ["pickup", "pickup_big", "hit", "kill"] else 0.03
	if kind in ["hurt","hurt_low","hurt_critical"]: cooldowns[kind]=0.18
	if kind=="energy_empty": cooldowns[kind]=0.65
	if kind=="cast_unready": cooldowns[kind]=0.35
	if kind in ["enemy_windup","enemy_shot","enemy_repair"]: cooldowns[kind]=0.45
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
	if kind in ["pickup","pickup_big"]:
		player.pitch_scale = pow(2.0, mini(pickup_chain, 12) / 24.0)
		pickup_chain += 1
		pickup_gap = 0.5
	player.volume_db = -26 if kind.begins_with("ui_") else (-22 if kind in ["shot", "hit"] else -14)
	if kind=="auto_shot": player.volume_db=-27
	elif kind=="heavy_shot": player.volume_db=-18
	elif kind in ["hurt","hurt_low","hurt_critical"]: player.volume_db=-9 if kind=="hurt_critical" else -11
	elif kind in ["energy_empty","chest_contents"]: player.volume_db=-12
	elif kind=="cast_unready" or kind.begins_with("enemy_"): player.volume_db=-20
	player.play()

func _sequence(starts: Array, ends: Array, seconds: float, noise: float) -> AudioStreamWAV:
	var stream:=AudioStreamWAV.new(); stream.format=AudioStreamWAV.FORMAT_16_BITS; stream.mix_rate=22050
	var pcm:=PackedByteArray()
	for i in range(starts.size()): pcm.append_array(_tone(starts[i],ends[i],seconds,noise).data)
	stream.data=pcm
	return stream

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
