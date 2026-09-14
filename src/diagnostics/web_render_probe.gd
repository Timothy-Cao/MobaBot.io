extends Node2D
## Explicit alternate scene only. In-memory rendering fixture: no profiles, rewards or services.
class ProbeRun extends SalvageRun:
	func _spawn_step(_delta: float) -> void: pass
class TimedArt extends "res://src/salvage/workshop_art.gd":
	var draw_us:=0
	var floor_us:=0
	var actors_us:=0
	func _draw() -> void:
		actors_us=0
		var start:=Time.get_ticks_usec(); super._draw(); draw_us=Time.get_ticks_usec()-start
	func _world_floor() -> void:
		var start:=Time.get_ticks_usec(); super._world_floor(); floor_us=Time.get_ticks_usec()-start
	func _enemy(enemy: Dictionary) -> void:
		var start:=Time.get_ticks_usec(); super._enemy(enemy); actors_us+=Time.get_ticks_usec()-start

var run: SalvageRun
var art: TimedArt
var ui
var label: Label
var samples: Array[Dictionary]=[]
var phase:=0
var elapsed:=0.0
var last_tick:=0
var sim_us:=0
var cast_clock:=0.0
var counts: Array[int]=[0,40,120,60]
var reports: Array[String]=[]

func _ready() -> void:
	run=ProbeRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	Vanguard.setup(run); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run)
	run.kit.loadout.support23=true; run.kit.loadout.arsenal26=true; DemoPacing.enable(run)
	FactoryMaps.enable(run); DiscoveryRules.enable(run); IntentRules.enable(run)
	ForgeEquipment.new().apply_to(run); run.health=run.max_health()
	art=TimedArt.new(); art.model=run; art.world_mode=true; add_child(art)
	ui=load("res://src/salvage/workshop_ui.gd").new(); add_child(ui); ui.show_running()
	label=Label.new(); label.position=Vector2(18,86); label.add_theme_font_size_override("font_size",14); ui.add_child(label)
	begin()

func begin() -> void:
	run.enemies.clear(); run.pickups.clear()
	for i in range(counts[phase]):
		var p:=run.player+Vector2((i%15-7)*45,(i/15-4)*43)
		if phase==3 and i>=55: RangedThreats.spawn(run,["lancer","bomber","mosquito","volley","scatter"][i-55],p,true)
		else: run.spawn_enemy(p,1 if phase==3 and i%8==0 else 3 if phase==3 and i%11==0 else 0)
		run.enemies.back().warmup=0
		if phase==3: run.enemies.back().hp=100000; run.enemies.back().max_hp=100000
	for i in range(counts[phase]*2):
		run.pickups.append({"id":i,"pos":run.player+Vector2((i%25-12)*30,(i/25-5)*32),"pull":false,"speed":0.0,"value":1})
	if phase==3:
		run.exp.practice=true; run.exp.god_mode=true; run.pickups.clear()
		for slot in ["q","w","e","r"]: run.kit.ranks[slot]=5
	elapsed=0; samples.clear(); last_tick=Time.get_ticks_usec()

func _physics_process(delta: float) -> void:
	if phase!=3: return
	var start:=Time.get_ticks_usec()
	run.kit.energy=run.kit.energy_max()
	run.command_move(FactoryMaps.CENTER+Vector2.from_angle(run.time*0.4)*230)
	cast_clock-=delta
	if cast_clock<=0:
		cast_clock=0.4
		var enemy:=run.nearest_enemy(run.player)
		if not enemy.is_empty():
			for slot in ["q","w","e","r"]: run.kit.cast(run,slot,enemy.pos)
			run.vanguard.swing(run,enemy.pos)
	run.step(delta,Vector2.ZERO)
	for event in run.events: art.receive(event)
	run.events.clear(); sim_us=Time.get_ticks_usec()-start

func _process(delta: float) -> void:
	if phase>=counts.size(): return
	var now:=Time.get_ticks_usec(); var frame_us:=now-last_tick; last_tick=now
	elapsed+=delta
	if phase!=3: run.time+=delta
	# Small camera movement defeats accidental whole-frame caching; no simulation stepping.
	run.detached_camera=true; run.detached_origin=run.player-run.view_size/2+Vector2(sin(run.time)*35,0)
	art.position=-run.camera_origin()
	var start:=Time.get_ticks_usec(); ui.update_hud(run); var hud_us:=Time.get_ticks_usec()-start
	if elapsed>2: samples.append({"frame":frame_us,"draw":art.draw_us,"floor":art.floor_us,"actors":art.actors_us,"hud":hud_us,"simulation":sim_us})
	label.text="PROBE — %d bodies / %d pickups\n%d FPS (%s; no player saves)"%[counts[phase],run.pickups.size(),Engine.get_frames_per_second(),"mixed combat" if phase==3 else "render-only"]
	if elapsed<8: return
	var result: Dictionary={"bodies":counts[phase],"combat":phase==3,"web":OS.has_feature("web"),"debug":OS.is_debug_build(),"frames":samples.size()}
	for key in ["frame","draw","floor","actors","hud","simulation"]:
		var values: Array=[]; var total:=0.0
		for sample in samples: values.append(sample[key]); total+=sample[key]
		values.sort(); result[key+"_mean_ms"]=snappedf(total/values.size()/1000,0.01)
		result[key+"_p95_ms"]=snappedf(values[int(values.size()*0.95)]/1000.0,0.01)
	result["fps"]=snappedf(1000/result.frame_mean_ms,0.1)
	var report: String="WEB_RENDER_PROBE "+JSON.stringify(result); print(report)
	if OS.has_feature("web"): JavaScriptBridge.eval("console.log("+JSON.stringify(report)+")")
	reports.append(report); phase+=1
	if phase<counts.size(): begin()
	else:
		label.text="PROBE COMPLETE — results in console"; set_process(false); art.set_process(false)
		if not OS.has_feature("web"): get_tree().quit()
