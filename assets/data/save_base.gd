extends Resource
class_name SaveBase

func save(path: StringName, save_path: StringName = ""):
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())

	print(str(self) + ": im saved!!" + " path: " + path)
	ResourceSaver.save(self, path)
