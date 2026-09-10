class_name ExpeditionView
extends RefCounted

static func frame(ui, title: String, back: Callable) -> void:
	ui.clear_overlay(); ui.hud.visible = false; ui._dim()
	ui._panel(Rect2(24,24,912,492),ui.PANEL)
	ui._label(ui.overlay,title,Rect2(47,39,600,45),30,ui.CREAM,true)
	ui._button("Back",Rect2(811,43,102,34),back,false)

static func prepare(game) -> void:
	var ui = game.ui
	frame(ui,"Expedition",game.show_home)
	ui._ability_icon(ui.overlay,"bolt",Rect2(110,153,105,105))
	ui._ability_icon(ui.overlay,"rocket",Rect2(236,153,105,105))
	ui._label(ui.overlay,"Vanguard",Rect2(404,169,454,40),29,ui.CREAM,true)
	ui._label(ui.overlay,"2 minutes. Survive, then defeat the guardian.",Rect2(404,218,454,40),16,ui.MUTED).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	ui._label(ui.overlay,"Ascension",Rect2(48,355,170,28),17,ui.MUTED)
	for i in range(6):
		var button: Button = ui._button(str(i),Rect2(205+i*47,350,40,38),func() -> void:
			game.ascension_choice=i; prepare(game),i==game.ascension_choice)
		button.disabled=i>game.collection.unlocked_ascension
		button.tooltip_text=BotExpedition.difficulty_text(i)
	var start: Button = ui._button("Start",Rect2(679,439,234,44),game.confirm_new_run)
	start.disabled=game.collection.blocked
	start.grab_focus()
	if not game.collection.checkpoint.is_empty():
		ui._button("Continue run",Rect2(424,439,234,44),func() -> void: game.launch_expedition(true),false)
	ui._label(ui.overlay,"8 stages · Save between rounds",Rect2(48,445,354,25),13,ui.MUTED)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,491,856,21),12,ui.CORAL)

static func chest(game) -> void:
	if game.model.kit.flexible(): KeyboardRewards.chest(game); return
	var ui=game.ui
	var run: SalvageRun=game.model
	frame(ui,"Salvage chest",func() -> void: pass)
	# A chest is a mandatory, bounded choice, not a dismissible loot roll.
	for child in ui.overlay.get_children():
		if child is Button and child.text=="Back": child.queue_free()
	for i in range(run.exp.chest_choices.size()):
		var choice: Dictionary=run.exp.chest_choices[i]
		var passive: bool=choice.slot.begins_with("p")
		var data: Dictionary=MobaKit.PASSIVES[choice.id] if passive else MobaKit.ABILITIES[choice.id]
		var known: bool=run.kit.unlocked(choice.slot)
		var same: bool=(run.kit.loadout.passives[int(choice.slot.substr(1))-1]==choice.id) if passive else run.kit.loadout[choice.slot]==choice.id
		var previous: String=MobaKit.PASSIVES[run.kit.loadout.passives[int(choice.slot.substr(1))-1]].name if passive else MobaKit.ABILITIES[run.kit.loadout[choice.slot]].name
		var action: String="Unlock" if not known else ("+2 ranks" if same and not passive else ("40 credits" if passive and same else "Replace " + previous))
		var card: Button=ui._button("",Rect2(48+i*292,128,278,315),func() -> void: game.choose_discovery(i),false)
		card.add_theme_stylebox_override("normal",ui._style(ui.PANEL,0,MobaKit.RARITY_COLORS[choice.tier],2))
		ui._ability_icon(card,data.icon if passive else choice.id,Rect2(88,40,102,102))
		ui._label(card,OS.get_keycode_string(run.kit.bindings[choice.slot]),Rect2(18,12,40,23),14,ui.GOLD,true)
		ui._label(card,data.name,Rect2(14,171,250,34),22,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		var label: Label=ui._label(card,action,Rect2(14,226,250,47),15,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text=data.text+"\n"+MobaKit.RARITIES[choice.tier]+("\nReplacement resets this slot's rank." if known and not same else "")
		if i==0: card.grab_focus()

static func camp(game) -> void:
	if Vanguard.enabled(game.model): vanguard_camp(game); return
	var ui=game.ui
	var run: SalvageRun=game.model
	var exp: BotExpedition=run.exp
	frame(ui,"Round clear",game.show_home)
	ui._label(ui.overlay,exp.label(),Rect2(48,96,830,32),20,ui.TEAL,true)
	ui._label(ui.overlay,"%d field credits" % exp.field_credits,Rect2(48,144,380,28),17,ui.GOLD,true)
	ui._button("Build",Rect2(48,423,182,44),game._open_build,false)
	ui._button("Equipment",Rect2(245,423,182,44),game._open_gear,false)
	if exp.pending_chests>0:
		ui._button("Open chest · %d" % exp.pending_chests,Rect2(652,423,260,44),game.open_discovery).grab_focus()
	else:
		ui._button("Finish" if exp.route_index==21 else "Next round",Rect2(652,423,260,44),game.continue_expedition).grab_focus()
	if exp.is_shop():
		if exp.shop_stock.is_empty():
			for i in range(3): exp.shop_stock.append(ForgeEquipment.roll_item(run.loot_rng,exp.ascension) if run.kit.flexible() else ExpeditionGear.roll_item(run.loot_rng,exp.ascension))
		for i in range(exp.shop_stock.size()):
			var id: String=exp.shop_stock[i]
			if id == "":
				ui._label(ui.overlay,"Sold",Rect2(48+i*292,259,276,30),20,ui.MUTED,true,HORIZONTAL_ALIGNMENT_CENTER)
				continue
			var data: Dictionary=ForgeEquipment.ITEMS[id] if game.collection is ForgeEquipment else ExpeditionGear.ITEMS[id]
			var price: int=100+data.tier*100
			var card: Button=ui._button("",Rect2(48+i*292,202,276,166),func() -> void: game.buy_item(i),false)
			card.disabled=exp.field_credits<price
			ui._ability_icon(card,data.icon,Rect2(16,18,72,72))
			ui._label(card,data.name,Rect2(100,24,163,52),16,ui.CREAM,true).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			ui._label(card,str(price),Rect2(16,118,240,26),19,ui.GOLD,true)
			card.tooltip_text=game.collection.item_text(id)+"\nAdded to permanent collection. Equip at the workshop."
	else:
		var reward:=RewardMotion.new(); reward.position=Vector2(405,194); reward.size=Vector2(150,150); reward.reduced=ui.reduced; ui.overlay.add_child(reward)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,478,856,24),12,ui.CORAL)

