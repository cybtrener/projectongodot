@tool
class_name BushBuilder
extends Node

@export var multimesh: MultiMesh
@export var mesh: Mesh

@export_range(0, 100) var scale_factor: float = 4:
	set(a):
		scale_factor = a
		build = true
@export_range(0, 100) var pos_factor: float = 0.1:
	set(a):
		pos_factor = a
		build = true
@export_range(0, 1) var rot: float = 0:
	set(a):
		rot = a
		build = true
@export var instances_slice: Vector2i = Vector2i.ZERO:
	set(a):
		instances_slice = a
		build = true
@export var rot_randomize: bool = false:
	set(a):
		rot_randomize = a
		build = true

@export_global_file("*.json")
var json: String

@export var build: bool:
	set(n):
		if self.get_parent() == null:
			return

		if !json:
			printerr("no json selected!")
			return

		if !multimesh:
			multimesh = MultiMesh.new()

		if instances_slice.x > instances_slice.y:
			printerr("make sure slice range is normal (x must be more than y)!")
			return

		multimesh.instance_count = 0
		multimesh.mesh = mesh

		var file: String = FileAccess.get_file_as_string(json)
		var deser: = JSON.parse_string(file)
		if deser is not Dictionary:
			printerr("selected file is not json lol")
			return
		var dict: Dictionary = deser

		if multimesh.transform_format != MultiMesh.TRANSFORM_3D:
			multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.instance_count = dict.keys().size()

		var slicin: bool = instances_slice != Vector2i.ZERO
		if slicin:
			multimesh.instance_count = absi(instances_slice.x - instances_slice.y)

		var pointer: int = 0
		for k in dict.keys() if !slicin else dict.keys().slice(instances_slice.x, instances_slice.y):
			var inst: Dictionary = dict[k]

			var apos: Array = inst["pos"]
			if apos.size() < 3:
				continue

			var pos: Vector3 = Vector3(apos[1], apos[2], apos[0]) * pos_factor
			var fscale: float = inst["scale"]

			if fscale == 0: continue
			fscale *= scale_factor

			var rfscale: float = - fscale if randf() > 0.3 else fscale
			var scale: Vector3 = Vector3(rfscale, rfscale, rfscale)

			var t: Transform3D = Transform3D(Basis.from_scale(scale), pos)

			multimesh.set_instance_transform(pointer, t)
			pointer += 1


func _ready() -> void :
	if !Engine.is_editor_hint(): self.queue_free()
