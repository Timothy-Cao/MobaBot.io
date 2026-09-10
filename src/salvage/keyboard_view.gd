class_name KeyboardView
extends RefCounted
const POS := {KEY_1:Vector2(150,0),KEY_2:Vector2(222,0),KEY_3:Vector2(294,0),KEY_4:Vector2(366,0),KEY_Q:Vector2(126,74),KEY_W:Vector2(198,74),KEY_E:Vector2(270,74),KEY_R:Vector2(342,74),KEY_T:Vector2(414,74),KEY_D:Vector2(244,148),KEY_F:Vector2(316,148)}

static func name_of(id: String) -> String:
	return MobaKit.PASSIVES[id].name if MobaKit.PASSIVES.has(id) else MobaKit.ABILITIES[id].name

static func description(kit, slot: String) -> String:
	var id:=BotKeyboard.id_at(kit,slot)
	if slot.begins_with("p"): return name_of(id)+"\n"+MobaKit.PASSIVES[id].text+("\n+1 equipment rank: +20% primary effect, or +1 shared weapon-track rank (cap 10)." if kit.rank_bonus>0 else "")
	var detail: String=SkillLibrary.description(id,kit.loadout.get("rules17",false))
	if id=="laser": detail=detail.replace("R again",OS.get_keycode_string(kit.bindings[slot])+" again")
	return "%s · Rank %d%s\n%s\n%.1fs recharge · %s"%[name_of(id),kit.ranks[slot]," +1 gear" if kit.rank_bonus>0 else "",detail,kit.cooldown(slot),MobaKit.cost_text(id)]

