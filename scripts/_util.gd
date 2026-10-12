extends Node3D

static var sec_to_min: float = 1.0 / 60.0
static var sec_to_hour: float = 1.0 / 3600.0
static var hour_to_day: float = 1.0 / 24
static var hour_to_montth: float = 1.0 / 24 / 30

class RaycastParams:
	var from: Vector3 = Vector3()
	var to: Vector3 = Vector3()
	var mask: int = 0
	var exclude: Array

func globalize_res_path(path: String) -> String:
	var res: String = "res://"
	if path.contains(res): path.remove_chars(res)
	return ProjectSettings.globalize_path(res + path) if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join(path)


func reparent_node(n: Node3D, new_parent: Node3D, keep_transform: bool = false) -> void :
	var pos_prev: Vector3 = n.position
	n.get_parent().remove_child(n)
	n.owner = null
	new_parent.add_child(n)

	if keep_transform: n.position = pos_prev

func rand_arr_id(array: Array):
	return randi_range(0, array.size() - 1)

func array_id_valid(array: Array, id: int) -> bool:
	return id >= 0 and array.size() - 1 >= id

func dict_add_to_int(dic: Dictionary, key, amount: int):
	if !dic.has(key):
		dic[key] = 0
	dic[key] += amount

static func projectile_yvelocity_step(gravity: float, delta: float):
	return gravity * delta

func curtime() -> float:
	return Time.get_ticks_msec() * 0.001
func curtime_sys() -> float: return Time.get_unix_time_from_system()
func curtime_sys_dict() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(curtime_sys())

func clampi_to_zero(num: int):
	return maxi(num, 0)
func clampf_to_zero(num: float):
	return maxf(num, 0)

static func reverse_children(parent: Node):
	var children: Array[Node] = parent.get_children()
	children.reverse()

	var total: int = children.size()
	for i in range(children.size()):
		var c: Node = children[i]
		if !is_instance_valid(c): continue

		parent.move_child(c, children.size() - 1)

static func clear_children(node: Node):
	if !is_instance_valid(node):
		printerr("clear_children: attempt to clear children of invalid node")
	for c in node.get_children():
		if !is_instance_valid(c): continue
		c.queue_free()

static func get_subfolders(folder_path: String) -> Array[String]:
	var folders: Array[String] = []
	var dir = DirAccess.open(folder_path)

	if !DirAccess.dir_exists_absolute(folder_path):
		printerr("Resource Loader get_subfolders: folder does not exist! '", folder_path, "'")
		return folders
	if !dir:
		printerr("Could not open directory '", folder_path, "' error: %s" % error_string(DirAccess.get_open_error()))
		return folders
	dir.list_dir_begin()
	var name = dir.get_next()

	while name != "":
		if not name.begins_with("."):
			var full_path = folder_path.path_join(name)
			if DirAccess.dir_exists_absolute(full_path):
				folders.append(name)
		name = dir.get_next()

	return folders

var gltf_cache: Dictionary[String, PackedScene] = {}

static func col_shape_from_model(mdl: MeshInstance3D, trimesh: bool) -> CollisionShape3D:
	if trimesh:
		mdl.create_trimesh_collision()
	else:
		mdl.create_convex_collision()

	if mdl.get_child(0) == null or mdl.get_child(0).get_child(0) == null:
		return null

	var col_shape: CollisionShape3D = mdl.get_child(0).get_child(0) as CollisionShape3D


	return col_shape

static func replace_collision_from_donor(donor: MeshInstance3D, receiver: CollisionShape3D, trimesh: bool) -> Shape3D:
	if !is_instance_valid(receiver): return

	var new_shape: CollisionShape3D = Util.col_shape_from_model(donor, trimesh)

	receiver.shape = new_shape.shape
	new_shape.queue_free()

	return receiver.shape

