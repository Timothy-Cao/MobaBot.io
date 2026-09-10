class_name VanguardHud
extends RefCounted

static func icon(slot: String) -> String:
	return {"gun":"bolt","p1":"orbit","e":"thrust","r":"nuke","x1":"pulse_sentry","x2":"medic_sentry","x3":"converter"}.get(slot,Vanguard.TOOLS.get(slot,"bolt"))

static func detail(run, slot: String) -> String:
	if slot=="gun": return "Permanent machine gun\nIndependent of movement, S and D.\n%.1f damage · %.2f shots/sec\nUpgrade here during an upgrade opportunity."%[run.attacks.auto_damage(run),1/run.attacks.auto_interval(run)]
	if slot=="p1": return "Orbit tools\n1: close / fast or far / slow. 2 energy/sec.\nPermanent blades. Rank increases damage and blade count."
	if slot=="d": return "Ghost drive\nHold D: +%.0f%% speed, %.1f energy/sec. Release to cast.\nNo invulnerability. The gun and deployed machines continue."%[65+maxi(0,run.kit.effective_rank("d")-1)*3.5,10-maxi(0,run.kit.effective_rank("d")-1)*0.3]
	if slot=="w": return "Core strike\n38 base edge damage / 76 center. 100 radius; 40 center.\nRank 5: stores two charges. Rank 10: brief stun.\n%.1fs recharge · 18 energy"%run.kit.cooldown("w")
	if slot=="f": return "Phase hop\nInstant blink. 80ms unreleased casts follow your new origin.\nPast the midpoint of thick cover: land on the far side."
	var data: Dictionary=MobaKit.ABILITIES[Vanguard.TOOLS[slot]]
	return data.name+"\n"+data.text+"\n%.1fs recharge · %d energy"%[run.kit.cooldown(slot),run.kit.ability_cost(Vanguard.TOOLS[slot])]

static func draw(ui, run) -> void:
	var modified: bool=run.exp.practice and (run.exp.god_mode or run.exp.free_energy or run.exp.fast_cooldowns or run.vanguard.freeze_ai or run.vanguard.time_scale!=1)
	var signature:=JSON.stringify(["v18",run.kit.ranks,run.kit.discovered,run.upgrades.power,run.upgrades.grinder,Vanguard.reward_kind(run),run.kit.loadout.rewards18.size(),PaintedIcons.enabled,modified])
	var slots: Array=["gun","p1","x1","x2","x3","q","w","e","r","d","f"]
	if ui.bar_signature!=signature:
		ui.bar_signature=signature
		for child in ui.ability_bar.get_children(): ui.ability_bar.remove_child(child); child.queue_free()
		ui.ability_labels.clear(); ui.ability_shades.clear(); ui.ability_recharge.clear()
		ui._surface(ui.ability_bar,Rect2(178,435,744,89),Color("14242cf2"),0)
		var kind:=Vanguard.reward_kind(run)
		ui._label(ui.ability_bar,("LEARN" if kind=="learn" else "UPGRADE")+" · %d"%run.kit.loadout.rewards18.size() if kind!="" else "MODIFIED TEST" if modified else "VANGUARD",Rect2(185,418,400,17),11,ui.GOLD,true)
		for i in range(slots.size()):
			var slot: String=slots[i]
			var core: bool=slot in ["q","w","e","r"]
			var x: float=[188,233,278,323,368,429,499,569,639,744,799][i]
			var width: float=62 if core else 39
			var y: float=450 if core else 465
			var tile=ui._surface(ui.ability_bar,Rect2(x,y,width,width),ui.PANEL,0,ui.EDGE)
			tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=detail(run,slot)
			ui._ability_icon(tile,icon(slot),Rect2(2,2,width-4,width-4))
			var shade:=ColorRect.new(); shade.size=Vector2.ONE*width; shade.color=Color("14242cbb"); shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; tile.add_child(shade)
			ui.ability_shades[slot]=shade
			ui._label(tile,"MG" if slot=="gun" else OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(2,0,width,17),11,ui.CREAM,true)
			ui._label(tile,str(Vanguard.rank_of(run,slot)),Rect2(width-17,width-16,15,15),10,ui.GOLD,true)
			ui.ability_labels[slot]=ui._label(tile,"",Rect2(0,width*0.38,width,20),12,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
			if slot in Vanguard.candidates(run,kind) and kind!="":
				var button: Button=ui._button("+",Rect2(x+width-18,y-9,20,20),func(): Vanguard.spend(run,slot),true)
				button.reparent(ui.ability_bar,false)
				button.add_theme_font_size_override("font_size",14)
				for state in ["normal","hover","pressed","focus"]:
					var style:=StyleBoxFlat.new(); style.bg_color=ui.GOLD if state!="hover" else ui.CREAM
					style.set_content_margin_all(0); style.set_border_width_all(1); style.border_color=ui.EDGE
					button.add_theme_stylebox_override(state,style)
				button.custom_minimum_size=Vector2.ZERO; button.size=Vector2(20,20)
				button.tooltip_text=("Learn " if kind=="learn" else "Upgrade ")+ ("machine gun" if slot=="gun" else OS.get_keycode_string(Vanguard.KEYS[slot])) + (" · Ctrl + key" if slot!="gun" else "")
		ui._label(ui.ability_bar,"MODULES",Rect2(231,437,180,15),9,ui.MUTED,true)
		ui._label(ui.ability_bar,"CORE",Rect2(429,437,100,15),9,ui.MUTED,true)
		ui._label(ui.ability_bar,"MOBILITY",Rect2(744,437,120,15),9,ui.MUTED,true)
		for i in range(2):
			var item: Button=ui._button(str(5+i),Rect2(867,456+i*27,33,23),func(): run.use_consumable(i),false)
			item.reparent(ui.ability_bar,false); item.add_theme_font_size_override("font_size",11)
			item.tooltip_text="Repair hull" if i==0 else "Restore energy"
	for slot in slots:
		var locked:=Vanguard.rank_of(run,slot)==0
		var cd: float=run.kit.recharge.get(slot,0)
		var empty: bool=run.kit.charges.get(slot,1)<=0
		ui.ability_shades[slot].visible=locked or empty
		ui.ability_labels[slot].text="—" if locked else (str(ceili(cd)) if empty else ("FAR" if run.kit.orbit_far else "NEAR") if slot=="p1" else "")
		if slot=="d": ui.ability_labels[slot].text="ON" if run.vanguard.ghost else ""
