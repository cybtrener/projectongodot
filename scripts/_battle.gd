extends Node

func err(error: String) -> void : printerr("Battle: " + error)

static var skill_to_coeff: Dictionary[AITankController.SkillLevel, float] = {
	AITankController.SkillLevel.IDLE: 0, 
	AITankController.SkillLevel.WHITE_ARMY: 0.5, 
	AITankController.SkillLevel.GREEN_ARMY: 1, 
	AITankController.SkillLevel.BLUE_ARMY: 1.5, 
	AITankController.SkillLevel.PURPLE_ARMY: 2, 
}

func predict_winning_team():
	var teamA_points: int = 0
	var teamB_points: int = 0

	for t in Battle.tanks_A:
		if !t.dead():
			teamA_points += t.tank_info.lvl
	for t in Battle.tanks_B:
		if !t.dead():
			teamB_points += t.tank_info.lvl

func is_ongoing() -> bool:
	return status == Status.STARTED

func get_tanks_alive(team: BaseTank.Team) -> int:
	if status != Status.STARTED: return 0

	var team_alive: int = 0
	for t in (Battle.tanks_A if team == BaseTank.Team.TEAM_A else Battle.tanks_B):
		if !t.dead(): team_alive += 1
	return team_alive

func get_winning_team():
	var teamA_alive: int = get_tanks_alive(BaseTank.Team.TEAM_A)
	var teamB_alive: int = get_tanks_alive(BaseTank.Team.TEAM_B)

	if teamA_alive == 0 and teamB_alive > 0:
		return BaseTank.Team.TEAM_B
	if teamB_alive == 0 and teamA_alive > 0:
		return BaseTank.Team.TEAM_A
	if teamA_alive == 0 and teamB_alive == 0:
		return null

	return null

func check_battle_ended():
	if self.status != Status.STARTED: return

	var winning_team = get_winning_team()

	var has_winning_team: bool = winning_team != null
	var base_captured: bool = base_points >= 100

	var time_is_up: bool = get_time_elapsed() <= 0

	if !(has_winning_team || base_captured || time_is_up):
		return

	self.status = Status.FINISHING

	print("battle end")
	print("\twinning team: ", winning_team)

	var endtimer: int = 5
	var players: Array[Player] = []
	for p in players_A:
		players.append(p)
	for p in players_B:
		players.append(p)

	for p in players:
		for pp in players:
			p.players_interacted[pp.name] = pp.create_meta_info()

	Util.timer(endtimer + 1.8, UIGlobal.please_wait_toggle.bind(true))
	Util.timer(endtimer + 2, Global.to_hangar.bind(true))
	Util.timer(endtimer, func():

		battle_finished.emit()
		for t in tanks_A:
			t.block(true)
		for t in tanks_B:
			t.block(true)

		compose_result(false, winning_team)
	)



func get_time() -> float:
	if Global.MAX_BATTLE_TIME_MIN == INF:
		return 0

	return maxf(0, Global.MAX_BATTLE_TIME_MIN * 60 - get_time_elapsed())

func compose_result(player_quit: bool, winning_team):
	if player_id == -1:
		return

	if get_time() < 10:
		return

	var result: BattleResultRes = BattleResultRes.new(start_time, get_time())

	var ply: Player = get_the_player()

	result.map_id = current_map.id

	result.status = BattleResultRes.Status.DRAW
	if winning_team != null:
		if winning_team == player_team:
			result.status = BattleResultRes.Status.WIN
			var fv: String = "first_victory"
			if !Global.get_current_player().has_reward(fv):
				Global.get_current_player().add_reward(fv)
				result.add_reward(fv)
		else:
			result.status = BattleResultRes.Status.DEFEAT

	print("\tstatus: ", result.status)

	result.player_tank_id = ply.tank.tank_info.name

	var warrior: bool = ply.kills.size() >= 4
	for p in self.players_A:
		result.teamA.append(p)
		p.earn_xp(result.status == BattleResultRes.Status.WIN)
		if player_team == BaseTank.Team.TEAM_A && p.kills.size() > ply.kills.size(): warrior = false


	for p in self.players_B:
		result.teamB.append(p)
		p.earn_xp(result.status == BattleResultRes.Status.WIN)
		if player_team != BaseTank.Team.TEAM_A && p.kills.size() > ply.kills.size(): warrior = false

	if warrior:
		result.add_reward("warrior")

	result.player_team_a = player_team == BaseTank.Team.TEAM_A
	result.player_id = player_id

	ply.earn_credits(result.status == BattleResultRes.Status.WIN, false)

	result.credits = ply.credits_earned - (ply.credits_lost_ammo + ply.credits_lost_consumables + ply.credits_lost_repair)
	result.credits_raw = ply.credits_earned
	result.gold += floori(ply.credits_earned * 0.001) if result.credits > 0 else 0
	result.xp = ply.xp_earned
	result.freexp = result.xp * 0.05
	result.resolved = player_quit

	result.date = Battle.start_time

	var acc: Account = Global.save_main.get_current_account()

	result.prem = acc.has_prem_account()

	for r in PlayerData.validate_rewards(acc, ply):
		var rew: PlayerData.Reward = PlayerData.get_reward(r)

		if !r: continue

		result.add_reward(r)



	acc.receive_battle_result(result)

	if !OS.has_feature("debug"):
		return

