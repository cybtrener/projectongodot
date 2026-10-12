class_name TankInfoMain
extends Resource

const flags_registered: Array[StringName] = [
	"atgm_autoaim", 
	"ramming_mk2", 
	"m_loyal", 
	"m_super_loyal", 
]
func has_flag(flag: StringName):
	return self.flags.has(flag) and flags_registered.has(flag)

enum Nation{
	NONE, 

	USSR, 
	GERMANY, 
	USA, 
	GB, 

	JAPAN, 
	FRANCE, 
	CHINA
}
enum Class{
	LT, 
	MT, 
	HT, 
	TD
}

enum EngineSound{
	DE_LT, DE_MT, DE_HT, DE_TRAKTOR, 
	UK_LT, UK_MT, UK_HT, UK_TRAKTOR, 
	USSR_LT, USSR_MT, USSR_HT, USSR_TRAKTOR, 
	USA_LT, USA_MT, USA_HT, USA_TRAKTOR, 
}
enum TrackSound{
	LT, MT, HT, TRAKTOR
}


static var nation_flags = [

	load("res://assets/gfx/ui/lobby_common/TankSlot.tres"), 


	load("res://assets/gfx/ui/lobby_common/TankSlot07_ussr.tres"), 

	load("res://assets/gfx/ui/lobby_common/TankSlot06_ger.tres"), 

	load("res://assets/gfx/ui/lobby_common/TankSlot05_usa.tres"), 

	load("res://assets/gfx/ui/lobby_common/TankSlot08_britsh.tres"), 


	load("res://assets/gfx/ui/lobby_common/flags/TankSlotFlags_04.tres"), 

	load("res://assets/gfx/ui/lobby_common/flags/TankSlotFlags_02.tres"), 

	load("res://assets/gfx/ui/lobby_common/flags/TankSlotFlags_03.tres"), 
]






@export var icon: String = "res://assets/tanks/icons/ussr-MS-1.tres"
@export var icon_small: String = ""

func get_small_icon() -> String:
	if icon_small.is_empty():
		var split: Array = icon.split("/")
		var path_res: String = "res://assets/tanks/icons_small/" + split[-1]
		var path_mod: String = "mods://assets/tanks/icons_small/" + split[-1]

		if ResourceLoader.exists(path_res):
			return path_res
		else:
			return path_mod
	else:
		return icon_small


@export var tex_main: String = "res://assets/tanks/ussr1-MS-1.png"

@export var tex_tracks: String = "res://assets/tanks/ussr1-MS-1_track.png"

@export var model_path: String = "res://assets/tanks/ussr1-ms-1.glb"

@export var name: String = "base_tank"

@export var display_name: String = "Base Tank"

@export var display_name_short: String = "Base Tank"

@export var health: int = 5000

@export var lvl: int = 1

@export var farm_coeff: float = 1.0

@export var tank_class: Class = Class.LT

@export var nation: Nation = Nation.NONE

@export var spot_radius: int = 400

@export var speed_limits: Vector2 = Vector2(72, 20)

@export var turret_rot_speed: float = 38
@export var turret_health: float = 94

@export var repair_cost: float = 3.55

@export var crew_xp_factor: float = 1


@export var unlock_tanks: Dictionary = {}

@export var shop_tank: bool = false

@export var tree_tank: bool = false

@export var tree_branch: int = 0

@export var prem: bool = false

@export var ignore_matchmaker: bool = false

@export var matchmaker_super_loyal: bool = false

@export var matchmaker_loyal: bool = false

@export var matchmaker_chance: float = 0.5

@export var cost_xp: int = 150

@export var cost: int = 1500


@export var camo_factors: Vector3 = Vector3(-1, -1, -1)

@export var hull_weight: int = 2500

@export var hidden: bool = false

@export var engine_sound: EngineSound = EngineSound.USSR_LT
@export var track_sound: TrackSound = TrackSound.LT


@export var guns: Array[ModuleGun] = [
	ModuleGun.new(), 
]

@export var engines: Array[ModuleEngine] = [
	ModuleEngine.new()
]

@export var tracks: Array[ModuleTracks] = [
	ModuleTracks.new()
]


@export var ai_gun_priority: int = 0

@export var ai_shell_priority: Array[ShellInfo.Type] = []

@export var flags: Array[StringName] = []

@export var scale_factor_mod: float = 0.1

func apply_crew_mastery_bonus(mul: float):
	for g in guns:
		if g.fire_mode == g.FireMode.NORMAL:
			g.reload *= mul
		g.aim_time *= mul




func repair_all_modules(): pass
func heal_all_crewmembers(): pass
func extinguish(): pass

func cleanup():
	self.lvl = clampi(lvl, 1, 10)
	if self.turret_rot_speed > 1:
		self.turret_rot_speed = deg_to_rad(self.turret_rot_speed)
	self.name = name.to_lower()

	self.matchmaker_chance = clampf(matchmaker_chance, 0, 1)
	if self.nation == Nation.USSR: matchmaker_chance *= 1.25

	var new_unlocks: = {}
	for key in self.unlock_tanks.keys():
		if key is not String: continue
		new_unlocks[key.to_lower()] = unlock_tanks[key]

	self.guns.filter( func(engine):
		for e in engines:
			if e.name == engine.name: return false

		return true
		)
	self.engines.filter( func(engine):
		for e in engines:
			if e.name == engine.name: return false

		return true
		)
	self.tracks.filter( func(engine):
		for e in engines:
			if e.name == engine.name: return false

		return true
		)

func _init() -> void :
	cleanup()

func get_power_to_weight(engine_id: int) -> float:
	return engines[engine_id].power / hull_weight

func elite() -> bool:
	for mod in self.guns:
		if not Global.save_main.module_researched(mod.name): return false
		return true
	for mod in self.engines:
		if not Global.save_main.module_researched(mod.name): return false
		return true
	for mod in self.tracks:
		if not Global.save_main.module_researched(mod.name): return false
		return true
	return false

func _to_dict() -> Dictionary:
	var d_guns: = {}
	var d_engines: = {}
	var d_tracks: = {}

	for gun in self.guns:
		d_guns.merge(gun._to_dict())
	for eng in self.engines:
		d_engines.merge(eng._to_dict())
	for tr in self.tracks:
		d_tracks.merge(tr._to_dict())

	return {
		"name": name, 
		"display_name": display_name, 
		"display_name_short": display_name_short, 
		"health": health, 
		"tank_class": tank_class, 
		"lvl": lvl, 
		"nation": nation, 

		"spot_radius": spot_radius, 
		"speed_limits": [speed_limits.x, speed_limits.y], 

		"turret_rot_speed": turret_rot_speed, 
		"turret_health": turret_health, 
		"repair_cost": repair_cost, 
		"crew_xp_factor": crew_xp_factor, 
		"unlock_tanks": unlock_tanks, 
		"prem": prem, 
		"tree_tank": tree_tank, 
		"tree_branch": tree_branch, 
		"ignore_matchmaker": ignore_matchmaker, 

		"cost_xp": cost_xp, 
		"cost_credits": cost, 

		"camo_factors": [camo_factors.x, camo_factors.y, camo_factors.z], 
		"weight": hull_weight, 
		"farm_coeff": farm_coeff, 

		"guns": d_guns, 
		"engines": d_engines, 
		"tracks": d_tracks, 
	}

static func _from_dict(dict: Dictionary) -> TankInfoMain:
	var info = TankInfoMain.new()

	info.reload = dict["reload"] or info.reload

	return info
