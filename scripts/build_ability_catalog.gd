extends SceneTree
## Regenerate the review artifact from the actual discovery pool and descriptions.
func _initialize() -> void:
	var entries: Array=[]
	for category in ["active","ultimate","speed","mobility","summon"]:
		for id in BotSkillCatalog.modern_ids(category):
			var data: Dictionary=MobaKit.ABILITIES[id]
			entries.append({"id":id,"name":data.name,"category":"movement" if category in ["speed","mobility"] else ("active" if category=="ultimate" else category),"description":SkillLibrary.description(id),"stats":["%.1fs recharge"%data.cd,MobaKit.cost_text(id),"%d charges"%data.max]})
	for id in MobaKit.PASSIVES:
		entries.append({"id":id,"name":MobaKit.PASSIVES[id].name,"category":"toggle","description":SkillLibrary.description(id),"stats":["Powered mode","1–4 / QWERT"]})
	var template:=FileAccess.get_file_as_string("res://docs/review/catalog-template.html")
	var file:=FileAccess.open("res://docs/review/abilities.html",FileAccess.WRITE)
	file.store_string(template.replace("__ABILITY_DATA__",JSON.stringify(entries)))
	print("ABILITY CATALOG: ",entries.size()," skills")
	quit(0 if entries.size()==49 else 1)