signal tank_got_spotted(t: BaseTank)
signal tank_got_unspotted(t: BaseTank)
signal battle_init
signal battle_start_countdown
signal battle_start
signal battle_finished
signal killfeed_sent(entry: Dictionary)

enum Status{
	NONE, INIT, COUNTDOWN, STARTED, FINISHING
}

var first_phys_tick: bool = true
var status: Status = Status.NONE
var start_time: float = -100000
var player_id: int = 0
var player_team: BaseTank.Team = BaseTank.Team.TEAM_A
var enemy_team: BaseTank.Team = BaseTank.Team.TEAM_B

func report_tanks_in_base_circle(teamA: int, teamB: int):
	pass

func is_player_team(team: BaseTank.Team) -> bool:
	return team == player_team

var base_points: int = 0
var base_capturing_team: BaseTank.Team = BaseTank.Team.TEAM_A
var players: Dictionary = {}
var players_A: Array[Player] = []
var players_B: Array[Player] = []

var tanks_A: Array[BaseTank] = []
var tanks_B: Array[BaseTank] = []

var ai_markers: Array[AIMarker] = []

var current_map: Map
var current_map_scene: Node

var killfeed_entries: Array[Dictionary] = []

enum QuickCommand{
	ATTACK, 
	ATTACK_TANK, 
	CAPTURE_BASE, 
	DEFEND_BASE, 
	HELP_ME, 
	POSITIVE, 
	NEGATIVE, 
	RELOADING
}
enum KillfeedMsgType{
	KILL, MESSAGE, QUICK_COMMAND
}
func quickcmd_send(sender: Player, cmd: QuickCommand):
	if !is_instance_valid(sender) or !is_instance_valid(sender.tank): return

	var entry: Dictionary = {type = KillfeedMsgType.QUICK_COMMAND, cmd = cmd, time = get_time_elapsed()}
	killfeed_entries.append(entry)
	killfeed_sent.emit(entry)

func message_send(sender: Player, msg: String, global: bool):
	if !is_instance_valid(sender) or !is_instance_valid(sender.tank): return

	var entry: Dictionary = {type = KillfeedMsgType.MESSAGE, sender = sender, message = msg, global = global, time = get_time_elapsed()}
	killfeed_entries.append(entry)
	killfeed_sent.emit(entry)

func killfeed_send(killer: Player, victim: Player):
	if !is_instance_valid(killer) or !is_instance_valid(killer.tank) or !is_instance_valid(victim) or !is_instance_valid(victim.tank): return
	if !killer.tank_info or !victim.tank_info: return



	var entry: Dictionary = {type = KillfeedMsgType.KILL, sender = killer, victim = victim, time = get_time_elapsed()}
	killfeed_entries.append(entry)
	killfeed_sent.emit(entry)


func get_time_elapsed() -> float:
	if Global.MAX_BATTLE_TIME_MIN == INF:
		return 0

	return maxf(start_time + Global.MAX_BATTLE_TIME_MIN * 60 - Util.curtime_sys(), 0)

func get_the_player() -> Player:
	var team: Array[Player] = {
		BaseTank.Team.TEAM_A: players_A, 
		BaseTank.Team.TEAM_B: players_B, 
	}[player_team]
	if team.size() >= player_id + 1:
		return team[player_id]

	return null

