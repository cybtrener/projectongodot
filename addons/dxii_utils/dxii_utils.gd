@tool
extends EditorPlugin

var scroll_box: ScrollContainer
var tab: VBoxContainer

var atlas_path_import: TextEdit
var atlas_path_export: TextEdit

var atlas_export_prefix: TextEdit
var max_variants: SpinBox

var reverse_variants: CheckBox

var atlas_texture: TextEdit
var atlas_texture1: TextEdit
var atlas_texture2: TextEdit
var atlas_texture3: TextEdit

var tank_xmls_path: TextEdit
var tank_xmls_strings_path: TextEdit
var tank_xmls_nation: TextEdit

var stitcher_folder: TextEdit
var stitcher_name_pattern: TextEdit

var atlas_stitch_holder: ArrayHolderAtlas = ArrayHolderAtlas.new([] as Array[AtlasTexture])


class ArrayHolderAtlas extends Resource:
	func _init(arr: Array[AtlasTexture]):
		self.array = arr
	@export var array: Array[AtlasTexture]

func _enter_tree():
	scroll_box = ScrollContainer.new()
	scroll_box.name = "WotBlitz Utils"
	scroll_box.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll_box.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	tab = VBoxContainer.new()
	scroll_box.add_child(tab)

	new_label("Tanks configs parser", true)
	new_label("Tanks xmls YAML strings path")
	tank_xmls_strings_path = new_text_edit("C:/Absolute/Path/To/Strings/file.yaml")
	tank_xmls_strings_path.text = "D://WOTB_revamp_stuff//old versions//1.5 apk//DataSource//Strings//ru.yaml"

	new_label("Nation key")
	tank_xmls_nation = new_text_edit("germany/ussr/usa/gb")
	tank_xmls_nation.text = "germany"
	new_label("Tanks xmls path")
	tank_xmls_path = new_text_edit("C:/Absolute/Path/To/XML/Subfolder")
	tank_xmls_path.tooltip_text = "this folder MUST have 'components' folder containing guns.xml, shells.xml, engines.xml"
	tank_xmls_path.text = "D://WOTB_revamp_stuff//old versions//1.5 ander backup//XML//items_def//vehicles//"
	new_button("Parse tanks xmls", parse_tank_xml, "Creates materials from all images selected in FileSystem")


	new_label("Atlas parser", true)
	new_label("Atlas import path")
	atlas_path_import = new_text_edit("C:/Absolute/Path/To/Gfx/Subfolder")
	new_label("Atlas export path")
	atlas_path_export = new_text_edit("res://export/path/")
	atlas_path_export.text = "res://assets/_atlas_parsed/"

	new_label("Atlas texture/texture0")
	atlas_texture = new_text_edit("res://path/to/(texture|texture0)")
	new_label("Atlas texture1")
	atlas_texture1 = new_text_edit("res://path/to/texture1")
	new_label("Atlas texture2")
	atlas_texture2 = new_text_edit("res://path/to/texture2")
	new_label("Atlas texture3")
	atlas_texture3 = new_text_edit("res://path/to/texture3")

	new_label("Maximum variants for an exported file:")
	max_variants = SpinBox.new()
	max_variants.step = 1
	max_variants.max_value = 256
	max_variants.value = 128
	add_element(max_variants)


	new_label("Atlas exported name prefix (%d - the number)")
	atlas_export_prefix = new_text_edit("res://path/to/texture2...")
	atlas_export_prefix.text = "_0%d"

	var rvars: HBoxContainer = HBoxContainer.new()
	var rvars_label: = _new_label("Reverse variants order")
	rvars.add_child(rvars_label)

	reverse_variants = CheckBox.new()
	reverse_variants.text = "On"
	reverse_variants.tooltip_text = "If the file has more than 1 variants, checking this will reverse their order of parsing"
	rvars.add_child(reverse_variants)
	add_element(rvars)

	new_button("Parse atlas", parse_atlas, "Turns wotblitz gfx/gfx2 subfolder and creates atlas textures using 'texture0...n' paths")
	new_button("Materials from selected images", create_materials_from_selected_images, "Creates materials from all images selected in FileSystem")

	new_label("Atlas stitcher", true)
	new_label("Textures to stitch", false)
	var stitcher_array_inspector: EditorInspector = EditorInspector.new()
	stitcher_array_inspector.custom_minimum_size.y = 300
	stitcher_array_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stitcher_array_inspector.edit(atlas_stitch_holder)

	add_element(stitcher_array_inspector)
	new_button("Stitch atlas", stitch_atlas, "Stitches atlas from array")
	new_button("Clear array", func():
		atlas_stitch_holder.array = []
		stitcher_array_inspector.edit(atlas_stitch_holder)
	, "Clears textures array")






	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, scroll_box)


