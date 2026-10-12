class_name ModUtils

static var ext_exclude: Array[String] = [
	".pck", 
]

static func err(...str):
	printerr("ModUtils: ", str(str))

static func print_log(...str):
	print("ModUtils: ", str)

static func pack_folder_pck(
	source_folder: String, 
	output_pck: String, 
	virtual_base: String
) -> bool:
	print_log("Begin packing from '%s' into: '%s'" % [source_folder, output_pck])


	var source = source_folder
	var output = output_pck
	if source.begins_with("res://") or source.begins_with("user://"):
		source = ProjectSettings.globalize_path(source)


	if not DirAccess.dir_exists_absolute(source):
		err("Source folder not found: %s" % source)
		return false


	if FileAccess.file_exists(output):
		DirAccess.remove_absolute(output)


	var packer = PCKPacker.new()
	if packer.pck_start(output, true) != OK:
		err("Failed to start PCK")
		return false


	var count = _add_files(packer, source, virtual_base)

	if count == 0:
		packer.flush()
		push_warning("No files to pack")
		return false


	if packer.flush() != OK:
		err("Failed to finalize PCK")
		return false

	print_log("✅ Packed %d files into: %s" % [count, output])
	return true


static func _add_files(packer: PCKPacker, folder: String, virtual_path: String) -> int:
	var dir = DirAccess.open(folder)
	if not dir:
		return 0

	var count = 0
	dir.list_dir_begin()
	var name = dir.get_next()

	while name != "":
		var full = folder.path_join(name)
		var virt = virtual_path.path_join(name)
		if full.contains(".godot"):
			virt = "res://.godot/".path_join(name)

		"\n\t\tres://mods_loaded/.godot D:/Godot/blitz_legacy/mods/german_lights-2.6.0/.godot\n\t\tres://mods_loaded/.godot/.gdignore D:/Godot/blitz_legacy/mods/german_lights-2.6.0/.godot/.gdignore\n\t\tres://mods_loaded/.godot/editor D:/Godot/blitz_legacy/mods/german_lights-2.6.0/.godot/editor\n\t\tres://mods_loaded/.godot/editor/editor_layout.cfg D:/Godot/blitz_legacy/mods/german_lights-2.6.0/.godot/editor/editor_layout.cfg\n\t\tres://mods_loaded/.godot/editor/filesystem_cache10 D:/Godot/blitz_legacy/mods/german_lights-2.6.0/.godot/editor/filesystem_cache10\n\t\t"







		if DirAccess.dir_exists_absolute(full):
			count += _add_files(packer, full, virt)
		elif FileAccess.file_exists(full):
			if not ext_exclude.has(name.get_extension()):
				if packer.add_file(virt, full) == OK:
					count += 1

		name = dir.get_next()

	return count


static func needs_repack(source_folder: String, output_pck: String) -> bool:
	var source = source_folder
	var output = output_pck
	if source.begins_with("res://") or source.begins_with("user://"):
		source = ProjectSettings.globalize_path(source)
	if output.begins_with("res://") or output.begins_with("user://"):
		output = ProjectSettings.globalize_path(output)

	if not FileAccess.file_exists(output):
		return true

	var source_time = _get_folder_time(source)
	var pck_time = FileAccess.get_modified_time(output)

	return source_time > pck_time


static func _get_folder_time(folder: String) -> int:
	var dir = DirAccess.open(folder)
	if not dir:
		return 0

	var newest = 0
	dir.list_dir_begin()
	var name = dir.get_next()

	while name != "":
		if not name.begins_with("."):
			var full = folder.path_join(name)
			if DirAccess.dir_exists_absolute(full):
				var sub = _get_folder_time(full)
				if sub > newest:
					newest = sub
			elif FileAccess.file_exists(full):
				var t = FileAccess.get_modified_time(full)
				if t > newest:
					newest = t
		name = dir.get_next()

	return newest