func random_team_template(player_lvl: int, super_loyal: bool = false) -> Array[int]:
	var team_size: int = Global.MAX_TEAM_TANKS

	team_size = clampi(team_size, 1, Global.MAX_TEAM_TANKS)
	var team_size_half: int = int(team_size * 0.5) + 1

	var team: Array[int] = []

	var offset_rand: int = randi_range(-1, 1)
	var offset: int = -1 if super_loyal else 0

	var top_lvls: int = randi_range(1 if offset_rand < 0 else 0, team_size_half)
	var mid_lvls: int = randi_range(1, team_size_half)
	var low_lvls: int = team_size - top_lvls - mid_lvls

	var loyal_treshold: int = 4
	var loyal: bool = player_lvl <= loyal_treshold or (player_lvl + offset_rand) <= loyal_treshold or (player_lvl - 1 + offset_rand) <= loyal_treshold and low_lvls > 0

	print("superloyal = ", super_loyal)
	print("loyal = ", loyal)
	print("offset_rand = ", offset_rand)

	if super_loyal:
		var moretops: bool = Util.random_chance(50)

		for i in range(top_lvls):
			team.append(0)
		for i in range(mid_lvls):
			team.append(0 if moretops else -1)
		for i in range(low_lvls):
			team.append(-1)
	elif loyal:
		var top: bool = Util.random_chance(50)

		for i in range(top_lvls):
			team.append(0 if top else 1)
		for i in range(mini(mid_lvls, team_size_half - 1)):
			team.append(0 if top else 1)
		for i in range(low_lvls + 2):
			team.append(-1 if top else 0)
	else:
		for i in range(top_lvls):
			team.append(1 + offset + offset_rand)
		for i in range(mid_lvls):
			team.append(offset + offset_rand)
		for i in range(low_lvls):
			team.append(-1 + offset + offset_rand)

	team.resize(team_size)




	return team

static func sort_players_by_class(a: Player, b: Player):
	return BaseTank.sort_by_class(a.tank, b.tank)

static func sort_players_by_lvl(a: Player, b: Player):
	return BaseTank.sort_by_lvl(a.tank.tank_info, b.tank.tank_info)

static var names_main: Array[String] = [
	"TQW", 
	"Mathaeusx", 
	"PateulBun", 
	"Frogster2015", 
	"corniguy", 
	"NQ9", 
	"PurpleHaze_", 
	"WaveWaveYt", 
	"KINGYu_", 
	"NikolaiIvanovichYezhov", 
	"Beria", 
	"RedCekist1938", 
	"Bronislava", 
	"BiancaJavra", 
	"Soyuz14", 
	"Adorable_Filter", 
	"__bullshut_with_fur", 
	"N1CE_TRY_TO_KILL_ME", 
	"laurentiumurraiu15", 
	"AkaskavXII", 
	"FlyDragon89", 
	"Yagoda_1", 
	"s_cristian_17 ", 
	"Yaonbuci", 
	"Yaongingi", 
	"Cekuray", 
	"WindowsXP", 
	"Black_widow", 
	"Big_Yahu", 
	"VulturulMetalizat", 

	"Frogster_sniper", 
	"Hunter2015", 
	"Steel_Wolf47", 
	"DarkTank_88", 
	"IronHunter2012", 
	"Shadow_Blitz", 
	"TankKiller99", 
	"RedFox_2017", 
	"GhostSniper_EU", 
	"ArmorPiercer07", 
	"NightWolf2014", 
	"BlitzHunter_33", 
	"SteelFang2009", 
	"ColdSteel_sniper", 
	"IronWolf_66", 
	"TankMaster2016", 
	"DarkFrog_99", 
	"SniperHawk2013", 
	"BloodSteel_77", 
	"ShadowTank_EU", 
	"StormHunter42", 
	"IceWolf2011", 
	"TankDestroyer_5", 
	"GhostFang2018", 
	"SteelHawk_sniper", 
	"RedWolf_2010​​​​​​​​​​​​​​​​ ", 
	"FlyDragon89", 
	"headshooooot1251253", 
	"RNG_HATES_ME", 
	"WindowsXD", 

	"MacJIuHa_TV", 
]
static var names_main_used: Array[String] = []

static func random_name():
	var name: String = "bot"
	var vacant_names: Array[String] = []
	for n in names_main:
		if names_main_used.has(n): continue
		vacant_names.append(n)

	if vacant_names.is_empty(): return name
	name = vacant_names.pick_random()
	names_main_used.append(name)

	return name

