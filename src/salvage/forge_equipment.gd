class_name ForgeEquipment
extends RefCounted
## v3 forging profile. Earlier profiles remain untouched as migration sources.
const PATH := "user://mobabot_forge.json"
const SLOTS := ["helmet", "chest", "legs", "boots", "charm", "ring", "flower", "cape"]
const SETS := ["courier", "bastion", "dynamo", "relay", "reclaimer"]
const TIER_NAMES := ["Salvaged","Tempered","Stormforged","Astral","Sovereign"]
const TIER_COLORS := [Color("b5c3cc"),Color("78c99a"),Color("69b8f0"),Color("be8aee"),Color("f2bd64")]
const ITEM_NAMES := {"helmet":"Visor","chest":"Carapace","legs":"Greaves","boots":"Striders","charm":"Heartcore","ring":"Signet","flower":"Ironbloom","cape":"Mantle"}
const AFFIXES := {"health": 2.0, "damage": 0.006, "regen": 0.15, "luck": 0.025, "resistance": 1.0}
var credits := 150
var chapter_cleared := 0
var recovery_used: Array=[]
var recovery_target := 0
var starting_ability := false
var unlocked_ascension := 0
var inventory: Dictionary = {}
var equipped: Dictionary = {}
var checkpoint: Dictionary = {}
var migration: Dictionary = {}
var loadouts: Dictionary = {}
var blocked := false
var message := ""
var rng := RandomNumberGenerator.new()
var path := PATH
static var ITEMS: Dictionary = make_items()

static func make_items() -> Dictionary:
	var items: Dictionary={}
	for i in range(5):
		for slot in SLOTS:
			var id: String=SETS[i]+"_"+slot
			items[id]={"name":TIER_NAMES[i]+" "+ITEM_NAMES[slot],"slot":slot,"tier":i+1,"icon":"gear_"+id}
	return items

func _init() -> void:
	rng.randomize()
	for id in ITEMS: inventory[id] = {"copies": 0, "stars": 0, "bonus": "health", "roll": 1}
	for slot in SLOTS: equipped[slot] = ""
	for slot in ["helmet", "chest", "boots"]:
		inventory["courier_" + slot].copies = 1
		equipped[slot] = "courier_" + slot

static func roll_item(random: RandomNumberGenerator, ascension: int) -> String:
	var value:=random.randf()
	var tier:=0
	if value<0.005+ascension*0.002: tier=3
	elif value<0.06+ascension*0.01: tier=2
	elif value<0.30+ascension*0.02: tier=1
	return SETS[tier]+"_"+SLOTS[random.randi_range(0,7)]

func snapshot() -> Dictionary:
	return {"version": 3, "starting_ability":starting_ability, "credits": credits, "chapter_cleared":chapter_cleared,"recovery_used":recovery_used.duplicate(),"recovery_target":recovery_target,"crate_rng":str(rng.state), "ascension": unlocked_ascension, "inventory": inventory.duplicate(true), "equipped": equipped.duplicate(), "checkpoint": checkpoint.duplicate(true), "migration": migration.duplicate(true), "loadouts": loadouts.duplicate(true)}

func unlocked_chapter() -> int: return mini(OperationRules.CHAPTERS,chapter_cleared+1)

func record_failure(run) -> void:
	if not LevelMastery.enabled(run) or run.state!="lost" or run.exp.practice: return
	var level: int=run.exp.operation_chapter
	if level<=1 or level!=chapter_cleared+1 or level in recovery_used or run.time<90 or run.kills<60: return
	recovery_used.append(level); recovery_target=level-1

func bulk(action: String, persist: bool=true) -> bool:
	if blocked or action not in ["craft","equip"]: return false
	var before:=snapshot(); var changed:=0
	for slot in SLOTS:
		if action=="craft":
			for tier in range(4):
				var id: String=SETS[tier]+"_"+slot; var next: String=SETS[tier+1]+"_"+slot
				var count:=mini(int(inventory[id].copies)/3,999-int(inventory[next].copies))
				if count<=0: continue
				inventory[id].copies-=count*3; inventory[next].copies+=count; changed+=count
				if equipped[slot]==id and inventory[id].copies==0: equipped[slot]=next
		else:
			for tier in range(4,-1,-1):
				var id: String=SETS[tier]+"_"+slot
				if inventory[id].copies>0:
					if equipped[slot]!=id: equipped[slot]=id; changed+=1
					break
	if persist and not save(): restore(before); message="Save failed. Nothing changed."; return false
	message=("Crafted %d upgrades" if action=="craft" else "Updated %d equipment slots")%changed
	return true

