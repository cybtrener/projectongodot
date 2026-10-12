extends Node

static var path_main: = "res://assets/tanks/"
static var path_mods_dir: = "res://mods"
static var path_mod: = "res://tanks_mod"

func ERR(strr):
	printerr("Tanks DataBase: " + strr)




var equipment_list: Dictionary[StringName, EquipmentBase] = {}
var consumables_list: Dictionary[StringName, EquipmentBase] = {}

var eq_rammer: EquipmentItem = new_equipment("rammer", 

	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		var the_gun: ModuleGun = tank_info.guns[gun]
		if the_gun.fire_mode == ModuleGun.FireMode.NORMAL:
			the_gun.reload *= 0.9
		elif the_gun.fire_mode == ModuleGun.FireMode.BURST:
			the_gun.burst_info.intraburst *= 0.9
			the_gun.burst_info.intraclip *= 0.9

		return true
		).with_icon(load("res://assets/gfx/ui/inventory/rammer.tres")).with_cost_factor(2)
var eq_vent: EquipmentItem = new_equipment("vent", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.apply_crew_mastery_bonus(0.95)
		return true
		).with_icon(load("res://assets/gfx/ui/inventory/improvedVentilation.tres")).with_cost_factor(2)
var eq_aimStab: EquipmentItem = new_equipment("aimStab", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.guns[gun].disp_factors *= 0.8

		return true
		).with_icon(load("res://assets/gfx/ui/inventory/aimingStabilizer.tres"))
var eq_aimDrive: EquipmentItem = new_equipment("aimDrive", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.guns[gun].aim_time *= 0.9

		return true
		).with_icon(load("res://assets/gfx/ui/inventory/enhancedAimDrives.tres"))
var eq_toolbox: EquipmentItem = new_equipment("toolbox", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		).with_icon(load("res://assets/gfx/ui/inventory/toolbox.tres"))
var eq_spallliner: EquipmentItem = new_equipment("spallliner", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		).with_icon(load("res://assets/gfx/ui/inventory/antifragmentationLining.tres"))
var eq_optics: EquipmentItem = new_equipment("optics", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.spot_radius = mini(tank_info.spot_radius * 1.1, 500)

		return true
		).with_icon(load("res://assets/gfx/ui/inventory/coatedOptics.tres"))
var eq_camonet: EquipmentItem = new_equipment("camonet", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		).with_icon(load("res://assets/gfx/ui/inventory/camouflageNet.tres"))
var eq_stereoscope: EquipmentItem = new_equipment("stereoscope", 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		).with_icon(load("res://assets/gfx/ui/inventory/stereoscope.tres"))


var cons_repair_kit: Consumable = new_consumable("repair_kit", 45, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):

		return tank.repair_everything()
		, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		, 
		Consumable.ConsumableType.REUSABLE).with_icon(load("res://assets/gfx/ui/inventory/largeRepairkit.tres")
	).set_use_time(0).with_sounds(Audio.ui_cons_repair, null).with_cant_use_msg("")

var cons_berserk: Consumable = new_consumable("berserk", 90, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.guns[gun].reload *= 0.75
		tank.gun_component.last_shot -= tank_info.guns[gun].reload * 0.25
		return true
		, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.guns[gun].reload /= 0.75
		return true
		, 
		Consumable.ConsumableType.REUSABLE).with_icon(load("res://assets/gfx/ui/inventory/berserk.tres")
	).set_use_time(30).with_sounds(Audio.ui_cons_berserk_on, Audio.ui_cons_berserk_off)
var cons_afterburning: Consumable = new_consumable("afterburning", 90, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank.suspension.engine_pow *= 1.25
		tank.suspension.max_speed_fw += 5
		tank.suspension.max_speed_back += 2
		return true
		, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank.suspension.engine_pow /= 1.25
		tank.suspension.max_speed_fw -= 5
		tank.suspension.max_speed_back -= 2
		return true
		, 

	Consumable.ConsumableType.REUSABLE).with_icon(load("res://assets/gfx/ui/inventory/afterburner.tres")
	).set_use_time(30).with_sounds(Audio.ui_cons_afterburner_on, Audio.ui_cons_afterburner_off)