static var ui_intro: PackedScene = load("uid://dna10c5pra2dv")
func start_battle(map: Map, scene: Node):
	current_map = map
	current_map_scene = scene

	status = Status.INIT

	print()
	print("Starting battle on the map: " + map.name_display)
	print("-------------------------------------------------------")

	var player_acc: = Global.save_main.get_current_account()
	player_acc.cleanup()

	var player_curtank: = player_acc.get_current_tank()
	var player_curtank_info: = TanksDataBase.get_tank_by_name(player_curtank.name)
	var player_lvl: = player_curtank_info.lvl

	var spawnersA: Array[TankSpawner] = []
	var spawnersB: Array[TankSpawner] = []

	var map_border_min: Vector2
	var map_border_max: Vector2
	for c in scene.find_children("*", "TankSpawner", true):
		(spawnersA if c.team == BaseTank.Team.TEAM_A else spawnersB).push_back(c)
	for c in scene.find_children("map_border_*", "", true):
		if c.name == "map_border_min":
			print("markeeeer!!!!")
			map_border_min = Vector2(c.global_position.x, c.global_position.z)
		if c.name == "map_border_max":
			map_border_max = Vector2(c.global_position.x, c.global_position.z)

	if map_border_min and map_border_max:
		current_map.size_x = map_border_max.x - map_border_min.x
		current_map.size_y = map_border_max.y - map_border_min.y

	var dice: bool = Util.random_chance(50)

	player_team = BaseTank.Team.TEAM_A if dice else BaseTank.Team.TEAM_B
	enemy_team = BaseTank.Team.TEAM_A if !dice else BaseTank.Team.TEAM_B

	var player_team_arr: = spawnersA if dice else spawnersB
	var enemy_team_arr: = spawnersA if !dice else spawnersB

	if player_team_arr.is_empty():
		if enemy_team_arr.is_empty():
			err("no TankSpawners found on the map! Be sure to place more than " + str(Global.MAX_TEAM_TANKS) + " for eaach team!")
			return

		err("randomly chosen ally team is empty, occupying supposed enemy team, be sure to have both team spawners on your map!")
		player_team_arr = enemy_team_arr

	var max_team_size: int = clampi(max(player_team_arr.size(), enemy_team_arr.size()), 0, Global.MAX_TEAM_TANKS)
	if max_team_size < Global.MAX_TEAM_TANKS:
		err("team size smaller than default! " + str(max_team_size) + "instead of " + str(Global.MAX_TEAM_TANKS) + "! Expect unexpected behavior!")

	var super_loyal: bool = player_curtank_info and player_curtank_info.matchmaker_super_loyal
	var t_player_team: Array[int] = random_team_template(player_lvl, player_curtank_info.matchmaker_super_loyal)
	var t_enemy_team: Array[int] = t_player_team

	if !t_player_team.has(0):
		err("couldn't find vacant place for player in the team! Defaulting to 0!")
		player_id = t_player_team.size() - 1
	else:
		var player_places = []
		for i in range(t_player_team.size()):
			if t_player_team[i] != 0: continue

			player_places.append(i)
		player_id = player_places.pick_random()

	var ply_tank: BaseTank = spawn_tank_at_spawner(player_team_arr[player_id], player_curtank.name, BaseTank.AIClass.PLAYER, player_curtank.gun_id, player_curtank.engine_id, player_curtank.track_id)
	ply_tank.setup_completed.connect( func():
		for item in player_curtank.equipment:
			ply_tank.apply_equipment(TanksDataBase.get_equipment(item))
		for item in player_curtank.consumables:
			ply_tank.add_consumable(TanksDataBase.get_consumable(item))
		ply_tank.shells_amounts = []
		for s in player_curtank.shells_amounts:
			ply_tank.shells_amounts.append(s)
	)

	if Global.attach_ai_to_player: ply_tank.add_child(AITankController.new().init(ply_tank))
	if map_border_min and map_border_max:
		ply_tank.map_border_min = map_border_min
		ply_tank.map_border_max = map_border_max

	for i in range(t_player_team.size()):
		if i == player_id:
			player_register(Global.save_main.get_current_account().name, ply_tank, player_team)
			continue
		var spawner = player_team_arr[i]
		var lvl_dev: int = t_player_team[i]
		var tank: BaseTank = spawn_bot_at_spawner(spawner, player_lvl, player_team, player_lvl + lvl_dev)
		tank.map_border_min = map_border_min
		tank.map_border_max = map_border_max

		player_register(random_name(), tank, player_team)

	for i in range(t_enemy_team.size()):
		var spawner = enemy_team_arr[i]
		var lvl_dev: int = t_enemy_team[i]
		var tank: BaseTank = spawn_bot_at_spawner(spawner, player_lvl, enemy_team, player_lvl + lvl_dev)
		tank.is_enemy = true
		tank.map_border_min = map_border_min
		tank.map_border_max = map_border_max

		player_register(random_name(), tank, enemy_team)















	print("player lvl: " + str(player_lvl))
	print("player team: " + str(t_player_team))
	print("enemy team: " + str(t_enemy_team))
	print("player index: " + str(player_id))
	print("-------------------------------------------------------")

	for p in players_A:
		p.tank.battle_start_countdown()
	for p in players_B:
		p.tank.battle_start_countdown()

	battle_init.emit()
	print("battle init")

	var ui_intro: Control = ui_intro.instantiate()
	var player_in_A: bool = player_team == BaseTank.Team.TEAM_A
	ui_intro.init(map, players_A if player_in_A else players_B, players_A if !player_in_A else players_B, player_id)
	UIGlobal.add_child(ui_intro)

	await Util.delay(0)

	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	Util.timer(0.5, AudioServer.set_bus_volume_linear.bind(sfx_bus, 0.0001))





	var map_music: AudioStream
	var map_music_player: AudioStreamPlayer
	if map.intro_music:
		map_music_player = Audio.play_sound2d(map.intro_music, "Music")
		map_music = map.intro_music
	else:
		map_music_player = Audio.play_sound2d(Map.music_urge_to_win, "Music")
		map_music = Map.music_urge_to_win

	if !battle_start.is_connected(actually_start_battle):
		battle_start.connect(actually_start_battle)

	var music_len: float = map_music.get_length() * randf_range(0.4, 0.75) * Global.save_settings.map_loading_screen_timer_mul if !Global.battle_skip_intro else 0.6

	Util.timer_curtime(music_len, func():
		if status != Status.INIT:
			return

		ui_intro.queue_free()
		AudioServer.set_bus_volume_linear(sfx_bus, Audio.VOL_SFX)
		if map_music_player: Audio.fade_out_player(map_music_player, 1)

		status = Status.COUNTDOWN

		print("battle count")
		battle_start_countdown.emit()
		Util.timer(5 if !Global.battle_skip_countdown else 0.6, battle_start.emit)
	)

