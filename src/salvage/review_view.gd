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
		ui._ability_icon(tile,VanguardHud.icon(slot),Rect2(17,5,50,50))
		ui._label(tile,"MG" if slot=="gun" else "LMB" if slot=="hammer" else OS.get_keycode_string(Vanguard.KEYS[slot]),Rect2(3,0,38,19),11,ui.CREAM,true)
		ui._label(tile,"Rank %d"%Vanguard.rank_of(run,slot) if Vanguard.rank_of(run,slot)>0 else "Shop" if slot in ReviewRules.MODULES else "Unlearned",Rect2(2,57,80,22),12,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		tile.mouse_filter=Control.MOUSE_FILTER_STOP; tile.tooltip_text=VanguardHud.detail(run,slot)
	var rows: Array=[["Hull","%d / %d"%[run.health,run.max_health()]],["Energy","%d / %d"%[run.kit.energy,run.kit.energy_max()]],["Resistance","%.0f"%run.exp.resistance],["Move speed","%.0f"%run.kit.speed()],["Energy / second","%.1f"%(run.kit.energy_regen()-run.kit.drain_rate())],["Field credits",str(run.exp.field_credits)]]
	for i in range(rows.size()):
		ui._label(ui.overlay,rows[i][0],Rect2(490,126+i*49,270,27),16,ui.MUTED)
		ui._label(ui.overlay,rows[i][1],Rect2(760,126+i*49,145,27),17,ui.CREAM,true,HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay,"Hover a tool for mechanics and milestones",Rect2(48,461,760,25),14,ui.MUTED)

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
		ui._label(ui.overlay,"Change equipment between rounds",Rect2(48,461,760,25),14,ui.MUTED)

static func upgrades(ui, run) -> void:
	ui.clear_overlay(); ui.hud.visible=false; ui._dim()
	ui._panel(Rect2(24,24,912,492),ui.PANEL)
	ui._label(ui.overlay,"Choose an upgrade",Rect2(48,42,650,42),28,ui.CREAM,true)
	ui._label(ui.overlay,"Level %d · %d pick%s remaining · Combat paused"%[run.level,run.kit.loadout.rewards18.size(),"" if run.kit.loadout.rewards18.size()==1 else "s"],Rect2(48,93,850,26),16,ui.GOLD)
	for i in range(run.offers.size()):
		var slot: String=run.offers[i]
		var rank_value:=Vanguard.rank_of(run,slot)
		var name: String=slot.capitalize() if slot in ["gun","hammer"] else MobaKit.ABILITIES[Vanguard.TOOLS[slot]].name
		var card: Button=ui._button("",Rect2(48+i*292,145,276,302),func(): ui.upgrade_selected.emit(i),false)
		card.set_meta("review_choice",slot)
		ui._ability_icon(card,VanguardHud.icon(slot),Rect2(99,24,78,78))
		ui._label(card,name,Rect2(12,121,252,38),21,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card,"Learn" if rank_value==0 else "Rank %d → %d"%[rank_value,rank_value+1],Rect2(12,167,252,28),18,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		var hint: Label=ui._label(card,upgrade_hint(run,slot),Rect2(14,201,248,95),12,ui.MUTED)
		hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text=VanguardHud.detail(run,slot)
		if i==0: card.grab_focus()
	ui._label(ui.overlay,"1 / 2 / 3 to choose · Modules are purchased between rounds",Rect2(48,470,860,22),13,ui.MUTED)

static func tabs(game) -> void:
	var names: Array=["Round clear","Build","Mastery","Equipment"]
	for i in range(names.size()):
		var tab: String=names[i]
		game.ui._tab(tab,Rect2(299+i*124,43,119,34),func():
			game.review_tab=tab; game.screen="camp"; camp(game),game.review_tab==tab)

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
	ui._label(ui.overlay,exp.label(),Rect2(48,95,590,30),19,ui.TEAL,true)
	ui._label(ui.overlay,"%d field credits"%exp.field_credits,Rect2(650,95,260,30),18,ui.GOLD,true,HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay,"Recovered · %d chests"%exp.reward_receipt.chests,Rect2(48,133,760,24),14,ui.MUTED)
	var receipt:=LootReceipt.new(); receipt.name="RoundReceipt"; receipt.position=Vector2(48,165); receipt.size=Vector2(856,128)
	ui.overlay.add_child(receipt); receipt.build(ui,exp.reward_receipt,false,true)
	for i in range(4):
		var slot: String=ReviewRules.MODULES[i]
		var rank_value:=Vanguard.rank_of(run,slot)
		var price:=ReviewRules.module_price(run,slot)
		var card: Button=ui._button("",Rect2(48+i*218,310,208,78),func(): game.buy_review_module(slot),false)
		card.set_meta("module_purchase",slot)
		card.disabled=rank_value>=10 or exp.field_credits<price or game.collection.blocked
		ui._ability_icon(card,VanguardHud.icon(slot),Rect2(8,13,46,46))
		var title: String="Orbit" if slot=="p1" else MobaKit.ABILITIES[Vanguard.TOOLS[slot]].name
		ui._label(card,title,Rect2(62,7,140,26),15,ui.CREAM,true)
		ui._label(card,"Max rank" if rank_value>=10 else "%s · %d"%["Buy" if rank_value==0 else "Rank %d"%(rank_value+1),price],Rect2(62,38,140,25),14,ui.GOLD)
		card.tooltip_text=VanguardHud.detail(run,slot)+"\nRun-only purchase. Resets next Operation."
	if exp.is_shop(true):
		for i in range(exp.shop_stock.size()):
			var id: String=exp.shop_stock[i]
			var label: String="Sold" if id=="" else "%s · %d"%[ForgeEquipment.ITEMS[id].name,100+ForgeEquipment.ITEMS[id].tier*100]
			var card: Button=ui._button(label,Rect2(48+i*292,403,278,35),func(): game.buy_item(i),false)
			card.add_theme_font_size_override("font_size",12)
			card.disabled=id=="" or game.collection.blocked or exp.field_credits<(100+ForgeEquipment.ITEMS[id].tier*100 if id!="" else 0)
			card.tooltip_text="Permanent equipment · "+(game.collection.item_text(id) if id!="" else "Sold")
	ui._button("Finish Operation" if OperationRules.enabled(run) and exp.final_round() else "Finish" if exp.final_round() else "Next round",Rect2(688,458,224,40),game.continue_expedition).grab_focus()
	ui._label(ui.overlay,"%d Salvage banked · Modules reset next Operation"%game.collection.credits if OperationRules.enabled(run) else "Module purchases last this expedition",Rect2(48,460,610,22),13,ui.MUTED)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,490,850,22),12,ui.CORAL)