func stitch_atlas():
	if atlas_stitch_holder.array.is_empty(): return

	var atlas_img: Image = stitch_atlas_textures_horizontally(atlas_stitch_holder.array)
	var path: String = atlas_stitch_holder.array[0].resource_path

	save_image_to_disk(atlas_img, path.get_basename() + "_stitched.png")

func stitch_atlas_textures_horizontally(atlas_array: Array[AtlasTexture], include_margin: bool = false) -> Image:
	print("Atlas stitching began!")
	print("total elements: " + str(atlas_array.size()))
	if atlas_array.is_empty():
		push_error("Stitching failed: Atlas array is empty.")
		return null

	var max_width: int = 0
	var max_height: int = 0
	var valid_count: int = 0


	for atlas_tex in atlas_array:
		if atlas_tex == null or atlas_tex.atlas == null:
			continue

		var region = _get_effective_rect(atlas_tex, include_margin)
		if region.size.x > max_width:
			max_width = region.size.x
		if region.size.y > max_height:
			max_height = region.size.y

		valid_count += 1

	if valid_count == 0 or max_width == 0 or max_height == 0:
		push_error("Stitching failed: No valid textures found or calculated dimensions are zero.")
		return null



	var total_width: int = max_width * valid_count
	var total_height: int = max_height

	print("max element width: " + str(max_width))
	print("max element height: " + str(max_height))


	var combined_image = Image.create(total_width, total_height, false, Image.FORMAT_RGBA8)
	combined_image.fill(Color.TRANSPARENT)


	var current_cell_index: int = 0
	for atlas_tex in atlas_array:
		if atlas_tex == null or atlas_tex.atlas == null:
			continue

		var region = _get_effective_rect(atlas_tex, include_margin)
		var base_image: Image = atlas_tex.atlas.get_image()

		if base_image == null:
			push_warning("Stitching: Could not get image data from atlas, skipping.")
			continue

		var sub_image: Image = base_image.get_region(region)


		var offset_x: int = int((max_width - sub_image.get_width()) / 2.0)
		var offset_y: int = int((max_height - sub_image.get_height()) / 2.0)


		var cell_start_x: int = current_cell_index * max_width


		var dst_pos: Vector2i = Vector2i(cell_start_x + offset_x, offset_y)


		combined_image.blit_rect(
			sub_image, 
			Rect2i(0, 0, sub_image.get_width(), sub_image.get_height()), 
			dst_pos
		)

		current_cell_index += 1

	return combined_image



func _get_effective_rect(atlas_tex: AtlasTexture, include_margin: bool) -> Rect2i:
	var rect = atlas_tex.region


	if rect.size.x == 0 or rect.size.y == 0:
		rect = Rect2i(0, 0, atlas_tex.atlas.get_width(), atlas_tex.atlas.get_height())

	if include_margin:

		rect.position.x -= atlas_tex.margin.position.x
		rect.position.y -= atlas_tex.margin.position.y
		rect.size.x += atlas_tex.margin.size.x
		rect.size.y += atlas_tex.margin.size.y

	return rect



func create_texture_from_image(image: Image) -> ImageTexture:
	if image == null:
		return null
	var texture = ImageTexture.create_from_image(image)
	return texture



func save_image_to_disk(image: Image, file_path: String) -> bool:
	if image == null:
		return false

	var error = image.save_png(file_path)
	if error == OK:
		print("Successfully saved stitched atlas to: ", file_path)
		return true
	else:
		push_error("Failed to save image. Error code: ", error)
		return false


