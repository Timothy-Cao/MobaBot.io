class_name UnifiedMasteryView
extends RefCounted

static func point(id: String, tree: Dictionary=ExpeditionTree.UNIFIED) -> Vector2:
	if id=="field": return Vector2(380,116)
	if id=="b0_0": return Vector2(402,116)
	var node: Dictionary=tree[id]
	return Vector2((80 if tree.has("field") else 102)+node.branch*300,213+node.index*58)

static func draw(ui,run) -> void:
	var tree: Dictionary=run.mastery.nodes()
	var width: float=200 if run.mastery.modern else 156
	ui._label(ui.overlay,"%d points"%run.mastery.available(run.level),Rect2(48,90,750,23),14,ui.GOLD)
	for id in tree:
		var node: Dictionary=tree[id]
		var at:=point(id,tree)
		if node.parent!="":
			var start:=point(node.parent,tree)+Vector2(width/2,48)
			var end:=at+Vector2(width/2,0)
			var line:=Line2D.new(); line.points=PackedVector2Array([start,Vector2(end.x,start.y+12),end]); line.width=2; line.default_color=ui.TEAL if run.mastery.rank_of(id)>0 else ui.GOLD if run.mastery.can_buy(id,run.level) else ui.EDGE
			ui.overlay.add_child(line)
	for i in range(3):
		ui._surface(ui.overlay,Rect2(102+i*300,183,156,24),ui.PANEL,0)
		ui._label(ui.overlay,(["Utility","Looting","Pet"] if run.mastery.modern else ["Offense","Defense","Utility"])[i],Rect2(102+i*300,183,156,24),16,ui.TEAL,true,HORIZONTAL_ALIGNMENT_CENTER)
		if run.mastery.modern: ui._ability_icon(ui.overlay,["mastery_utility","mastery_looting","mastery_pet"][i],Rect2(58+i*300,176,38,38))
	for id in tree:
		var node: Dictionary=tree[id]
		var button: Button=ui._button("",Rect2(point(id,tree),Vector2(width,48)),func():
			run.mastery.buy(run,id)
			if run.state=="camp": ReviewView.camp(ui.host)
			else: ui.show_build(run,false),false)
		button.set_meta("mastery_node",id)
		var available: bool=run.mastery.can_buy(id,run.level)
		var owned: bool=run.mastery.rank_of(id)>0
		var face: Color=Color("29474c") if owned else Color("273d42") if available else Color("172c34")
		var edge: Color=ui.GOLD if available else ui.TEAL if owned else Color("485c61")
		var casing: StyleBoxFlat=ui._style(face,2,edge,1)
		casing.border_width_left=4 if available or owned else 1
		button.add_theme_stylebox_override("normal",casing)
		var left: float=54 if run.mastery.modern else 5
		if run.mastery.modern:
			MasteryBadge.attach(ui,button,["mastery_utility","mastery_looting","mastery_pet"][node.branch],"charge" if node.stat=="starting_ability" else MasteryBadge.STATS[node.stat],Rect2(8,6,36,36))
		ui._label(button,node.name,Rect2(left,3,width-left-5,21),12 if run.mastery.modern else 13,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(button,"%d / %d"%[run.mastery.rank_of(id),node.max],Rect2(left,25,width-left-5,18),12,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		button.tooltip_text=(LevelMastery.text(id) if run.mastery.modern else ExpeditionTree.text(id,true,true))+("\nRequires "+tree[node.parent].name if node.parent!="" else "")
	if run.state=="camp":
		ui._button("Reset points",Rect2(718,472,190,30),func():
			run.mastery.refund(run); ReviewView.camp(ui.host),false)
