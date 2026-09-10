class_name VanguardHud
extends RefCounted

const SLOT_X := {"p1":150,"x1":204,"x2":258,"x3":312,"q":390,"w":450,"e":510,"r":570,"d":658,"f":712,"hammer":794,"gun":848}

static func slot_rect(slot: String) -> Rect2:
	var core: bool=slot in ["q","w","e","r"]
	var width: float=54 if core else 48
	return Rect2(SLOT_X[slot],470 if core else 476,width,width)

static func icon(slot: String) -> String:
	return "vanguard_"+slot

static func detail(run, slot: String) -> String:
	if slot=="hammer": return "Hammer · Rank %d\n%.0f head damage · %.0f reach\n5: wider sweep. 10: swing while moving."%[Vanguard.hammer_rank(run),run.attacks.damage(run),run.attacks.attack_range(run)]
	if slot=="gun": return "Machine gun · Rank %d\n%.2f damage · %.2f shots/sec\n5: fires during E / Ghost drive.\n10: every fifth shot deals 2× damage, reaches 450 and hits up to four targets.\nAlso upgrades Bulwark's gun. `: toggle; S never disables it."%[Vanguard.gun_rank(run),run.attacks.auto_damage(run),1/run.attacks.auto_interval(run)]
	if slot=="p1": return "Orbit tools\n1: close / far. Always fast. 2 energy/sec.\nPermanent blades. Rank increases damage and blade count."
	if slot=="x1": return "Bulwark\nGun damage, speed and fifth shot use MG rank.\nBulwark ranks improve hull and pulse.\n%.1fs recharge · 20 energy"%run.kit.cooldown(slot)
	if slot=="d": return "Ghost drive\nHold D: +%.0f%% speed, %.1f energy/sec. Release to cast.\nNo invulnerability. The gun and deployed machines continue."%[65+maxi(0,run.kit.effective_rank("d")-1)*3.5,10-maxi(0,run.kit.effective_rank("d")-1)*0.3]
	if slot=="w": return "Core strike · 2 charges\n38 base edge damage / 76 center. 100 radius; 40 center.\nRank 5: wider impact. Rank 10: brief stun.\n%.1fs per charge · 18 energy"%run.kit.cooldown("w")
	if slot=="q": return "Impact bolt · 2 charges\nStraight rocket with contact/range explosion.\n%.1fs per charge"%run.kit.cooldown("q")
	if slot=="e": return "Body slam · 2 charges\nCollide, blast and push. Walls rebound you for 2× remaining dash distance, once per cast.\n%.1fs per charge"%run.kit.cooldown("e")
	if slot=="f": return "Phase hop\nInstant blink. 80ms unreleased casts follow your new origin.\nPast the midpoint of thick cover: land on the far side."
	var data: Dictionary=MobaKit.ABILITIES[Vanguard.TOOLS[slot]]
	return data.name+"\n"+data.text+"\n%.1fs recharge · %d energy"%[run.kit.cooldown(slot),run.kit.ability_cost(Vanguard.TOOLS[slot])]