func load_gltf(path: String, scale_factor: float = 1) -> PackedScene:
	if gltf_cache.has(path):
		return gltf_cache[path]

	var doc: GLTFDocument = GLTFDocument.new()
	var state: GLTFState = GLTFState.new()

	var err = doc.append_from_file(path, state)
	if err != OK:
		push_error("GLB import failed: %d, %s" % [err, path])
		return null

	var scene: Node3D = doc.generate_scene(state)
	if !scene:
		return null
	var mesh_instances = scene.find_children("", "MeshInstance3D", true, false)
	for mi in mesh_instances:
		if mi.mesh:
			mi.mesh = _scale_array_mesh(mi.mesh, scale_factor)
		mi.position *= scale_factor

	var packed: PackedScene = PackedScene.new()
	packed.pack(scene)

	gltf_cache[path] = packed

	return gltf_cache[path]


func _scale_array_mesh(mesh: ArrayMesh, scale_factor: float) -> ArrayMesh:
	var new_mesh = ArrayMesh.new()

	for i in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(i)

		if arrays.size() > Mesh.ARRAY_VERTEX and arrays[Mesh.ARRAY_VERTEX] != null:
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var scaled_vertices = PackedVector3Array()

			for v in vertices:
				scaled_vertices.append(v * scale_factor)

			arrays[Mesh.ARRAY_VERTEX] = scaled_vertices

		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return new_mesh

static func save_resource_encrypted(res: Resource, path: String, ext: String = "bin"):
	var dir: String = path.get_base_dir()

	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	if !ext.begins_with("."): ext = "." + ext

	var filename: String = path.get_file().get_basename()


	if !DirAccess.dir_exists_absolute(dir + "/temp/"):
		DirAccess.make_dir_absolute(dir + "/temp/")

	var temp: String = dir + "/temp/" + filename + ".tres"
	var savepath: String = dir + "/" + filename + ext
	ResourceSaver.save(res, temp)

	var tempf: FileAccess = FileAccess.open(temp, FileAccess.READ)

	if !tempf:
		printerr("encrypted resource saving failed, cant create temp file there: '" + temp + "'")

	var tempb: PackedByteArray = tempf.get_buffer(tempf.get_length())
	tempf.close()

	var savedf: FileAccess = FileAccess.open_encrypted_with_pass(savepath, FileAccess.WRITE, Global.encryption_key)
	savedf.store_buffer(tempb)
	savedf.close()

	if !Global.dont_delete_temp_encrypted_resources: DirAccess.remove_absolute(temp)

	print("saved encrypted resource: '" + savepath + "'")

static func load_resource_encrypted(filepath: String) -> Resource:
	if !FileAccess.file_exists(filepath):
		printerr("failed to load encrypted resource: '" + filepath + "', " + "file doesnt exist!")
		return null


	var savedf: FileAccess = FileAccess.open_encrypted_with_pass(filepath, FileAccess.READ, Global.encryption_key)
	if !savedf:
		printerr("failed to load encrypted resource: '" + filepath + "', " + "failed to open/decrypt!")
		return null

	var filename: String = filepath.get_file()
	var filepath_dir: String = filepath.get_base_dir()

	var tempp_dir: String = filepath_dir + "/temp_load/"
	if !DirAccess.dir_exists_absolute(tempp_dir):
		DirAccess.make_dir_absolute(tempp_dir)

	var tempp: String = tempp_dir + filename.get_basename() + ".tres"

	var tempf: FileAccess = FileAccess.open(tempp, FileAccess.WRITE)
	var tempb: PackedByteArray = savedf.get_buffer(savedf.get_length())

	tempf.store_buffer(tempb)
	tempf.close()



	var res: Resource = load(tempp)
	if !Global.dont_delete_temp_encrypted_resources: DirAccess.remove_absolute(tempp)

	return res

static func get_files_from_folder(folder_path: String, ext_whitelist: Array[String] = [], create_missing_folder: bool = true):
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

