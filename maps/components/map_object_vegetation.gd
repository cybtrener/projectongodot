@tool
extends Node3D
class_name MapObjectVegetation


@export var _update: bool = false:
	set(new):
		if !Engine.is_editor_hint(): return

		update()
		return new

@export var dont_upd: bool = false

@export var no_lods_on_fade: bool = false
@export var flip_h: bool = false
@export var flip_v: bool = false
@export var no_rand_flip: bool = false

@export var modulate_global: Color

@export var density: float = 0.45

@export var sprites: Node3D
@export var lods: Node3D
@export var collider: StaticBody3D

@export var texture_normal: Texture2D
@export var texture_lod: Texture2D
@export var material: ShaderMaterial
@export var material_lod: ShaderMaterial


static var mat_base: ShaderMaterial = load("res://maps/vegetation/_vegetavion_shader_mat.tres")
static var sh_base: Shader = load("res://maps/vegetation/_vegetation_shader.gdshader")
func iterate_mesh(s: Node, lod: bool = true):
	if s is Sprite3D: return
	if s is not GeometryInstance3D: return
	var as_m3d: GeometryInstance3D = s as GeometryInstance3D

	if !material:
		material = mat_base.duplicate()
	if !material_lod:
		material_lod = mat_base.duplicate()
	material.shader = sh_base
	material_lod.shader = sh_base

	if texture_normal: material.set_shader_parameter("texture_albedo", texture_normal)
	if texture_lod: material_lod.set_shader_parameter("texture_albedo", texture_lod)

	as_m3d.material_override = material if !lod else material_lod



func fade_mat(mat: StandardMaterial3D, fade: bool):
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if fade else BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.albedo_color.a = 0.3 if fade else 1

func iterate_sprite(s: Node, rand_flip_hv: bool = true, billboard: bool = true):
	if s is not Sprite3D: return
	var as_s3d: Sprite3D = s as Sprite3D

	if rand_flip_hv:
		as_s3d.flip_h = randf() > 0.5 and !flip_h or flip_h
		as_s3d.flip_v = randf() > 0.5 and !flip_v or flip_v
	else:
		as_s3d.flip_h = false
		as_s3d.flip_v = false
	if billboard:
		as_s3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		as_s3d.double_sided = false

	as_s3d.render_priority = -1

func update():
	if !sprites: return
	for c in sprites.get_children(true):
		iterate_sprite(c, !no_rand_flip)
		iterate_mesh(c, false)
	for c in lods.get_children(true):
		iterate_sprite(c, false, false)
		iterate_mesh(c, true)

	collider.collision_layer = 32
	collider.collision_mask = 0
	collider.owner = self


func static_body_from_model(mdl: MeshInstance3D) -> StaticBody3D:
	if !mdl: return null

	mdl.create_convex_collision()

	for c in mdl.get_children():
		if c is StaticBody3D: return c

	return null

func replace_collision_from_donor(new_owner: Node, donor: MeshInstance3D, receiver: CollisionShape3D, scale: Vector3 = Vector3.ONE):
	var body: StaticBody3D = static_body_from_model(donor)

	if body:
		var colshape: Shape3D = (body.get_child(0).shape as Shape3D).duplicate_deep()
		if scale != Vector3.ONE:
			for i in range(colshape.points.size()):
				var p: Vector3 = colshape.points[i]
				colshape.points[i] = p * scale
		receiver.shape = colshape


		body.queue_free()

var state: DistState = DistState.NORMAL
var last_enable_fade: bool = false

enum DistState{
	NORMAL, CLOSE, FAR
}

func _physics_process(delta: float) -> void :
	var cam3d: Camera3D = get_viewport().get_camera_3d()





	if !cam3d:
		return

	var dist_sqr: float = cam3d.global_position.distance_squared_to(self.global_position)

	var state_new: DistState = DistState.NORMAL

	var active_dist: float = 8
	var allow_fade: bool = true
	if !Engine.is_editor_hint():
		active_dist = Global.bush_active_dist
		allow_fade = Global.SNIPER_ALLOW_BUSH_FADE

	if dist_sqr * cam3d.fov > 1000 ** 2:
		state_new = DistState.FAR
	else:
		state_new = DistState.NORMAL

	if state_new != state or last_enable_fade != allow_fade:
		state = state_new
		last_enable_fade = allow_fade
		match state:
			DistState.CLOSE:

				pass

			DistState.FAR:
				enable_lod(true)
				fade(false, allow_fade)
			DistState.NORMAL:
				enable_lod(false)
				fade(false, allow_fade)

func enable_lod(yep: bool):
	if yep:
		lods.show()
		sprites.hide()
	else:
		lods.hide()
		sprites.show()

func fade(yep: bool, allow_fade: bool):
	yep = yep and allow_fade
	if no_lods_on_fade:
		for c in sprites.get_children(true):
			if c is not Sprite3D: continue
			var as_s3d: Sprite3D = c as Sprite3D
			as_s3d.modulate.a = 0.5 if yep else 1
	else:
		for c in lods.get_children(true):
			if c is not Sprite3D: continue
			var as_s3d: Sprite3D = c as Sprite3D
			as_s3d.modulate.a = 0.5 if yep else 1
