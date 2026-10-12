class_name ModuleTracks
extends ModuleBase

@export var rot_speed: = 72
@export var disp_move_mul: = 0.2

func _to_dict() -> Dictionary:
	var my_dict = {
		"rot_speed": rot_speed
	}

	return my_dict.merged( super._to_dict())

static func _from_dict(dict: Dictionary) -> ModuleTracks:
	var base = super._from_dict(dict)
	var info = ModuleTracks.new()
	info.copy_from_base(base)

	info.rot_speed = dict["rot_speed"] or info.rot_speed

	return info