func _new_label(text: String) -> Label:
	var label: = Label.new()
	label.text = text

	return label

func new_checkbox(name: String = "Checkbox", tooltip: String = "", checkbox_text: String = "") -> CheckBox:
	var hbox: HBoxContainer = HBoxContainer.new()
	var label: = _new_label(name)
	hbox.add_child(label)

	var cbox: CheckBox = CheckBox.new()
	cbox.text = checkbox_text
	cbox.tooltip_text = tooltip
	hbox.add_child(cbox)
	add_element(hbox)

	return cbox

func new_label(text: String, header: bool = false) -> Label:
	var label: = Label.new()
	label.text = text

	if header:
		label.add_theme_font_size_override("font_size", 25)

	add_element(label)
	return label

func new_text_edit(placeholder_text: String):
	var text_edit: = TextEdit.new()
	text_edit.placeholder_text = placeholder_text
	text_edit.custom_minimum_size = Vector2(0, 30)
	add_element(text_edit)

	return text_edit

func new_button(text: String, function: Callable, tooltip: String = "") -> void :
	var button = Button.new()
	button.text = text
	button.pressed.connect(function)
	button.tooltip_text = tooltip

	add_element(button)

func add_element(elem):
	tab.add_child(elem)

func _exit_tree():
	remove_control_from_docks(scroll_box)

func parse_atlas():
	if atlas_path_import.text.right(1) != "/":
		atlas_path_import.text += "/"

	var tex: = load(atlas_texture.text) as Texture2D
	var tex1: = load(atlas_texture1.text) as Texture2D
	var tex2: = load(atlas_texture2.text) as Texture2D
	var tex3: = load(atlas_texture3.text) as Texture2D
	ensure_res_folder(atlas_path_export.text)

	for temp in parse_icons(atlas_path_import.text):
		var texx
		match temp.tex:
			"texture":
				texx = tex
			"texture0":
				texx = tex
			"texture1":
				texx = tex1
			"texture2":
				texx = tex2
			"texture3":
				texx = tex3
		atlas_create_save(temp.name, texx, temp.rect)

func atlas_create_save(name: String, base_tex: Texture2D, rect: Rect2):
	var atlas_tex: = AtlasTexture.new()
	atlas_tex.atlas = base_tex
	atlas_tex.region = rect

	var path: = atlas_path_export.text + name + ".tres"
	ResourceSaver.save(atlas_tex, path)

func array_valid_index(array: Array, id: int):
	return id <= array.size() - 1


func parse_icons(path: String):
	var dir = DirAccess.open(path)

	var templates = []
	var files: Array = get_files_in_path_dir(path, "txt")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = dir.get_next()
			print("parsing file: " + file_name)

			if dir.current_is_dir():
				continue
			var split = file_name.split(".")
			var ext: String = split[split.size() - 1]
			if ext != "txt":
				print("error: the file is not txt silly")
				continue

			var file = FileAccess.open(path + file_name, FileAccess.ModeFlags.READ)
			if not file:
				print("error: no file")
				continue

			var lines = file.get_as_text().split("\n")
			var texname = lines[1]

			var rang: Array = range(4, clampi(lines.size() - 1, 0, max_variants.value))
			print("variants: " + str(rang))

			if reverse_variants.toggle_mode: rang.reverse()

			var c: = 1
			for i in rang:
				var the_line = lines[i].split(" ")

				if the_line.is_empty(): continue
				if not array_valid_index(the_line, 1):
					print("error: no line part 1")
					continue
				if not array_valid_index(the_line, 2):
					print("error: no line part 2")
					continue
				if not array_valid_index(the_line, 3):
					print("error: no line part 3")
					continue

				var x = the_line[0].to_int()
				var y = the_line[1].to_int()
				var r1 = the_line[2].to_int()
				var r2 = the_line[3].to_int()

				var prefix: = atlas_export_prefix.text % c if c > 1 else ""

				templates.push_back({
					name = file_name.split(".")[0] + prefix, 
					tex = texname.split(".")[0], 
					rect = Rect2(x, y, r1, r2)
				})
				print("\t\tname:" + file_name.split(".")[0] + prefix)
				print("\t\ttex:" + texname.split(".")[0])

				c += 1




		return templates
	else:
		return []
		print("An error occurred when trying to access the path.")