var cons_improved_fuel: Consumable = new_consumable("fuel", 0, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.engines[engine].power *= 1.1
		tank_info.tracks[tracks].rot_speed *= 1.1
		tank_info.turret_rot_speed *= 1.1
		if tank:
			tank.suspension.max_speed_fw += 3
			tank.suspension.max_speed_back += 1
		else:
			tank_info.speed_limits.x += 3
			tank_info.speed_limits.y += 1

		return true
		, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		, 
		Consumable.ConsumableType.PASSIVE).with_icon(load("res://assets/gfx/ui/inventory/provisions/regular_fuel.tres")
	)

var cons_ration: Consumable = new_consumable("ration_ussr", 0, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		tank_info.apply_crew_mastery_bonus(0.9)
		return true
		, 
	func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
		return true
		, 
		Consumable.ConsumableType.PASSIVE).with_icon(load("res://assets/gfx/ui/inventory/russ-food.tres")
	).restrict_to_nation(TankInfoMain.Nation.USSR)

var cons_chocolate_bar: Consumable = Consumable.new().copy_from(cons_ration).set_main_info("choc_bar", 
	"consumables:ration_ger/name", 
	"consumables:ration/desc", 
	load("res://assets/gfx/ui/inventory/chocolate.tres")).restrict_to_nation(TankInfoMain.Nation.GERMANY)

var cons_cola: Consumable = Consumable.new().copy_from(cons_ration).set_main_info("coca_cola", 
	"consumables:ration_usa/name", 
	"consumables:ration/desc", 
	load("res://assets/gfx/ui/inventory/cocacola.tres")).restrict_to_nation(TankInfoMain.Nation.USA)

var cons_teapudding: Consumable = Consumable.new().copy_from(cons_ration).set_main_info("teapudding", 
	"consumables:ration_gb/name", 
	"consumables:ration/desc", 
	load("res://assets/gfx/ui/inventory/teapudding.tres")).restrict_to_nation(TankInfoMain.Nation.GB)

var cons_onigiri: Consumable = Consumable.new().copy_from(cons_ration).set_main_info("onigiri", 
	"consumables:ration_jp/name", 
	"consumables:ration/desc", 
	load("res://assets/gfx/ui/inventory/provisions/onigiri.tres")).restrict_to_nation(TankInfoMain.Nation.JAPAN)




func init_equipment():
	register_consumable(cons_chocolate_bar)
	register_consumable(cons_cola)
	register_consumable(cons_teapudding)
	register_consumable(cons_onigiri)

func register_equipment(eq: EquipmentBase):
	equipment_list[eq.name_id] = eq
func register_consumable(eq: EquipmentBase):
	consumables_list[eq.name_id] = eq


static var cost_by_lvl_equipment: Array[int] = [
	1500, 
	5000, 
	35000, 
	35000, 
	70000, 
	90000, 
	90000, 
	90000, 
	180000, 
	180000, 
]
static var cost_by_lvl_consumables: Array[int] = [
	500, 
	750, 
	1000, 
	1250, 
	1500, 
	1750, 
	2000, 
	2250, 
	2500, 
	2750, 
]

func get_equipment_cost_by_lvl(lvl: int):
	return cost_by_lvl_equipment[lvl - 1]
func get_consumable_cost_by_lvl(lvl: int):
	return cost_by_lvl_consumables[lvl - 1]


func new_consumable(
			id: StringName, 
			cooldown: int, 
			on_apply: Callable, 
			on_stop_use: Callable, 
			type: Consumable.ConsumableType) -> Consumable:
	var cons: Consumable = Consumable.new()

	if consumables_list.has(id):
		printerr("Attempt to add consumable of already existing id: '" + id + "'!")
		return null

	cons.name_id = id
	cons.name_key = "consumables:" + id + "/name"
	cons.desc_key = "consumables:" + id + "/desc"
	cons.cooldown = cooldown
	cons.type = type

	cons._on_apply = on_apply
	cons._on_stop_use = on_stop_use

	consumables_list[id] = cons

	return cons

