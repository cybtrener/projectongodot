class_name Consumable
extends EquipmentBase

var reusable: = false
var cooldown: int = 60
var use_time: int = 30
var type: ConsumableType = ConsumableType.SINGLE_USE

var snd_apply: AudioStream
var snd_stop_use: AudioStream

var cant_use_msg: String = "consumables:generic/cant_use"
func with_cant_use_msg(new: String) -> Consumable:
	self.cant_use_msg = new

	return self

func with_sounds(apply: AudioStreamWAV, stop_use: AudioStreamWAV) -> Consumable:
	self.snd_apply = apply
	self.snd_stop_use = stop_use

	return self

func set_use_time(ut: int) -> Consumable:
	self.use_time = ut

	return self

enum ConsumableType{

	SINGLE_USE, 

	REUSABLE, 

	PASSIVE
}

var _on_stop_use: Callable = func(tank: BaseTank):
	pass

func with_type(_type: ConsumableType) -> Consumable:
	self.type = _type

	return self

func _meta() -> String:
	return "equip_" + str(self.name_id)

func copy_from(c: Consumable) -> Consumable:
	self._on_apply = c._on_apply
	self._on_stop_use = c._on_stop_use
	self.type = c.type

	self.reusable = c.reusable
	self.cooldown = c.cooldown

	return self

func on_apply(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):
	if is_instance_valid(tank) and tank.has_meta(_meta()): return false

	if !self._on_apply.call(tank, tank_info, gun, engine, tracks):
		return false

	if is_instance_valid(tank) and tank.is_player():
		Audio.play_sound2d(self.snd_apply)

	print("Consumable: '" + self.name_id + "' used on tank '" + str(tank) + "', cooldown:", self.cooldown, ", usetime: ", self.use_time)

	if is_instance_valid(tank): tank.set_meta(_meta(), 1)
	return true

func on_stop_use(tank: BaseTank, tank_info: TankInfoMain, gun: int, engine: int, tracks: int):

	if is_instance_valid(tank) and not tank.has_meta(_meta()): return
	if !is_instance_valid(tank): return
	if !is_instance_valid(tank_info): return

	if is_instance_valid(tank) and tank.is_player():
		Audio.play_sound2d(self.snd_stop_use)

	self._on_stop_use.call(tank, tank_info, gun, engine, tracks)
	print("Consumable: '" + self.name_id + "' stopped use on tank '" + str(tank) + "'")

	if is_instance_valid(tank): tank.remove_meta(_meta())
