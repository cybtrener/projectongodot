@tool
class_name MapObjectStatic
extends StaticBody3D

@export var mesh: Mesh:
	set(m):
		mesh = m
		if !can_update(): return

		mesh_instance.mesh = m
@export var material: Material:
	set(m):
		material = m
		if !can_update(): return
		mesh_instance.material_override = m
@export var colshape: Shape3D:
	set(s):
		colshape = s
		if !can_update(): return

		colshape_main.shape = s
@export_category("components")
@export var mesh_instance: MeshInstance3D
@export var colshape_main: CollisionShape3D

var force_update: bool = false

func _ready() -> void :
	self.collision_layer = 2 ** 0

func can_update() -> bool:
	return force_update || Engine.is_editor_hint() && self.is_inside_tree()
