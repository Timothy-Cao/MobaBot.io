class_name PracticeSandbox
extends RefCounted
## Scratch UI and deterministic placements. No save/collection API.
static func terrain(run) -> void:
	run.kit.extra.walls.clear()
	var center: Vector2=run.player
	var forms: Array=[[-390,-230,-180,-230,65],[250,-230,440,-180,80],[-400,180,-280,320,65],[220,240,490,240,95],[-90,480,100,480,50]]
	for i in range(forms.size()):
		var f: Array=forms[i]
		run.kit.extra.walls.append({"uid":-100-i,"a":center+Vector2(f[0],f[1]),"b":center+Vector2(f[2],f[3]),"width":float(f[4]),"life":99999.0,"terrain":true})

static func points(game, center: Vector2) -> Array[Vector2]:
	var result: Array[Vector2]=[]
	var count: int=1 if game.practice_formation=="Point" else game.practice_count
	var spacing: float=145 if game.practice_enemy=="foreman" else 85 if game.practice_enemy in ["rammer","artillery"] else 52
	for i in range(count):
		var offset:=Vector2.ZERO
		match game.practice_formation:
			"Line": offset=Vector2((i-(count-1)*0.5)*spacing,0)
			"Ring": offset=Vector2.from_angle(i*TAU/count)*maxf(spacing,spacing*count/TAU)
			"Cluster":
				var columns:=ceili(sqrt(count))
				offset=Vector2((i%columns-(columns-1)*0.5)*spacing,(i/columns-(columns-1)*0.5)*spacing)
		result.append(center+offset)
	return result

static func placement_valid(game, locations: Array[Vector2]) -> bool:
	var radius: float=65 if game.practice_enemy=="foreman" else 36 if game.practice_enemy in ["rammer","artillery"] else 25
	if game.model.enemies.size()+locations.size()>game.model.MAX_ENEMIES: return false
	for p in locations:
		if not Vanguard.valid_point(game.model,p,radius): return false
		if p.distance_to(game.model.player)<radius+20: return false
		for enemy in game.model.enemies:
			if not enemy.dead and p.distance_to(enemy.pos)<radius+enemy.radius: return false
	return true

static func place(game, center: Vector2) -> bool:
	var locations:=points(game,center)
	if not placement_valid(game,locations): return false
	for point in locations:
		if RangedThreats.NAMES.has(game.practice_enemy): RangedThreats.spawn(game.model,game.practice_enemy,point,true)
		elif game.practice_enemy in ["rammer","artillery","foreman"]:
			DemoCampaign.spawn_special(game.model,game.practice_enemy); game.model.enemies.back().pos=point
		else: game.model.spawn_enemy(point,{"bumper":0,"charger":1,"tank":3,"dummy":3}.get(game.practice_enemy,0))
		if game.practice_enemy=="dummy":
			game.model.enemies.back()["dummy"]=true; game.model.enemies.back().hp=1000000.0; game.model.enemies.back().max_hp=1000000.0
	return true

static func draw(game) -> void:
	var ui=game.ui
	ui.clear_overlay(); ui.hud.visible=true
	ui.update_hud(game.model)
	var panel=ui._surface(ui.overlay,Rect2(12,12,310,406),Color("14242cf5"),0,ui.EDGE)
	panel.mouse_filter=Control.MOUSE_FILTER_STOP
	ui._label(ui.overlay,"Practice",Rect2(26,23,200,30),22,ui.CREAM,true)
	ui._button("×",Rect2(276,20,32,29),game.close_practice,false)
	ui._button("Resume",Rect2(26,67,178,31),game.close_practice)
	ui._button("Reset",Rect2(213,67,94,31),game.practice_reset,false)
	var modified: bool=game.model.exp.god_mode or game.model.exp.free_energy or game.model.exp.fast_cooldowns or game.model.vanguard.freeze_ai
	ui._label(ui.overlay,"MODIFIED TEST" if modified else "NORMAL",Rect2(26,104,270,20),10,ui.GOLD if modified else ui.TEAL,true)
	var pages: Array=["Build","Player","Enemies"]
	if game.practice_page not in pages: game.practice_page="Build"
	for i in range(pages.size()):
		var page: String=pages[i]
		ui._tab(page,Rect2(22+i*96,128,94,31),func(): game.practice_page=page; draw(game),game.practice_page==page)
	match game.practice_page:
		"Build":
			ui._label(ui.overlay,"All abilities",Rect2(26,181,180,23),16,ui.CREAM)
			for i in range(3):
				var rank_value: int=[1,5,10][i]
				ui._button(str(rank_value),Rect2(26+i*95,218,88,35),func():
					game.practice_rank=rank_value
					Vanguard.setup(game.model,rank_value)
					draw(game),game.practice_rank==rank_value)
			for i in range(Vanguard.KEYS.size()):
				var slot: String=Vanguard.KEYS.keys()[i]
				var point:=Vector2(28+(i%5)*55,280+(i/5)*57)
				ui._ability_icon(ui.overlay,VanguardHud.icon(slot),Rect2(point,Vector2(40,40)))
				ui._label(ui.overlay,OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(point,Vector2(20,16)),10,ui.GOLD,true)
		"Player":
			for i in range(5):
				var field: String=["god_mode","free_energy","fast_cooldowns","freeze_ai","numbers"][i]
				var owner=game.model.exp if i<3 else game.model.vanguard if i==3 else game.model.practice_meter
				ui._label(ui.overlay,["God mode","Free energy","Instant recharge","Freeze enemies","Damage numbers"][i],Rect2(26,180+i*43,194,27),15,ui.CREAM)
				var toggle: Button=ui._button("On" if owner.get(field) else "Off",Rect2(232,174+i*43,72,32),func():
					owner.set(field,not owner.get(field))
					if field=="numbers": game.model.practice_meter.hits.clear()
					draw(game),false)
				toggle.name=field
		"Enemies":
			var types: Array=["dummy","bumper","charger","tank","breacher","mender","scatter","emp","lancer","volley","bomber","rammer","artillery","foreman"]
			PracticeView.select(ui,["Target dummy","Bumper","Charger","Tank","Breacher","Mender","Scattergun","EMP suppressor","Arc lancer","Burst battery","Bomb carrier","Rammer","Artillery","Boss"],types.find(game.practice_enemy),Rect2(26,173,278,33),func(i): game.practice_enemy=types[i])
			PracticeView.select(ui,[1,5,10,25,50],[1,5,10,25,50].find(game.practice_count),Rect2(26,218,96,33),func(i): game.practice_count=[1,5,10,25,50][i])
			game.practice_formation="Cluster"
			ui._button("Place",Rect2(26,270,278,37),game.begin_practice_placement)
			ui._label(ui.overlay,"B: dummy   ·   C: clear enemies",Rect2(26,324,278,22),12,ui.MUTED)
			ui._label(ui.overlay,"Click to place · Shift repeats",Rect2(26,349,278,22),12,ui.MUTED)