func buy_crate(persist: bool=true) -> String:
	if blocked: return ""
	if credits<150: message="150 Salvage required"; return ""
	var before:=snapshot()
	var roll:=rng.randf()
	var tier:=0 if roll<0.94 else 1 if roll<0.995 else 2 if roll<0.9998 else 3
	var id: String=SETS[tier]+"_"+SLOTS[rng.randi_range(0,7)]
	if inventory[id].copies>=999: restore(before); message="Inventory full; nothing spent"; return ""
	credits-=150; inventory[id].copies+=1
	if persist and not save(): restore(before); message="Save failed. Nothing spent."; return ""
	message="Recovered "+ITEMS[id].name
	return id

func valid(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 3: return false
	if not data.get("starting_ability",false) is bool: return false
	if not integer(data.get("chapter_cleared",0),0,OperationRules.CHAPTERS): return false
	if not integer(data.get("recovery_target",0),0,7) or not data.get("recovery_used",[]) is Array: return false
	var used: Array=[]
	for level in data.get("recovery_used",[]):
		if not integer(level,2,8) or level in used: return false
		used.append(level)
	if data.get("recovery_target",0)>0 and data.recovery_target+1 not in used: return false
	if data.has("crate_rng") and (not data.crate_rng is String or not data.crate_rng.is_valid_int() or str(int(data.crate_rng))!=data.crate_rng): return false
	for key in ["inventory", "equipped", "checkpoint", "migration"]:
		if not data.get(key) is Dictionary: return false
	for key in ["credits", "ascension"]:
		if not integer(data.get(key), 0, 10000000 if key == "credits" else 5): return false
	for id in ITEMS:
		var item: Variant = data.inventory.get(id)
		if not item is Dictionary or not AFFIXES.has(item.get("bonus", "")): return false
		if not integer(item.get("copies"), 0, 999) or not integer(item.get("stars"), 0, 5) or not integer(item.get("roll"), 1, 5): return false
	for slot in SLOTS:
		var id: Variant = data.equipped.get(slot)
		if not id is String: return false
		if id != "" and (not ITEMS.has(id) or ITEMS[id].slot != slot or data.inventory[id].copies < 1): return false
	if not data.checkpoint.is_empty() and not valid_checkpoint(data.checkpoint): return false
	if not data.get("loadouts", {}) is Dictionary: return false
	for id in data.get("loadouts", {}):
		if not BotExpedition.CLASSES.has(id) or not MobaKit.valid_loadout(data.loadouts[id]): return false
	return true

static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is float or value is int) and is_finite(value) and value == floorf(value) and value >= low and value <= high

