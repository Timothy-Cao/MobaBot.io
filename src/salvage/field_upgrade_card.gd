class_name FieldUpgradeCard
extends RefCounted
static func draw(ui, run, id: String, index: int) -> void:
	var credit:=id=="field_credit"
	var heal:=id=="full_heal"
	var rank_value:=DiscoveryRules.rank_of(run,id)
	var card: Button=ui._button("",Rect2(132+index*236,173,224,244),func(): ui.upgrade_selected.emit(index),false)
	card.set_meta("review_choice",id)
	var title: String="Full heal" if heal else "200 credits" if credit else "XP gain" if id=="xp_gain" else "Pickup range"
	ui._ability_icon(card,"health_pack" if heal else "field_credit" if credit else "magnet" if id=="pickup_range" else "xp_gain",Rect2(88,12,48,48))
	ui._label(card,title,Rect2(8,65,208,26),17,ui.GOLD if credit else ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
	if heal:
		ui._label(card,"HP %d → %d"%[ceili(run.health),ceili(run.max_health())],Rect2(8,158,208,30),20,Color("78c995"),true,HORIZONTAL_ALIGNMENT_CENTER)
	elif not credit:
		ui._label(card,"Level %d / 5"%(rank_value+1),Rect2(8,94,208,20),13,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		for i in range(5):
			var cell=ui._surface(card,Rect2(42+i*29,119,24,9),ui.TEAL if i<rank_value else ui.GOLD if i==rank_value else ui.INK,0,ui.GOLD if i==4 else ui.EDGE,1)
			cell.mouse_filter=Control.MOUSE_FILTER_IGNORE
		ui._label(card,"+%d%% → +%d%%"%[rank_value*10,(rank_value+1)*10],Rect2(8,151,208,28),20,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		card.tooltip_text="XP gained" if id=="xp_gain" else "Pickup radius"
	if index==0: card.grab_focus()
