class_name BotKeyboard
extends RefCounted
## Physical keys own positions; logical banks own cooldown/rank/ongoing casts.
const GENERAL := [KEY_1,KEY_2,KEY_3,KEY_4,KEY_Q,KEY_W,KEY_E,KEY_R,KEY_T]
const MOVEMENT := [KEY_D,KEY_F]
const ACTIVE_BANKS := ["q","w","e","r","d","f","t","x1","x2","x3","x4"]
const SYSTEM_DEFAULTS := {"attack":KEY_A,"center":KEY_SPACE,"build":KEY_TAB,"settings":KEY_ESCAPE,"lock":KEY_L}

static func enable(run) -> void:
	var kit: MobaKit=run.kit
	if kit.flexible(): return
	kit.loadout["flexible"]=true
	kit.bindings=MobaKit.DEFAULT_BINDS.duplicate()
	while kit.loadout.passives.size()<9: kit.loadout.passives.append(""); kit.toggles.append(false)
	for i in range(5,10): kit.bindings["p%d"%i]=0
	for slot in ACTIVE_BANKS:
		if slot in MobaKit.SLOTS: continue
		kit.loadout[slot]="rocket"; kit.ranks[slot]=0; kit.tiers[slot]=0
		kit.charges[slot]=2; kit.recharge[slot]=0.0; kit.bindings[slot]=0
		run.upgrades["skill_"+slot]=0

static func id_at(kit, slot: String) -> String:
	return kit.loadout.passives[int(slot.substr(1))-1] if slot.begins_with("p") else kit.loadout.get(slot,"")

static func slot_at(kit, key: int) -> String:
	for slot in kit.discovered:
		if kit.bindings.get(slot,0)==key: return slot
	return ""

static func learned(kit, id: String) -> String:
	for slot in kit.discovered:
		if id_at(kit,slot)==id: return slot
	return ""

static func allowed(id: String, key: int) -> bool:
	if MobaKit.PASSIVES.has(id): return key in GENERAL
	if not MobaKit.ABILITIES.has(id): return false
	return key in MOVEMENT if MobaKit.ABILITIES[id].category in ["speed","mobility"] else key in GENERAL

static func can_place(kit, id: String, key: int) -> bool:
	if not allowed(id,key): return false
	var old:=slot_at(kit,key)
	if kit.loadout.get("rules17",false) and old!="": return false
	if old!="" and id_at(kit,old)=="orbit" and id!="orbit" and learned(kit,"ricochet")!="": return false
	if id=="ricochet" and learned(kit,"orbit")=="": return false
	return true

static func place(run, id: String, key: int, tier: int=0) -> bool:
	if Vanguard.enabled(run): return false
	var kit: MobaKit=run.kit
	if not kit.flexible() or not can_place(kit,id,key): return false
	var existing:=learned(kit,id)
	if existing!="": return false # Duplicate rewards improve the existing skill, not another copy.
	var previous:=slot_at(kit,key)
	var passive:=MobaKit.PASSIVES.has(id)
	var bank: String=""
	if passive:
		for i in range(9):
			var candidate:="p%d"%(i+1)
			if candidate not in kit.discovered or candidate==previous: bank=candidate; break
	else:
		for candidate in ACTIVE_BANKS:
			if (key in MOVEMENT)!=(candidate in ["d","f"]): continue
			if candidate not in kit.discovered or candidate==previous: bank=candidate; break
	if bank=="": return false
	if previous!="":
		var removed_id:=id_at(kit,previous)
		if removed_id=="repair_channel": kit.extra.repair_left=0
		if removed_id=="roller": kit.extra.roll_left=0
		kit.discovered.erase(previous)
		kit.extra.recasts.erase(previous)
		if previous==kit.laser_slot: kit.cancel_laser()
		if previous==kit.flame_slot: kit.flame_left=0
		if previous.begins_with("p"):
			kit.loadout.passives[int(previous.substr(1))-1]=""
			kit.toggles[int(previous.substr(1))-1]=false
		kit.bindings[previous]=0
	if passive:
		for i in range(9):
			if "p%d"%(i+1) not in kit.discovered and kit.loadout.passives[i]==id: kit.loadout.passives[i]=""
		var index:=int(bank.substr(1))-1
		kit.loadout.passives[index]=id; kit.toggles[index]=true
	else:
		run.exp.install(run,bank,id,false); kit.tiers[bank]=tier
	kit.bindings[bank]=key; kit.discovered.append(bank)
	return true

static func swap(kit, key_a: int, key_b: int) -> bool:
	if kit.loadout.get("vanguard",false): return false
	if key_a==key_b or (key_a in MOVEMENT)!=(key_b in MOVEMENT): return false
	if key_a not in GENERAL+MOVEMENT or key_b not in GENERAL+MOVEMENT: return false
	var a:=slot_at(kit,key_a); var b:=slot_at(kit,key_b)
	if a=="" and b=="": return false
	if a!="": kit.bindings[a]=key_b
	if b!="": kit.bindings[b]=key_a
	return true

static func valid_system(keys: Dictionary) -> bool:
	var used: Array=[]
	for action in SYSTEM_DEFAULTS:
		var key: Variant=keys.get(action,SYSTEM_DEFAULTS[action])
		if action=="lock" and key is int and key>=-9 and key<=-1:
			used.append(key); continue
		if not key is int or key<=0 or key in GENERAL+MOVEMENT+[KEY_S,KEY_M,KEY_5,KEY_6,KEY_F2,KEY_QUOTELEFT] or key in used: return false
		if not ((key>=KEY_A and key<=KEY_Z) or (key>=KEY_0 and key<=KEY_9) or key in [KEY_SPACE,KEY_TAB,KEY_ESCAPE,KEY_BACKSPACE,KEY_HOME,KEY_END,KEY_INSERT,KEY_DELETE,KEY_F1,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12]): return false
		used.append(key)
	return true

static func binding_name(key: int) -> String:
	if key<0: return {1:"Mouse left",2:"Mouse right",3:"Mouse middle",4:"Wheel up",5:"Wheel down",6:"Wheel left",7:"Wheel right",8:"Mouse side 1",9:"Mouse side 2"}.get(-key,"Mouse")
	return OS.get_keycode_string(key)

static func valid_config(config: Dictionary) -> bool:
	if not SkillLibrary.valid(config): return false
	if not config.get("passives") is Array or config.passives.size()!=9: return false
	for id in config.passives:
		if not id is String or (id!="" and not MobaKit.PASSIVES.has(id)): return false
	for slot in ACTIVE_BANKS:
		if not MobaKit.ABILITIES.has(config.get(slot,"")): return false
	return MobaKit.PETS.has(config.get("pet",""))
