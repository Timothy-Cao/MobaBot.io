class_name ReviewView
extends RefCounted

static func upgrade_hint(run, slot: String) -> String:
	return UpgradePreview.text(run,slot)

static func overview(ui, run) -> void:
	var slots: Array=ReviewRules.CORE+ReviewRules.MODULES
	for i in range(slots.size()):
		var slot: String=slots[i]
		var at:=Vector2(48+(i%4)*98,128+(i/4)*98)
		var tile=ui._surface(ui.overlay,Rect2(at,Vector2(84,80)),ui.PANEL,1)
		ui._ability_icon(tile,VanguardHud.icon(slot,run),Rect2(17,5,50,50))
		ui._label(tile,"MG" if slot=="gun" else "LMB" if slot=="hammer" else OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(3,0,38,19),11,ui.CREAM,true)
		ui._label(tile,"Rank %d"%Vanguard.rank_of(run,slot) if Vanguard.rank_of(run,slot)>0 else "Shop" if slot in ReviewRules.MODULES else "Unlearned",Rect2(2,57,80,22),12,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=VanguardHud.detail(run,slot)
	var rows: Array=[["Hull","%d / %d"%[run.health,run.max_health()]],["Energy","%d / %d"%[run.kit.energy,run.kit.energy_max()]],["Resistance","%.0f"%run.exp.resistance],["Move speed","%.0f"%run.kit.speed()],["Energy / second","%.1f"%(run.kit.energy_regen()-run.kit.drain_rate())],["Field credits",str(run.exp.field_credits)]]
	if DiscoveryRules.enabled(run):
		rows.append(["XP bonus","+%.0f%%"%(((1.0+float(run.exp.stats.get("xp",0)))*(1.0+DiscoveryRules.rank_of(run,"xp_gain")*0.1)-1)*100)])
		rows.append(["Pickup reach","%.0f"%run.magnet_radius()])
	for i in range(rows.size()):
		ui._label(ui.overlay,rows[i][0],Rect2(490,126+i*49,270,27),16,ui.MUTED)
		ui._label(ui.overlay,rows[i][1],Rect2(760,126+i*49,145,27),17,ui.CREAM,true,HORIZONTAL_ALIGNMENT_RIGHT)

static func build(ui, run) -> void:
	var page: String="Mastery" if ui.build_page=="mastery" else "Equipment" if ui.build_page=="gear" else "Build"
	ExpeditionView.frame(ui,page,func(): ui.build_closed.emit())
	for i in range(4):
		var name: String=["Round clear","Build","Mastery","Equipment"][i]
		var button: Button=ui._tab(name,Rect2(299+i*124,43,119,34),func():
			ui.build_page="mastery" if name=="Mastery" else "gear" if name=="Equipment" else "overview"
			ui.show_build(run,false),page==name)
		button.disabled=i==0
	if page=="Mastery": ExpeditionView.mastery(ui,run)
	elif page=="Build": overview(ui,run)
	else:
		for i in range(run.equipment_snapshot.size()):
			var item: Dictionary=run.equipment_snapshot[i]
			var at:=Vector2(48+(i%4)*218,124+(i/4)*150)
			var card=ui._surface(ui.overlay,Rect2(at,Vector2(208,132)),ui.PANEL,1)
			ui._ability_icon(card,item.icon,Rect2(12,12,54,54))
			var label: Label=ui._label(card,item.name,Rect2(76,12,124,55),15,ui.CREAM,true); label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			ui._label(card,"Tier %d"%item.tier,Rect2(12,83,180,25),15,ui.GOLD)
			card.mouse_filter=Control.MOUSE_FILTER_STOP; card.tooltip_text=item.stats

static func upgrades(ui, run) -> void:
	ui.clear_overlay(); ui.hud.visible=true
	var dim:=ColorRect.new(); dim.color=Color(0.035,0.07,0.10,0.38)
	ui.overlay.add_child(dim); dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui._label(ui.overlay,"Choose an upgrade",Rect2(132,100,696,35),25,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
	ui._label(ui.overlay,"1 pick left" if run.kit.loadout.rewards18.size()==1 else "%d picks left"%run.kit.loadout.rewards18.size(),Rect2(132,135,696,24),14,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
	for i in range(run.offers.size()):
		var slot: String=run.offers[i]
		if slot in DiscoveryRules.BONUS or slot in ["field_credit","full_heal"]:
			FieldUpgradeCard.draw(ui,run,slot,i); continue
		var rank_value:=Vanguard.rank_of(run,slot)
		var name: String=slot.capitalize() if slot in ["gun","hammer"] else MobaKit.ABILITIES[Vanguard.TOOLS[slot]].name
		var card: Button=ui._button("",Rect2(132+i*236,173,224,244),func(): ui.upgrade_selected.emit(i),false)
		card.set_meta("review_choice",slot)
		var next:=rank_value+1
		var accent: Color=Color("c4a1e8") if next==10 else ui.GOLD
		if next in [5,10]:
			var frame: Control=ui._surface(card,Rect2(0,0,224,244),Color.TRANSPARENT,2,accent,2)
			frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ui._ability_icon(card,VanguardHud.icon(slot,run),Rect2(88,12,48,48))
		var binding: String="LMB" if slot=="hammer" else "`" if slot=="gun" else OS.get_keycode_string(Vanguard.KEYS[slot])
		var key_badge: Control=ui._surface(card,Rect2(147,22,62,28),ui.INK,4,ui.TEAL,1)
		key_badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ui._label(key_badge,binding,Rect2(0,0,62,28),18,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card,name,Rect2(8,65,208,26),17,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card,"Level %d / 10"%next,Rect2(8,94,208,20),13,accent,true,HORIZONTAL_ALIGNMENT_CENTER)
		for step in range(1,11):
			var edge: Color=Color("c4a1e8") if step==10 else ui.GOLD if step==5 else ui.EDGE
			var cell: Control=ui._surface(card,Rect2(17+(step-1)*19,119,16,9),ui.TEAL if step<=rank_value else accent if step==next else ui.INK,0,edge,1)
			cell.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var changes:=UpgradePreview.text(run,slot,false).split("\n")
		for row in range(changes.size()):
			ui._label(card,changes[row],Rect2(15,138+row*17,194,17),12,ui.CREAM)
		var bonus:=UpgradePreview.milestone(slot,mini(10,rank_value+run.kit.rank_bonus),mini(10,next+run.kit.rank_bonus),SupportModules.enabled(run),ArsenalBurst.enabled(run))
		if next in [5,10] or not bonus.is_empty():
			var label: Label=ui._label(card,bonus if not bonus.is_empty() else "",Rect2(15,211,194,30),12,accent,true)
			label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text=VanguardHud.detail(run,slot)
		if i==0: card.grab_focus()
	ui._label(ui.overlay,"1 / 2 / 3",Rect2(132,430,696,22),13,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)

static func tabs(game) -> void:
	var names: Array=["Round clear","Build","Mastery","Equipment"]
	for i in range(names.size()):
		var tab: String=names[i]
		game.ui._tab(tab,Rect2(299+i*124,43,119,34),func():
			game.review_tab=tab; game.screen="camp"; camp(game),game.review_tab==tab)
	game.ui._button("Finish level" if game.model.exp.final_round() else "Next round",Rect2(745,88,167,32),game.continue_expedition).set_meta("continue_round",true)

static func camp(game) -> void:
	var ui=game.ui; var run=game.model; var exp=run.exp
	if game.review_tab=="Equipment":
		game.gear_return="camp"; ForgeView.draw(game); return
	ExpeditionView.frame(ui,game.review_tab,game.show_home)
	tabs(game)
	if game.review_tab=="Build":
		overview(ui,run); return
	if game.review_tab=="Mastery":
		ExpeditionView.mastery(ui,run); return
	ui._label(ui.overlay,exp.label(),Rect2(48,95,360,30),17,ui.TEAL,true)
	ui._label(ui.overlay,"%d field credits"%exp.field_credits,Rect2(452,95,263,30),16,ui.GOLD,true,HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay,"Recovered" if DiscoveryRules.enabled(run) else "Recovered · %d chests"%exp.reward_receipt.chests,Rect2(48,133,760,24),14,ui.MUTED)
	var receipt:=LootReceipt.new(); receipt.name="RoundReceipt"; receipt.position=Vector2(48,165); receipt.size=Vector2(856,108)
	ui.overlay.add_child(receipt); receipt.build(ui,exp.reward_receipt,false,true)
	ui._label(ui.overlay,"Modules",Rect2(48,274,400,22),14,ui.MUTED,true)
	for i in range(4):
		var slot: String=ReviewRules.MODULES[i]
		var rank_value:=Vanguard.rank_of(run,slot)
		var price:=ReviewRules.module_price(run,slot)
		var card: Button=ui._button("",Rect2(48+i*218,302,208,151),func(): game.buy_review_module(slot),false)
		card.set_meta("module_purchase",slot)
		card.disabled=rank_value>=10 or exp.field_credits<price or game.collection.blocked
		var module_icon: Control=ui._ability_icon(card,VanguardHud.icon(slot,run),Rect2(13,14,56,56))
		if card.disabled: module_icon.modulate=Color(0.65,0.7,0.7)
		var title: String="Orbit" if slot=="p1" else MobaKit.ABILITIES[Vanguard.TOOLS[slot]].name
		if SupportModules.enabled(run) and slot in ["x1","x3"]: title=SupportModules.title(slot)
		if ArsenalBurst.enabled(run) and slot=="x3": title="Missile Barrage"
		var text_color: Color=ui.MUTED if card.disabled else ui.CREAM
		var accent: Color=ui.MUTED if card.disabled else ui.TEAL if rank_value>0 else ui.GOLD
		var title_label: Label=ui._label(card,title,Rect2(80,14,118,43),15,text_color,true)
		title_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var key=ui._surface(card,Rect2(80,58,24,18),ui.INK,0,ui.EDGE,1)
		key.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ui._label(key,OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(0,0,24,18),11,text_color,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card,"%d / 10"%rank_value,Rect2(118,57,75,19),11,ui.MUTED,false,HORIZONTAL_ALIGNMENT_RIGHT)
		for step in range(10):
			var pip=ui._surface(card,Rect2(14+step*18,83,14,6),accent if step<rank_value else ui.INK,0,ui.EDGE,1)
			pip.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var footer=ui._surface(card,Rect2(9,105,190,37),ui.INK,0)
		footer.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ui._label(footer,"Max" if rank_value>=10 else "Buy" if rank_value==0 else "Upgrade",Rect2(9,5,95,26),14,text_color,true)
		ui._label(footer,"10 / 10" if rank_value>=10 else str(price),Rect2(98,5,82,26),15,accent,true,HORIZONTAL_ALIGNMENT_RIGHT)
		card.tooltip_text=VanguardHud.detail(run,slot)+"\nRun-only purchase. Resets next level."
	if exp.is_shop(true):
		for i in range(exp.shop_stock.size()):
			var id: String=exp.shop_stock[i]
			var label: String="Sold" if id=="" else "%s · %d"%[ForgeEquipment.ITEMS[id].name,100+ForgeEquipment.ITEMS[id].tier*100]
			var card: Button=ui._button(label,Rect2(48+i*292,463,278,30),func(): game.buy_item(i),false)
			card.add_theme_font_size_override("font_size",12)
			card.disabled=id=="" or game.collection.blocked or exp.field_credits<(100+ForgeEquipment.ITEMS[id].tier*100 if id!="" else 0)
			card.tooltip_text="Permanent equipment · "+(game.collection.item_text(id) if id!="" else "Sold")
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,496,850,18),12,ui.CORAL)