static func valid_checkpoint(c: Dictionary) -> bool:
	if c.has("receipt") and not RewardLedger.valid(c.receipt): return false
	if not c.get("loadout") is Dictionary: return false
	if not c.loadout.get("flexible",false): return ExpeditionGear.valid_checkpoint(c)
	if c.get("class","")!="shared" and not BotExpedition.CLASSES.has(c.get("class","")): return false
	if not BotKeyboard.valid_config(c.loadout): return false
	if c.loadout.has("review19") and (c.loadout.review19!=true or not c.loadout.get("vanguard",false)): return false
	if c.loadout.has("operation20"):
		if not c.loadout.get("review19",false) or not c.loadout.get("unified_mastery",false) or not integer(c.loadout.operation20,1,OperationRules.CHAPTERS): return false
		if not integer(c.get("route"),0,2) or not c.loadout.get("operation_xp") is Array or c.loadout.operation_xp.size()!=3: return false
		for i in range(3):
			if not integer(c.loadout.operation_xp[i],0,OperationRules.SURVIVAL_XP[i]): return false
	if c.loadout.has("unified_mastery"):
		if c.loadout.unified_mastery!=true or not c.loadout.get("review19",false): return false
		if not integer(c.get("level"),1,2147483647): return false
		if not c.get("tree") is Dictionary or not integer(c.get("spent"),0,int(c.get("level",0))): return false
		var tree: Dictionary=LevelMastery.TREE if c.loadout.get("level22",false) else ExpeditionTree.UNIFIED
		var spent:=0
		for id in c.tree:
			if not tree.has(id) or not integer(c.tree[id],0,tree[id].max): return false
			spent+=int(c.tree[id])
			var parent: String=tree[id].parent
			if c.tree[id]>0 and parent!="" and c.tree.get(parent,0)<=0: return false
			if c.loadout.get("level22",false) and c.tree[id]>0 and parent!="" and c.tree.get(parent,0)<tree[parent].max: return false
		if spent!=c.spent: return false
	if c.loadout.has("level22") and (c.loadout.level22!=true or not c.loadout.get("operation20",0)>0): return false
	if c.loadout.has("support23") and (c.loadout.support23!=true or not c.loadout.get("level22",false)): return false
	if c.loadout.has("arsenal26") and (c.loadout.arsenal26!=true or not c.loadout.get("support23",false)): return false
	if c.loadout.has("vanguard"):
		if not integer(c.loadout.get("hammer_rank",1),1,10): return false
		if not c.get("bindings") is Dictionary: return false
		if c.loadout.vanguard!=true or not c.loadout.get("rewards18") is Array or c.loadout.rewards18.size()>256: return false
		if not integer(c.loadout.get("reward_turn18"),0,1000000): return false
		for reward in c.loadout.rewards18:
			if reward not in ["learn","upgrade"]: return false
		for slot in Vanguard.TOOLS:
			if slot=="p1":
				if c.loadout.passives[0]!="orbit": return false
			elif c.loadout.get(slot)!=Vanguard.TOOLS[slot]: return false
			if c.get("bindings",{}).get(slot)!=Vanguard.KEYS[slot]: return false
	for key in ["ranks","tiers","upgrades","stats","bindings"]:
		if not c.get(key) is Dictionary: return false
	if not c.get("discovered") is Array or c.discovered.size()>11: return false
	if not c.get("toggles") is Array or c.toggles.size()!=9: return false
	for toggle in c.toggles:
		if not toggle is bool: return false
	var used: Array=[]
	var ids: Array=[]
	for slot in c.discovered:
		if slot not in BotKeyboard.ACTIVE_BANKS+["p1","p2","p3","p4","p5","p6","p7","p8","p9"]: return false
		var id: String=c.loadout.passives[int(slot.substr(1))-1] if slot.begins_with("p") else c.loadout[slot]
		if id=="" or id in ids: return false
		ids.append(id)
		var key: Variant=c.bindings.get(slot)
		if not integer(key,1,10000000) or int(key) in used or not BotKeyboard.allowed(id,int(key)): return false
		used.append(int(key))
	if "ricochet" in ids and "orbit" not in ids: return false
	for id in c.loadout.get("library",{}):
		if id in ids: return false
	for slot in BotKeyboard.ACTIVE_BANKS:
		if not integer(c.ranks.get(slot),0,10) or not integer(c.tiers.get(slot),0,2) or c.upgrades.get("skill_"+slot)!=c.ranks[slot]: return false
	if c.loadout.get("vanguard",false):
		if not c.loadout.get("library",{}).is_empty() or c.get("sniper",false): return false
		for slot in c.discovered:
			if slot not in Vanguard.KEYS: return false
		for slot in Vanguard.KEYS:
			var rank_value: int=int(c.upgrades.get("grinder",0)) if slot=="p1" else int(c.ranks[slot])
			if (slot in c.discovered)!=(rank_value>0): return false
	for key in ["ability_rank","forge_pet"]:
		if not integer(c.stats.get(key,0),0,1): return false
	var old: Dictionary=c.duplicate(true)
	if c.loadout.get("level22",false): old.tree={}; old.spent=0
	old["class"]="ranged" if c.get("class","")=="shared" else c.get("class","ranged")
	old.loadout=BotExpedition.class_loadout(old["class"])
	old.toggles=old.toggles.slice(0,4)
	old.discovered=old.discovered.filter(func(slot): return slot in MobaKit.BIND_SLOTS)
	old.stats.erase("ability_rank"); old.stats.erase("forge_pet")
	for slot in ["x1","x2","x3","x4"]: old.upgrades.erase("skill_"+slot)
	return ExpeditionGear.valid_checkpoint(old)

