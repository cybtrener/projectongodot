extends Node
class_name Atlas_

var textures: Dictionary = {}

func _ready() -> void :
	var texture0 = load("res://assets/tanks/icons/bigTankIcons1.png") as CompressedTexture2D
	var texture1 = load("res://assets/tanks/icons/bigTankIcons2.png") as CompressedTexture2D
	var texture2 = load("res://assets/tanks/icons/bigTankIcons3.png") as CompressedTexture2D


	add("tank_icons:britsh-Centurion_7-1", texture0, Rect2(645, 1213, 320, 200))
	add("tank_icons:britsh-Centurion_I", texture0, Rect2(967, 1011, 320, 200))
	add("tank_icons:britsh-Comet", texture0, Rect2(1287, 1415, 315, 200))
	add("tank_icons:britsh-Covenanter", texture1, Rect2(632, 1, 314, 198))
	add("tank_icons:britsh-Cromwell", texture0, Rect2(1606, 1213, 316, 200))
	add("tank_icons:britsh-Cruiser_III", texture1, Rect2(1731, 1001, 258, 198))
	add("tank_icons:britsh-Cruiser_IV", texture1, Rect2(1192, 1001, 271, 198))
	add("tank_icons:britsh-Crusader", texture1, Rect2(614, 600, 302, 197))
	add("tank_icons:britsh-FV4202", texture0, Rect2(967, 1617, 317, 200))
	add("tank_icons:britsh-MatildaBP", texture0, Rect2(1611, 1011, 318, 200))
	add("tank_icons:britsh-Medium_I", texture1, Rect2(629, 203, 315, 189))
	add("tank_icons:germany-B-1bis_captured", texture1, Rect2(314, 1408, 292, 200))
	add("tank_icons:germany-DickerMax", texture1, Rect2(314, 398, 301, 200))
	add("tank_icons:germany-DW_II", texture1, Rect2(1260, 1, 310, 200))
	add("tank_icons:germany-E-100", texture0, Rect2(1, 607, 320, 200))
	add("tank_icons:germany-E-50", texture1, Rect2(1220, 398, 302, 198))
	add("tank_icons:germany-E-50M", texture1, Rect2(1, 605, 309, 198))
	add("tank_icons:germany-E-75", texture0, Rect2(1, 1819, 320, 200))
	add("tank_icons:germany-Ferdinand", texture0, Rect2(1287, 1213, 317, 200))
	add("tank_icons:germany-G20_Marder_II", texture1, Rect2(1192, 1403, 261, 200))
	add("tank_icons:germany-Hetzer", texture1, Rect2(907, 1405, 280, 200))
	add("tank_icons:germany-JagdPanther", texture0, Rect2(967, 405, 320, 200))
	add("tank_icons:germany-JagdPzE100", texture0, Rect2(1289, 405, 320, 200))
	add("tank_icons:germany-JagdPzIV", texture0, Rect2(323, 809, 320, 200))
	add("tank_icons:germany-JagdTiger", texture0, Rect2(323, 1011, 320, 200))
	add("tank_icons:germany-JagdTiger8_8", texture0, Rect2(1604, 1615, 318, 198))
	add("tank_icons:germany-JagdTiger8_8_Snowstorm", texture1, Rect2(1, 203, 311, 198))
	add("tank_icons:germany-Lowe", texture1, Rect2(918, 600, 293, 197))
	add("tank_icons:germany-Ltraktor", texture2, Rect2(247, 1, 242, 200))
	add("tank_icons:germany-Maus", texture0, Rect2(1604, 1815, 313, 200))
	add("tank_icons:germany-Panther_II", texture0, Rect2(323, 1819, 320, 200))
	add("tank_icons:germany-Panther_M10", texture1, Rect2(1, 1, 312, 200))
	add("tank_icons:germany-PanzerJager_I", texture2, Rect2(1, 1, 244, 200))
	add("tank_icons:germany-Pz35t", texture1, Rect2(1770, 799, 275, 200))
	add("tank_icons:germany-Pz38t", texture1, Rect2(1784, 600, 261, 197))
	add("tank_icons:germany-Pz38_NA", texture1, Rect2(1228, 203, 252, 192))
	add("tank_icons:germany-PzII", texture1, Rect2(1192, 1605, 260, 200))
	add("tank_icons:germany-PzIII_A", texture1, Rect2(614, 1001, 291, 200))
	add("tank_icons:germany-PzII_J", texture1, Rect2(1732, 1201, 265, 200))
	add("tank_icons:germany-PzIV", texture1, Rect2(1524, 398, 298, 200))
	add("tank_icons:germany-PzIV_Hydro", texture1, Rect2(919, 398, 299, 200))
	add("tank_icons:germany-PzV", texture0, Rect2(323, 1617, 320, 200))
	add("tank_icons:germany-PzVI", texture0, Rect2(323, 1415, 320, 200))
	add("tank_icons:germany-PzVIB_Tiger_II", texture0, Rect2(323, 1213, 320, 200))
	add("tank_icons:germany-PzVI_Tiger_P", texture1, Rect2(314, 203, 313, 193))
	add("tank_icons:germany-StugIII", texture1, Rect2(614, 1203, 289, 200))
	add("tank_icons:germany-T-15", texture1, Rect2(1706, 1605, 250, 198))
	add("tank_icons:germany-T-25", texture1, Rect2(314, 600, 298, 200))
	add("tank_icons:germany-VK3001H", texture1, Rect2(1, 805, 305, 200))
	add("tank_icons:germany-VK3001P", texture1, Rect2(1498, 600, 284, 194))
	add("tank_icons:germany-VK3002M", texture0, Rect2(323, 607, 320, 200))
	add("tank_icons:germany-VK3601H", texture1, Rect2(1, 1411, 304, 200))
	add("tank_icons:germany-VK4502A", texture1, Rect2(315, 1, 315, 198))
	add("tank_icons:germany-VK4502P", texture1, Rect2(314, 1812, 292, 200))
	add("tank_icons:usa-M103", texture0, Rect2(1611, 405, 320, 200))
	add("tank_icons:usa-M10_wolverine", texture1, Rect2(1, 1209, 305, 200))
	add("tank_icons:usa-M22_Locust", texture2, Rect2(738, 1, 240, 198))
	add("tank_icons:usa-M2_MT", texture1, Rect2(907, 1607, 275, 200))
	add("tank_icons:usa-M36_Slagger", texture1, Rect2(1, 1007, 305, 200))
	add("tank_icons:usa-M3lee", texture1, Rect2(907, 799, 287, 200))
	add("tank_icons:usa-M46_Patton", texture0, Rect2(645, 405, 320, 200))
	add("tank_icons:usa-M48A1_Patton", texture0, Rect2(323, 405, 320, 200))
	add("tank_icons:usa-M4A2E4", texture1, Rect2(314, 802, 297, 200))
	add("tank_icons:usa-M4A3E8_Fury", texture0, Rect2(1611, 203, 320, 200))
	add("tank_icons:usa-M4A3E8_Sherman", texture1, Rect2(314, 1004, 295, 200))
	add("tank_icons:usa-M4_Sherman", texture1, Rect2(1196, 799, 286, 200))
	add("tank_icons:usa-M6", texture0, Rect2(1289, 203, 320, 200))
	add("tank_icons:usa-Pershing", texture0, Rect2(967, 203, 320, 200))
	add("tank_icons:usa-Ram-II", texture1, Rect2(614, 1405, 289, 200))
	add("tank_icons:usa-T1", texture2, Rect2(980, 1, 224, 200))
	add("tank_icons:usa-T110E3", texture0, Rect2(645, 203, 320, 200))
	add("tank_icons:usa-T110E5", texture0, Rect2(323, 203, 320, 200))
	add("tank_icons:usa-T18", texture1, Rect2(1715, 1403, 251, 200))
	add("tank_icons:usa-T1Heavy", texture0, Rect2(1, 1617, 320, 200))
	add("tank_icons:usa-T1_E6", texture1, Rect2(1706, 1805, 244, 200))
	add("tank_icons:usa-T20", texture1, Rect2(1, 1815, 301, 200))
	add("tank_icons:usa-T25_AT", texture0, Rect2(1, 1415, 320, 200))
	add("tank_icons:usa-T26_E4_SuperPershing", texture0, Rect2(1, 1213, 320, 200))
	add("tank_icons:usa-T28", texture0, Rect2(1, 1011, 320, 200))
	add("tank_icons:usa-T29", texture0, Rect2(1, 809, 320, 200))
	add("tank_icons:usa-T2lt", texture2, Rect2(491, 1, 245, 195))
	add("tank_icons:usa-T2_MT", texture1, Rect2(1462, 1201, 268, 200))
	add("tank_icons:usa-T32", texture0, Rect2(1, 405, 320, 200))
	add("tank_icons:usa-T34_hvy", texture0, Rect2(1, 203, 320, 200))
	add("tank_icons:usa-T40", texture1, Rect2(614, 1809, 288, 200))
	add("tank_icons:usa-T82", texture1, Rect2(1455, 1807, 247, 200))
	add("tank_icons:usa-T95", texture0, Rect2(1611, 1, 320, 200))
	add("tank_icons:ussr-A-20", texture1, Rect2(614, 1607, 288, 200))
	add("tank_icons:ussr-A-32", texture1, Rect2(314, 1206, 293, 200))
	add("tank_icons:ussr-AT-1", texture1, Rect2(1192, 1807, 259, 200))
	add("tank_icons:ussr-BT-2", texture1, Rect2(1192, 1201, 268, 200))
	add("tank_icons:ussr-BT-7", texture1, Rect2(907, 1809, 270, 200))
	add("tank_icons:ussr-BT-SV", texture1, Rect2(1, 1613, 303, 200))
	add("tank_icons:ussr-IS-3", texture0, Rect2(1289, 1, 320, 200))
	add("tank_icons:ussr-IS-4M", texture1, Rect2(314, 1610, 292, 200))
	add("tank_icons:ussr-IS-7", texture0, Rect2(967, 1, 320, 200))
	add("tank_icons:ussr-IS-8", texture0, Rect2(645, 1, 320, 200))
	add("tank_icons:ussr-IS", texture0, Rect2(323, 1, 320, 200))
	add("tank_icons:ussr-ISU-152", texture0, Rect2(1, 1, 320, 200))
	add("tank_icons:ussr-KV-1s", texture0, Rect2(967, 1415, 318, 200))
	add("tank_icons:ussr-KV-220", texture0, Rect2(967, 607, 320, 200))
	add("tank_icons:ussr-KV-3", texture0, Rect2(1287, 1617, 315, 200))
	add("tank_icons:ussr-KV-4", texture0, Rect2(1611, 607, 320, 200))
	add("tank_icons:ussr-KV-5", texture0, Rect2(645, 1011, 320, 200))
	add("tank_icons:ussr-KV1", texture0, Rect2(1611, 809, 320, 200))
	add("tank_icons:ussr-LTP", texture1, Rect2(946, 203, 280, 175))
	add("tank_icons:ussr-M3_Stuart_LL", texture1, Rect2(1455, 1605, 249, 200))
	add("tank_icons:ussr-MS-1", texture1, Rect2(1482, 203, 218, 193))
	add("tank_icons:ussr-Object268", texture0, Rect2(1289, 809, 320, 200))
	add("tank_icons:ussr-Object_252", texture0, Rect2(1604, 1415, 318, 198))
	add("tank_icons:ussr-Object_704", texture0, Rect2(967, 809, 320, 200))
	add("tank_icons:ussr-ST-1", texture0, Rect2(645, 1617, 320, 200))
	add("tank_icons:ussr-SU-100", texture0, Rect2(645, 809, 320, 200))
	add("tank_icons:ussr-SU-100Y", texture0, Rect2(1289, 607, 320, 200))
	add("tank_icons:ussr-SU-152", texture0, Rect2(645, 607, 320, 200))
	add("tank_icons:ussr-SU-76", texture1, Rect2(907, 1203, 283, 200))
	add("tank_icons:ussr-SU-85", texture0, Rect2(645, 1415, 320, 200))
	add("tank_icons:ussr-SU-85b", texture1, Rect2(907, 1001, 283, 200))
	add("tank_icons:ussr-SU-85I", texture1, Rect2(617, 398, 300, 200))
	add("tank_icons:ussr-T-127", texture1, Rect2(1465, 1001, 264, 195))
	add("tank_icons:ussr-T-26", texture1, Rect2(1455, 1403, 258, 200))
	add("tank_icons:ussr-T-28", texture0, Rect2(1289, 1011, 320, 200))
	add("tank_icons:ussr-T-34-85", texture0, Rect2(967, 1213, 318, 200))
	add("tank_icons:ussr-T-34", texture1, Rect2(1, 403, 306, 200))
	add("tank_icons:ussr-T-43", texture0, Rect2(967, 1819, 317, 200))
	add("tank_icons:ussr-T-44", texture1, Rect2(1572, 1, 310, 200))
	add("tank_icons:ussr-T-46", texture1, Rect2(614, 799, 291, 200))
	add("tank_icons:ussr-T-54", texture0, Rect2(1287, 1819, 313, 200))
	add("tank_icons:ussr-T150", texture1, Rect2(948, 1, 310, 200))
	add("tank_icons:ussr-T62A", texture0, Rect2(645, 1819, 320, 200))
	add("tank_icons:ussr-Valentine_LL", texture1, Rect2(1484, 799, 284, 200))


	add("tank_icons:usa-XM551", texture2, Rect2(1204, 1, 242, 200))