static func vanguard_camp(game) -> void:
	if ReviewRules.enabled(game.model): ReviewView.camp(game); return
	var ui=game.ui; var run=game.model; var exp: BotExpedition=run.exp
	var shop:=exp.is_shop(true)
	frame(ui,"Stage clear" if shop else "Round clear",game.show_home)
	ui._label(ui.overlay,exp.label(),Rect2(48,96,700,32),20,ui.TEAL,true)
	var balance: Label=ui._label(ui.overlay,"%d field credits"%exp.field_credits,Rect2(48,140,410,28),17,ui.GOLD,true)
	balance.mouse_filter=Control.MOUSE_FILTER_STOP; balance.tooltip_text="Buy equipment after each stage. Field credits reset with a new run; purchased gear persists."
	ui._label(ui.overlay,"Recovered · %d chest%s"%[exp.reward_receipt.chests,"" if exp.reward_receipt.chests==1 else "s"] if exp.reward_receipt.chests>0 else "Recovered",Rect2(48,182,380,26),15,ui.MUTED,true)
	var receipt:=LootReceipt.new(); receipt.name="RoundReceipt"; receipt.position=Vector2(48,218); receipt.size=Vector2(430 if shop else 820,174)
	ui.overlay.add_child(receipt); receipt.build(ui,exp.reward_receipt)
	if shop:
		ui._label(ui.overlay,"Shop",Rect2(510,142,380,28),19,ui.CREAM,true)
		for i in range(exp.shop_stock.size()):
			var id: String=exp.shop_stock[i]
			var rect:=Rect2(510+i*137,190,126,202)
			if id=="":
				ui._label(ui.overlay,"Sold",rect,16,ui.MUTED,true,HORIZONTAL_ALIGNMENT_CENTER); continue
			var data: Dictionary=ForgeEquipment.ITEMS[id]; var price: int=100+data.tier*100
			var card: Button=ui._button("",rect,func(): game.buy_item(i),false)
			card.disabled=exp.field_credits<price or game.collection.blocked
			ui._ability_icon(card,data.icon,Rect2(29,12,68,68))
			var label: Label=ui._label(card,data.name,Rect2(8,91,110,57),14,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
			label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			ui._label(card,str(price),Rect2(8,164,110,26),18,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
			card.tooltip_text=game.collection.item_text(id)+"\nBuy for %d field credits. Added to equipment."%price
	ui._button("Build",Rect2(48,423,182,44),game._open_build,false)
	ui._button("Equipment",Rect2(245,423,182,44),game._open_gear,false)
	ui._button("Finish" if exp.route_index==21 else "Next stage" if shop else "Next round",Rect2(652,423,260,44),game.continue_expedition).grab_focus()
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,478,856,24),12,ui.CORAL)

