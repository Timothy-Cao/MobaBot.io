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
	var panel=ui._surface(ui.overlay,Rect2(12,12,310,406),Color("14242cf5"),0,ui.EDGE)
	panel.mouse_filter=Control.MOUSE_FILTER_STOP
	ui._label(ui.overlay,"Practice",Rect2(26,23,200,30),22,ui.CREAM,true)
	ui._button("×",Rect2(276,20,32,29),game.close_practice,false)
	ui._button("Resume",Rect2(26,67,87,31),game.close_practice)
	ui._button("Clear",Rect2(120,67,86,31),game.practice_clear,false)
	ui._button("Reset",Rect2(213,67,94,31),func():
		game.practice_clear(); game.model.player=Vector2(480,300); terrain(game.model)
		game.model.vanguard=Vanguard.new(); game.model.damage_dealt.clear(); game.model.time=0; game.free_center=game.model.player; game._update_camera(); draw(game),false)
	var modified: bool=game.model.exp.god_mode or game.model.exp.free_energy or game.model.exp.fast_cooldowns or game.model.vanguard.freeze_ai or game.model.vanguard.time_scale!=1
	ui._label(ui.overlay,"MODIFIED TEST" if modified else "NORMAL",Rect2(26,104,270,20),10,ui.GOLD if modified else ui.TEAL,true)
	var pages: Array=["Build","Player","Enemies","Session"]
	for i in range(pages.size()):
		var page: String=pages[i]
		ui._tab(page,Rect2(22+i*73,128,72,31),func(): game.practice_page=page; draw(game),game.practice_page==page)
	match game.practice_page:
		"Build":
			PracticeView.select(ui,["Vanguard","Legacy laboratory"],0 if Vanguard.enabled(game.model) else 1,Rect2(26,174,278,32),func(i):
				if i==0: Vanguard.setup(game.model,maxi(1,game.practice_rank)); draw(game)
				else: game.launch_practice(true))
			ui._label(ui.overlay,"Kit rank",Rect2(26,220,100,23),15,ui.MUTED)
			PracticeView.select(ui,["Starter","1","5","10"],[0,1,5,10].find(game.practice_rank),Rect2(152,213,152,33),func(i):
				game.practice_rank=[0,1,5,10][i]; Vanguard.setup(game.model,game.practice_rank); draw(game))
			for i in range(Vanguard.KEYS.size()):
				var slot: String=Vanguard.KEYS.keys()[i]
				var point:=Vector2(28+(i%5)*55,270+(i/5)*57)
				ui._ability_icon(ui.overlay,VanguardHud.icon(slot),Rect2(point,Vector2(40,40)))
				ui._label(ui.overlay,OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(point,Vector2(20,16)),10,ui.GOLD,true)
			var slots: Array=Vanguard.KEYS.keys()
			PracticeView.select(ui,slots.map(func(s): return OS.get_keycode_string(Vanguard.KEYS[s])),slots.find(game.practice_slot),Rect2(26,374,88,29),func(i): game.practice_slot=slots[i]; draw(game))
			PracticeView.select(ui,["Locked","Rank 1","Rank 2","Rank 3","Rank 4","Rank 5","Rank 6","Rank 7","Rank 8","Rank 9","Rank 10"],Vanguard.rank_of(game.model,game.practice_slot),Rect2(124,374,180,29),func(i):
				var slot: String=game.practice_slot
				if slot=="p1": game.model.upgrades.grinder=i; game.model.orbit.clear()
				else: game.model.kit.ranks[slot]=i; game.model.upgrades["skill_"+slot]=i
				if i==0: game.model.kit.discovered.erase(slot)
				elif slot not in game.model.kit.discovered: game.model.kit.discovered.append(slot)
				draw(game))
		"Player":
			for i in range(4):
				var field: String=["god_mode","free_energy","fast_cooldowns","freeze_ai"][i]
				var owner=game.model.exp if i<3 else game.model.vanguard
				ui._label(ui.overlay,["God mode","Free energy","Instant recharge","Freeze enemies"][i],Rect2(26,180+i*45,194,27),15,ui.CREAM)
				var toggle: Button=ui._button("On" if owner.get(field) else "Off",Rect2(232,174+i*45,72,32),func(): owner.set(field,not owner.get(field)); draw(game),false)
				toggle.name=field
		"Enemies":
			var types: Array=["dummy","bumper","charger","tank","lancer","volley","bomber","rammer","artillery","foreman"]
			PracticeView.select(ui,["Target dummy","Bumper","Charger","Tank","Arc lancer","Burst battery","Bomb carrier","Rammer","Artillery","Boss"],types.find(game.practice_enemy),Rect2(26,173,278,33),func(i): game.practice_enemy=types[i])
			PracticeView.select(ui,[1,5,10,25,50],[1,5,10,25,50].find(game.practice_count),Rect2(26,218,96,33),func(i): game.practice_count=[1,5,10,25,50][i])
			var forms: Array=["Point","Line","Ring","Cluster"]
			PracticeView.select(ui,forms,forms.find(game.practice_formation),Rect2(135,218,169,33),func(i): game.practice_formation=forms[i])
			ui._button("Place",Rect2(26,270,278,37),func():
				game.practice_placing=true; game.screen="placement"; ui.clear_overlay(); ui.hud.visible=true
				ui._button("Cancel placement",Rect2(26,25,180,34),func(): game.practice_placing=false; game.open_practice(),false))
			ui._label(ui.overlay,"Click to place · Shift repeats",Rect2(26,324,278,22),12,ui.MUTED)
		"Session":
			ui._label(ui.overlay,"Damage numbers",Rect2(26,358,194,27),15,ui.CREAM)
			ui._button("On" if game.model.practice_meter.numbers else "Off",Rect2(232,353,72,32),func():
				game.model.practice_meter.numbers=not game.model.practice_meter.numbers; game.model.practice_meter.hits.clear(); draw(game),false)
			PracticeView.select(ui,["0.5× speed","1× speed","2× speed"],[0.5,1.0,2.0].find(game.model.vanguard.time_scale),Rect2(26,177,278,34),func(i): game.model.vanguard.time_scale=[0.5,1.0,2.0][i]; draw(game))
			var total:=0.0
			for value in game.model.damage_dealt.values(): total+=float(value)
			ui._label(ui.overlay,"%.0f damage · %.1f / sec"%[total,total/maxf(1,game.model.time)],Rect2(26,232,278,28),16,ui.CREAM)
			ui._label(ui.overlay,"%.1fs · %d enemies"%[game.model.time,game.model.enemies.size()],Rect2(26,264,278,25),14,ui.MUTED)
			ui._button("Reset measurement",Rect2(26,308,278,35),func(): game.model.damage_dealt.clear(); game.model.practice_meter.clear(); game.model.time=0; draw(game),false)
