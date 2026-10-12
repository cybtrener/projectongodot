class_name ModuleGun
extends ModuleBase


enum FireMode{
	NORMAL, 
	BURST, 
	AUTOLOAD
}
enum ShootSound{

	shot_auto, 

	shot_small, 

	shot_medium, 

	shot_main, 

	shot_large, 

	shot_huge
}

@export var reload: float = 4.88

@export var disp: float = 0.44

@export var aim_time: float = 2.3

@export var deviation_up: Vector2 = Vector2(20, 8)
@export var deviation_up_custom: Curve = Curve.new()
@export var deviation_down_custom: Curve = Curve.new()

@export var deviation_r: Vector2 = Vector2(180, 180)

@export var caliber: int = 37

@export var shot_sound: ShootSound = ShootSound.shot_small


@export var impulse_mul: float = 1

@export var fire_mode: FireMode = FireMode.NORMAL

@export var rot_speed: = 72

@export var max_ammo: int = 150

@export var disp_factors: Vector3 = Vector3(0.1, 3, 2)

@export var burst_info: BurstInfo = BurstInfo.new()

@export var model_id_override: int = -1

@export var shells: Array[ShellInfo] = [
	ShellInfo.new(), 
	ShellInfo.new(), 
	ShellInfo.new(), 
]

func _init() -> void :
	self.deviation_r.x = abs(self.deviation_r.x)
	self.deviation_r.y = abs(self.deviation_r.y)
	self.deviation_up.x = abs(self.deviation_up.x)
	self.deviation_up.y = abs(self.deviation_up.y)
func get_pen() -> int:
	return shells[0].pen
func get_dmg() -> int:
	return shells[0].dmg
func get_fire_rate() -> float:
	var firerate: float = 60 / self.reload
	if self.fire_mode == ModuleGun.FireMode.BURST:
		var burst_shots: int = 0
		var burst_unload: float = 0

		for b in self.burst_info.bursts:
			if burst_shots > 0 and b > 1:
				burst_unload += b * self.burst_info.intraburst

			burst_shots += b
		burst_unload += (self.burst_info.bursts.size() - 1) * self.burst_info.intraclip
		firerate = (60 / (burst_unload + self.reload)) * burst_shots

	return Util.round_to_dec(firerate, 2)
func get_dpm() -> int:
	return get_fire_rate() * get_dmg()


func _to_dict() -> Dictionary:
	var sh: = []
	for shell in self.shells:
		sh.append(shell._to_dict())

	var my_dict = {
		"reload": reload, 
		"disp": disp, 
		"aim_time": aim_time, 
		"deviation_up": [deviation_up.x, deviation_up.y], 
		"deviation_r": [deviation_r.x, deviation_r.y], 
		"impulse_mul": impulse_mul, 
		"fire_mode": fire_mode, 
		"rot_speed": rot_speed, 
		"max_ammo": max_ammo, 
		"shells": sh, 

		"disp_factors": [disp_factors.x, disp_factors.y, disp_factors.z], 
		"burst_info": burst_info
	}

	return my_dict.merged( super._to_dict())

static func _from_dict(dict: Dictionary) -> ModuleGun:
	var base = super._from_dict(dict)
	var info = ModuleGun.new()
	info.copy_from_base(base)

	info.reload = dict["reload"] or info.reload
	info.disp = dict["disp"] or info.disp
	info.aim_time = dict["aim_time"] or info.aim_time
	info.deviation_up = dict["deviation_up"] or info.deviation_up
	info.deviation_r = dict["deviation_r"] or info.deviation_r
	info.impulse_mul = dict["impulse_mul"] or info.impulse_mul
	info.fire_mode = dict["fire_mode"] or info.fire_mode
	info.rot_speed = dict["rot_speed"] or info.rot_speed
	info.max_ammo = dict["max_ammo"] or info.max_ammo
	info.shells = dict["shells"] or info.shells

	return info