func save_parsed_stuff():
	_parse_icons("G:\\Wotb_Revamp\\old_versions\\1.5mali\\DataSource\\Gfx2\\UI\\BattleScreenHUD")

func get_texture(id: StringName):
	id = id.to_lower()

	if not textures.has(id): return Texture2D.new()
	return textures[id]

func create_atlas_tex(tex: Texture2D, rect: Rect2) -> AtlasTexture:
	var atlas_tex: = AtlasTexture.new()
	atlas_tex.atlas = tex
	atlas_tex.region = rect

	return atlas_tex

func add(id: StringName, tex: Texture2D, rect: Rect2):
	id = id.to_lower()

	var atlas_tex: = create_atlas_tex(tex, rect)

	textures[id] = atlas_tex

static func atlas_create_save(name: String, base_tex: Texture2D, rect: Rect2):
	print(name, base_tex)




static func _parse_icons(path: String, name_prefix: StringName = ""):
	var dir = DirAccess.open(path)
	var templates = []

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = dir.get_next()
			if dir.current_is_dir(): continue

			var split = file_name.split(".")
			var ext: String = split[split.size() - 1]
			if ext != "txt": continue

			var file = FileAccess.open(path + file_name, FileAccess.ModeFlags.READ)
			if not file: continue

			var lines = file.get_as_text().split("\n")
			var texname = lines[1]
			var the_line = lines[4].split(" ")

			var x = the_line[0].to_int()
			var y = the_line[1].to_int()
			var r1 = the_line[2].to_int()
			var r2 = the_line[3].to_int()

			templates.push_back({
				name = file_name, tex = texname, rect = Rect2(x, y, r1, r2)
			})





		return templates
	else:
		return []
		print("An error occurred when trying to access the path.")