func ensure_res_folder(path: String) -> bool:

	if DirAccess.dir_exists_absolute(path):
		return true


	var err = DirAccess.make_dir_recursive_absolute(path)
	if err == OK:
		print("Created folder: %s" % path)
		return true
	else:
		push_error("Failed to create folder: %s (error %d)" % [path, err])
		return false

func create_materials_from_selected_images():
	var editor_interface = get_editor_interface()
	var selected_files: = editor_interface.get_selected_paths()

	if selected_files.is_empty():
		push_warning("No files selected in FileSystem dock.")
		return

	var image_files = []
	var image_exts = ["png", "jpg", "jpeg", "webp", "tga", "exr", "hdr"]

	for file_path in selected_files:
		if not FileAccess.file_exists(file_path): return
		var ext = file_path.to_lower().get_extension()
		if ext in image_exts:
			image_files.append(file_path)

	if image_files.is_empty():
		push_warning("No valid image files selected.")
		return

	for img_path in image_files:
		create_material_from_image(img_path)

	editor_interface.get_resource_filesystem().scan()
	print("Created %d material(s)." % image_files.size())

func create_material_from_image(image_path: String):
	var texture = load(image_path)
	if not texture or not (texture is Texture2D):
		push_error("Failed to load texture: %s" % image_path)
		return

	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.metallic_specular = 0.0
	mat.metallic = 0.0
	mat.roughness = 1.0

	var dir = image_path.get_base_dir()
	var stem = image_path.get_file().get_basename()
	var mat_path = dir.path_join(stem + ".material")

	var err = ResourceSaver.save(mat, mat_path)
	if err != OK:
		push_error("Failed to save material: %s" % mat_path)
	else:
		print("Created: %s" % mat_path)

func get_files_in_path_dir(path: StringName, files_ext: StringName) -> Array[String]:
	if path.right(1) != "/":
		path += "/"
	var dir = DirAccess.open(path)
	if !dir: return []

	var paths: Array[String] = []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		file_name = dir.get_next()
		if dir.current_is_dir(): continue

		var split = file_name.split(".")
		var ext: String = split[split.size() - 1]
		if ext != files_ext: continue

		paths.append(path + file_name)

	return paths

func get_array_last(array: Array):
	return array[array.size() - 1]

func xml_find_unlock_by_name(node: XMLNode, name: String) -> XMLNode:
	var unlocks: XMLNode = node.get_child_by_name("unlocks")
	if !unlocks: return null

	for unlock in unlocks.children:
		if unlock.content != name: continue

		return unlock
	return null

func setup_module_from_xml(other_modules: Array[XMLNode], node: XMLNode, module: ModuleBase, strings: Dictionary):
	var name_k: = node.get_child_by_name("userString").content
	module.name = node.name
	if strings.has(name_k): module.display_name = strings[name_k]

	module.level = node.get_child_by_name("level").content.to_int()
	module.health = node.get_child_by_name("maxHealth").content.to_int()
	module.weight = node.get_child_by_name("weight").content.to_int()

	module.cost_xp = 0

	for n in other_modules:
		var unlock: = xml_find_unlock_by_name(n, node.name)
		if unlock:
			module.cost_xp = unlock.get_child_by_name("cost").content.to_int()

