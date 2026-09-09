class_name KeyboardRewards
extends RefCounted

static func make_chest(run) -> void:
	var exp: BotExpedition=run.exp
	exp.chest_choices.clear()
	exp.chest_return="camp" if run.state=="camp" else "running"
	var pool: Array=[]
	for category in ["active","ultimate","speed","mobility","summon"]:
		for id in BotSkillCatalog.modern_ids(category):
			if id not in pool: pool.append(id)
	for id in MobaKit.PASSIVES:
		if id!="ricochet" or BotKeyboard.learned(run.kit,"orbit")!="": pool.append(id)
	for i in range(3):
		var id: String=BotSkillCatalog.draw_discovery(pool,run.offer_rng)
		if i==0 and exp.chests_opened==0: id="returner" if exp.revised else BotExpedition.CLASSES[exp.class_id].w
		pool.erase(id)
		var rarity:=2 if run.offer_rng.randf()<0.08 else (1 if run.offer_rng.randf()<0.25 else 0)
		exp.chest_choices.append({"slot":BotKeyboard.learned(run.kit,id),"id":id,"tier":rarity})

static func choose(run, index: int, key: int=0) -> bool:
	var exp: BotExpedition=run.exp
	if run.state!="chest" or exp.pending_chests<=0 or index<0 or index>=exp.chest_choices.size(): return false
	var choice: Dictionary=exp.chest_choices[index]
	var slot:=BotKeyboard.learned(run.kit,choice.id)
	if exp.revised and slot=="" and (SkillLibrary.stored(run.kit,choice.id) or not SkillLibrary.has_space(run.kit,choice.id)):
		if SkillLibrary.stored(run.kit,choice.id):
			var saved: Dictionary=run.kit.loadout.library[choice.id]
			if MobaKit.PASSIVES.has(choice.id):
				var upgrade:=passive_upgrade(choice.id)
				for i in range(2):
					if run.upgrades.has(upgrade) and run.rank_of(upgrade)<run.rank_limit(upgrade): run.upgrades[upgrade]+=1
					else: exp.field_credits+=20
				run._sync_resource_ranks()
			else:
				exp.field_credits+=maxi(0,int(saved.rank)+2-10)*20
				saved.rank=mini(10,int(saved.rank)+2)
			saved.tier=maxi(int(saved.tier),int(choice.tier))
		else: SkillLibrary.remember(run.kit,choice.id,0,int(choice.tier))
	elif slot=="":
		if key==0:
			# Deterministic non-UI probes choose an empty legal position first.
			for candidate in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
				if BotKeyboard.can_place(run.kit,choice.id,candidate) and BotKeyboard.slot_at(run.kit,candidate)=="": key=candidate; break
			if key==0:
				for candidate in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT:
					if BotKeyboard.can_place(run.kit,choice.id,candidate): key=candidate; break
		if not BotKeyboard.place(run,choice.id,key,choice.tier): return false
	elif slot.begins_with("p"):
		var upgrade: String=passive_upgrade(choice.id)
		for i in range(2):
			if upgrade!="" and run.upgrades.has(upgrade) and run.rank_of(upgrade)<run.rank_limit(upgrade): run.upgrades[upgrade]=int(run.upgrades.get(upgrade,0))+1
			else: exp.field_credits+=20
		run._sync_resource_ranks()
	else:
		for i in range(2):
			if run.kit.rank_up(slot): run.upgrades["skill_"+slot]=run.kit.ranks[slot]
			else: exp.field_credits+=20
		run.kit.tiers[slot]=maxi(run.kit.tiers[slot],choice.tier)
	exp.pending_chests-=1; exp.chests_opened+=1
	if run.loot_rng.randf()<0.18: exp.pending_items.append(ForgeEquipment.roll_item(run.loot_rng,exp.ascension))
	exp.chest_choices.clear(); run.state=exp.chest_return
	return true

static func passive_upgrade(id: String) -> String:
	return {"bolt":"power","orbit":"grinder","pulse":"pulse","ricochet":"ricochet","plating":"plating","thorns":"thorns","sidebolts":"sidebolts","plates":"plates","poison":"power","lightning":"power","threehit":"power","momentum":"momentum","hopdrive":"hopdrive","converter":"converter","mounted":"mounted"}.get(id,"")

static func chest(game) -> void:
	var ui=game.ui
	ExpeditionView.frame(ui,"Choose a skill",func() -> void: pass)
	for child in ui.overlay.get_children():
		if child is Button and child.text=="Back": child.queue_free()
	var cards: Array=[]
	for i in range(game.model.exp.chest_choices.size()):
		var choice: Dictionary=game.model.exp.chest_choices[i]
		var card: Button=ui._button("",Rect2(91+i*264,141,248,282),func() -> void: game.choose_discovery(i),false)
		cards.append(card)
		card.add_theme_stylebox_override("normal",ui._style(ui.PANEL,2,MobaKit.RARITY_COLORS[choice.tier],2))
		ui._ability_icon(card,choice.id,Rect2(73,32,102,102))
		ui._label(card,KeyboardView.name_of(choice.id),Rect2(13,158,222,52),21,ui.CREAM,true,HORIZONTAL_ALIGNMENT_CENTER).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		var known:=BotKeyboard.learned(game.model.kit,choice.id)!="" or SkillLibrary.stored(game.model.kit,choice.id)
		var reward: String="+2 ranks" if MobaKit.ABILITIES.has(choice.id) or game.model.upgrades.has(passive_upgrade(choice.id)) else "40 credits"
		ui._label(card,reward if known else ("Learn · fit at camp" if game.model.exp.revised and not SkillLibrary.has_space(game.model.kit,choice.id) else "Choose key"),Rect2(13,230,222,24),15,ui.GOLD,true,HORIZONTAL_ALIGNMENT_CENTER)
		var data: Dictionary=MobaKit.PASSIVES.get(choice.id,MobaKit.ABILITIES.get(choice.id,{}))
		card.tooltip_text=SkillLibrary.description(choice.id,game.model.exp.revised)+"\n"+MobaKit.RARITIES[choice.tier]
		if i==0: card.grab_focus()
	RewardMotion.reveal(ui,cards)
