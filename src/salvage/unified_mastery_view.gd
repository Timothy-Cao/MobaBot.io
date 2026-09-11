class_name UnifiedMasteryView
extends RefCounted

static func point(id: String, tree: Dictionary=ExpeditionTree.UNIFIED) -> Vector2:
	if id in ["b0_0","field"]: return Vector2(402,116)
	var node: Dictionary=tree[id]
	return Vector2(102+node.branch*300,213+node.index*58)

static func draw(ui,run) -> void:
	var tree: Dictionary=run.mastery.nodes()
	ui._label(ui.overlay,"%d points · Resets next run"%run.mastery.available(run.level),Rect2(48,90,750,23),14,ui.GOLD)
	for id in tree:
		var node: Dictionary=tree[id]
		var at:=point(id,tree)
		if node.parent!="":
			var start:=point(node.parent,tree)+Vector2(78,48)
			var end:=at+Vector2(78,0)
			var line:=Line2D.new(); line.points=PackedVector2Array([start,Vector2(end.x,start.y+12),end]); line.width=2; line.default_color=ui.EDGE
			ui.overlay.add_child(line)
	for i in range(3):
		ui._surface(ui.overlay,Rect2(102+i*300,183,156,24),ui.PANEL,0)
		ui._label(ui.overlay,(["Utility","Looting","Pet"] if run.mastery.modern else ["Offense","Defense","Utility"])[i],Rect2(102+i*300,183,156,24),16,ui.TEAL,true,HORIZONTAL_ALIGNMENT_CENTER)
	for id in tree:
		var node: Dictionary=tree[id]
		var button: Button=ui._button("",Rect2(point(id,tree),Vector2(156,48)),func():
			run.mastery.buy(run,id)
			if run.state=="camp": ReviewView.camp(ui.host)
			else: ui.show_build(run,false),false)
		button.set_meta("mastery_node",id)
		button.modulate=Color.WHITE if run.mastery.can_buy(id,run.level) else Color(0.65,0.65,0.65)
		ui._label(button,node.name,Rect2(5,3,146,21),13,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(button,"%d / %d"%[run.mastery.rank_of(id),node.max],Rect2(5,25,146,18),12,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		button.tooltip_text=(LevelMastery.text(id) if run.mastery.modern else ExpeditionTree.text(id,true,true))+("\nRequires "+tree[node.parent].name if node.parent!="" else "")
	if run.state=="camp":
		ui._button("Reset points",Rect2(718,472,190,30),func():
			run.mastery.refund(run); ReviewView.camp(ui.host),false)
