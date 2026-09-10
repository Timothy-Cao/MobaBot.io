class_name SkillLibrary
extends RefCounted
static func description(id: String, revised: bool = true) -> String:
	var data: Dictionary=MobaKit.PASSIVES.get(id,MobaKit.ABILITIES.get(id,{}))
	var text_value: String=data.get("text","")
	if not revised: return text_value
	match id:
		"laser": return text_value.replace("R again","The assigned key again")
		"flame": return text_value.replace("26 damage","41.6 damage")
		"sweep": return text_value.replace("26 damage","41.6 damage")
		"reap": return text_value.replace("16 damage","25.6 damage").replace("36 and","57.6 and")
		"thrust": return text_value.replace("25 damage","40 damage").replace("440","506")
		"repulsor": return text_value.replace("20 damage","32 damage").replace("18 damage","28.8 damage")
		"tractor": return text_value.replace("18 damage","28.8 damage")
	return text_value

## Learned tools are never discarded. Unfitted tools remain available at camp.
static func stored(kit, id: String) -> bool:
	return kit.loadout.get("library",{}).has(id)

static func has_space(kit, id: String) -> bool:
	for key in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
		if BotKeyboard.allowed(id,key) and BotKeyboard.slot_at(kit,key)=="": return true
	return false

static func remember(kit, id: String, rank: int=0, tier: int=0) -> void:
	if not kit.loadout.has("library"): kit.loadout["library"]={}
	kit.loadout.library[id]={"rank":rank,"tier":tier}

static func equip(run, id: String, key: int) -> bool:
	if Vanguard.enabled(run): return false
	if run.exp==null or (run.state!="camp" and not run.exp.practice): return false
	if not stored(run.kit,id) or not BotKeyboard.allowed(id,key): return false
	var kit=run.kit
	var old:=BotKeyboard.slot_at(kit,key)
	var old_id: String="" if old=="" else BotKeyboard.id_at(kit,old)
	if old_id=="orbit" and BotKeyboard.learned(kit,"ricochet")!="": return false
	if id=="ricochet" and BotKeyboard.learned(kit,"orbit")=="": return false
	var incoming: Dictionary=kit.loadout.library[id].duplicate()
	var old_rank: int=0 if old=="" or old.begins_with("p") else kit.ranks[old]
	var old_tier: int=0 if old=="" or old.begins_with("p") else kit.tiers[old]
	kit.loadout["rules17"]=false
	var placed:=BotKeyboard.place(run,id,key,int(incoming.tier))
	kit.loadout.rules17=true
	if not placed: return false
	kit.loadout.library.erase(id)
	if old_id!="": remember(kit,old_id,old_rank,old_tier)
	var slot:=BotKeyboard.learned(kit,id)
	if not slot.begins_with("p"):
		kit.ranks[slot]=int(incoming.rank); run.upgrades["skill_"+slot]=int(incoming.rank)
	return true

static func valid(config: Dictionary) -> bool:
	var library: Variant=config.get("library",{})
	if not library is Dictionary or library.size()>49: return false
	for id in library:
		if not MobaKit.PASSIVES.has(id) and not MobaKit.ABILITIES.has(id): return false
		var data: Variant=library[id]
		if not data is Dictionary or not ForgeEquipment.integer(data.get("rank"),0,10) or not ForgeEquipment.integer(data.get("tier"),0,2): return false
	return true
