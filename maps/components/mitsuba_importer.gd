@tool
extends Node
class_name MitsubaImporter

@export var import_scene: bool:
	set(b):
		_import_scene()
@export var regenerate_scene: bool:
	set(b):
		_generate_scene()
@export var clear_scene: bool:
	set(b):
		for c in scene_root.get_children(): c.queue_free()
@export_global_file("*.xml")
var scene_xml: String

@export var scene_root: Node3D
@export var navmesh: NavigationRegion3D

@export var nodes_prefabs: Dictionary[String, PackedScene] = {

}

func cleanup_object_name(obj: String) -> String:
	for i in range(30):
		obj = obj.replace(".sc2_batch_0" + str(i), "")
		obj = obj.replace(".sc2_batch_" + str(i), "")
		obj = obj.replace("_batch_0" + str(i), "")
		obj = obj.replace("_batch_" + str(i), "")
		obj = obj.replace("batch_0" + str(i), "")
		obj = obj.replace("batch_" + str(i), "")
	if obj.begins_with("1_"):
		obj = obj.trim_prefix("1_")

	return obj

@export var objects_blacklist: Array[String] = [
	"landscape"
]

func _ready() -> void :
	if !Engine.is_editor_hint(): self.queue_free()

var node_entries_imported: Array[NodeEntry] = []
func _import_scene():
	if !Engine.is_editor_hint(): return

	if !scene_xml:
		printerr("You must specify an XML mitsuba scene config!")
		return
	var scene_file: FileAccess = FileAccess.open(scene_xml, FileAccess.READ)
	if !scene_file:
		printerr("Invalid scene file!")
		return
	var scene_root: XMLNode = XML.parse_buffer(scene_file.get_buffer(scene_file.get_length())).root
	if scene_root.name != "scene":
		printerr("Provided XML is not a scene file!")
		return
	node_entries_imported = []
	for c in scene_root.children:
		if c.name != "shape": continue

		var cstring: XMLNode = c.get_child_by_name("string")
		var ctransform: XMLNode = c.get_child_by_name("transform")

		if !cstring or !ctransform: continue
		var filename: String = cstring.attributes["value"].get_basename().get_file()
		filename = cleanup_object_name(filename)
		if objects_blacklist.has(filename): continue

		var smatrix: String = ctransform.get_child_by_name("matrix").attributes["value"]
		var ssmatrix: PackedStringArray = smatrix.split(" ")
		var fmatrix: Array[float] = []

		for s in ssmatrix:
			fmatrix.append(s.to_float())

		var decomposed: Transform3D = convert_dava_matrix_to_transform(fmatrix)

		var flag: = true
		for n in node_entries_imported:
			if n.transform.is_equal_approx(decomposed):
				flag = false
				break
		if !flag: continue

		node_entries_imported.append(NodeEntry.new().build(
			filename, 
			decomposed
		))

		if nodes_prefabs.is_empty():
			nodes_prefabs = {}

		if !nodes_prefabs.keys().has(filename):
			nodes_prefabs[filename] = null







	nodes_prefabs.sort()

	print("total prefabs: ", nodes_prefabs.size())
	print("total scene nodes: ", node_entries_imported.size())


func convert_dava_matrix_to_transform(matrix_array: Array) -> Transform3D:

	var m00: float = matrix_array[0]
	var m01: float = matrix_array[1]
	var m02: float = matrix_array[2]
	var m03: float = matrix_array[3]

	var m10: float = matrix_array[4]
	var m11: float = matrix_array[5]
	var m12: float = matrix_array[6]
	var m13: float = matrix_array[7]

	var m20: float = matrix_array[8]
	var m21: float = matrix_array[9]
	var m22: float = matrix_array[10]
	var m23: float = matrix_array[11]


	var dava_pos_x: float = m03
	var dava_pos_y: float = m13
	var dava_pos_z: float = m23


	var godot_pos: Vector3 = Vector3(dava_pos_x, dava_pos_z, - dava_pos_y)






	var dava_col_x: Vector3 = Vector3(m00, m10, m20)
	var dava_col_y: Vector3 = Vector3(m01, m11, m21)
	var dava_col_z: Vector3 = Vector3(m02, m12, m22)





	var godot_basis_x: Vector3 = Vector3(dava_col_x.x, dava_col_x.z, - dava_col_x.y)
	var godot_basis_y: Vector3 = Vector3(dava_col_z.x, dava_col_z.z, - dava_col_z.y)
	var godot_basis_z: Vector3 = Vector3( - dava_col_y.x, - dava_col_y.z, dava_col_y.y)


	var godot_basis: Basis = Basis(godot_basis_x, godot_basis_y, godot_basis_z)


	var transform: Transform3D = Transform3D(godot_basis, godot_pos)

	return transform


func _generate_scene():
	if !Engine.is_editor_hint(): return
	if !EditorInterface: return

	if !scene_root:
		printerr("You must specify 3D scene root to place objects to!")
		return

	for entry in node_entries_imported:
		if !nodes_prefabs.has(entry.obj_name): continue
		if !nodes_prefabs[entry.obj_name]: continue

		print("placing object '", entry.obj_name, "'")

		var flag: bool = true
		for c in scene_root.get_children():
			if c is not Node3D: continue
			if (c as Node3D).transform.is_equal_approx(entry.transform):
				flag = false
				if !entry.has_node(): entry.node = c

				break

		if !flag:
			print("object with same transform found, skipping")
			continue


		if entry.has_node():
			entry.node.transform = entry.transform
			continue

		var node_to_place: Node3D = nodes_prefabs[entry.obj_name].instantiate()
		node_to_place.transform = entry.transform

		if node_to_place is MapObjectStatic:
			node_to_place.add_to_group("navmesh_obstacle", true)

		var edited_root: Node = EditorInterface.get_edited_scene_root()




		scene_root.add_child(node_to_place, true, Node.INTERNAL_MODE_DISABLED)
		node_to_place.owner = edited_root


	EditorInterface.mark_scene_as_unsaved()








	if navmesh:
		navmesh.bake_navigation_mesh()
		ResourceSaver.save(navmesh.navigation_mesh)


class NodeEntry:
	var obj_name: String
	var transform: Transform3D
	var node: Node3D

	func has_node() -> bool:
		return node and is_instance_valid(node)

	func build(obj_name: String, transform: Transform3D) -> NodeEntry:
		self.obj_name = obj_name
		self.transform = transform

		return self