func parse_tank_xml():
	var path: StringName = tank_xmls_path.text
	if path.right(1) != "/":
		path += "/"
	path += tank_xmls_nation.text
	var dir = DirAccess.open(path)
	if !dir: return


	var guns_xml: = XML.parse_file(path + "/components/guns.xml").root.get_child_by_name("shared")
	var shells_xml: = XML.parse_file(path + "/components/shells.xml").root
	var engines_xml: = XML.parse_file(path + "/components/engines.xml").root.get_child_by_name("shared")
	var list: = XML.parse_file(path + "/list.xml").root

	var files: = get_files_in_path_dir(path, "xml")

	var parsed_strings: YAMLResult
	var parsed_strings_file = FileAccess.open(tank_xmls_strings_path.text, FileAccess.ModeFlags.READ)


	var strings: Dictionary = {}


	if parsed_strings_file:
		parsed_strings = YAML.parse(parsed_strings_file.get_as_text())
		strings = parsed_strings.get_data()

	var infos: Array[TankInfoMain] = []
	var paths: Array[String] = []

	var path_key_to_nation: = {
		"germany" = TankInfoMain.Nation.GERMANY, 
		"uk" = TankInfoMain.Nation.GB, 
		"usa" = TankInfoMain.Nation.USA, 
		"ussr" = TankInfoMain.Nation.USSR, 
		"france" = TankInfoMain.Nation.FRANCE, 
		"china" = TankInfoMain.Nation.CHINA, 
		"japan" = TankInfoMain.Nation.JAPAN, 
	}


	var save_path: = "res://assets/tanks/parsed_infos/"
	for file in files:
		var parsed: XMLDocument = XML.parse_file(file)
		if !parsed: continue
		var file_path_split: = file.split("/")

		var file_name: String = get_array_last(file_path_split)

		print()
		print("parsing " + file_name + " ...")
		print("----------------------------------")

		var info: TankInfoMain = TankInfoMain.new()
		info.name = file_name.split(".")[0]

		if path_key_to_nation.has(tank_xmls_nation.text):
			info.nation = path_key_to_nation[tank_xmls_nation.text]

		var root: = parsed.root
		if !root.get_child_by_name("blitz"):
			print("error: this is not a tank config! skipping...")
			print("----------------------------------")
			continue

		var hull: = root.get_child_by_name("hull")


		var blitz: = root.get_child_by_name("blitz")
		var icon_path: = blitz.get_child_by_name("smallIconPath")
		var icon_big_path: = blitz.get_child_by_name("bigIconPath")

		var engine_snd_split: = blitz.get_child_by_name("engineSoundPC").content.split("/")
		var engine_snd: = engine_snd_split[engine_snd_split.size() - 2] + "_" + engine_snd_split[engine_snd_split.size() - 1]
		var snd_str_to_es: Dictionary = {
			de_ht = TankInfoMain.EngineSound.DE_HT, 
			de_lt = TankInfoMain.EngineSound.DE_LT, 
			de_mt = TankInfoMain.EngineSound.DE_MT, 
			de_tractor = TankInfoMain.EngineSound.DE_TRAKTOR, 

			ussr_ht = TankInfoMain.EngineSound.USSR_HT, 
			ussr_lt = TankInfoMain.EngineSound.USSR_LT, 
			ussr_mt = TankInfoMain.EngineSound.USSR_MT, 
			ussr_tractor = TankInfoMain.EngineSound.USSR_TRAKTOR, 

			usa_ht = TankInfoMain.EngineSound.USA_HT, 
			usa_lt = TankInfoMain.EngineSound.USA_LT, 
			usa_mt = TankInfoMain.EngineSound.USA_MT, 
			usa_tractor = TankInfoMain.EngineSound.USA_TRAKTOR, 

			uk_ht = TankInfoMain.EngineSound.UK_HT, 
			uk_lt = TankInfoMain.EngineSound.UK_LT, 
			uk_mt = TankInfoMain.EngineSound.UK_MT, 
			uk_tractor = TankInfoMain.EngineSound.UK_TRAKTOR, 
		}

		if snd_str_to_es.has(engine_snd): info.engine_sound = snd_str_to_es[engine_snd]
		if icon_big_path != icon_path: icon_big_path = icon_path

		var iconpath_split: = icon_path.content.split("/")
		var db_name: String = get_array_last(iconpath_split)






		var name_key: = file_name.split(".")[0]

		print("\tname key: '" + name_key + "'")
		print("\tname: " + info.name)
		print("\tfile name: " + db_name)


		for k in strings.keys():
			var key: String = k
			if not key.containsn(name_key): continue
			var split_to_name: = key.split(":")

			if get_array_last(split_to_name).to_lower() == name_key.to_lower():
				if !strings.has(key):
					info.display_name = name_key
				else:
					info.display_name = strings[key]

			var name_key_short: = name_key + "_short"

			if get_array_last(split_to_name).to_lower() == name_key_short.to_lower():
				if !strings.has(key):
					info.display_name_short = info.display_name
				else:
					info.display_name_short = strings[key]

			if info.display_name_short == "Base Tank": info.display_name_short = info.display_name

		var list_entry: = list.get_child_by_name(info.name)
		if list_entry:
			var tag_type_to_class: = {
				"lightTank" = TankInfoMain.Class.LT, 
				"mediumTank" = TankInfoMain.Class.MT, 
				"heavyTank" = TankInfoMain.Class.HT, 
				"AT-SPG" = TankInfoMain.Class.TD, 
			}
			info.cost = list_entry.get_child_by_name("price").content.to_int()
			if list_entry.get_child_by_name("price").get_child_by_name("gold"):
				info.prem = true
			info.lvl = list_entry.get_child_by_name("level").content.to_int()
			var type: = list_entry.get_child_by_name("tags").content.split(" ")[0]
			if tag_type_to_class.has(type):
				info.tank_class = tag_type_to_class[type]

		var res_path: = save_path + "/" + tank_xmls_nation.text + str(info.lvl) + "-" + info.name + ".tres"

		var icon_nation: = "britsh" if tank_xmls_nation.text == "uk" else tank_xmls_nation.text

		info.icon = "res://assets/tanks/icons/" + icon_nation + "-" + info.name + ".tres"
		info.tex_main = "res://assets/tanks/" + tank_xmls_nation.text + str(info.lvl) + "-" + info.name + ".png"
		info.tex_tracks = "res://assets/tanks/" + tank_xmls_nation.text + str(info.lvl) + "-" + info.name + "_track.png"
		info.model_path = "res://assets/tanks/" + tank_xmls_nation.text + str(info.lvl) + "-" + info.name + ".glb"

		paths.push_back(res_path)

		info.health = hull.get_child_by_name("maxHealth").content.to_int() * 1.25

		info.hull_weight = hull.get_child_by_name("weight").content.to_int()

		print("hull weight: " + str(info.hull_weight))

		info.guns.clear()
		info.engines.clear()
		info.tracks.clear()

		var turrets: = root.get_child_by_name("turrets0").children
		var engines: = root.get_child_by_name("engines").children
		var chassis: Array[XMLNode] = root.get_child_by_name("chassis").children

		var gun_unlockers: Array[XMLNode] = []
		for tur in turrets:
			gun_unlockers.append_array(tur.get_child_by_name("guns").children)

		var turret: XMLNode = turrets.back()
		print("turret weight: " + str(turret.get_child_by_name("weight").content.to_int()))
		info.hull_weight += turret.get_child_by_name("weight").content.to_int()

		gun_unlockers.append_array(turrets)

		var guns: = turret.get_child_by_name("guns").children
		var guns_orig: Array[XMLNode] = []
		for gun in guns:
			var orig: = guns_xml.get_child_by_name(gun.name)
			if orig: guns_orig.push_back(orig)


		for i in range(guns.size()):
			var gun = guns[i]
			if guns_orig.size() < i + 1: continue
			var gun_orig = guns_orig[i]

			for child in gun.children:
				var child_overlap: = gun_orig.get_child_by_name(child.name)

				if child_overlap and child_overlap.content != child.content:
					child_overlap.content = child.content

			var module: = ModuleGun.new()
			setup_module_from_xml(gun_unlockers, gun_orig, module, strings)

			var clip = gun_orig.get_child_by_name("clip")
			var burst = gun_orig.get_child_by_name("burst")

			var dispFactors: = gun_orig.get_child_by_name("shotDispersionFactors")

			module.max_ammo = gun_orig.get_child_by_name("maxAmmo").content.to_int()
			module.disp_factors.x = dispFactors.get_child_by_name("turretRotation").content.to_float()
			module.disp_factors.y = dispFactors.get_child_by_name("afterShot").content.to_float()
			module.disp_factors.z = dispFactors.get_child_by_name("whileGunDamaged").content.to_float()

			if clip and burst:
				module.fire_mode = ModuleGun.FireMode.BURST

				var intraclip: = 60 / clip.get_child_by_name("rate").content.to_float()
				var clip_count = clip.get_child_by_name("count").content.to_int()

				var intraburst: = 60 / burst.get_child_by_name("rate").content.to_float()
				var burst_count = burst.get_child_by_name("count").content.to_int()

				module.burst_info.intraclip = intraclip
				module.burst_info.intraburst = intraburst

				module.burst_info.bursts.clear()
				var rang: = float(clip_count) / float(burst_count)
				for j in range(ceil(rang)):
					module.burst_info.bursts.push_back(burst_count)



			module.rot_speed = gun_orig.get_child_by_name("rotationSpeed").content.to_float()

			module.reload = gun_orig.get_child_by_name("reloadTime").content.to_float()
			module.reload *= 1.15
			module.disp = gun_orig.get_child_by_name("shotDispersionRadius").content.to_float()
			module.aim_time = gun_orig.get_child_by_name("aimingTime").content.to_float()

			var deviation_up: = gun_orig.get_child_by_name("pitchLimits").content.split(" ")
			var deviation_r: = turret.get_child_by_name("yawLimits").content.split(" ")

			module.deviation_up.x = abs(deviation_up[0].to_int())
			module.deviation_up.y = abs(deviation_up[1].to_int())

			module.deviation_r.x = abs(deviation_r[0].to_int())
			module.deviation_r.y = abs(deviation_r[1].to_int())

			module.caliber = gun_orig.name.left(4).to_int()

			var effects_to_shoot_snd: = {
				"shot_auto" = ModuleGun.ShootSound.shot_auto, 
				"shot_Breda_auto" = ModuleGun.ShootSound.shot_auto, 
				"shot_small" = ModuleGun.ShootSound.shot_small, 
				"shot_KwK_L46" = ModuleGun.ShootSound.shot_small, 
				"shot_medium" = ModuleGun.ShootSound.shot_medium, 
				"shot_medium_mb" = ModuleGun.ShootSound.shot_medium, 
				"shot_main" = ModuleGun.ShootSound.shot_main, 
				"shot_main_mb" = ModuleGun.ShootSound.shot_main, 
				"shot_large" = ModuleGun.ShootSound.shot_large, 
				"shot_large_mb" = ModuleGun.ShootSound.shot_large, 
				"shot_huge" = ModuleGun.ShootSound.shot_huge, 
				"shot_huge_mb" = ModuleGun.ShootSound.shot_huge, 
			}
			var effect: = gun_orig.get_child_by_name("effects").content
			if effects_to_shoot_snd.has(effect): module.shot_sound = effects_to_shoot_snd[effect]
			module.shells.clear()

			var kind_to_type: = {
				ARMOR_PIERCING = ShellInfo.Type.AP, 
				ARMOR_PIERCING_CR = ShellInfo.Type.APCR, 
				HIGH_EXPLOSIVE = ShellInfo.Type.HE, 
				HOLLOW_CHARGE = ShellInfo.Type.HEAT, 
			}
			for shell_node in gun_orig.get_child_by_name("shots").children:
				var shell_config: = shells_xml.get_child_by_name(shell_node.name)
				var shell_res: = ShellInfo.new()

				var name_k: = shell_config.get_child_by_name("userString").content
				var dmg_node: = shell_config.get_child_by_name("damage")

				if strings.has(name_k): shell_res.name = strings[name_k]
				shell_res.dmg = dmg_node.get_child_by_name("armor").content.to_int()
				shell_res.pen = shell_node.get_child_by_name("piercingPower").content.split(" ")[0].to_int()
				shell_res.caliber = shell_config.get_child_by_name("caliber").content.to_int()
				shell_res.speed = shell_node.get_child_by_name("speed").content.to_int()
				shell_res.max_dist = shell_node.get_child_by_name("maxDistance").content.to_int()

				shell_res.cost = shell_config.get_child_by_name("price").content.to_int()
				if shell_config.get_child_by_name("price").get_children_by_name("gold"):
					shell_res.cost *= 400
					shell_res.premium = true

				if shell_config.name.right(4) == "HESH":
					shell_res.type = ShellInfo.Type.HESH
				else:
					var kind: = shell_config.get_child_by_name("kind").content
					shell_res.type = kind_to_type[kind]

				module.caliber = shell_res.caliber
				module.shells.push_back(shell_res)

			info.guns.push_back(module)

		var engines_final: Array[XMLNode] = [engines.front(), engines.back()]

		for engine in engines_final:
			var engine_module: = ModuleEngine.new()
			var engine_orig: = engines_xml.get_child_by_name(engine.name)

			setup_module_from_xml(engines, engine_orig, engine_module, strings)
			engine_module.power = engine_orig.get_child_by_name("power").content.to_int()
			engine_module.fireStartingChance = engine_orig.get_child_by_name("fireStartingChance").content.to_float()

			info.engines.push_back(engine_module)

		var chassis_final: Array[XMLNode] = [chassis.front(), chassis.back()]

		for track in chassis_final:
			var module: = ModuleTracks.new()
			setup_module_from_xml(chassis_final, track, module, strings)
			module.rot_speed = track.get_child_by_name("rotationSpeed").content.to_int()

			var track_str_to_ts: Array[TankInfoMain.TrackSound] = [
				TankInfoMain.TrackSound.LT, 
				TankInfoMain.TrackSound.MT, 
				TankInfoMain.TrackSound.HT, 
			]
			var id: int
			if track.get_child_by_name("sound") != null:
				id = track.get_child_by_name("sound").content.right(1).to_int() - 1
			elif track.get_child_by_name("soundPC") != null:
				id = track.get_child_by_name("soundPC").content.right(1).to_int() - 1
			info.track_sound = track_str_to_ts[clampi(id, 0, 2)]

			var disp_factors: = track.get_child_by_name("shotDispersionFactors")
			module.disp_move_mul = disp_factors.get_child_by_name("vehicleMovement").content.to_float()

			info.tracks.push_back(module)

		var unlock_holders: Array[XMLNode] = []
		unlock_holders.append_array(gun_unlockers)
		unlock_holders.append_array(turrets)
		unlock_holders.append_array(engines)
		unlock_holders.append_array(chassis)

		info.unlock_tanks.clear()
		for unlock in unlock_holders:
			var current_unlocks: = unlock.get_child_by_name("unlocks")
			if !current_unlocks: continue
			for c in current_unlocks.children:
				if c.name != "vehicle": continue

				var next_tank: = c.content
				var cost = c.get_child_by_name("cost").content.to_int()

				print("unlock tank: " + next_tank + "; cost: " + str(cost))
				info.unlock_tanks.merge({next_tank: cost})

		info.spot_radius = turret.get_child_by_name("circularVisionRadius").content.to_int()
		info.turret_health = turret.get_child_by_name("maxHealth").content.to_float()
		info.turret_rot_speed = turret.get_child_by_name("rotationSpeed").content.to_float()

		var speed_limits: = root.get_child_by_name("speedLimits")
		info.speed_limits.x = speed_limits.get_child_by_name("forward").content.to_int()
		info.speed_limits.y = speed_limits.get_child_by_name("backward").content.to_int()

		info.repair_cost = root.get_child_by_name("repairCost").content.to_int()

		infos.push_back(info)
		print("----------------------------------")

	for i in range(infos.size()):
		var info = infos[i]
		var res_path = paths[i]

		info.cost_xp = 0

		for tank in infos:
			if !tank.unlock_tanks.has(info.name): continue
			info.cost_xp = tank.unlock_tanks[info.name]

		if not DirAccess.dir_exists_absolute(save_path):
			DirAccess.make_dir_recursive_absolute(save_path)

		info._init()
		var err: = ResourceSaver.save(info, res_path)
		if err == OK: print("\tsaved file: " + info.name + ".tres")
		else: print("\terror saving the file!")

	get_editor_interface().get_resource_filesystem().scan()