func actually_start_battle() -> void :
	if status != Status.COUNTDOWN: return

	status = Status.STARTED

	start_time = Util.curtime_sys()

	Audio.play_crew_message(Audio.CrewMessage.BATTLE_START)

	print("battle start")
	for p in players_A:
		if !is_instance_valid(p.tank):
			continue
		p.tank.start_battle()
	for p in players_B:
		if !is_instance_valid(p.tank):
			continue
		p.tank.start_battle()


func tank_select_modules(skill: AITankController.SkillLevel, tank_name: String) -> Array[int]:
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(tank_name)
	var gun_id: = 0
	var engine_id: = randi_range(0, info.engines.size() - 1)
	var track_id: = randi_range(0, info.tracks.size() - 1)

	if Util.random_chance(15):
		return [Util.rand_arr_id(info.guns), Util.rand_arr_id(info.engines), Util.rand_arr_id(info.tracks)]

	var guns_points: Array[int] = []
	var gun_pointer: int = 0
	var guns: Array[ModuleGun] = info.guns.duplicate_deep()
	guns.shuffle()
	for g in guns:
		var points: int = 0

		var alpha_supremacy: bool = false
		var dpm_supremacy: bool = false
		var accuracy_supremacy: bool = false
		var penetration_supremacy: bool = false

		var best_dmg: int = g.get_dmg()
		var best_dpm: int = g.get_dpm()
		var best_pen: int = g.get_pen()
		var best_accuracy: int = g.disp
		for _g in info.guns:
			if g == _g: continue
			if _g.get_dmg() > best_dmg:
				best_dmg = _g.get_dmg()
			if _g.get_dpm() > best_dpm:
				best_dpm = _g.get_dpm()
			if _g.get_pen() > best_pen:
				best_pen = _g.get_pen()
			if _g.disp > best_accuracy:
				best_accuracy = _g.disp

		var supremacy_dmg: bool = best_dmg == g.get_dmg()
		var supremacy_dpm: bool = best_dpm == g.get_dpm()

		if supremacy_dmg and !supremacy_dpm: points += 15 if skill <= AITankController.SkillLevel.GREEN_ARMY else 5
		if supremacy_dpm and !supremacy_dmg: points += 10 if skill <= AITankController.SkillLevel.GREEN_ARMY else 15
		if best_pen == g.get_pen(): points += 5 if skill <= AITankController.SkillLevel.GREEN_ARMY else 10
		if best_accuracy == g.disp: points += 2 if skill <= AITankController.SkillLevel.GREEN_ARMY else 15


		if points < 10 and Util.random_chance(25) and gun_pointer < info.guns.size() - 1:
			points += 50

		gun_pointer += 1
		guns_points.append(points)

	var best_points: int = 0
	for i in range(guns_points.size()):
		var p: int = guns_points[i]
		if p < best_points: continue

		gun_id = i
		best_points = p

	return [gun_id, engine_id, track_id]


