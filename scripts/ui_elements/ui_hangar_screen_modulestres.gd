extends Control
class_name HangarScreenModules




@export var hangar: Control

@export var guns: HBoxContainer
@export var engines: HBoxContainer
@export var tracks: HBoxContainer

var guns_modules: Array[Control] = []
var engines_modules: Array[Control] = []
var tracks_modules: Array[Control] = []

@export var the_tank: Control
@export var spacer_prefab: Control
@export var modules: Control

@export var info_box: VBoxContainer
@export var module_action_button: Button
@export var mod_unavailable: Label
@export var tank_name: Label

@export var selected_name: Label
@export var buy_cost_text: Label
@export var buy_cost: Label
@export var buy_currency: TextureRect

@export var tank_info_panel: Control


static var currency_xp: Texture2D = load("res://assets/gfx/ui/lobby_common/CurrencyIconsSmall04.tres")
static var currency_cred: Texture2D = load("res://assets/gfx/ui/lobby_common/CurrencyIconsSmall02_cred.tres")
static var currency_gold: Texture2D = load("res://assets/gfx/ui/lobby_common/CurrencyIconsSmall_gold.tres")

static var module_prefab: Control = load("res://assets/gfx/ui/hangar/tech_tree/ui_tank_module.tscn").instantiate()

signal on_choose_module(name: StringName, status: Global.ResearchStatus)
signal on_install_module(id: int)

var save_tank_ref: SaveTank
var selected_mod_id: Vector2i = Vector2i(0, 0)
var selected_mod_status: Global.ResearchStatus = Global.ResearchStatus.NOT_AVAILABLE

var selected_tank_name: StringName
var selected_tank_status: Global.ResearchStatus

func acc() -> Account:
	return Global.save_main.get_current_account()

enum {
	SND_INSTALL
}
func play_sound(snd: int):
	Audio.stop_sound2d(Audio.ui_enter)
	Audio.stop_sound2d(Audio.ui_select)
	match snd:
		SND_INSTALL:
			Audio.play_sound2d(Audio.ui_install)

func selected_mod_action():
	match selected_mod_status:
		Global.ResearchStatus.AVAILABLE:
			acc().try_research_module(save_tank_ref.name, selected_mod_id.x, selected_mod_id.y, hangar)
		Global.ResearchStatus.RESEARCHED:
			var success: bool = acc().install_module(save_tank_ref.name, selected_mod_id.x, selected_mod_id.y)
			if success and is_instance_valid(hangar):
				hangar.update_hangar(true, save_tank_ref.name)
				play_sound(SND_INSTALL)

func selected_tank_action():
	match selected_tank_status:
		Global.ResearchStatus.AVAILABLE:
			acc().try_research_tank(selected_tank_name, hangar)
		Global.ResearchStatus.RESEARCHED:
			acc().try_buy_tank(selected_tank_name, hangar)
		Global.ResearchStatus.INSTALLED_BOUGHT:
			acc().try_sell_tank(selected_tank_name, hangar)

func button_action():
	if selected_mod_id.x >= 0 or selected_mod_id.y >= 0:
		selected_mod_action()
	else:
		selected_tank_action()

func _ready() -> void :
	the_tank.on_pressed.connect(tank_select)
	module_action_button.pressed.connect(button_action)
	hangar.hangar_updated.connect(init.bind(self.save_tank_ref))

func force_select_module(id: int, kind: int):
	var list: Array = [guns_modules, engines_modules, tracks_modules][clampi(kind, 0, 2)]
	var mod: Control = list[clampi(id, 0, list.size() - 1)]

	if mod.has_signal("on_pressed"):
		mod.select()

