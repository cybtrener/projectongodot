extends Node

const max_segments: = 32
const max_dist: = 500

const num_segments: = 0
const width: = 0.2
const segment_life_time: = 0.8

var shell_mesh: ImmediateMesh = ImmediateMesh.new()
var shell_mesh_instance: MeshInstance3D

static var trail_mat: ShaderMaterial = load("res://assets/tanks/base/projectile/trail.material") as ShaderMaterial
var segments: Array[Dictionary] = []

func segment():
	return {
		birth = Util.curtime(), 
		vertices = PackedVector3Array(), 
		uvs = PackedVector2Array(), 
		color = Color()
	}

func _ready() -> void :
	shell_mesh = ImmediateMesh.new()

	shell_mesh_instance = MeshInstance3D.new()
	shell_mesh_instance.mesh = shell_mesh
	shell_mesh_instance.material_override = trail_mat
	shell_mesh_instance.top_level = true
	add_child(shell_mesh_instance)
	shell_mesh_instance.global_position = Vector3()

func add_segment(segment: Dictionary):
	if segment != {}: segments.append(segment)

var nextpoint: = 0
func _physics_process(delta: float) -> void :
	update(delta)
func update(delta: float) -> void :
	if Util.curtime() > nextpoint:
		nextpoint = Util.curtime() + 0.2
		shell_mesh.clear_surfaces()

		if segments.size() > 0: shell_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		for s in segments:
			if !process_segment(s):

				shell_mesh.surface_add_vertex(Vector3())
				shell_mesh.surface_add_vertex(Vector3())
				shell_mesh.surface_add_vertex(Vector3())
				continue
		if segments.size() > 0: shell_mesh.surface_end()

func process_segment(s) -> bool:
	if Util.curtime() > s.birth + segment_life_time:
		segments.pop_front()
		return false

	var age: float = 1 - ((Util.curtime() - s.birth) / segment_life_time)

	age = clampf(age, 0, 1) * 0.2
	for i in range(s.vertices.size()):
		var v: Vector3 = s.vertices[i]
		var uv: Vector2 = s.uvs[i]

		shell_mesh.surface_set_uv(Vector2(1, 0))

		s.color.a = age
		shell_mesh.surface_set_uv(uv)
		shell_mesh.surface_set_color(s.color)
		shell_mesh.surface_add_vertex(v)

	return true
