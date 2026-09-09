extends "res://src/salvage/workshop.gd"
## The expanded game entry point. Legacy workshop scene remains a regression fixture.
var collection := ExpeditionGear.new()
var class_choice := "ranged"
var ascension_choice := 0
var gear_slot := "helmet"
var gear_item := "courier_helmet"
var banked_camp := -1

func _ready() -> void:
	collection.load_profile()
	super._ready()
	ui.expedition_ui = true
	if screen == "home": ui.show_home()
	select_class(class_choice)
	ui.loadout_changed.connect(func(config: Dictionary, _keys: Dictionary) -> void:
		var before := collection.snapshot()
		collection.loadouts[class_choice] = config.duplicate(true)
		if persistent_run() and not collection.save(): collection.restore(before); ui.loadout_message = "Could not save loadout")
	get_window().title="MobaBot.io · Expedition"

func select_class(id: String) -> void:
	class_choice = id
	ui.loadout_config = collection.loadouts.get(id, BotExpedition.class_loadout(id)).duplicate(true)

func persistent_run() -> bool:
	return not auto_play and capture_kind.is_empty() and persist_settings

func start_run(mode: String="salvage") -> void:
	if auto_play or not capture_kind.is_empty(): super.start_run(mode); return
	screen="prepare"
	ExpeditionView.prepare(self)

func launch_expedition(resume: bool=false) -> void:
	if collection.blocked:
		ui.announce(collection.message,2); return
	seed_value=int(collection.checkpoint.get("seed",2407)) if resume else int(Time.get_unix_time_from_system())%2147483647
	super.start_run("salvage")
	if resume:
		if not collection.resume_into(model): show_home(); return
		banked_camp=model.exp.route_index
		screen="camp"; ExpeditionView.camp(self)
	else:
		var expedition:=BotExpedition.new()
		expedition.start(model,class_choice,ascension_choice,collection.loadouts.get(class_choice, {}))
		collection.apply_to(model)
		model.health=model.max_health(); model.kit.energy=model.kit.energy_max()
		banked_camp=-1
		collection.checkpoint.clear()
		if persistent_run() and not collection.save(): ui.announce("Save unavailable; run is not protected",2)
		ui.show_running()
	free_center=model.player
	_update_camera(); ui.update_hud(model)

func confirm_new_run() -> void:
	if collection.checkpoint.is_empty(): launch_expedition(false); return
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Replace the saved expedition? Banked equipment stays."
	dialog.title = "New expedition"
	dialog.confirmed.connect(func() -> void: launch_expedition(false); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.popup_centered(Vector2i(440,140))

func _physics_process(delta: float) -> void:
	if model!=null and model.kit!=null: model.kit.extra.cursor=get_global_mouse_position()
	super._physics_process(delta)
	if model==null or model.exp==null: return
	if screen=="result" and collection.message.begins_with("Could not save") and not ui.overlay.has_node("ExpeditionSaveError"):
		var warning: Label=ui._label(ui.overlay,collection.message,Rect2(220,449,500,21),12,ui.CORAL)
		warning.name="ExpeditionSaveError"
	if screen=="running" and model.state=="chest":
		_clear_held_movement(); screen="chest"; ExpeditionView.chest(self)
	elif screen=="running" and model.state=="camp":
		_clear_held_movement(); screen="camp"
		if banked_camp!=model.exp.route_index:
			if collection.bank_camp(model,persistent_run()): banked_camp=model.exp.route_index
		ExpeditionView.camp(self)

func open_discovery() -> void:
	if model.exp.pending_chests<=0: return
	model.exp.make_chest(model); model.state="chest"; screen="chest"
	ExpeditionView.chest(self)

func choose_discovery(index: int) -> void:
	if not model.exp.choose_chest(model,index): return
	if model.state=="camp":
		collection.bank_camp(model,persistent_run()); screen="camp"; ExpeditionView.camp(self)
	else: screen="running"; ui.show_running()

func continue_expedition() -> void:
	if not collection.bank_camp(model,persistent_run()): ExpeditionView.camp(self); return
	model.exp.shop_stock.clear()
	model.exp.advance(model)
	screen="running"; ui.show_running()
	free_center=model.player; _update_camera()

func buy_item(index: int) -> void:
	var exp: BotExpedition=model.exp
	if model.state!="camp" or not exp.is_shop() or index<0 or index>=exp.shop_stock.size(): return
	var id: String=exp.shop_stock[index]
	if id == "": return
	var price: int=100+ExpeditionGear.ITEMS[id].tier*100
	if exp.field_credits<price: return
	exp.field_credits-=price; exp.pending_items.append(id); exp.shop_stock[index] = ""
	if not collection.bank_camp(model,persistent_run()):
		exp.field_credits+=price; exp.pending_items.erase(id); exp.shop_stock[index] = id
	ExpeditionView.camp(self)

func _open_gear() -> void:
	gear_return = "camp" if screen == "camp" else "home"
	screen="gear"; ExpeditionView.gear(self)

func close_gear() -> void:
	if gear_return == "camp": screen = "camp"; ExpeditionView.camp(self)
	else: show_home()

func gear_action(action: String, id: String) -> void:
	if collection.transact(action,id,persistent_run()) and gear_return == "camp":
		collection.apply_to(model)
		collection.bank_camp(model,persistent_run())
	ExpeditionView.gear(self)

func _close_build() -> void:
	super._close_build()
	if screen=="camp":
		collection.bank_camp(model,persistent_run()); ExpeditionView.camp(self)

func _bank_loot(completed_level: int) -> void:
	if model.exp==null: super._bank_loot(completed_level); return
	if not persistent_run(): return
	var before:=collection.snapshot()
	collection.credits=mini(10000000,collection.credits+model.coins)
	if model.state=="won": collection.unlocked_ascension=mini(5,maxi(collection.unlocked_ascension,model.exp.ascension+1))
	collection.checkpoint.clear()
	if not collection.save(): collection.restore(before); collection.message="Could not save rewards. Last checkpoint preserved."

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if screen=="chest" and event.keycode in [KEY_1,KEY_2,KEY_3]:
			choose_discovery(event.keycode-KEY_1); get_viewport().set_input_as_handled(); return
		if screen in ["prepare","camp","gear"] and event.keycode==KEY_ESCAPE:
			if screen == "gear": close_gear()
			else: show_home()
			get_viewport().set_input_as_handled(); return
		if screen=="camp" and event.keycode==KEY_TAB:
			_open_build(); get_viewport().set_input_as_handled(); return
	super._input(event)