func spawn_bot_at_spawner(spawner: TankSpawner, player_lvl: int, team: BaseTank.Team, bot_lvl: int = 1) -> BaseTank:
	var name: StringName = TanksDataBase.get_by_lvl_random(bot_lvl, true)
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(name)

	if info.matchmaker_super_loyal and bot_lvl < player_lvl:
		info = TanksDataBase.get_tank_by_name(TanksDataBase.get_by_lvl_random(bot_lvl, true))

	var controller: AITankController = AITankController.new()
	var skill: AITankController.SkillLevel = controller.choose_skill(info.lvl, team)

	var modules: Array[int] = tank_select_modules(skill, name)

	var tank: = spawn_tank_at_spawner(spawner, name, BaseTank.AIClass.AI, modules[0], modules[1], modules[2])

	tank.setup_completed.connect( func():
		if !Util.random_chance(0.01):
			tank.add_child(controller.init(tank))

		var gun: ModuleGun = info.guns[modules[0]]
		var shells: Array[ShellInfo] = gun.shells

		if shells.size() == 1:
			tank.shells_amounts[0] = gun.max_ammo
		elif shells.size() == 2:
			tank.shells_amounts[0] = int(float(gun.max_ammo) * 0.75)
			tank.shells_amounts[1] = int(float(gun.max_ammo) * 0.25)
		elif shells.size() == 3:
			tank.shells_amounts[0] = int(float(gun.max_ammo) * 0.4)
			tank.shells_amounts[1] = int(float(gun.max_ammo) * 0.2)
			tank.shells_amounts[2] = int(float(gun.max_ammo) * 0.4)
	)

	tank.turret_block = true
	return tank

func spawn_tank_at_spawner(spawner: TankSpawner, name: String, ai_class: BaseTank.AIClass, gun_id: int, engine_id: int, track_id: int) -> BaseTank:
	var pos: = spawner.global_position
	var rot: = spawner.global_rotation
	var tank = BaseTank.construct_setup_spawn(name, ai_class, current_map_scene, gun_id, engine_id, track_id)
	tank.setup_completed.connect( func():
		tank.global_position = pos
		tank.global_rotation = rot
	)

	return tank

func get_player_by_tank(tank: BaseTank) -> Player:
	if tank.player == null: printerr("player is null! tank: ", tank.name)
	return tank.player

