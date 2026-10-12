class_name HealthComponent

signal on_damage_block(dmg: int)
signal on_damage_taken(dmg: int)
signal on_damage_info_taken(dinfo: DamageInfo)
signal health_changed(new_health: int)
signal on_death

var damage_infos_taken: Array[DamageInfo] = []

var health: int = 100
var max_health: int = 100:
	set = set_max_health

func dead() -> bool:
	return health <= 0

func set_max_health(new_health: int):
	max_health = new_health
	health = new_health

	health_changed.emit(health)

func receive_damage_basic(dmg: int):
	if dmg >= health:
		on_death.emit()
		health = 0

		on_damage_taken.emit(clampi(dmg, 0, health))
		health_changed.emit(health)

		return

	self.health = clampi(health - dmg, 0, max_health)
	health_changed.emit(health)
	on_damage_taken.emit(mini(dmg, health))

func receive_damage(dinfo: DamageInfo):
	if dead(): return
	if dinfo.is_null(): return

	damage_infos_taken.push_back(dinfo)
	on_damage_info_taken.emit(dinfo)

	if dinfo.is_block():
		on_damage_block.emit(dinfo.dmg_base)
		return

	var dmg: int = dinfo.dmg

	receive_damage_basic(dmg)
