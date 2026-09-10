class_name LootReceipt
extends Control
## Display-only receipt. Awards happen in simulation, never in animation callbacks.
var reveal_cards: Array[Control]=[]
var animation: Tween

func build(ui, receipt: Dictionary, compact: bool=false) -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var rows: Array=[]
	# Put rare equipment first so it cannot hide below routine currency.
	for id in receipt.items: rows.append([ForgeEquipment.ITEMS[id].icon,ForgeEquipment.ITEMS[id].name+" ×%d"%receipt.items[id]])
	if receipt.points>0: rows.append(["reward_point","+%d skill point%s"%[receipt.points,"" if receipt.points==1 else "s"]])
	if receipt.credits>0: rows.append(["field_credit","+%d field credits"%receipt.credits])
	if compact:
		ui._surface(self,Rect2(Vector2.ZERO,size),Color("14242cee"),0)
		ui._label(self,"CHEST" if receipt.chests==1 else "%d CHESTS"%receipt.chests,Rect2(10,3,size.x-20,18),10,ui.GOLD,true)
		# The full round receipt retains every item; this toast stays compact.
		for i in range(mini(rows.size(),3)):
			var at:=Vector2(10+i*size.x/3,25)
			ui._ability_icon(self,rows[i][0],Rect2(at,Vector2(30,30)))
			var label: Label=ui._label(self,rows[i][1],Rect2(at+Vector2(35,0),Vector2(size.x/3-47,45)),11,ui.CREAM,true)
			label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		return
	var chest:=RewardMotion.new(); chest.position=Vector2(0,2); chest.size=Vector2(96,100); chest.reduced=ui.reduced; chest.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(chest)
	var scroll:=ScrollContainer.new(); scroll.position=Vector2(108,0); scroll.size=size-Vector2(108,0); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	scroll.gui_input.connect(_skip_input)
	var list:=VBoxContainer.new(); list.size_flags_horizontal=Control.SIZE_EXPAND_FILL; list.add_theme_constant_override("separation",6); scroll.add_child(list)
	for row in rows:
		var card:=Control.new(); card.custom_minimum_size=Vector2(0,50); list.add_child(card)
		card.gui_input.connect(_skip_input)
		ui._ability_icon(card,row[0],Rect2(2,3,44,44))
		var label: Label=ui._label(card,row[1],Rect2(56,2,size.x-186,46),14,ui.CREAM,true)
		label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		reveal_cards.append(card)
	if rows.is_empty():
		ui._label(list,"Rewards already collected",Rect2(0,0,size.x-116,46),14,ui.MUTED)
	if not ui.reduced:
		animation=create_tween().set_parallel()
		for i in range(reveal_cards.size()):
			var card:=reveal_cards[i]; card.modulate.a=0
			animation.tween_property(card,"modulate:a",1.0,0.18).set_delay(0.28+mini(i,5)*0.08)
			card.scale=Vector2.ONE*0.96
			animation.tween_property(card,"scale",Vector2.ONE,0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.28+mini(i,5)*0.08)
	# Click anywhere on the receipt to reveal immediately; never a claim action.
	mouse_filter=Control.MOUSE_FILTER_PASS
	gui_input.connect(_skip_input)

func _skip_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT: finish_reveal()

func finish_reveal() -> void:
	if animation!=null and animation.is_valid(): animation.kill()
	for card in reveal_cards: card.modulate.a=1; card.scale=Vector2.ONE
