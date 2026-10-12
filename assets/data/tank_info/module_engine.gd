class_name ModuleEngine
extends ModuleBase

@export var power: = 100
@export var fireStartingChance: = 0.2

func _to_dict() -> Dictionary:
	var my_dict = {
		"power": power, 
		"fireStartChance": fireStartingChance, 
	}

	return my_dict.merged( super._to_dict())

static func _from_dict(dict: Dictionary) -> ModuleEngine:
	var base = super._from_dict(dict)
	var info = ModuleEngine.new()
	info.copy_from_base(base)

	info.power = dict["power"] or info.power
	info.fireStartingChance = dict["fireStartChance"] or info.fireStartingChance

	return info
