extends Node
## Two voices crossfade only when encounter context changes.
var voices: Array[AudioStreamPlayer] = []
var active := 0
var current := ""
var fade: Tween
var silenced := false

func _ready() -> void:
	for i in range(2):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voice.volume_db = -60
		voices.append(voice)

func update_context(screen: String, run, muted: bool) -> void:
	# The headless dummy audio driver does not drain MP3 playbacks at shutdown.
	if DisplayServer.get_name() == "headless": return
	if voices.is_empty(): return
	if muted != silenced:
		silenced = muted
		for voice in voices: voice.stream_paused = muted
	var track := "menu"
	if screen in ["build", "upgrade"] and run != null and run.demo_mode and not current.is_empty(): return
	if screen in ["settings", "paused"]: track = "settings"
	elif screen in ["loadout", "equipment", "build", "result", "stage_reward"]: track = "casual"
	elif run != null and run.demo_mode and screen in ["running", "upgrade"]:
		track = "main_loop%d" % run.stage
		for enemy in run.enemies:
			if not enemy.dead and enemy.has("role"):
				track = ("big_boss2" if enemy.enraged else "big_boss") if enemy.role == "foreman" else "boss1"
				if enemy.role == "foreman": break
	if track == current: return
	var path := "res://music/%s.mp3" % track
	if not ResourceLoader.exists(path): return
	current = track
	if fade != null: fade.kill()
	var previous := active
	active = 1 - active
	voices[active].stop()
	var stream: AudioStreamMP3 = load(path)
	stream.loop = true
	voices[active].stream = stream
	voices[active].volume_db = -60
	voices[active].play()
	voices[active].stream_paused = silenced
	fade = create_tween().set_parallel()
	fade.tween_property(voices[previous], "volume_db", -60.0, 0.6)
	fade.tween_property(voices[active], "volume_db", -15.0, 0.6)
	fade.chain().tween_callback(voices[previous].stop)

func _exit_tree() -> void:
	if fade != null: fade.kill()
	for voice in voices:
		voice.stop()
		voice.stream = null