static func gear(game) -> void:
	if game.collection is ForgeEquipment:
		ForgeView.draw(game)
		return
	var ui=game.ui
	var collection: ExpeditionGear=game.collection
	frame(ui,"Equipment",game.close_gear)
	ui._label(ui.overlay,"%d credits" % collection.credits,Rect2(624,91,288,26),17,ui.GOLD,true,HORIZONTAL_ALIGNMENT_RIGHT)
	for i in range(8):
		var slot: String=ExpeditionGear.SLOTS[i]
		var id: String=collection.equipped[slot]
		var button: Button=ui._button("",Rect2(48+(i%4)*79,124+(i/4)*84,68,68),func() -> void:
			game.gear_slot=slot; game.gear_item=collection.equipped[slot]; gear(game),false)
		ui._ability_icon(button,"gear_courier_"+slot if id=="" else ExpeditionGear.ITEMS[id].icon,Rect2(5,5,58,58)).modulate=Color(0.4,0.4,0.4) if id=="" else Color.WHITE
		button.tooltip_text=slot.capitalize()+ (" · Empty" if id=="" else "\n"+collection.item_text(id))
	ui._label(ui.overlay,game.gear_slot.capitalize(),Rect2(48,323,312,30),22,ui.CREAM,true)
	for i in range(5):
		var id: String=ExpeditionGear.SETS[i]+"_"+game.gear_slot
		var button: Button=ui._button("",Rect2(48+i*63,371,56,56),func() -> void:
			game.gear_item=id; gear(game),false)
		ui._ability_icon(button,ExpeditionGear.ITEMS[id].icon,Rect2(3,3,50,50)).modulate=Color.WHITE if collection.inventory[id].copies>0 else Color(0.35,0.35,0.35)
		button.tooltip_text=ExpeditionGear.ITEMS[id].name+"\n"+collection.item_text(id)
	ui._surface(ui.overlay,Rect2(392,124,1,332),ui.EDGE,0,ui.EDGE,0)
	var selected: String=game.gear_item
	if selected!="":
		var data: Dictionary=ExpeditionGear.ITEMS[selected]
		var item: Dictionary=collection.inventory[selected]
		ui._ability_icon(ui.overlay,data.icon,Rect2(429,130,90,90))
		ui._label(ui.overlay,data.name,Rect2(538,135,373,40),25,ui.CREAM,true)
		ui._label(ui.overlay,"%d stars · %d copies" % [item.stars,item.copies],Rect2(538,180,373,26),15,ui.GOLD)
		var row_index := 0
		var fitted: String = collection.equipped[data.slot]
		var old_values: Dictionary = collection.values(fitted) if fitted != "" else {}
		var comparison: Dictionary = collection.values(selected)
		for stat in old_values:
			if not comparison.has(stat): comparison[stat] = 0.0
		for stat in comparison:
			var value: float = comparison[stat]
			var delta: float = value - float(old_values.get(stat,0))
			var percent: bool = stat in ["damage","attack","speed","haste","luck","summon_damage"]
			var amount: String = str(snappedf(value*(100 if percent else 1),0.01)) + ("%" if percent else "")
			var label: String = {"regen":"Energy / sec","health_regen":"Hull / sec","damage":"Ability damage","attack":"Basic damage","haste":"Attack speed"}.get(stat,stat.capitalize())
			ui._label(ui.overlay,label,Rect2(429,239+row_index*23,245,23),14,ui.MUTED)
			ui._label(ui.overlay,amount,Rect2(690,239+row_index*23,100,23),15,ui.CREAM,true,HORIZONTAL_ALIGNMENT_RIGHT)
			var change: String = ("+" if delta>0 else "") + str(snappedf(delta*(100 if percent else 1),0.01)) + ("%" if percent else "")
			ui._label(ui.overlay,change if delta!=0 else "—",Rect2(802,239+row_index*23,90,23),14,ui.TEAL if delta>0 else (ui.CORAL if delta<0 else ui.MUTED),false,HORIZONTAL_ALIGNMENT_RIGHT)
			row_index+=1
		var count: int = collection.equipped.values().filter(func(item_id: String) -> bool: return item_id.begins_with(data.set+"_")).size()
		var set_label: Label = ui._label(ui.overlay,"%s · %d/4" % [data.set.capitalize(),count],Rect2(429,365,470,25),14,ui.GOLD,true)
		set_label.mouse_filter=Control.MOUSE_FILTER_STOP; set_label.tooltip_text=ExpeditionGear.SET_TEXT[data.set]
		for i in range(3):
			var action: String=["equip","reroll","star"][i]
			var button: Button=ui._button(["Equip","Reroll · 35","Star · %d" % (25*(item.stars+1))][i],Rect2(429+i*162,407,151,40),func() -> void:
				game.gear_action(action,selected),i==0)
			button.disabled=item.copies<1 or collection.blocked
	if not collection.message.is_empty(): ui._label(ui.overlay,collection.message,Rect2(48,478,858,25),12,ui.CORAL)

