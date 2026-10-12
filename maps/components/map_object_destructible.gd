@tool
extends Area3D
class_name MapObjectDestructible

enum Effect{
	CERAMIC, 
	FENCE_BEAM, 
	FENCE_WOOD, 
	FENCE_STONE, 
	FENCE_METAL, 
	FENCE_METAL_FORGED, 
	HAY, 
	LINEN, 
	METAL_CONSTRUCTION, 
	METAL_BARREL, 
	METAL_CAR, 
	METAL_LAMP, 
	STONE, 
	TENT, 
	WOOD_TOILET, 
	WOOD_BOX, 
}

const COLLISION_STATIC: int = 2 ** 0
const COLLISION_PHYS: int = 2 ** 1
const COLLISION_DESTRUCTIBLE: int = 2 ** 8

@export var destroyed: bool = false:
	set(d):
		destroyed = d

		if mesh_instance_normal: mesh_instance_normal.visible = !destroyed
		if mesh_instance_destroyed: mesh_instance_destroyed.visible = destroyed

		if static_body_normal: static_body_normal.visible = !destroyed
		if static_body_destroyed: static_body_destroyed.visible = destroyed

		static_body_normal.collision_layer = COLLISION_DESTRUCTIBLE if !destroyed else 0
		static_body_destroyed.collision_layer = COLLISION_STATIC if destroyed else 0
		self.collision_mask = COLLISION_PHYS

@export var health: int = 10

var force_update: bool = false
func can_update() -> bool:
	return force_update || self.is_inside_tree()

@export var mesh_normal: Mesh:
	set(m):
		mesh_normal = m
		if !can_update(): return

		mesh_instance_normal.mesh = m
@export var mesh_destroyed: Mesh:
	set(m):
		mesh_destroyed = m
		if !can_update(): return

		mesh_instance_destroyed.mesh = m
@export var material: Material:
	set(m):
		material = m
		if !can_update(): return
		mesh_instance_normal.material_override = m
		mesh_instance_destroyed.material_override = m

@export var colshape_normal: Shape3D:
	set(s):
		colshape_normal = s
		if !can_update(): return

		colshape_area_3d.shape = s
		colshape_static_normal.shape = s

@export var colshape_destroyed: Shape3D:
	set(s):
		colshape_destroyed = s
		if !can_update(): return

		colshape_static_destroyed.shape = s

@export var material_destroyed: Material:
	set(m):
		material_destroyed = m
		if !can_update(): return
		mesh_instance_destroyed.material_override = m

@export var effect: Effect = Effect.FENCE_WOOD

@export_category("Components")

@export var mesh_instance_normal: MeshInstance3D
@export var mesh_instance_destroyed: MeshInstance3D

@export var colshape_area_3d: CollisionShape3D

@export var static_body_normal: StaticBody3D
@export var colshape_static_normal: CollisionShape3D

@export var static_body_destroyed: StaticBody3D
@export var colshape_static_destroyed: CollisionShape3D





static var effect_to_particle: Dictionary[Effect, PackedScene] = {}

func damage(dmg: int):
	self.health -= dmg

	if self.health <= 0:
		self.destroyed = true

func _ready() -> void :
	self.body_entered.connect( func(body):
		if body is BaseTank: destructible_on_tank_enter(body)
	)

func destructible_on_tank_enter(tank: BaseTank):
	if destroyed: return
	destroyed = true

	var totank: Vector3 = self.global_position.direction_to(tank.pos())
	var coeff: float = 0.1
	var impulse: float = maxf((health * coeff / tank.mass) * coeff, tank.mass)


	tank.apply_torque(totank.cross( - Vector3.UP) * impulse * coeff * 0.5)
	tank.apply_force(totank * impulse * coeff)
