@tool
extends Node3D
class_name ParticleStarter

@export var emit: bool = false:
	set(b):
		start()
		emit = false
@export var unshade_everything: bool = false:
	set(b):
		for c in self.get_children():
			if c is not GPUParticles3D: continue
			var cas: GPUParticles3D = (c as GPUParticles3D)
			var mat: Material = cas.draw_pass_1.surface_get_material(0)
			if !mat or mat is not StandardMaterial3D: continue
			(mat as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			(mat as StandardMaterial3D).disable_fog = true
			(mat as StandardMaterial3D).disable_specular_occlusion = true
			(mat as StandardMaterial3D).disable_ambient_light = true
			(mat as StandardMaterial3D).specular_mode = BaseMaterial3D.SPECULAR_DISABLED

func stop():
	for c in self.get_children():
		if c is not GPUParticles3D: continue
		var cas: GPUParticles3D = (c as GPUParticles3D)
		cas.emitting = false


func start(self_destroy: bool = false, normal: Vector3 = Vector3.UP):
	var max_lifetime: float = 0

	if normal != Vector3.UP: self.global_basis.y = normal.normalized()

	for c in self.get_children():
		if c is not GPUParticles3D: continue
		var cas: GPUParticles3D = (c as GPUParticles3D)
		if cas.lifetime > max_lifetime: max_lifetime = cas.lifetime
		var bigg: float = 10000
		cas.custom_aabb = AABB(Vector3( - bigg, - bigg, - bigg), Vector3(bigg, bigg, bigg))
		cas.restart()

	if !Engine.is_editor_hint() and self_destroy: Util.timer(max_lifetime + 1, self.queue_free)