func new_equipment(id: StringName, on_apply: Callable) -> EquipmentItem:
	var eq: EquipmentItem = EquipmentItem.new()
	eq.name_key = "equipment:" + id + "/name"
	eq.desc_key = "equipment:" + id + "/desc"
	eq._on_apply = on_apply

	if equipment_list.has(id):
		printerr("Attempt to add equipment of already existing id: '" + id + "'!")
		return null

	eq.name_id = id
	equipment_list[id] = eq

	return eq

func get_equipment(id: String) -> EquipmentItem:
	if !equipment_list.has(id): return null
	return equipment_list[id]

func get_consumable(id: String) -> Consumable:
	if !consumables_list.has(id): return null
	return consumables_list[id]





var list_main: Dictionary = {
	Global.BASE_TANK: TankInfoMain.new()
}
var list_mod: Dictionary = {}

static var tanks_lvl1: Array[TankInfoMain] = []
static var tanks_lvl2: Array[TankInfoMain] = []
static var tanks_lvl3: Array[TankInfoMain] = []
static var tanks_lvl4: Array[TankInfoMain] = []
static var tanks_lvl5: Array[TankInfoMain] = []
static var tanks_lvl6: Array[TankInfoMain] = []
static var tanks_lvl7: Array[TankInfoMain] = []
static var tanks_lvl8: Array[TankInfoMain] = []
static var tanks_lvl9: Array[TankInfoMain] = []
static var tanks_lvl10: Array[TankInfoMain] = []
static var lvl_to_array = [
	tanks_lvl1, 
	tanks_lvl2, 
	tanks_lvl3, 
	tanks_lvl4, 
	tanks_lvl5, 
	tanks_lvl6, 
	tanks_lvl7, 
	tanks_lvl8, 
	tanks_lvl9, 
	tanks_lvl10
]

static var tanks_by_nation: Dictionary[TankInfoMain.Nation, Array] = {}

func get_tanks_by_nation(nation: TankInfoMain.Nation) -> Array:
	if !tanks_by_nation.has(nation):
		return []
	return tanks_by_nation[nation]

func add_tank_by_nation(info: TankInfoMain, nation: TankInfoMain.Nation):
	if !tanks_by_nation.has(nation):
		tanks_by_nation[nation] = []
	tanks_by_nation[nation].push_back(info)

static var mod_loader_exclude: Array[String] = [
	"_packed", "_disabled", "_"
]

func init_mods():
	if OS.has_feature("android"): return

	var mods_dir: = Util.globalize_res_path(path_mods_dir)
	if !DirAccess.dir_exists_absolute(mods_dir):
		DirAccess.make_dir_recursive_absolute(mods_dir)


	if Engine.is_editor_hint():
		var ignore = FileAccess.open(mods_dir.path_join(".gdignore"), FileAccess.WRITE)
		if ignore: ignore.close()

	var cache_folder: String = mods_dir.path_join("_packed")
	if !DirAccess.dir_exists_absolute(cache_folder):
		DirAccess.make_dir_recursive_absolute(cache_folder)

	var folders: = Util.get_subfolders(mods_dir)
	for folder in folders:
		if mod_loader_exclude.has(folder): continue
		var mod_folder: String = mods_dir.path_join(folder)
		var mod_cache_path: String = cache_folder.path_join(folder + ".pck")
		if !ModUtils.needs_repack(mod_folder, mod_cache_path):
			continue

		print("TanksDataBase: begin caching mod '" + folder + "'")
		ModUtils.pack_folder_pck(mod_folder, mod_cache_path, "res://")

	for file_path in Util.get_files_from_folder(cache_folder, ["pck", "zip"], false):
		var success: = ProjectSettings.load_resource_pack(file_path, true)
		if !success: printerr("Failed loading mod '" + file_path + "'")
		else: print("Success loading mod '" + file_path + "'!")