func populate_with_modules(box: HBoxContainer, modules: Array, prem: bool, installed_id: int, selected: int = -1, modules_internal: Array = []):
	for c in box.get_children():
		c.queue_free()

	var modules_names: Array[String] = []
	var sorted: Array = []

	modules_internal.clear()

	module_action_button.hide()
	mod_unavailable.hide()

	for mod in modules:
		if modules_names.has(mod.name): continue
		modules_names.push_back(mod.name)
		sorted.push_back(mod)

	var modules_total: int = 1
	for mod in sorted:
		var m_prefab: Control = module_prefab.duplicate()

		var hook_onchoose: Callable = func(name: StringName, status: Global.ResearchStatus):
			if !m_prefab: return
			if name == mod.name:
				m_prefab.select()
			else:
				m_prefab.deselect()

		on_choose_module.connect(hook_onchoose)
		m_prefab.tree_exiting.connect( func():
			on_choose_module.disconnect(hook_onchoose)
		)

		m_prefab.index = modules_total - 1
		m_prefab.name = mod.name

		m_prefab.init(mod, acc().has_tank(save_tank_ref.name, true), prem, acc().has_tank(save_tank_ref.name) and modules_total - 1 == installed_id, modules_total - 1)
		m_prefab.on_pressed.connect(choose_module.bind(modules_total - 1))

		box.add_child(m_prefab)
		modules_internal.push_back(m_prefab)

		if modules_total < sorted.size():
			var s: Control = spacer_prefab.duplicate()
			s.show()
			box.add_child(s)

		modules_total += 1

func init(st: SaveTank):
	if !st:
		return

	self.save_tank_ref = st
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(save_tank_ref.name)

	tank_name.text = info.display_name

	the_tank.init(info)

	Util.timer(0.1, func():
		tank_select(save_tank_ref.name, the_tank.get_status(save_tank_ref.name))
	)

	tank_info_panel.setup_from_tank(st.name, st.gun_id, st.engine_id, st.track_id)

	module_action_button.show()
	selected_name.text = ""
	change_buy_panel(-1)

	populate_with_modules(guns, info.guns, info.prem, save_tank_ref.gun_id, -1, guns_modules)
	populate_with_modules(engines, info.engines, info.prem, save_tank_ref.engine_id, -1, engines_modules)
	populate_with_modules(tracks, info.tracks, info.prem, save_tank_ref.track_id, -1, tracks_modules)

	Util.timer(0.1, func():
		if selected_mod_id.x > 0 or selected_mod_id.y > 0:
			force_select_module(selected_mod_id.y, selected_mod_id.x)
	)

	selected_mod_id.x = clampi(selected_mod_id.x, 0, 2)

	var mod_lists: Array[HBoxContainer] = [
		guns, engines, tracks
	]
	var list: HBoxContainer = mod_lists[selected_mod_id.x]
	if !list: return

	selected_mod_id.y = clampi(selected_mod_id.y, 0, list.get_children().size() - 1)
	if selected_mod_id.y < 0: return
	var selected_mod: Node = list.get_child(selected_mod_id.y)
	if selected_mod.has_method("select") and is_instance_valid(selected_mod): selected_mod.select()

func get_all_tree_tanks() -> Array[Control]:
	return [the_tank]

func change_buy_panel(variant: int = 0, tank_prem: bool = false):
	match variant:
		-1:
			module_action_button.hide()
			mod_unavailable.hide()

			buy_cost.hide()
			buy_cost_text.hide()
			buy_currency.hide()
		0:

			module_action_button.hide()
			mod_unavailable.show()
			mod_unavailable.text = tr("hangar:research_prev_mods")

			buy_cost.hide()
			buy_cost_text.hide()
			buy_currency.hide()
		1:

			module_action_button.theme_type_variation = ""
			mod_unavailable.hide()
			module_action_button.show()
			module_action_button.text = tr("RESEARCH")

			buy_cost.show()
			buy_cost_text.show()
			buy_currency.show()

			buy_currency.texture = currency_xp
			buy_cost_text.text = tr("hangar:reserch_cost")
		2:

			module_action_button.theme_type_variation = "ButtonGreen"
			mod_unavailable.hide()
			module_action_button.show()
			module_action_button.text = tr("BUY")

			buy_cost.show()
			buy_cost_text.show()
			buy_currency.show()

			buy_currency.texture = currency_cred if !tank_prem else currency_gold
			buy_cost_text.text = tr("hangar:buy_cost")
		3:

			module_action_button.theme_type_variation = "ButtonGreen"

			mod_unavailable.show()
			mod_unavailable.text = tr("hangar:mod_alr_researched")

			module_action_button.show()
			module_action_button.text = tr("INSTALL")


			buy_cost.hide()
			buy_cost_text.hide()
			buy_currency.hide()
		4:

			module_action_button.theme_type_variation = "ButtonRed"
			module_action_button.text = tr("SELL")
			module_action_button.show()
			mod_unavailable.show()
			mod_unavailable.text = tr("hangar:tank_alr_bought")

			buy_cost.hide()
			buy_cost_text.hide()
			buy_currency.hide()
		5:

			module_action_button.hide()
			mod_unavailable.show()
			mod_unavailable.text = tr("hangar:mod_alr_installed")

			buy_cost.hide()
			buy_cost_text.hide()
			buy_currency.hide()