func player_register(nam: StringName, tank: BaseTank, team: BaseTank.Team):
	var team_to_arr: Dictionary[BaseTank.Team, Array] = {
		BaseTank.Team.TEAM_A: players_A, 
		BaseTank.Team.TEAM_B: players_B, 
	}
	var ply: Player = Player._new(nam, tank, team)
	ply.max_health = tank.health_component.max_health
	ply.health = tank.health_component.max_health

	tank.health_component.on_damage_taken.connect( func(d: int):
		ply.dmg_taken += d
		ply.credits_lost_repair += d * tank.tank_info.repair_cost


		ply.health = tank.health()
	)
	tank.health_component.on_damage_block.connect( func(d: int):
		ply.dmg_blocked += d
	)
	tank.health_component.on_death.connect( func():
		ply.destroyed_time = get_time()

		check_battle_ended()
	)
	tank.on_enemy_damage.connect( func(tank: BaseTank, d: int):
		ply.dmg += d
		ply.hits_dmg += 1

		var tply: Player = get_player_by_tank(tank)
		if !tply: return

		Util.dict_add_to_int(ply.log_damage_dealt, tply.name, d)
		Util.dict_add_to_int(ply.log_hits_dmg, tply.name, 1)

		Util.dict_add_to_int(tply.log_damage_received, ply.name, d)

		if tank.last_hit_dinfo.dmg_type == DamageInfo.DamageType.SHELL:
			ply.ach_piercer_streak_current += 1
			if ply.ach_piercer_streak_current >= 10:
				ply.ach_piercer_streaks += 1
				ply.ach_piercer_streak_current = 0
	)
	tank.on_enemy_bounce.connect( func(tank: BaseTank, d: int):
		ply.hits_bounce += 1

		var tply: Player = get_player_by_tank(tank)
		if !tply: return
		Util.dict_add_to_int(ply.log_hits_bounce, tply.name, 1)
	)
	tank.on_enemy_destroy.connect( func(vict: BaseTank, dinfo: DamageInfo):
		var tply: Player = get_player_by_tank(tank)
		if !tply: return

		if tank.team == vict.team:
			return

		ply.kills.append(vict.tank_info.name)
		killfeed_send(tply, get_player_by_tank(vict))

		if !ply.log_hits_dmg.has(tply.name):
			ply.ach_hand_of_death += 1
		if get_tanks_alive(tank.team) == 1:
			ply.ach_kolobanov_kills += 1

		var no_shells: bool = true
		for s in tank.shells_amounts:
			if s > 0: no_shells = false

		if no_shells: ply.give_reward("fadin")

		if ply.health_coeff() > 0 && ply.health_coeff() <= 0.2 && ply.module_crits >= 5:
			ply.ach_tarczay_kills += 1
	)
	tank.on_enemy_spot.connect( func(t: BaseTank):
		var tp: Player = get_player_by_tank(t)
		if !tp or ply.spotted.has(tp): return

		if !t.was_spotted && ply.spotted.has(tp.name): ply.spotted.append(tp.name)
	)
	tank.on_spotted.connect( func(on: bool):
		if on:
			tank_got_spotted.emit(tank)
		else:
			tank_got_unspotted.emit(tank)
	)
	tank.on_module_crit.connect( func():
		ply.module_crits += 1
	)
	tank.on_consumable_used.connect( func(cons: Consumable):
		ply.credits_lost_consumables += cons.cost_factor * TanksDataBase.get_consumable_cost_by_lvl(tank.tank_info.lvl)
	)


	tank.setup_completed.connect( func():
		tank.gun_component.shoot.connect( func(first: bool):
			ply.shells_shot[tank.shell_id] += 1
			ply.credits_lost_ammo += tank.current_shell().cost
		)

		ply.tank = tank
	)

	tank.team = team

	if team == BaseTank.Team.TEAM_A:
		players_A.push_back(ply)
		tanks_A.append(tank)
	else:
		players_B.push_back(ply)
		tanks_B.append(tank)

func get_enemy_tanks(team: BaseTank.Team) -> Array[BaseTank]:
	if team == BaseTank.Team.TEAM_A:
		return tanks_B
	else:
		return tanks_A
func get_ally_tanks(team: BaseTank.Team) -> Array[BaseTank]:
	if team == BaseTank.Team.TEAM_B:
		return tanks_B
	else:
		return tanks_A

func get_player_team() -> Array[Player]:
	return {
		BaseTank.Team.TEAM_A: players_A, 
		BaseTank.Team.TEAM_B: players_B
	}[player_team]
func get_enemy_team() -> Array[Player]:
	return {
		BaseTank.Team.TEAM_A: players_A, 
		BaseTank.Team.TEAM_B: players_B
	}[enemy_team]

func _physics_process(delta: float) -> void :
	check_battle_ended()

func reset():
	player_id = -1

	players.clear()
	players_A.clear()
	players_B.clear()

	tanks_A.clear()
	tanks_B.clear()
	killfeed_entries.clear()

	start_time = -10000

	ai_markers.clear()
	status = Status.NONE
	names_main_used.clear()