func restore(data: Dictionary) -> void:
	starting_ability=data.get("starting_ability",false)
	credits = int(data.credits); unlocked_ascension = int(data.ascension)
	chapter_cleared=int(data.get("chapter_cleared",0))
	recovery_used=data.get("recovery_used",[]).duplicate(); recovery_target=int(data.get("recovery_target",0))
	if data.has("crate_rng"): rng.state=int(data.crate_rng)
	inventory = data.inventory.duplicate(true); equipped = data.equipped.duplicate()
	checkpoint = data.checkpoint.duplicate(true); migration = data.migration.duplicate(true)
	loadouts = data.get("loadouts", {}).duplicate(true)

func load_profile() -> void:
	if FileAccess.file_exists(path):
		var file:=FileAccess.open(path,FileAccess.READ)
		if file==null: blocked=true; message="Save unreadable. Original preserved."; return
		var data: Variant=JSON.parse_string(file.get_as_text())
		if valid(data): restore(data)
		else: blocked=true; message="Save damaged. Original preserved."
		return
	var previous:=ExpeditionGear.new()
	previous.load_profile()
	if previous.blocked: blocked=true; message=previous.message; return
	if not FileAccess.file_exists(ExpeditionGear.PATH) and not FileAccess.file_exists(BotEquipment.PATH): return
	import_previous(previous.snapshot())

func import_previous(data: Dictionary) -> bool:
	if not ExpeditionGear.new().valid(data): return false
	credits=int(data.credits); unlocked_ascension=int(data.ascension)
	for item in inventory.values(): item.copies=0
	for slot in SLOTS: equipped[slot]=""
	for id in data.inventory:
		var old: Dictionary=data.inventory[id]
		var slot: String=ExpeditionGear.ITEMS[id].slot
		var target: String="courier_"+slot
		inventory[target].copies=mini(999,inventory[target].copies+int(old.copies)+int(old.stars)*(int(old.stars)+1)/2)
		if id in data.equipped.values() and inventory[target].copies>0: equipped[slot]=target
	checkpoint=data.checkpoint.duplicate(true)
	if not checkpoint.is_empty():
		checkpoint.stats={}; checkpoint.sets={}; checkpoint.equipment=[]
		for i in range(checkpoint.items.size()): checkpoint.items[i]="courier_"+ExpeditionGear.ITEMS[checkpoint.items[i]].slot
		for i in range(checkpoint.shop.size()):
			if checkpoint.shop[i]!="": checkpoint.shop[i]="courier_"+ExpeditionGear.ITEMS[checkpoint.shop[i]].slot
	migration={"source":ExpeditionGear.PATH,"original":data.duplicate(true),"rule":"Same-slot tier-1 copies; old stars return consumed duplicates. Old file preserved."}
	message="Collection converted. Original save preserved."
	return true

func save() -> bool:
	if blocked or not valid(snapshot()): return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(snapshot())); file.flush()
	var ok := file.get_error() == OK
	file.close()
	if not ok: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) == OK

func transact(action: String, id: String, persist: bool=true) -> bool:
	if blocked or not ITEMS.has(id) or inventory[id].copies<1: return false
	var before:=snapshot()
	if action=="equip": equipped[ITEMS[id].slot]=id
	elif action=="forge":
		var tier: int=ITEMS[id].tier
		if tier>=5 or inventory[id].copies<3:
			message="Highest tier" if tier>=5 else "3 copies required"
			return false
		var next: String=SETS[tier]+"_"+ITEMS[id].slot
		if inventory[next].copies>=999: message="Inventory full"; return false
		inventory[id].copies-=3; inventory[next].copies+=1
		if equipped[ITEMS[id].slot]==id: equipped[ITEMS[id].slot]=next
	else: return false
	if persist and not save(): restore(before); message="Save failed. Nothing spent."; return false
	message=""
	return true