func tank_select(nam: StringName, status: Global.ResearchStatus):
	selected_mod_id.x = -1
	selected_mod_id.y = -1

	var gun_id: = 0
	var engine_id: = 0
	var track_id: = 0
	var equipment: Array[StringName] = []
	var consumables: Array[StringName] = []
	if acc().has_tank(nam):
		var t: SaveTank = acc().get_tank(nam)
		gun_id = t.gun_id
		engine_id = t.engine_id
		track_id = t.track_id
		equipment = t.equipment
		consumables = t.consumables

	tank_info_panel.setup_from_tank(nam, gun_id, engine_id, track_id, equipment, consumables)

	var tank_info: TankInfoMain
	for t in get_all_tree_tanks():
		if t.info.name == nam:
			tank_info = t.info

			t.select()

	selected_name.text = ""

	for box in [guns, engines, tracks]:
		for c in box.get_children():
			if is_instance_valid(c) and c.has_method("deselect"): c.deselect()

	if !tank_info: return

	selected_tank_name = tank_info.name
	selected_tank_status = status

	tank_name.text = tr("Tank") + " " + (tr(tank_info.name) if tr(tank_info.name) != tank_info.name else tank_info.display_name)
	match status:
		Global.ResearchStatus.NOT_AVAILABLE:
			change_buy_panel(0, tank_info.prem)
		Global.ResearchStatus.AVAILABLE:
			buy_cost.text = Util.format_number_to_k(tank_info.cost_xp)
			change_buy_panel(1, tank_info.prem)
		Global.ResearchStatus.RESEARCHED:
			buy_cost.text = Util.format_number_to_k(tank_info.cost)
			change_buy_panel(2, tank_info.prem)
		Global.ResearchStatus.INSTALLED_BOUGHT:
			change_buy_panel(4, tank_info.prem)

func choose_module(mod: ModuleBase, status: Global.ResearchStatus, id: int):
	var n: = str(mod.name)


	var gun_id: int = 0
	var engine_id: int = 0
	var track_id: int = 0


	if save_tank_ref:
		gun_id = save_tank_ref.gun_id
		engine_id = save_tank_ref.engine_id
		track_id = save_tank_ref.track_id

	if mod is ModuleGun:
		gun_id = id
		selected_name.text = tr("Gun")
	elif mod is ModuleEngine:
		engine_id = id
		selected_name.text = tr("Engine")
	elif mod is ModuleTracks:
		track_id = id
		selected_name.text = tr("Chassis")
	selected_name.text += " " + tr(mod.display_name)

	if save_tank_ref:
		tank_info_panel.setup_from_tank(save_tank_ref.name, gun_id, engine_id, track_id)

	on_choose_module.emit(n, status)
	for t in get_all_tree_tanks():
		t.deselect()

	match status:
		Global.ResearchStatus.NOT_AVAILABLE:
			change_buy_panel(0)
		Global.ResearchStatus.AVAILABLE:
			buy_cost.text = Util.format_number(mod.cost_xp)
			change_buy_panel(1)
		Global.ResearchStatus.RESEARCHED:
			change_buy_panel(3)
		Global.ResearchStatus.INSTALLED_BOUGHT:
			change_buy_panel(5)

	if mod is ModuleGun:
		selected_mod_id.x = 0
	elif mod is ModuleEngine:
		selected_mod_id.x = 1
	elif mod is ModuleTracks:
		selected_mod_id.x = 2
	selected_mod_id.y = id

	selected_mod_status = status
