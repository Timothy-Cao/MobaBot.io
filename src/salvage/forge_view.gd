class_name ForgeView
extends RefCounted

static func draw(game) -> void:
	var ui=game.ui; var collection: ForgeEquipment=game.collection
	ExpeditionView.frame(ui,"Equipment",game.close_gear)
	if game.gear_return!="camp":
		ui._label(ui.overlay,"%d Salvage"%collection.credits,Rect2(48,87,420,26),17,ui.GOLD)
		var crate: Button=ui._button("Supply crate · 150 Salvage",Rect2(625,85,267,30),game.buy_supply_crate,false)
		crate.add_theme_font_size_override("font_size",13)
		crate.disabled=collection.blocked or collection.credits<150
		crate.tooltip_text="One equipment item. Tier odds: 1: 94%, 2: 5.5%, 3: 0.48%, 4: 0.02%, 5: 0%. Each slot equally likely. Forge 3 identical pieces for the next tier."
	if ReviewRules.enabled(game.model) and game.model.state=="camp" and game.gear_return=="camp": ReviewView.tabs(game)
	var craft: Button=ui._button("Auto craft",Rect2(48,280,145,30),func(): game.bulk_gear("craft"),false)
	var craft_reason:=collection.bulk_unavailable_reason("craft")
	craft.disabled=not craft_reason.is_empty()
	craft.tooltip_text=craft_reason if craft.disabled else "Craft all matching sets of 3."
	craft.mouse_default_cursor_shape=Control.CURSOR_ARROW if craft.disabled else Control.CURSOR_POINTING_HAND
	var fit: Button=ui._button("Auto equip",Rect2(208,280,145,30),func(): game.bulk_gear("equip"),false)
	var equip_reason:=collection.bulk_unavailable_reason("equip")
	fit.disabled=not equip_reason.is_empty()
	fit.tooltip_text=equip_reason if fit.disabled else "Equip your best gear."
	fit.mouse_default_cursor_shape=Control.CURSOR_ARROW if fit.disabled else Control.CURSOR_POINTING_HAND
	for i in range(8):
		var slot: String=ForgeEquipment.SLOTS[i]
		var id: String=collection.equipped[slot]
		var button: Button=ui._button("",Rect2(48+(i%4)*79,124+(i/4)*84,68,68),func() -> void:
			game.gear_slot=slot; game.gear_item=collection.equipped[slot] if collection.equipped[slot]!="" else "courier_"+slot; draw(game),false)
		ui._ability_icon(button,"gear_courier_"+slot if id=="" else ForgeEquipment.ITEMS[id].icon,Rect2(5,5,58,58)).modulate=Color(0.3,0.3,0.3) if id=="" else Color.WHITE
		button.tooltip_text=slot.capitalize()+(" · Empty" if id=="" else "\n"+collection.item_text(id))
	ui._label(ui.overlay,game.gear_slot.capitalize(),Rect2(48,323,312,30),22,ui.CREAM,true)
	for i in range(5):
		var id: String=ForgeEquipment.SETS[i]+"_"+game.gear_slot
		var button: Button=ui._button("",Rect2(48+i*63,371,56,64),func() -> void: game.gear_item=id; draw(game),false)
		ui._ability_icon(button,ForgeEquipment.ITEMS[id].icon,Rect2(3,3,50,50)).modulate=Color.WHITE if collection.inventory[id].copies>0 else Color(0.3,0.3,0.3)
		ui._label(button,str(collection.inventory[id].copies),Rect2(2,46,50,18),11,ui.GOLD,true,HORIZONTAL_ALIGNMENT_RIGHT)
		button.tooltip_text="Tier %d\n%s"%[i+1,collection.item_text(id)]
	ui._surface(ui.overlay,Rect2(392,124,1,332),ui.EDGE,0)
	var selected: String=game.gear_item
	if selected!="":
		var data: Dictionary=ForgeEquipment.ITEMS[selected]; var item: Dictionary=collection.inventory[selected]
		ui._ability_icon(ui.overlay,data.icon,Rect2(429,130,90,90))
		ui._label(ui.overlay,data.name,Rect2(538,135,373,40),23,ui.CREAM,true)
		ui._label(ui.overlay,"Tier %d · %d copies"%[data.tier,item.copies],Rect2(538,180,373,26),15,ForgeEquipment.TIER_COLORS[data.tier-1])
		var values:=collection.values(selected)
		var fitted: String=collection.equipped[data.slot]
		var old: Dictionary={} if fitted=="" else collection.values(fitted)
		for i in range(values.size()):
			var key: String=values.keys()[i]; var factor:=100 if key=="speed" else 1
			var delta: float=(values[key]-old.get(key,0))*factor
			ui._label(ui.overlay,{"regen":"Energy / sec","health_regen":"Health / sec"}.get(key,key.capitalize()),Rect2(429,244+i*36,230,28),16,ui.MUTED)
			ui._label(ui.overlay,"%s%s"%[UpgradePreview.number(values[key]*factor),"%" if key=="speed" else ""],Rect2(658,244+i*36,130,28),18,ui.CREAM,true,HORIZONTAL_ALIGNMENT_RIGHT)
			ui._label(ui.overlay,(("+" if delta>0 else "")+UpgradePreview.number(delta)+("%" if key=="speed" else "")) if delta!=0 else "—",Rect2(806,244+i*36,86,28),14,ui.TEAL if delta>0 else ui.MUTED,false,HORIZONTAL_ALIGNMENT_RIGHT)
		if data.tier>=4:
			var bonus: Label=ui._label(ui.overlay,"+1 skill ranks"+(" · Gun companion" if data.tier==5 else ""),Rect2(429,361,470,28),15,ui.GOLD)
			bonus.mouse_filter=Control.MOUSE_FILTER_STOP; bonus.tooltip_text=collection.item_text(selected)
		var equip: Button=ui._button("Equipped" if fitted==selected else "Equip",Rect2(429,412,175,42),func() -> void: game.gear_action("equip",selected),false)
		equip.disabled=item.copies<1 or fitted==selected or collection.blocked
		var forge: Button=ui._button("Forge · 3 → 1" if data.tier<5 else "Highest tier",Rect2(625,412,267,42),func() -> void: game.gear_action("forge",selected))
		forge.disabled=item.copies<3 or data.tier>=5 or collection.blocked
	if not collection.message.is_empty(): ui._label(ui.overlay,collection.message,Rect2(48,478,858,25),12,ui.CORAL)
