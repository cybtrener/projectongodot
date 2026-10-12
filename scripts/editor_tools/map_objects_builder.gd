@tool
extends Node
class_name MapObjectsBuilder

"\ndefault object structure:\n\tparent_node\n\t\t-mesh\n\t\t-mesh.col\n\t\t\t-collision_object\n"







static var template_static: String = "res://maps/components/_map_object_static_inh.tscn"
static var template_destructible: String = "res://maps/components/_map_object_destructible_inh.tscn"


@export var build: bool:
	set(a):
		if !export_folder || !DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(export_folder)):
			printerr("no export folder selected!")
			return



		print("build process started")
		print("-------------------------------")


		var parent: Node = self.get_parent()
		for c in parent.get_children():
			if c == self: continue

			print(c.name, ": ")
			var sc_name: String = c.name.replace("_sc2", "")

			var col: Node
			var meshes: Array[MeshInstance3D] = []
			for cc in c.get_children():
				if cc is not MeshInstance3D: continue
				var has_colshapes: bool = cc.find_children("*", "CollisionShape3D", true).is_empty()
				if cc.name.contains("col") && !has_colshapes || !has_colshapes:
					col = cc
					continue

				meshes.append(cc)

			if meshes.is_empty(): continue

			print("\tmeshes: ", meshes)
			print("\tcol: ", col)
			var template: Node = load(template_destructible if destructibles else template_static).instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
			template.name = sc_name + "_01"

			if destructibles:
				var as_d: MapObjectDestructible = template as MapObjectDestructible
				as_d.force_update = true
				as_d.mesh_normal = meshes[0].mesh
				if meshes.size() > 1: as_d.mesh_destroyed = meshes[1].mesh
				as_d.material = as_d.material.duplicate()
				if col: as_d.colshape_normal = (col.find_children("*", "CollisionShape3D", true)[0] as CollisionShape3D).shape
				as_d.force_update = false
			else:
				var as_st: MapObjectStatic = template as MapObjectStatic
				as_st.force_update = true
				as_st.mesh = meshes[0].mesh
				as_st.material = as_st.material.duplicate()
				if col: as_st.colshape = (col.find_children("*", "CollisionShape3D", true)[0] as CollisionShape3D).shape
				as_st.force_update = false

			var scene: PackedScene = PackedScene.new()
			scene.pack(template)
			var err: = ResourceSaver.save(scene, export_folder + "/" + sc_name + ".tscn", ResourceSaver.FLAG_CHANGE_PATH)
			if err:
				print("\tsave err: ", err)



		print("-------------------------------")
		print("build finished")
@export_dir()
var export_folder: String = "res://maps/_export_test"
@export var destructibles: bool = false




static func get_files_from_folder(folder_path: String, ext_whitelist: Array[String] = [], create_missing_folder: bool = true) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(folder_path)

	print("Util.get_files_from_folder: begin loading folder: ", folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and ext_whitelist.has(file_name.get_extension()) or ext_whitelist.has("." + file_name.get_extension()):
				var file_path = folder_path.path_join(file_name)
				print("\t\tfile passed whitelist: '" + file_name + "'")
				files.push_back(file_path)
			file_name = dir.get_next()

		dir.list_dir_end()
	elif create_missing_folder:
		DirAccess.make_dir_recursive_absolute(folder_path)
		printerr("\tInvalid folder path: ", folder_path)

	print("Util.get_files_from_folder: end loading folder: ", folder_path)

	return files