func values(id: String) -> Dictionary:
	var data: Dictionary=ITEMS[id]
	var factor: float=[1.0,2.0,3.5,5.5,8.0][data.tier-1]
	var result: Dictionary={"health":(7.0 if data.slot in ["helmet","legs","flower","cape"] else 2.0)*factor,"resistance":(4.0 if data.slot=="chest" else 1.0)*factor}
	if data.slot=="boots": result.speed=[0.085,0.12,0.17,0.23,0.30][data.tier-1]
	if data.tier>=3 and data.slot=="helmet": result.regen=0.4*(data.tier-2)
	if data.tier>=3 and data.slot=="chest": result.health_regen=0.25*(data.tier-2)
	return result

func item_text(id: String) -> String:
	var lines: Array[String]=[]
	for key in values(id):
		var value: float=values(id)[key]
		lines.append("+%s%s %s"%[str(snappedf(value*(100 if key=="speed" else 1),0.01)),"%" if key=="speed" else "",{"regen":"energy / sec","health_regen":"health / sec"}.get(key,key)])
	if ITEMS[id].tier>=4: lines.append("+1 learned ability rank (once across equipment)")
	if ITEMS[id].tier>=5: lines.append("Gun companion (one, does not stack)")
	return "\n".join(lines)

func apply_to(run) -> void:
	var total: Dictionary={}
	var highest:=0
	run.equipment_snapshot.clear()
	for id in equipped.values():
		if id=="": continue
		for key in values(id): total[key]=float(total.get(key,0))+values(id)[key]
		var data: Dictionary=ITEMS[id]
		highest=maxi(highest,data.tier)
		run.equipment_snapshot.append({"name":data.name,"slot":data.slot,"icon":data.icon,"stars":0,"tier":data.tier,"stats":item_text(id)})
	total.ability_rank=1 if highest>=4 else 0
	total.forge_pet=1 if highest>=5 else 0
	run.exp.gear_stats=total; run.exp.set_counts={}
	run.exp.sync_stats(run)

func pack_run(run) -> Dictionary:
	return {
		"receipt":run.exp.reward_receipt.duplicate(true),
		"route": run.exp.route_index, "ascension": run.exp.ascension, "class": run.exp.class_id,
		"bindings":run.kit.bindings.duplicate(), "loadout": run.kit.loadout.duplicate(true), "discovered": run.kit.discovered.duplicate(),
		"ranks": run.kit.ranks.duplicate(), "tiers": run.kit.tiers.duplicate(), "upgrades": run.upgrades.duplicate(),
		"tree": run.mastery.ranks.duplicate(), "spent": run.mastery.spent,
		"level": run.level, "xp": run.total_xp, "next": run.next_level, "health": run.health, "energy": run.kit.energy,
		"pending": run.exp.pending_chests, "opened": run.exp.chests_opened, "field": run.exp.field_credits,
		"items": run.exp.pending_items.duplicate(), "stats": run.exp.gear_stats.duplicate(), "sets": run.exp.set_counts.duplicate(),
		"seed": run.run_seed, "consumables": run.consumables.duplicate(),
		"toggles": run.kit.toggles.duplicate(), "sniper": run.kit.gun_sniper, "orbit_far": run.kit.orbit_far,
		"arc_focused": run.kit.arc_focused, "converter": run.kit.extra.converter_mode,
		"rng": str(run.spawn_rng.state), "offers_rng": str(run.offer_rng.state), "loot_rng": str(run.loot_rng.state),
		"shop": run.exp.shop_stock.duplicate(), "time": run.time, "kills": run.kills, "equipment": run.equipment_snapshot.duplicate(true)}

