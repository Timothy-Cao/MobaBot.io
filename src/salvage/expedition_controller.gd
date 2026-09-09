extends "res://src/salvage/workshop.gd"
## The expanded game entry point. Legacy workshop scene remains a regression fixture.
var collection = ForgeEquipment.new()
var fullscreen_setting := true
var pending_discovery := -1
var keyboard_target := 0
var keyboard_return := "build"
var class_choice := "ranged"
var ascension_choice := 0
var gear_slot := "helmet"
var gear_item := "courier_helmet"
var banked_camp := -1

func _ready() -> void:
	collection.load_profile()
	super._ready()
	ui.expedition_ui = true
	ui.host=self
	ui.keyboard_requested.connect(open_keyboard)
	if persistent_run(): apply_fullscreen()
	if screen == "home": ui.show_home()
	select_class(class_choice)
	get_window().title="MobaBot.io · Expedition"

func select_class(id: String) -> void:
	class_choice = id
	ui.loadout_config = BotExpedition.class_loadout(id).duplicate(true)

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
		expedition.start(model,class_choice,ascension_choice)
		BotKeyboard.enable(model)
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
	if index<0 or index>=model.exp.chest_choices.size(): return
	if model.kit.flexible() and BotKeyboard.learned(model.kit,model.exp.chest_choices[index].id)=="":
		pending_discovery=index; keyboard_target=0; screen="keyboard"; KeyboardView.draw(self); return
	if not model.exp.choose_chest(model,index): return
	finish_discovery()

func finish_discovery() -> void:
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
	var price: int=100+ForgeEquipment.ITEMS[id].tier*100
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

func _close_settings() -> void:
	super._close_settings()
	ui.rebind_system=""
	match screen:
		"chest": ExpeditionView.chest(self)
		"camp": ExpeditionView.camp(self)
		"gear": ExpeditionView.gear(self)
		"prepare": ExpeditionView.prepare(self)
		"build": ui.show_build(model,false)

func _bank_loot(completed_level: int) -> void:
	if model.exp==null: super._bank_loot(completed_level); return
	if not persistent_run(): return
	var before:=collection.snapshot()
	collection.credits=mini(10000000,collection.credits+model.coins)
	if model.state=="won": collection.unlocked_ascension=mini(5,maxi(collection.unlocked_ascension,model.exp.ascension+1))
	collection.checkpoint.clear()
	if not collection.save(): collection.restore(before); collection.message="Could not save rewards. Last checkpoint preserved."

func _input(event: InputEvent) -> void:
	if screen=="settings" and ui.rebind_system!="" and event is InputEventKey and event.pressed and not event.echo:
		var candidate: Dictionary=ui.system_keys.duplicate()
		candidate[ui.rebind_system]=event.keycode
		if BotKeyboard.valid_system(candidate):
			ui.system_keys=candidate; ui.rebind_system=""; _save_settings(); ui.show_settings()
		else: ui.announce("Reserved or already assigned",1.5)
		get_viewport().set_input_as_handled(); return
	if screen=="keyboard" and event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT: keyboard_key(event.keycode)
			elif event.keycode==ui.system_keys.settings: close_keyboard()
		get_viewport().set_input_as_handled(); return
	event=system_event(event)
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


func open_keyboard() -> void:
	pending_discovery=-1; keyboard_target=0; keyboard_return=screen
	tab_held=false; _clear_held_movement(); screen="keyboard"
	KeyboardView.draw(self)

func close_keyboard() -> void:
	if pending_discovery>=0:
		pending_discovery=-1; screen="chest"; ExpeditionView.chest(self)
	else:
		screen="build"; ui.show_build(model,false)

func keyboard_key(key: int) -> void:
	if pending_discovery>=0:
		if BotKeyboard.can_place(model.kit,model.exp.chest_choices[pending_discovery].id,key): keyboard_target=key
	elif keyboard_target==0: keyboard_target=key
	else:
		BotKeyboard.swap(model.kit,keyboard_target,key); keyboard_target=0
	KeyboardView.draw(self)

func place_discovery() -> void:
	if keyboard_target==0 or not KeyboardRewards.choose(model,pending_discovery,keyboard_target): return
	pending_discovery=-1; keyboard_target=0; finish_discovery()

func system_event(event: InputEvent) -> InputEvent:
	if not event is InputEventKey: return event
	var mapped: InputEventKey=event.duplicate()
	for action in BotKeyboard.SYSTEM_DEFAULTS:
		if event.keycode==ui.system_keys[action]:
			mapped.keycode=BotKeyboard.SYSTEM_DEFAULTS[action]; return mapped
	if event.keycode in BotKeyboard.SYSTEM_DEFAULTS.values(): mapped.keycode=0
	return mapped

func _unhandled_key_input(event: InputEvent) -> void:
	if screen=="keyboard": return
	super._unhandled_key_input(system_event(event))

func _load_settings() -> void:
	super._load_settings()
	var config:=ConfigFile.new()
	if config.load("user://salvage_settings.cfg")!=OK: return
	fullscreen_setting=bool(config.get_value("visual","fullscreen",true))
	PaintedIcons.enabled=config.get_value("visual","icon_skin","painted")!="base"
	var keys: Variant=config.get_value("keyboard","system",BotKeyboard.SYSTEM_DEFAULTS)
	if keys is Dictionary and BotKeyboard.valid_system(keys): ui.system_keys=keys.duplicate()

func _save_settings() -> void:
	super._save_settings()
	if not persist_settings: return
	var config:=ConfigFile.new(); config.load("user://salvage_settings.cfg")
	config.set_value("visual","fullscreen",fullscreen_setting)
	config.set_value("visual","icon_skin","painted" if PaintedIcons.enabled else "base")
	config.set_value("keyboard","system",ui.system_keys)
	if config.save("user://salvage_settings.cfg")!=OK: ui.announce("Could not save settings",2)

func apply_fullscreen() -> void:
	get_window().mode=Window.MODE_FULLSCREEN if fullscreen_setting else Window.MODE_WINDOWED
	if not fullscreen_setting: get_window().size=Vector2i(1536,864)

func toggle_fullscreen() -> void:
	fullscreen_setting=not fullscreen_setting; apply_fullscreen(); _save_settings(); ui.show_settings()

func toggle_skin() -> void:
	PaintedIcons.enabled=not PaintedIcons.enabled
	ui.bar_signature=""; _save_settings(); ui.show_settings()

func confirm_leave() -> void:
	var dialog:=ConfirmationDialog.new(); dialog.title="Leave run?"
	dialog.dialog_text="Continue returns to the last cleared round."
	dialog.confirmed.connect(func() -> void: show_home(); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.popup_centered(Vector2i(440,140))
