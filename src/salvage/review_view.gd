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
	ui.clear_overlay(); ui.hud.visible=true
	var dim:=ColorRect.new(); dim.color=Color(0.035,0.07,0.10,0.38)
	ui.overlay.add_child(dim); dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui._label(ui.overlay,"Choose an upgrade",Rect2(132,100,696,35),25,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
	ui._label(ui.overlay,"Paused · %d picks left"%run.kit.loadout.rewards18.size(),Rect2(132,135,696,24),14,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
	for i in range(run.offers.size()):
		var slot: String=run.offers[i]
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
		ui._label(card,name,Rect2(8,65,208,26),17,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card,"Level %d / 10"%next,Rect2(8,94,208,20),13,accent,true,HORIZONTAL_ALIGNMENT_CENTER)
		for step in range(1,11):
			var edge: Color=Color("c4a1e8") if step==10 else ui.GOLD if step==5 else ui.EDGE
			var cell: Control=ui._surface(card,Rect2(17+(step-1)*19,119,16,9),ui.TEAL if step<=rank_value else accent if step==next else ui.INK,0,edge,1)
			cell.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var changes:=UpgradePreview.text(run,slot,false).split("\n")
		for row in range(changes.size()):
			ui._label(card,changes[row],Rect2(15,138+row*17,194,17),12,ui.CREAM)
		var bonus:=UpgradePreview.milestone(slot,mini(10,rank_value+run.kit.rank_bonus),mini(10,next+run.kit.rank_bonus))
		if next in [5,10] or not bonus.is_empty():
			var label: Label=ui._label(card,bonus if not bonus.is_empty() else "Milestone · stronger stats",Rect2(15,211,194,30),12,accent,true)
			label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text=VanguardHud.detail(run,slot)
		if i==0: card.grab_focus()
	ui._label(ui.overlay,"1 / 2 / 3 · Special levels: 5 and 10",Rect2(132,430,696,22),13,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)

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
	ui._label(ui.overlay,exp.label(),Rect2(48,95,590,30),19,ui.TEAL,true)
	ui._label(ui.overlay,"%d field credits"%exp.field_credits,Rect2(480,95,235,30),18,ui.GOLD,true,HORIZONTAL_ALIGNMENT_RIGHT)
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
		ui._ability_icon(card,VanguardHud.icon(slot,run),Rect2(8,13,46,46))
		var title: String="Orbit" if slot=="p1" else MobaKit.ABILITIES[Vanguard.TOOLS[slot]].name
		if SupportModules.enabled(run) and slot in ["x1","x3"]: title=SupportModules.title(slot)
		ui._label(card,title,Rect2(62,7,140,26),15,ui.CREAM,true)
		ui._label(card,"Max rank" if rank_value>=10 else "%s · %d"%["Buy" if rank_value==0 else "Rank %d"%(rank_value+1),price],Rect2(62,38,140,25),14,ui.GOLD)
		card.tooltip_text=VanguardHud.detail(run,slot)+"\nRun-only purchase. Resets next level."
	if exp.is_shop(true):
		for i in range(exp.shop_stock.size()):
			var id: String=exp.shop_stock[i]
			var label: String="Sold" if id=="" else "%s · %d"%[ForgeEquipment.ITEMS[id].name,100+ForgeEquipment.ITEMS[id].tier*100]
			var card: Button=ui._button(label,Rect2(48+i*292,403,278,35),func(): game.buy_item(i),false)
			card.add_theme_font_size_override("font_size",12)
			card.disabled=id=="" or game.collection.blocked or exp.field_credits<(100+ForgeEquipment.ITEMS[id].tier*100 if id!="" else 0)
			card.tooltip_text="Permanent equipment · "+(game.collection.item_text(id) if id!="" else "Sold")
	ui._label(ui.overlay,"%d Salvage banked · Modules reset next level"%game.collection.credits if OperationRules.enabled(run) else "Module purchases last this expedition",Rect2(48,460,610,22),13,ui.MUTED)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,490,850,22),12,ui.CORAL)