func bank_camp(run, persist: bool = true) -> bool:
	if run.state != "camp" or blocked: return false
	run.exp.ensure_shop(run)
	var before := snapshot()
	credits = mini(10000000, credits + int(run.exp.carry_credits * (1 + run.exp.ascension * 0.1)))
	if LevelMastery.enabled(run) and run.mastery.rank_of("charge")>0 and not run.exp.practice: starting_ability=true
	if LevelMastery.enabled(run): credits=mini(10000000,credits+roundi(run.exp.carry_credits*run.mastery.value("loot_bonus")))
	if LevelMastery.enabled(run) and run.exp.final_round() and run.exp.clear_clock==-2 and recovery_target==run.exp.operation_chapter:
		credits=mini(10000000,credits+45); recovery_target=0
	if OperationRules.enabled(run) and run.exp.final_round() and run.exp.clear_clock==-2 and run.exp.operation_chapter>chapter_cleared:
		chapter_cleared=run.exp.operation_chapter; credits=mini(10000000,credits+100)
		if recovery_target>0 and recovery_target+1<=chapter_cleared: recovery_target=0
	for id in run.exp.pending_items: inventory[id].copies = mini(999, inventory[id].copies + 1)
	checkpoint = pack_run(run)
	checkpoint.items = []
	if persist and not save(): restore(before); message = "Save failed. Rewards remain unbanked."; return false
	run.exp.carry_credits = 0; run.exp.pending_items.clear()
	message = ""
	return true

func resume_into(run) -> bool:
	if checkpoint.is_empty() or not valid_checkpoint(checkpoint): return false
	var c := checkpoint
	var expedition := BotExpedition.new()
	expedition.start(run, c.class, int(c.ascension))
	expedition.route_index = int(c.route); expedition.gear_stats = c.stats.duplicate(); expedition.set_counts = c.sets.duplicate()
	run.kit.loadout = c.loadout.duplicate(true); run.kit.discovered = c.discovered.duplicate()
	expedition.operation_chapter=int(c.loadout.get("operation20",0))
	if c.has("bindings"): run.kit.bindings=c.bindings.duplicate()
	run.kit.ranks = c.ranks.duplicate(); run.kit.tiers = c.tiers.duplicate(); run.upgrades = c.upgrades.duplicate()
	run._sync_resource_ranks()
	run.kit.toggles.assign(c.toggles); run.kit.gun_sniper = c.sniper; run.kit.orbit_far = c.orbit_far
	run.kit.arc_focused = c.arc_focused; run.kit.extra.converter_mode = int(c.converter)
	for slot in run.kit.active_slots():
		run.kit.charges[slot] = int(MobaKit.ABILITIES[run.kit.loadout[slot]].max)
		if Vanguard.enabled(run) and slot in ["q","w","e"]: run.kit.charges[slot]=2
		if ArsenalBurst.enabled(run) and slot=="e" and run.kit.effective_rank("e")>=10: run.kit.charges.e=4
		run.kit.recharge[slot] = 0.0
	run.mastery.ranks = c.tree.duplicate(); run.mastery.spent = int(c.spent)
	run.mastery.unified=c.loadout.get("unified_mastery",false)
	run.mastery.modern=c.loadout.get("level22",false)
	run.level = int(c.level); run.total_xp = int(c.xp); run.next_level = int(c.next)
	expedition.pending_chests = int(c.pending); expedition.chests_opened = int(c.opened); expedition.field_credits = int(c.field)
	expedition.pending_items.assign(c.items)
	apply_to(run)
	run.health = minf(run.max_health(), c.health); run.kit.energy = minf(run.kit.energy_max(), c.energy)
	run.state = "camp"; expedition.clear_clock = -2
	run.consumables.assign(c.consumables)
	run.spawn_rng.state=int(c.rng); run.offer_rng.state=int(c.offers_rng); run.loot_rng.state=int(c.loot_rng)
	expedition.shop_stock.assign(c.shop)
	expedition.reward_receipt=c.get("receipt",RewardLedger.empty()).duplicate(true)
	run.time=float(c.get("time",0)); run.kills=int(c.get("kills",0))
	BotKeyboard.enable(run)
	if run.kit.loadout.get("rules17",false): expedition.enable_revision(run)
	return true
