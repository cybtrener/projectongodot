class_name EquipmentBase
extends Node

var icon: Texture2D = load("res://assets/gfx/ui/inventory/filterCyclone.tres")
var name_id: String = "rammer"
var name_key: = "equipment:rammer/name"
var desc_key: = "equipment:rammer/desc"

var nations_whitelist: Array[TankInfoMain.Nation] = []

var cost_factor: float = 1



var weight: = 200


var _on_apply: Callable = func(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
	return true

func with_icon(i: Texture2D) -> EquipmentBase:
	self.icon = i
	return self

func with_cost_factor(factor: int):
	self.cost_factor = factor
	return self

func on_apply(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
	if tank and is_instance_valid(tank): tank.mass += self.weight
	self._on_apply.call(tank, tank_info, gun, engine, tracks)

func restrict_to_nation(nation: TankInfoMain.Nation) -> EquipmentBase:
	nations_whitelist.append(nation)
	return self


func set_main_info(id: String, name_key: String, desc_key: String, icon: Texture2D) -> EquipmentBase:
	self.name_id = id
	self.name_key = name_key
	self.desc_key = desc_key
	self.icon = icon

	nations_whitelist.clear()

	return self

func can_be_used_on_nation(nation: TankInfoMain.Nation):

	return nations_whitelist.is_empty() or nations_whitelist.has(nation)

func add_nation_to_whitelist(nation: TankInfoMain.Nation):
	nations_whitelist.push_back(nation)
