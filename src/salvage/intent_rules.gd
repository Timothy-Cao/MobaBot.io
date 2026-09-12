class_name IntentRules
extends RefCounted
## New-run pacing and offer policy; old checkpoints keep their original rules.
const OFFENSE := ["q","w","e","r","gun","hammer"]
static func enabled(run) -> bool:
	return DiscoveryRules.enabled(run) and run.kit.loadout.get("intent39",false)==true and not run.exp.practice
static func enable(run) -> void:
	run.kit.loadout.intent39=true
	run.kit.loadout.intent_choices=0
	run.kit.loadout.intent_focus="q"
static func valid(data: Dictionary) -> bool:
	if not data.has("intent39"):
		return not data.has("intent_choices") and not data.has("intent_focus")
	return typeof(data.intent39)==TYPE_BOOL and data.intent39==true and data.get("discovery35",false)==true and ForgeEquipment.integer(data.get("intent_choices"),0,1000000) and data.get("intent_focus","") in OFFENSE
static func survival_expected(run, budget: int) -> int:
	var time: float=clampf(run.stage_time,0,run.exp.round_seconds())
	if run.exp.route_index!=0: return floori(budget*time/run.exp.round_seconds())
	# Move six existing points forward; the full-round budget stays identical.
	if time<=15: return floori(6.0*time/15.0)
	return mini(budget,6+floori((budget-6)*(time-15)/(run.exp.round_seconds()-15)))
static func protect_offers(run, pool: Array) -> void:
	if not enabled(run): return
	var count: int=run.kit.loadout.intent_choices
	var focus: String=run.kit.loadout.intent_focus
	# Every other choice supports the player's last chosen offensive investment.
	# Other cards keep their random draws; no extra RNG or hidden rank awards.
	if count%2==0 and focus in pool: place_offer(run,focus,0)
	# A second-choice E offer teaches the class; declining it remains valid.
	if count==1 and Vanguard.rank_of(run,"e")==0 and "e" in pool: place_offer(run,"e",1)
	if count==2 and Vanguard.rank_of(run,"w")==0 and "w" in pool: place_offer(run,"w",1)
static func place_offer(run, id: String, slot: int) -> void:
	if run.offers.size()<=slot: return
	var existing: int=run.offers.find(id)
	if existing>=0: run.offers[existing]=run.offers[slot]
	run.offers[slot]=id
static func chosen(run, id: String) -> void:
	if not enabled(run): return
	run.intent_decisions.append({"seconds":snappedf(run.time,0.1),"round":run.exp.route_index+1,"level":run.level,"offered":run.offers.duplicate(),"chosen":id,"rank":DiscoveryRules.rank_of(run,id) if id in DiscoveryRules.BONUS else Vanguard.rank_of(run,id) if id in ReviewRules.CORE else 0})
	if run.intent_decisions.size()>160: run.intent_decisions.pop_front()
	run.kit.loadout.intent_choices=mini(1000000,run.kit.loadout.intent_choices+1)
	if id in OFFENSE: run.kit.loadout.intent_focus=id

static func pressure_phase(run) -> float:
	return fposmod(run.stage_time-100.0,50.0)
static func spawn_delay(run) -> float:
	if not enabled(run) or run.stage_time<100: return 1.0
	var phase:=pressure_phase(run)
	return 0.9 if phase<12 else 1.8 if phase>=35 else 1.0
static func pressure_pack(run) -> bool:
	# A few fast packs punctuate the surge; twelve straight seconds of elites
	# created a sharp difficulty cliff in the first comparison.
	return run.stage_time>=100 and pressure_phase(run)<12 and int(run.stage_time)%4==0
static func pack_side(run) -> int:
	# Same approach for ten seconds creates readable groups and open flanks.
	# The spawn itself still uses the existing offscreen/world-edge safeguards.
	return posmod(int(run.stage_time/10)+run.run_seed,4)
