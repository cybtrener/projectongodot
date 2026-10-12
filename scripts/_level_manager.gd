extends Node

var current_scene: Node
signal level_changed

func _ready() -> void :
	pass

func change_map(map: Map):
	Battle.reset()
	switch_scene(map.scene_path)
	Battle.start_battle(map, current_scene)

func switch_scene(path: String):
	print("Battle.status: ", Battle.status)
	if Battle.status == Battle.Status.STARTED:
		var wteam = Battle.get_winning_team()
		if wteam == Battle.player_team:
			wteam = null

		print("player exiting ongoing battle, composing battle result...")

		Battle.compose_result(true, wteam)

	Battle.reset()

	if not ResourceLoader.exists(path):
		printerr("Battle: trying to switch to non-existent scene: '" + path + "'")
		return

	if is_instance_valid(current_scene):
		current_scene.queue_free()


	var scene_pack: PackedScene = load(path) as PackedScene

	var scene: = scene_pack.instantiate()

	self.add_child(scene)

	level_changed.emit()

	current_scene = scene
	print("current_scene:" + str(current_scene))

	Audio.muffle_sfx(false)
	UIGlobal.loading_screen_toggle(false)
	UIGlobal.please_wait_toggle(false)