func init_tanks():
	print("TANKS DATA BASE:")
	print("-------------------------------------------------------------")
	var ress_main = Util.load_resources_from_folder(path_main)
	var ress_mod = Util.load_resources_from_folder(path_mod, false)
	print("-------------------------------------------------------------")
	for res in ress_main:
		add_tank_res(res)
	for res in ress_mod:
		add_tank_res(res, true)

	print("Total tanks loaded:")
	print("--------------------")
	print("main:")
	for k in list_main.keys():
		print("\t'" + k + "'")
	print("--------------------")
	print("modded:")
	for k in list_mod.keys():
		print("\t'" + k + "'")
	print("-------------------------------------------------------------")

var error_tanks: = []

func get_tank_by_name(name: String) -> TankInfoMain:
	var nam = name.to_lower()
	if list_main.has(nam):
		return list_main[nam]
	if list_mod.has(nam):
		return list_mod[nam]
	else:
		if error_tanks.has(name): return list_main[Global.BASE_TANK]

		push_warning("TanksDataBase: cant get tank by name: " + nam + "; using 'base_tank' instead")
		error_tanks.push_back(name)
		return list_main[Global.BASE_TANK]

func get_preceeding_tanks(name: StringName):
	for t in self.tanks:
		var info: TankInfoMain = TanksDataBase.get_tank_by_name(t.name)
		for key in info.unlock_tanks.keys():
			if (key as String).to_lower() == name: return true

func tank_exists(tank: StringName):
	return list_main.has(tank) or list_mod.has(tank)

func _add_tank(info: TankInfoMain, mod: bool = false):
	info.cleanup()
	if mod:
		if list_mod.has(info.name) or list_main.has(info.name):
			ERR("error adding already existing entry: " + info.name)
			return
		list_mod[info.name] = info
	else:
		if list_main.has(info.name):
			ERR("error adding already existing entry: " + info.name)
			return
		list_main[info.name] = info

	var lvl: int = clampi(info.lvl - 1, 0, 9)
	var lvl_arr: Array = lvl_to_array[lvl]
	lvl_arr.push_back(info)

	add_tank_by_nation(info, info.nation)

func get_by_lvl_random(lvl: int, matchmaker: bool = false) -> StringName:
	var lvl_arr: Array[TankInfoMain] = lvl_to_array[clampi(lvl - 1, 0, 9)]
	var tanks: Array[TankInfoMain] = []
	for i in lvl_arr:
		if !matchmaker or !i.hidden and !i.ignore_matchmaker and i.matchmaker_chance > 0:
			tanks.push_back(i)

	tanks.shuffle()
	for info in tanks:
		if Util.random_chance(info.matchmaker_chance * 100):
			return info.name

	return lvl_arr.pick_random().name

func add_tank_res(res: Resource, mod: bool = false):
	if res is TankInfoMain:
		_add_tank(res as TankInfoMain, mod)
	else:
		ERR("Non-tank resource detected in data base folder!")

func _ready() -> void :
	init_mods()
	init_tanks()
	init_equipment()
	PlayerData.init()

static var lvl1: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew.tres") as Texture2D
static var lvl1_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew011.tres") as Texture2D
static var lvl2: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew02.tres") as Texture2D
static var lvl2_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew012.tres") as Texture2D
static var lvl3: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew03.tres") as Texture2D
static var lvl3_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew013.tres") as Texture2D
static var lvl4: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew04.tres") as Texture2D
static var lvl4_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew014.tres") as Texture2D
static var lvl5: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew05.tres") as Texture2D
static var lvl5_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew015.tres") as Texture2D
static var lvl6: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew06.tres") as Texture2D
static var lvl6_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew016.tres") as Texture2D
static var lvl7: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew07.tres") as Texture2D
static var lvl7_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew017.tres") as Texture2D
static var lvl8: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew08.tres") as Texture2D
static var lvl8_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew018.tres") as Texture2D
static var lvl9: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew09.tres") as Texture2D
static var lvl9_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew019.tres")
static var lvl10: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew010.tres") as Texture2D
static var lvl10_prem: = load("res://assets/gfx/ui/lobby_common/TankLevelsNew020.tres") as Texture2D

