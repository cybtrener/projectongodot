class_name ModuleBase
extends Resource

@export var name: = "Ebatel' mk1"
@export var display_name: = "ebatel_mk1"
@export var level: = 1
@export var cost_xp: = 100

@export var health: = 100


@export var weight: = 150

func _to_dict() -> Dictionary:
	return {
		"name": name, 
		"display_name": display_name, 
		"health": health, 
		"level": level, 
		"cost_xp": cost_xp, 
		"weight": weight, 
	}

static func _from_dict(dict: Dictionary) -> ModuleBase:
	var info = ModuleBase.new()

	info.name = dict["name"] or info.name
	info.display_name = dict["display_name"] or info.display_name
	info.health = dict["health"] or info.health
	info.level = dict["level"] or info.level
	info.cost_xp = dict["cost_xp"] or info.cost_xp
	info.weight = dict["weight"] or info.weight

	return info

func copy_from_base(base: ModuleBase):
	self.name = base.name
	self.health = base.health
	self.level = base.level
	self.cost_xp = base.cost_xp
	self.weight = base.weight
