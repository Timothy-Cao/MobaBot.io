class_name UnifiedMasteryView
extends RefCounted

static func point(id: String) -> Vector2:
	if id=="b0_0": return Vector2(402,116)
	var node: Dictionary=ExpeditionTree.UNIFIED[id]
	return Vector2(102+node.branch*300,213+node.index*58)

static func draw(ui,run) -> void:
	ui._label(ui.overlay,"%d points · Resets next run"%run.mastery.available(run.level),Rect2(48,90,750,23),14,ui.GOLD)
	for id in ExpeditionTree.UNIFIED:
		var node: Dictionary=ExpeditionTree.UNIFIED[id]
		var at:=point(id)
		if node.parent!="":
			var start:=point(node.parent)+Vector2(78,48)
			var end:=at+Vector2(78,0)
			var line:=Line2D.new(); line.points=PackedVector2Array([start,Vector2(end.x,start.y+12),end]); line.width=2; line.default_color=ui.EDGE
			ui.overlay.add_child(line)
	for i in range(3):
		ui._surface(ui.overlay,Rect2(102+i*300,183,156,24),ui.PANEL,0)
		ui._label(ui.overlay,["Offense","Defense","Utility"][i],Rect2(102+i*300,183,156,24),16,ui.TEAL,true,HORIZONTAL_ALIGNMENT_CENTER)
	for id in ExpeditionTree.UNIFIED:
		var node: Dictionary=ExpeditionTree.UNIFIED[id]
		var button: Button=ui._button("",Rect2(point(id),Vector2(156,48)),func():
			run.mastery.buy(run,id)
			if run.state=="camp": ReviewView.camp(ui.host)
			else: ui.show_build(run,false),false)
		button.set_meta("mastery_node",id)
		button.disabled=not run.mastery.can_buy(id,run.level)
		ui._label(button,node.name,Rect2(5,3,146,21),13,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(button,"%d / %d"%[run.mastery.rank_of(id),node.max],Rect2(5,25,146,18),12,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		button.tooltip_text=ExpeditionTree.text(id,true,true)+("\nRequires "+ExpeditionTree.UNIFIED[node.parent].name if node.parent!="" else "")
	if run.state=="camp":
		ui._button("Reset points",Rect2(718,472,190,30),func():
			run.mastery.refund(run); ReviewView.camp(ui.host),false)
