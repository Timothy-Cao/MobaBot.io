class_name PracticeView
extends RefCounted

static func select(ui, items: Array, selected: int, rect: Rect2, callback: Callable) -> OptionButton:
	var control:=OptionButton.new(); control.position=rect.position; control.size=rect.size
	control.add_theme_font_size_override("font_size",17)
	for text_value in items: control.add_item(str(text_value))
	control.select(maxi(0,selected)); control.item_selected.connect(callback)
	ui.overlay.add_child(control); return control

static func draw(game) -> void:
	var ui=game.ui; var exp=game.model.exp
	ExpeditionView.frame(ui,"Practice",game.close_practice)
	ui._label(ui.overlay,"Skills",Rect2(49,100,410,30),20,ui.CREAM,true)
	var ids: Array=[]
	for category in ["active","ultimate","speed","mobility","summon"]:
		for id in BotSkillCatalog.modern_ids(category):
			if id not in ids: ids.append(id)
	ids.append_array(MobaKit.PASSIVES.keys())
	var names: Array=ids.map(func(id): return KeyboardView.name_of(id))
	select(ui,names,ids.find(game.practice_skill),Rect2(49,143,365,38),func(i):
		game.practice_skill=ids[i]
		if not BotKeyboard.allowed(game.practice_skill,game.practice_key): game.practice_key=KEY_D if BotKeyboard.allowed(game.practice_skill,KEY_D) else KEY_Q
		draw(game))
	var keys: Array=BotKeyboard.MOVEMENT if BotKeyboard.allowed(game.practice_skill,KEY_D) else BotKeyboard.GENERAL
	select(ui,keys.map(func(k): return OS.get_keycode_string(k)),keys.find(game.practice_key),Rect2(49,195,105,37),func(i): game.practice_key=keys[i])
	select(ui,["Rank 0","Rank 5","Rank 10"],[0,5,10].find(game.practice_rank),Rect2(168,195,144,37),func(i): game.practice_rank=[0,5,10][i])
	ui._button("Fit",Rect2(325,195,89,37),game.practice_fit)
	ui._ability_icon(ui.overlay,game.practice_skill,Rect2(49,260,70,70))
	var data: Dictionary=MobaKit.PASSIVES.get(game.practice_skill,MobaKit.ABILITIES.get(game.practice_skill,{}))
	ui._label(ui.overlay,SkillLibrary.description(game.practice_skill),Rect2(135,258,290,105),14,ui.MUTED).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	for i in range((BotKeyboard.GENERAL+BotKeyboard.MOVEMENT).size()):
		var key: int=(BotKeyboard.GENERAL+BotKeyboard.MOVEMENT)[i]
		var slot:=BotKeyboard.slot_at(game.model.kit,key)
		var point:=Vector2(49+i%6*61,372+i/6*55)
		if slot!="": ui._ability_icon(ui.overlay,BotKeyboard.id_at(game.model.kit,slot),Rect2(point,Vector2(43,43)))
		ui._label(ui.overlay,OS.get_keycode_string(key),Rect2(point,Vector2(24,18)),11,ui.GOLD,true)
	ui._surface(ui.overlay,Rect2(465,105,1,354),ui.EDGE,0)
	ui._label(ui.overlay,"Enemies",Rect2(499,100,400,30),20,ui.CREAM,true)
	var types: Array=["dummy","bumper","charger","tank","lancer","volley","bomber","rammer","artillery","foreman"]
	select(ui,["Target dummy","Bumper","Charger","Tank","Arc lancer","Burst battery","Bomb carrier","Rammer","Artillery","Boss"],types.find(game.practice_enemy),Rect2(499,143,265,38),func(i): game.practice_enemy=types[i])
	select(ui,[1,5,10,25,50,100],[1,5,10,25,50,100].find(game.practice_count),Rect2(780,143,119,38),func(i): game.practice_count=[1,5,10,25,50,100][i])
	ui._button("Spawn",Rect2(499,195,191,37),game.practice_spawn)
	ui._button("Clear",Rect2(705,195,194,37),game.practice_clear,false)
	for i in range(3):
		var field: String=["god_mode","free_energy","fast_cooldowns"][i]
		var label: String=["God mode","Infinite energy","Instant recharge"][i]
		ui._label(ui.overlay,label,Rect2(499,272+i*54,260,30),17,ui.CREAM)
		var toggle: Button=ui._button("On" if exp.get(field) else "Off",Rect2(800,265+i*54,99,37),func(): exp.set(field,not exp.get(field)); draw(game),false)
		toggle.name=field
	ui._label(ui.overlay,"Tab · test / configure     Progress is not saved",Rect2(499,451,406,30),13,ui.MUTED)
