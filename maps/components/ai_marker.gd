@tool
extends Marker3D
class_name AIMarker

enum Type{
	PRIORITY_PRIMARY, 
	PRIORITY_SECONDARY, 
	PRIORITY_TERTIARY, 

	SNIPE, 
	HIDEOUT
}

@export var type: Type = Type.PRIORITY_TERTIARY

@export_range(1, 500) var radius: float = 10:
	set = set_radius
@export_range(0, 5) var priority: int = 0

var rad_visual: MeshInstance3D
var occupier: Node = null

func is_sniper() -> bool:
	return type == Type.SNIPE
func is_normal() -> bool:
	return type == Type.PRIORITY_PRIMARY || type == Type.PRIORITY_SECONDARY || type == Type.PRIORITY_TERTIARY

func occupy(new: Node):
	occupier = new
func can_occupy():
	return occupier == null

func set_radius(new_rad: float) -> float:
	radius = new_rad
	if is_instance_valid(rad_visual):
		rad_visual.mesh.top_radius = new_rad
		rad_visual.mesh.bottom_radius = new_rad
		rad_visual.mesh.height = new_rad

	return new_rad

func _enter_tree() -> void :
	if Engine.is_editor_hint(): add_editor_stuff()

func add_editor_stuff():
	gizmo_extents = 5

	var flag: MeshInstance3D = MeshInstance3D.new()
	flag.mesh = load("res://maps/components/flag.glb").instantiate().get_child(0).mesh
	flag.scale *= 10
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	flag.material_override = mat

	self.add_child(flag)

	if is_instance_valid(rad_visual): rad_visual.queue_free()

	rad_visual = MeshInstance3D.new()
	rad_visual.mesh = CylinderMesh.new()

	mat = StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color.RED
	mat.albedo_color.a = 0.2
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rad_visual.material_override = mat

	self.add_child(rad_visual)
	rad_visual.name = "sphere"

	set_radius(radius)

func _ready() -> void :
	if Engine.is_editor_hint(): return
	Util.clear_children(self)

	Battle.ai_markers.push_back(self)
