class_name DamageInfo
extends Resource

enum DamageType{
	SHELL, 
	EXPLOSION, 
	COLLISION, 
	FIRE
}

var attacker: Player = null
var attacker_tank: BaseTank = null
var dmg: int = 0
var dmg_base: int = 0

var dmg_type: DamageType = DamageType.SHELL
var shell_type: ShellInfo.Type = ShellInfo.Type.AP

var pos: Vector3 = Vector3()

func should_have_marker() -> bool:
	return self.dmg_type == DamageType.SHELL || self.dmg_type == DamageType.EXPLOSION
func is_null() -> bool:
	return dmg == 0 and dmg_base == 0
func is_block() -> bool:
	return should_have_marker() and dmg == 0
