extends Node3D
class_name MapObjectTree

@export var fall_speed: float = 0.2

@export var collision: Area3D
@export var trunk: MeshInstance3D

@export var pole: bool = false

var fell: bool = false

func fall_from(pos: Vector3) -> void :
	if fell: return

	var dir: Vector3 = pos.direction_to(self.global_position)
	trunk.global_rotation.x = 0
	self.global_rotation.y = 0
	self.global_rotation.y = dir.signed_angle_to( - self.global_basis.z, - self.global_basis.y)
	if !trunk.mesh: return

	var height: float = trunk.mesh.get_aabb().abs().size.y

	var steps: int = 3
	var step_ang: float = PI * 0.5 / steps


	var fall_ang: float = deg_to_rad(90)

	var ratios: Array[float] = [0.2, 0.5, 0.9]
	var ang_accum: float = 0
	for height_ratio in [0.2, 0.5, 0.9]:
		var height_dir_temp: Vector3 = self.global_basis.y * height * height_ratio
		var height_dir_init: Vector3 = height_dir_temp
		for a in range(steps + 1):
			var current_height_dir: Vector3 = height_dir_temp
			height_dir_temp = height_dir_temp.normalized().rotated(trunk.global_basis.x.normalized(), - step_ang)

			var origin: Vector3 = self.global_position
			var hit: Dictionary = Util.raycast_3d(
				origin + current_height_dir, 
				origin + height_dir_temp, 
				2 ** 0
			)

			if hit.hit:
				var height_dir_final: Vector3 = self.global_position - hit.position

				var ang: float = height_dir_init.angle_to(height_dir_final)
				if ang < fall_ang:
					fall_ang = ang
				break

	var target_rot: float = - absf(fall_ang - deg_to_rad(15)) * signf(fall_ang)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	var dur: float = (1 / fall_speed) * absf(trunk.global_rotation.x - target_rot) * 0.5

	tween.tween_method( func(r: float):
		trunk.global_rotation.x = r

		, trunk.global_rotation.x, target_rot, dur)

func _ready() -> void :
	collision.body_entered.connect( func(body):
		if body is BaseTank:

			fall_from(body.global_position)
			fell = true
	)