static func draw(game) -> void:
	var ui=game.ui; var kit: MobaKit=game.model.kit
	ExpeditionView.frame(ui,"Place skill" if game.pending_discovery>=0 else "Skills",game.close_keyboard)
	var incoming: String="" if game.pending_discovery<0 else game.model.exp.chest_choices[game.pending_discovery].id
	if game.library_choice!="": incoming=game.library_choice
	for key in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
		var at: Vector2=Vector2(63,133)+POS[key]
		var slot:=BotKeyboard.slot_at(kit,key)
		var available:=incoming=="" or (BotKeyboard.allowed(incoming,key) if game.library_choice!="" else BotKeyboard.can_place(kit,incoming,key))
		var button: Button=ui._button("",Rect2(at,Vector2(64,64)),func() -> void:
			game.keyboard_key(key),false)
		button.name="Key_"+OS.get_keycode_string(key)
		button.set_meta("keyboard_key",key)
		button.disabled=not available
		button.add_theme_stylebox_override("normal",ui._style(ui.PANEL,2,ui.GOLD if game.keyboard_target==key else (ui.TEAL if available and incoming!="" else ui.EDGE),2))
		if slot!="":
			ui._ability_icon(button,BotKeyboard.id_at(kit,slot),Rect2(8,7,48,48))
			button.tooltip_text=description(kit,slot)
		ui._label(button,OS.get_keycode_string(key),Rect2(4,0,24,20),12,ui.CREAM,true)
		if incoming!="" and available and not ui.reduced:
			var tween:=button.create_tween().set_loops()
			tween.tween_property(button,"self_modulate",Color(0.7,1,0.93),0.5)
			tween.tween_property(button,"self_modulate",Color.WHITE,0.5)
	for entry in [["settings",Vector2(0,0),"Settings"],["build",Vector2(0,74),"Build"],["attack",Vector2(74,148),"Attack"],["center",Vector2(126,222),"Camera"]]:
		var width: float=288 if entry[0]=="center" else 64
		var tile=ui._surface(ui.overlay,Rect2(Vector2(63,133)+entry[1],Vector2(width,54)),Color("1b2934"),2)
		ui._label(tile,OS.get_keycode_string(ui.system_keys[entry[0]]),Rect2(5,3,width-10,20),12,ui.MUTED,true)
		ui._label(tile,entry[2],Rect2(5,28,width-10,18),11,ui.MUTED)
	ui._label(ui.overlay,"D / F",Rect2(442,294,140,21),12,ui.MUTED)
	ui._label(ui.overlay,"Movement",Rect2(442,315,145,24),14,ui.CREAM)
	ui._surface(ui.overlay,Rect2(600,132,1,306),ui.EDGE,0)
	if incoming!="":
		ui._ability_icon(ui.overlay,incoming,Rect2(670,139,110,110))
		ui._label(ui.overlay,name_of(incoming),Rect2(622,268,288,54),23,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var previous:=BotKeyboard.slot_at(kit,game.keyboard_target)
		var text_value: String="" if game.keyboard_target==0 else ("Empty slot" if previous=="" else "Store "+name_of(BotKeyboard.id_at(kit,previous)))
		ui._label(ui.overlay,text_value,Rect2(622,340,288,50),14,ui.MUTED,false,HORIZONTAL_ALIGNMENT_CENTER).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var place: Button=ui._button("Fit" if game.library_choice!="" else "Place",Rect2(660,415,210,43),game.place_discovery)
		place.disabled=game.keyboard_target==0
	else:
		ui._label(ui.overlay,"Select two keys to swap",Rect2(622,170,284,60),20,ui.CREAM,true).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		if game.keyboard_target!=0:
			var slot:=BotKeyboard.slot_at(kit,game.keyboard_target)
			if slot!="":
				ui._ability_icon(ui.overlay,BotKeyboard.id_at(kit,slot),Rect2(670,248,110,110))
				ui._label(ui.overlay,name_of(BotKeyboard.id_at(kit,slot)),Rect2(622,377,284,50),19,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	if not kit.loadout.get("library",{}).is_empty() and game.pending_discovery<0:
		var stored:=OptionButton.new(); stored.position=Vector2(63,445); stored.size=Vector2(480,37)
		stored.add_item("Stored skills · %d"%kit.loadout.library.size())
		var ids: Array=kit.loadout.library.keys()
		for id in ids: stored.add_item(name_of(id)+" · "+str(kit.loadout.library[id].rank))
		stored.item_selected.connect(func(i: int) -> void:
			if i>0: game.library_choice=ids[i-1]; game.keyboard_target=0; draw(game))
		ui.overlay.add_child(stored)

static func hud(ui, run) -> void:
	var kit: MobaKit=run.kit
	var signature:=JSON.stringify([kit.loadout,kit.bindings,kit.discovered,kit.ranks,kit.tiers,kit.rank_bonus,ui.system_keys])
	if signature!=ui.bar_signature:
		ui.bar_signature=signature
		for child in ui.ability_bar.get_children(): ui.ability_bar.remove_child(child); child.queue_free()
		ui.ability_labels.clear(); ui.ability_recharge.clear(); ui.ability_shades.clear(); ui.consumable_counts.clear()
		ui._surface(ui.ability_bar,Rect2(269,419,653,103),Color("14242ce8"),2)
		for key in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
			var p: Vector2=Vector2(343,426)+POS[key]*0.55
			if key in BotKeyboard.MOVEMENT: p=Vector2(742+BotKeyboard.MOVEMENT.find(key)*44,473)
			var tile=ui._surface(ui.ability_bar,Rect2(p,Vector2(37,39)),ui.PANEL,1)
			var slot:=BotKeyboard.slot_at(kit,key)
			tile.mouse_filter=Control.MOUSE_FILTER_STOP
			if slot!="":
				ui._ability_icon(tile,BotKeyboard.id_at(kit,slot),Rect2(2,1,33,33))
				tile.tooltip_text=description(kit,slot)
			var shade:=ColorRect.new(); shade.color=Color("07121a99"); shade.size=Vector2(35,34); shade.position=Vector2.ONE; shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; tile.add_child(shade)
			ui.ability_shades[key]=shade
			ui._label(tile,OS.get_keycode_string(key),Rect2(2,0,20,15),10,ui.CREAM,true)
			ui.ability_labels[key]=ui._label(tile,"",Rect2(6,17,30,18),11,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
			ui.ability_recharge[key]=ui._bar(tile,Rect2(2,35,33,2),ui.TEAL,1)
		for entry in [["settings",Vector2(282,430)],["build",Vector2(282,475)],["attack",Vector2(326,475)],["center",Vector2(622,475)]]:
			ui._label(ui.ability_bar,OS.get_keycode_string(ui.system_keys[entry[0]]),Rect2(entry[1],Vector2(64,30)),10,ui.MUTED,true)
		for i in range(2):
			var tile=ui._surface(ui.ability_bar,Rect2(853,432+i*42,53,32),ui.PANEL,1)
			ui._ability_icon(tile,"repair_channel" if i==0 else "converter",Rect2(12,2,28,28))
			ui._label(tile,str(i+5),Rect2(1,1,12,18),10,ui.CREAM,true)
			ui.consumable_counts.append(ui._label(tile,"",Rect2(40,8,12,18),10,ui.GOLD,true))
	for key in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
		var slot:=BotKeyboard.slot_at(kit,key)
		var text_value: String=""
		var shade:=slot==""; var progress:=0.0
		if slot!="":
			if slot.begins_with("p"):
				var id:=BotKeyboard.id_at(kit,slot)
				shade=not kit.passive_active(id); progress=0 if shade else 1
				text_value="OFF" if shade else ({"bolt":"SNP" if kit.gun_sniper else "MG","orbit":"FAR" if kit.orbit_far else "NEAR","lightning":"LONG" if kit.arc_focused else "FAST","poison":"ON"}.get(id,"ON"))
			else:
				shade=kit.charges[slot]==0 or kit.energy<kit.ability_cost(kit.loadout[slot])
				text_value=str(ceili(kit.recharge[slot])) if kit.charges[slot]==0 else (str(kit.charges[slot]) if MobaKit.ABILITIES[kit.loadout[slot]].max>1 else "")
				progress=1-kit.recharge[slot]/kit.cooldown(slot)
				if kit.extra.recasts.has(slot): text_value="↻"; shade=false
				if kit.laser_left>0 and slot==kit.laser_slot: text_value="%.1f"%kit.laser_left
		ui.ability_shades[key].visible=shade; ui.ability_labels[key].text=text_value; ui.ability_recharge[key].value=progress
	for i in range(2): ui.consumable_counts[i].text=str(run.consumables[i])

static func overview(ui, run) -> void:
	var arrange: Button=ui._button("Arrange skills",Rect2(49,110,340,35),func() -> void: ui.keyboard_requested.emit(),false)
	if Vanguard.enabled(run): arrange.visible=false
	arrange.disabled=run.exp.revised and run.state!="camp" and not run.exp.practice
	arrange.tooltip_text="Available between rounds" if arrange.disabled else "Swap bindings or fit stored skills. Learned tools keep their ranks."
	for i in range((BotKeyboard.GENERAL+BotKeyboard.MOVEMENT).size()):
		var key: int=(BotKeyboard.GENERAL+BotKeyboard.MOVEMENT)[i]
		var slot:=BotKeyboard.slot_at(run.kit,key)
		var tile=ui._surface(ui.overlay,Rect2(49+(i%4)*84,164+(i/4)*76,65,61),ui.PANEL,1)
		if slot!="":
			ui._ability_icon(tile,BotKeyboard.id_at(run.kit,slot),Rect2(9,5,48,48))
			tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=description(run.kit,slot)
		ui._label(tile,OS.get_keycode_string(key),Rect2(2,0,30,20),11,ui.CREAM,true)
	for i in range(run.equipment_snapshot.size()):
		var item: Dictionary=run.equipment_snapshot[i]
		var tile=ui._surface(ui.overlay,Rect2(49+i*44,435,40,44),ui.PANEL,1)
		ui._ability_icon(tile,item.icon,Rect2(2,2,36,36)); tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=item.name+"\n"+item.stats
	var rows: Array=[["Hull","%d / %d"%[run.health,run.max_health()]],["Energy","%d / %d"%[run.kit.energy,run.kit.energy_max()]],["Resistance","%.0f"%run.exp.resistance],["Move speed","%.0f"%run.stats().move_speed],["Energy / sec","%+.1f"%(run.kit.energy_regen()-run.kit.drain_rate())],["Pickup reach","%.0f"%run.stats().magnet_radius]]
	for i in range(rows.size()):
		ui._label(ui.overlay,rows[i][0],Rect2(500,123+i*51,226,27),16,ui.MUTED)
		ui._label(ui.overlay,rows[i][1],Rect2(730,123+i*51,168,27),19,ui.CREAM,true,HORIZONTAL_ALIGNMENT_RIGHT)
		ui._rule(Vector2(500,159+i*51),398)
	ui._label(ui.overlay,"%d field credits"%run.exp.field_credits,Rect2(500,456,398,25),14,ui.GOLD,false,HORIZONTAL_ALIGNMENT_RIGHT)

static func settings(ui) -> void:
	ExpeditionView.frame(ui,"Settings",func() -> void: ui.settings_closed.emit())
	for i in range(2):
		var page: String=["options","controls"][i]
		ui._tab(page.capitalize(),Rect2(490+i*153,43,140,34),func() -> void:
			ui.settings_page=page; ui.rebind_system=""; ui.show_settings(),ui.settings_page==page)
	if ui.settings_page=="controls":
		var names: Dictionary={"attack":"Attack move","center":"Recenter camera","build":"Build","settings":"Settings"}
		for i in range(names.size()):
			var action: String=names.keys()[i]
			ui._label(ui.overlay,names[action],Rect2(165,145+i*65,370,30),19,ui.CREAM)
			ui._button("Press key…" if ui.rebind_system==action else OS.get_keycode_string(ui.system_keys[action]),Rect2(579,140+i*65,206,37),func() -> void:
				ui.rebind_system=action; ui.show_settings(),false)
		ui._label(ui.overlay,"Right-click: move / target     S: stop     Wheel: zoom",Rect2(165,415,680,28),14,ui.MUTED)
		ui._label(ui.overlay,"L: camera lock     5 / 6: consumables",Rect2(165,446,680,28),14,ui.MUTED)
	else:
		var game=ui.host
		var rows: Array=[
			["Sound","Off" if ui.muted else "On",func() -> void: ui.mute_changed.emit(not ui.muted)],
			["Reduced effects","On" if ui.reduced else "Off",func() -> void: ui.effects_changed.emit(not ui.reduced)],
			["Camera lock","On" if ui.camera_locked else "Off",func() -> void: ui.camera_lock_changed.emit(not ui.camera_locked)],
			["Area quick cast","On" if ui.r_quickcast else "Off",func() -> void: ui.quickcast_changed.emit(not ui.r_quickcast)],
			["Fullscreen","On" if game.fullscreen_setting else "Off",game.toggle_fullscreen],
			["Icon skin","Painted" if PaintedIcons.enabled else "Base",game.toggle_skin]]
		for i in range(rows.size()):
			ui._label(ui.overlay,rows[i][0],Rect2(165,130+i*52,350,30),19,ui.CREAM)
			ui._button(rows[i][1],Rect2(615,126+i*52,170,36),rows[i][2],false)
	if ui.settings_in_run: ui._button("Main menu",Rect2(725,468,186,33),func() -> void: ui.host.confirm_leave(),false)