static var lvls = [lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10]
static var lvls_prem = [lvl1_prem, lvl2_prem, lvl3_prem, lvl4_prem, lvl5_prem, lvl6_prem, lvl7_prem, lvl8_prem, lvl9_prem, lvl10_prem]

static var lvl_icons: Array[Texture2D] = [
	load("res://assets/gfx/ui/battle/parsed/Levels.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels03.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels05.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels07.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels09.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels011.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels013.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels015.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels017.tres"), 
	load("res://assets/gfx/ui/battle/parsed/Levels019.tres"), 
]

static func get_lvl_icon(lvl: int, prem: bool = false, neutral: bool = false) -> Texture2D:
	if neutral:
		return lvl_icons[lvl - 1]

	return lvls_prem[lvl - 1] if prem else lvls[lvl - 1]
static func get_tank_icon(info: TankInfoMain) -> Texture2D:
	var _path_main: = path_main + info.name + ".tres"
	if ResourceLoader.exists(_path_main): return load(_path_main) as Texture2D

	var _path_mod: = path_mod + info.name + ".tres"
	if ResourceLoader.exists(_path_mod): return load(_path_mod) as Texture2D

	var path_aux: = info.icon
	if ResourceLoader.exists(path_aux): return load(path_aux) as Texture2D

	var icon_null: = load("res://assets/gfx/ui/lobby_common/noImage.tres") as AtlasTexture
	return icon_null

static var lt: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall02.tres") as Texture2D
static var mt: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall03.tres") as Texture2D
static var ht: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall04.tres") as Texture2D
static var td: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall05.tres") as Texture2D
static var tank_class: = [
	lt, mt, ht, td
]
static var lt_prem: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall07.tres") as Texture2D
static var mt_prem: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall08.tres") as Texture2D
static var ht_prem: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall09.tres") as Texture2D
static var td_prem: = load("res://assets/gfx/ui/lobby_common/TankTypesSmall010.tres") as Texture2D
static var tank_class_prem: = [
	lt_prem, mt_prem, ht_prem, td_prem
]
static var elite: Texture2D = load("res://assets/gfx/ui/lobby_common/TankTypesBig.tres")
static var elite_prem: Texture2D = load("res://assets/gfx/ui/lobby_common/TankTypesBig06.tres")

static var class_to_icon_neutral: Dictionary[TankInfoMain.Class, Texture2D] = {
	TankInfoMain.Class.LT: load("res://assets/gfx/ui/battle/parsed/MinimapTank02.tres"), 
	TankInfoMain.Class.MT: load("res://assets/gfx/ui/battle/parsed/MinimapTank03.tres"), 
	TankInfoMain.Class.HT: load("res://assets/gfx/ui/battle/parsed/MinimapTank04.tres"), 
	TankInfoMain.Class.TD: load("res://assets/gfx/ui/battle/parsed/MinimapTank.tres"), 
}

static var shell_type_to_color: Dictionary[ShellInfo.Type, Color] = {
	ShellInfo.Type.AP: Color(0.718, 0.353, 0.173, 1.0), 
	ShellInfo.Type.APCR: Color(0.071, 0.071, 0.075, 1.0), 
	ShellInfo.Type.HEAT: Color(0.851, 0.486, 0.012, 1.0), 
	ShellInfo.Type.HE: Color(0.729, 0.267, 0.004, 1.0), 
	ShellInfo.Type.HESH: Color(0.729, 0.267, 0.004, 1.0), 
}
static func get_shell_color(type: ShellInfo.Type) -> Color:
	if shell_type_to_color.has(type):
		return shell_type_to_color[type]

	return Color()

static func get_class_icon(info: TankInfoMain, neutral: bool = false) -> Texture2D:
	if neutral:
		return class_to_icon_neutral[info.tank_class]

	return tank_class_prem[info.tank_class] if info.prem else tank_class[info.tank_class]

static func get_nation_icon(info: TankInfoMain) -> Texture2D:
	return TankInfoMain.nation_flags[info.nation]
static func get_elite_icon(prem: bool) -> Texture2D:
	return elite_prem if prem else elite