static func load_resources_from_folder(folder_path: String, create_missing_folder: bool = true) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(folder_path)

	print("Resource Loader: begin loading folder: ", folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var file_path = folder_path.path_join(file_name)
				var resource = load(file_path)

				if resource:
					resources.append(resource)
					print("\tLoaded resource: ", file_path)
				else:
					push_warning("\tFailed to load resource: ", file_path)

			file_name = dir.get_next()

		dir.list_dir_end()
	elif create_missing_folder:
		DirAccess.make_dir_recursive_absolute(folder_path)
		printerr("\tInvalid folder path: ", folder_path)

	print("Resource Loader: end loading folder: ", folder_path)

	return resources



static func mouse_lock(lock: bool):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if lock && !Global.save_settings.show_mobile_controls else Input.MOUSE_MODE_VISIBLE
static func get_mouse_lock() -> bool:
	return Global.save_settings.show_mobile_controls || Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

static func k_pressed(code: Key) -> bool:
	return Input.is_key_pressed(code)
static func a_pressed(key: StringName) -> bool:
	return Input.is_action_pressed(key)
static func a_jpressed(key: StringName) -> bool:
	return Input.is_action_just_pressed(key)
static func action_vec(
	a1: StringName, a2: StringName, a3: StringName, a4: StringName) -> Vector2:
	return Input.get_vector(
		a1, a2, a3, a4
		)


static func get_forward(basis: Basis):
	return basis.z
static func get_right(basis: Basis):
	return basis.x

static func pos_to_local_rotated(node: Node3D, pos: Vector3) -> Vector3:
	var pos_local: Vector3 = node.to_local(pos)
	var b: Basis = node.basis
	var offset_local: Vector3 = pos_local.x * b.x + pos_local.y * b.y + pos_local.z * b.z

	return offset_local

static func raycast_3d_dummy() -> Dictionary:
	return raycast_hit_null.duplicate(true)

static var raycast_hit_null: Dictionary = {
		hit = false, 
		collider = null, collider_id = -1, normal = Vector3(), 
		position = Vector3(), face_index = -1, rid = null, 
		shape = -1
	}
static var param3d: PhysicsRayQueryParameters3D = null


func get_best_option(dict: Dictionary):
	dict.sort()
	return dict[dict.keys().back()]

func raycast_3d_dict(params: Dictionary, debug: bool = false, debug_dur: float = 0, debug_color: Color = Color.RED) -> Dictionary:
	params.from = params.from if params.has("from") else Vector3()
	params.to = params.to if params.has("to") else Vector3()
	params.mask = params.mask if params.has("mask") else 0
	if params.has("exclude"):
		params.exclude = params.exclude
	return raycast_3d(params.from, params.to, params.collision_mask, params.exclude, debug, debug_dur, debug_color)

func raycast_3d(from: Vector3, to: Vector3, collision_mask: int = 1, exclude: Array[RID] = [], debug: bool = false, debug_dur: float = 0, debug_color: Color = Color.RED) -> Dictionary:
	if not param3d:
		param3d = PhysicsRayQueryParameters3D.create(Vector3(), Vector3())

	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	param3d.from = from
	param3d.to = to
	param3d.collision_mask = collision_mask
	param3d.exclude = exclude

	param3d.hit_from_inside = false

	if !is_instance_valid(space):

		return raycast_hit_null.duplicate(true)

	var ray: Dictionary = space.intersect_ray(param3d)
	var result = raycast_hit_null.duplicate(true)

	if ray.keys().size() != 0:
		result.hit = true
		result.collider = ray.collider
		result.collider_id = ray.collider_id
		result.normal = ray.normal
		result.position = ray.position
		result.face_index = ray.face_index
		result.rid = ray.rid
		result.shape = ray.shape







	else:
		result.position = to

	if debug:
		Line3D.DrawLine(param3d.from, result.position if result.hit else param3d.to, debug_color, debug_dur, true)

	return result

static func trace_projectile(params: Dictionary, start: Vector3, dir: Vector3, flight_time: float, steps: float, speed: float, gravity: float):
	var time_step: = (flight_time) / steps
	var vel: Vector3 = dir * speed
	vel.y -= gravity * time_step * 0.5

	var start_pos: Vector3 = start

	var hit
	for i in range(steps):
		var from = start_pos
		var to = from + vel * time_step

		hit = Util.raycast_3d(
			from, 
			to, 
			params.mask if params.has("mask") else 0, 
			params.exclude if params.has("exclude") else [], 
		)

		Line3D.DrawLine(from, hit.position, Color.RED, 0)

		if hit.hit:
			return hit

		vel.y -= gravity * time_step
		start_pos = to

	return hit

var timers: Array[Dictionary] = []
func timer_curtime(time: float, f: Callable, name: String = "") -> Dictionary:
	var t: Dictionary = {
		time = curtime() + time, function = f, invalid = false
	}
	timers.push_front(t)

	return t

func _physics_process(delta: float) -> void :
	for i in range(timers.size()):
		if timers.size() - 1 < i: continue

		var t: Dictionary = timers[i]
		if t.invalid: continue

		if curtime() >= t.time:
			if t.function is not Callable || !t.function.is_valid():
				continue

			t.function.call()
			t.invalid = true
			timers.remove_at(i)

func timer(time: float, f: Callable):
	get_tree().create_timer(abs(time)).timeout.connect(f)

func delay(time: float):
	return get_tree().create_timer(abs(time)).timeout

var _curtime_delays: Dictionary[StringName, float] = {}

func delay_curtime(name: StringName, time: float, requestor: Node = null):
	if requestor:
		name += "_" + str(requestor.get_instance_id())
	_curtime_delays[name] = curtime() + time
func delay_curtime_elapsed(name: StringName, requestor: Node = null) -> bool:
	if requestor: name += "_" + str(requestor.get_instance_id())
	if _curtime_delays.has(name):
		return curtime() >= _curtime_delays[name]
	return true

func delay_curtime_elapsed_set(name: StringName, time: float, requestor: Node = null) -> bool:
	if delay_curtime_elapsed(name, requestor):
		delay_curtime(name, time, requestor)
		return true
	else:
		return false

func round_to_dec(num: float, digit: int) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func split_time(time_sec: float) -> Array[int]:
	var rem_min: int = floorf(time_sec * Util.sec_to_min)
	var rem_sec: int = floori(fmod(time_sec, 60))

	return [rem_min, rem_sec]

func select(o1, o2, cond: bool):
	return o1 if cond else o2

func format_number(num: int) -> String:
	var num_s: String = str(absi(num))

	var res: = ""
	var lenn: = num_s.length()

	for i in range(lenn):
		if i > 0 and (lenn - i) % 3 == 0:
			res += " "
		res += num_s[i]

	if num < 0:
		res = "-" + res

	return res

func artificial_stutter():
	if !Global.save_settings.artificial_load_times: return

	for i in range(100000):
		var j = i


func format_number_to_k(value: int) -> String:

	if value >= 1000000:
		var divided: float = value / 1000000.0
		return _format_suffix(divided, "kk")



	elif value >= 10000:
		var divided: float = value / 1000.0
		return _format_suffix(divided, "k")

	else:
		return format_number(value)

func _format_suffix(value: float, suffix: String) -> String:

	var rounded: float = roundf(value * 10.0) / 10.0


	var text: String = str(rounded)


	if text.contains("."):
		text = text.rstrip("0").rstrip(".")

	return text + suffix


func random_chance(chance: float) -> bool:
	return chance * 0.01 > randf()

func _node_valid(node: Node) -> bool:
	return node is Node and is_instance_valid(node)

var print_delay_requestors: Dictionary[Node, float] = {}
var next_print: float = 0
func print_with_delay(str, delay: float = 0.2, requestor: Node = null):
	if _node_valid(requestor):
		if print_delay_requestors.has(requestor) and curtime() < print_delay_requestors[requestor]:
			return
		print(str)
		await get_tree().process_frame

		if !is_instance_valid(requestor): return
		print_delay_requestors[requestor] = curtime() + delay
	else:
		if curtime() < next_print: return
		print(str)
		await get_tree().process_frame
		next_print = curtime() + delay
