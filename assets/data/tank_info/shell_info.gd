class_name ShellInfo
extends Resource




enum Type{

	AP, 

	APCR, 

	HEAT, 

	HE, 

	HESH
}

@export var name: String = "76мм УБР-354А"
@export var dmg: int = 10
@export var dmg_module_mul: float = 1
@export var pen: int = 100

@export var caliber: int = 75

@export var speed: int = 750

@export var max_dist: float = 720

@export var gravity_mul: float = 1
@export var type: Type = Type.AP

@export var cost: int = 10
@export var premium: bool = false


@export var homing: bool = false
@export var homing_strength: float = 0.2
@export var homing_uses_autoaim: bool = false

func is_heat() -> bool:
	return self.type == Type.HEAT
func is_high_explosive() -> bool:
	return self.type == Type.HE or self.type == Type.HESH

func get_normalization() -> float:
	if self.type == Type.AP: return 5
	elif self.type == Type.APCR: return 2

	return 0

func _to_dict() -> Dictionary:
	return {
		"name": name, 
		"dmg": dmg, 
		"pen": pen, 
		"caliber": caliber, 
		"speed": speed, 
		"max_dist": max_dist, 
		"gravity_mul": gravity_mul, 
		"type": type, 
	}

static func _from_dict(dict: Dictionary) -> ShellInfo:
	var info: = ShellInfo.new()

	info.name = dict["name"] or info.name
	info.dmg = dict["dmg"] or info.dmg
	info.pen = dict["pen"] or info.pen
	info.caliber = dict["caliber"] or info.caliber
	info.speed = dict["speed"] or info.speed
	info.type = dict["type"] or info.type
	info.gravity_mul = dict["gravity_mul"] or info.gravity_mul
	info.type = dict["type"] or info.type

	return info
