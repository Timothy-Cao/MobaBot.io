class_name UpgradePreview
extends RefCounted
## Read-only projections: no rank changes, RNG draws, charges or save writes.

static func stats(run, slot: String, earned: int) -> Dictionary:
	var rank_value:=mini(10,earned+run.kit.rank_bonus)
	var power:=Vanguard.power(rank_value)
	var attack: float=1+run.kit.attack_damage_bonus
	var area:=1.0+SalvageProgression.milestone(rank_value)*0.25
	var data: Dictionary={}
	if slot=="gun":
		return {"Damage":1.2*Vanguard.GUN_POWER[rank_value]*attack,"Shots / sec":SalvageProgression.multiplier(run.rank_of("rapid"))*(1+run.kit.attack_speed_bonus)/Vanguard.GUN_INTERVAL[rank_value]}
	if slot=="hammer":
		return {"Head damage":38*power*attack*0.9,"Reach":125*area+run.kit.attack_range_bonus,"Swing / sec":(1+run.kit.attack_speed_bonus)/(1.05-0.05*int(rank_value/5))}
	# A separate kit gives learned previews the same equipment-rank semantics as a purchase.
	var kit:=MobaKit.new()
	kit.loadout=run.kit.loadout.duplicate(true); kit.ranks=run.kit.ranks.duplicate()
	kit.discovered=run.kit.discovered.duplicate(); kit.discovered.append(slot)
	kit.ranks[slot]=earned; kit.tiers=run.kit.tiers.duplicate(); kit.rank_bonus=run.kit.rank_bonus
	kit.gear_damage=run.kit.gear_damage; kit.mastery_damage=run.kit.mastery_damage; kit.cooldown_bonus=run.kit.cooldown_bonus
	kit.energy_efficiency=run.kit.energy_efficiency
	var scale_value:=kit.damage_scale(slot)
	match slot:
		"q": data={"Direct + blast":23*scale_value,"Blast radius":62*area}
		"w": data={"Center damage":76*scale_value,"Radius":100*area}
		"e": data={"Impact damage":32*scale_value,"Reach":kit.cast_range(slot)}
		"r": data={"Impact damage":135*scale_value*(0.8 if rank_value>=10 else 1.0),"Radius":170*area}
		"d": return {"Energy / sec":lerpf(28,10,float(clampi(rank_value,1,10)-1)/9.0)*(1-run.kit.energy_efficiency),"Speed bonus %":65+(rank_value-1)*3.5}
		"f": data={"Charges":2 if rank_value>=5 else 1,"Energy":kit.ability_cost("blink"),"Reach":kit.cast_range(slot)}
	data["Recharge sec"]=kit.cooldown(slot)
	return data

static func milestone(slot: String, before: int, after: int) -> String:
	if before<5 and after>=5:
		return {"gun":"Fire while driving: off → on","hammer":"Sweep: 90° → 120°","e":"Impact stun: 0 → 0.6s","r":"Impact shield: 0 → 1.5s"}.get(slot,"")
	if before<10 and after>=10:
		return {"gun":"Every fifth shot: 1× → 2×","hammer":"Moving swings: off → on","e":"Impact shield: 0 → 1s","r":"Follow-up damage: 0 → 25%","d":"Cast while driving: off → on","f":"Landing blast: off → on"}.get(slot,"")
	return ""

static func number(value: float) -> String:
	var rounded:=snappedf(value,0.01)
	return str(roundi(rounded)) if is_equal_approx(rounded,roundf(rounded)) else str(rounded)

static func text(run, slot: String) -> String:
	var earned:=Vanguard.rank_of(run,slot)
	var before:=stats(run,slot,maxi(1,earned))
	var after:=stats(run,slot,mini(10,earned+1))
	var lines: Array[String]=[]
	for key in after:
		if earned==0: lines.append("%s  %s"%[key,number(after[key])])
		elif not is_equal_approx(before[key],after[key]): lines.append("%s  %s → %s"%[key,number(before[key]),number(after[key])])
	var extra:=milestone(slot,mini(10,earned+run.kit.rank_bonus),mini(10,earned+1+run.kit.rank_bonus))
	if not extra.is_empty(): lines.append(extra)
	if lines.is_empty(): lines.append("Earned rank  %d → %d"%[earned,earned+1]); lines.append("Equipment already grants rank 10")
	return "\n".join(lines)
