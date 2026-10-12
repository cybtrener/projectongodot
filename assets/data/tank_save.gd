extends Resource
class_name SaveTank

@export var name: String = "base_tank"

@export var bought: bool = false

@export var gun_id: int = 0
@export var engine_id: int = 0
@export var track_id: int = 0

@export var exp: int = 0

@export var ach_max_dmg: int = 0
@export var ach_max_block: int = 0

@export var ach_invincible_streak: int = 0
@export var ach_diehard_streak: int = 0

@export var shells_amounts: Array[int] = [0, 0, 0]
@export var equipment: Array[StringName] = []
@export var consumables: Array[StringName] = []
@export var rewards: Dictionary[StringName, int] = {}

@export var stat_battles: int = 0
@export var stat_kills: int = 0
@export var stat_max_kills: int = 0
@export var stat_max_xp: int = 0
@export var stat_damage_dealt: int = 0
@export var stat_damage_taken: int = 0

@export var stat_shells_shot: int = 0
@export var stat_shells_hits: int = 0

func _init() -> void :
	cleanup()

func sort_modules(orig: Array) -> Array:
	var sorted: Array[ModuleBase] = []
	var modules_names: Array[StringName] = []
	for mod in orig:
		if modules_names.has(mod.name): continue
		modules_names.push_back(mod.name)
		sorted.push_back(mod)

	return sorted

func cleanup():
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(name)

	var guns_sorted: Array = sort_modules(info.guns)
	var engines_sorted: Array = sort_modules(info.engines)
	var tracks_sorted: Array = sort_modules(info.tracks)

	gun_id = clampi(gun_id, 0, guns_sorted.size() - 1)
	engine_id = clampi(engine_id, 0, engines_sorted.size() - 1)
	track_id = clampi(track_id, 0, tracks_sorted.size() - 1)

func with_name(name: StringName) -> SaveTank: self.name = name;return self