static func draw(ui, run) -> void:
	var modified: bool=run.exp.practice and (run.exp.god_mode or run.exp.free_energy or run.exp.fast_cooldowns or run.vanguard.freeze_ai or run.vanguard.time_scale!=1)
	var signature:=JSON.stringify(["v18",run.kit.loadout.get("hammer_rank",1),run.kit.ranks,run.kit.discovered,run.upgrades.power,run.upgrades.grinder,Vanguard.reward_kind(run),run.kit.loadout.rewards18.size(),PaintedIcons.enabled,modified])
	var slots: Array=["hammer","gun","p1","x1","x2","x3","q","w","e","r","d","f"]
	if ui.bar_signature!=signature:
		ui.bar_signature=signature
		for child in ui.ability_bar.get_children(): ui.ability_bar.remove_child(child); child.queue_free()
		ui.ability_labels.clear(); ui.ability_shades.clear(); ui.ability_recharge.clear()
		# Central QWER rail, grouped modules and quieter flanking tools.
		ui._surface(ui.ability_bar,Rect2(141,470,228,61),Color("14242cdd"),0,ui.INK,0)
		ui._surface(ui.ability_bar,Rect2(381,464,252,67),Color("14242cf2"),0,ui.EDGE,1)
		ui._surface(ui.ability_bar,Rect2(381,529,252,2),ui.GOLD,0,ui.GOLD,0)
		ui._surface(ui.ability_bar,Rect2(649,470,120,61),Color("14242cdd"),0,ui.INK,0)
		ui._surface(ui.ability_bar,Rect2(785,470,120,61),Color("14242cdd"),0,ui.INK,0)
		var kind:=Vanguard.reward_kind(run)
		ui._label(ui.ability_bar,("LEARN" if kind=="learn" else "UPGRADE")+" · %d"%run.kit.loadout.rewards18.size() if kind!="" else "MODIFIED TEST" if modified else "",Rect2(381,428,252,17),11,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		for i in range(slots.size()):
			var slot: String=slots[i]
			var rect:=slot_rect(slot)
			var x: float=rect.position.x
			var width: float=rect.size.x
			var y: float=rect.position.y
			var tile=ui._surface(ui.ability_bar,Rect2(x,y,width,width),ui.PANEL,0,ui.EDGE)
			tile.set_meta("vanguard_slot",slot)
			tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=detail(run,slot)
			ui._ability_icon(tile,icon(slot),Rect2(2,2,width-4,width-4))
			var shade:=ColorRect.new(); shade.size=Vector2.ONE*width; shade.color=Color("14242cbb"); shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; tile.add_child(shade)
			ui.ability_shades[slot]=shade
			if slot in ["p1","x1","x2","x3"]:
				var active=preload("res://src/salvage/active_icon.gd").new()
				active.name="Active"; active.size=Vector2.ONE*width; tile.add_child(active)
			ui._label(tile,"LMB" if slot=="hammer" else "MG" if slot=="gun" else OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(2,0,width,17),11,ui.CREAM,true)
			ui._label(tile,str(Vanguard.rank_of(run,slot)),Rect2(width-17,width-16,15,15),10,ui.GOLD,true)
			ui.ability_labels[slot]=ui._label(tile,"",Rect2(0,width*0.38,width,20),12,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
			if slot in ["q","w","e"]: ui.ability_recharge[slot]=ui._label(tile,"",Rect2(4,width-16,30,14),9,ui.GOLD,true)
			for child in tile.get_children():
				if child is Label:
					child.add_theme_color_override("font_outline_color",ui.INK)
					child.add_theme_constant_override("outline_size",3)
			if slot in Vanguard.candidates(run,kind) and kind!="":
				var button: Button=ui._button("+",Rect2(x,y-20,width,16),func(): Vanguard.spend(run,slot),true)
				button.reparent(ui.ability_bar,false)
				button.set_meta("vanguard_upgrade",slot)
				button.add_theme_font_size_override("font_size",12)
				for state in ["normal","hover","pressed","focus"]:
					var style:=StyleBoxFlat.new(); style.bg_color=ui.GOLD if state!="hover" else ui.CREAM
					style.set_content_margin_all(0); style.set_border_width_all(1); style.border_color=ui.EDGE
					button.add_theme_stylebox_override(state,style)
				button.custom_minimum_size=Vector2.ZERO; button.size=Vector2(width,16)
				button.tooltip_text=("Learn " if kind=="learn" else "Upgrade ")+ (slot if slot in ["gun","hammer"] else OS.get_keycode_string(Vanguard.KEYS[slot])) + (" · Ctrl + key" if slot not in ["gun","hammer"] else "")
	for slot in slots:
		var locked:=Vanguard.rank_of(run,slot)==0
		var cd: float=run.kit.recharge.get(slot,0)
		var empty: bool=run.kit.charges.get(slot,1)<=0
		ui.ability_shades[slot].visible=locked or empty
		ui.ability_labels[slot].text="—" if locked else (str(ceili(cd)) if empty else "")
		if slot in ["p1","x1","x2","x3"]:
			var active=ui.ability_shades[slot].get_parent().get_node("Active")
			active.active=not locked and (run.kit.passive_active("orbit") if slot=="p1" else run.vanguard.constructs.any(func(unit): return unit.slot==slot))
			active.reduced=ui.reduced
			if active.active: ui.ability_shades[slot].visible=false; ui.ability_labels[slot].text=""
		if slot=="d": ui.ability_labels[slot].text="ON" if run.vanguard.ghost else ""
		if slot=="gun":
			ui.ability_labels[slot].text="OFF" if not run.vanguard.gun_on else "PAUSE" if Vanguard.gun_paused(run) else "%d/5"%(run.vanguard.gun_shots%5+1) if Vanguard.gun_rank(run)>=10 else ""
			ui.ability_shades[slot].visible=not run.vanguard.gun_on
		if slot in ["q","w","e"]:
			ui.ability_recharge[slot].text="" if locked else ["○○","●○","●●"][clampi(run.kit.charges[slot],0,2)]