static func mastery(ui,run) -> void:
	if run.mastery.unified: UnifiedMasteryView.draw(ui,run); return
	ui._label(ui.overlay,"◇ %d" % run.mastery.available(run.level),Rect2(48,94,140,27),19,ui.GOLD,true)
	var detail: Label = ui._label(ui.overlay,"",Rect2(48,468,649,36),12,ui.MUTED)
	detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	for branch in range(6):
		ui._label(ui.overlay,ExpeditionTree.BRANCHES[branch],Rect2(48+branch*143,132,133,22),14,ui.TEAL,true,HORIZONTAL_ALIGNMENT_CENTER)
	for id in ExpeditionTree.TREE:
		var node: Dictionary=ExpeditionTree.TREE[id]
		var index: int=node.index
		var p:=Vector2(64+node.branch*143+(index%2)*59,177+(index/2)*72)
		if index>=2: ui._surface(ui.overlay,Rect2(p+Vector2(25,-21),Vector2(1,21)),ui.EDGE,0,ui.EDGE,0)
		var button: Button=ui._button("",Rect2(p,Vector2(51,51)),func() -> void:
			run.mastery.buy(run,id)
			if ReviewRules.enabled(run) and run.state=="camp": ReviewView.camp(ui.host)
			else: ui.show_build(run,false),false)
		var icon: String={"attack":"power","damage":"rocket","haste":"rapid","range":"rail","shock":"lightning","aftershock":"pulse","speed":"tumble","cooldown":"cell","tenacity":"sprint","resistance":"shield","health":"capacity","health_regen":"repair_channel","energy":"reactor","regen":"cell","magnet":"magnet","xp":"poison","luck":"ricochet","summon_damage":"forward_sentry","duration":"mirror_sentry","capacity":"pulse_sentry"}[node.stat]
		ui._ability_icon(button,icon,Rect2(4,3,43,43))
		ui._label(button,"%d/%d" % [run.mastery.rank_of(id),node.max],Rect2(12,38,36,15),10,ui.GOLD,true)
		button.add_theme_stylebox_override("normal",ui._style(ui.PANEL,0,ui.GOLD if run.mastery.can_buy(id,run.level) else ui.EDGE,2))
		button.tooltip_text=node.name+"\n"+ExpeditionTree.text(id,Vanguard.enabled(run))+("\nRequires "+ExpeditionTree.TREE[node.parent].name if node.parent!="" else "")
		var inspect := func() -> void: detail.text=node.name+" · "+ExpeditionTree.text(id,Vanguard.enabled(run))
		button.mouse_entered.connect(inspect); button.focus_entered.connect(inspect)
	if run.state=="camp":
		ui._button("Reset points",Rect2(718,472,190,30),func() -> void:
			run.mastery.refund(run)
			if ReviewRules.enabled(run) and run.state=="camp": ReviewView.camp(ui.host)
			else: ui.show_build(run,false),false)
