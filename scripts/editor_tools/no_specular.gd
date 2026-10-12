@tool
extends EditorScript

func _run():
	var scene = EditorInterface.get_edited_scene_root()
	_process_node(scene)

func _process_node(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		var mat2 = node.material_override
		mat2.metallic_specular = 0.0

		if not mesh: return
		for i in range(mesh.get_surface_count()):
			var mat = mesh.surface_get_material(i)

			mat.metallic_specular = 0.0

			print("Set specular=0 on material in ", node.name)
	for child in node.get_children():
		_process_node(child)
