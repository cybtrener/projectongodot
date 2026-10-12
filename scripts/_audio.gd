extends Node

static var VOL_SFX: float = 0.45
static var VOL_UI: float = 0.35
static var VOL_MUSIC: float = 0.4
static var VOL_RADIO: float = 0.4
static var VOL_SNIPER: float = 0.4

static var gun_auto: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_auto.tres")
static var gun_small: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_small.tres")
static var gun_medium: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_medium.tres")
static var gun_main: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_main.tres")
static var gun_large: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_large.tres")
static var gun_huge: ExplosionSound = load("res://assets/sfx/tanks/guns/shot_huge.tres")

static var tank_explosion: ExplosionSound = load("res://assets/sfx/tanks/explosion/exp_destruction.tres")

static var shell_ap: ShellSounds = load("res://assets/sfx/tanks/shells/ap.tres")
static var shell_apcr: ShellSounds = load("res://assets/sfx/tanks/shells/apcr.tres")
static var shell_he: ShellSounds = load("res://assets/sfx/tanks/shells/he.tres")
static var shell_heat: ShellSounds = load("res://assets/sfx/tanks/shells/heat.tres")

static var inside_pen: StreamRandom = load("res://assets/sfx/tanks/shells/inside/_pierce.tres")
static var inside_bounce: StreamRandom = load("res://assets/sfx/tanks/shells/inside/_bounce.tres")

static var shell_type_to_sound: Dictionary = {
	ShellInfo.Type.AP: shell_ap, 
	ShellInfo.Type.APCR: shell_apcr, 
	ShellInfo.Type.HE: shell_he, 
	ShellInfo.Type.HEAT: shell_heat, 
	ShellInfo.Type.HESH: shell_he, 
}

static var engine_de_ht: EngineSounds = load("res://assets/sfx/tanks/engine/de_ht.tres")
static var engine_de_lt: EngineSounds = load("res://assets/sfx/tanks/engine/de_lt.tres")
static var engine_de_mt: EngineSounds = load("res://assets/sfx/tanks/engine/de_mt.tres")
static var engine_de_traktor: EngineSounds = load("res://assets/sfx/tanks/engine/de_traktor.tres")

static var engine_uk_ht: EngineSounds = load("res://assets/sfx/tanks/engine/uk_ht.tres")
static var engine_uk_lt: EngineSounds = load("res://assets/sfx/tanks/engine/uk_lt.tres")
static var engine_uk_mt: EngineSounds = load("res://assets/sfx/tanks/engine/uk_mt.tres")
static var engine_uk_traktor: EngineSounds = load("res://assets/sfx/tanks/engine/uk_traktor.tres")

static var engine_usa_ht: EngineSounds = load("res://assets/sfx/tanks/engine/usa_ht.tres")
static var engine_usa_lt: EngineSounds = load("res://assets/sfx/tanks/engine/usa_lt.tres")
static var engine_usa_mt: EngineSounds = load("res://assets/sfx/tanks/engine/usa_mt.tres")
static var engine_usa_traktor: EngineSounds = load("res://assets/sfx/tanks/engine/usa_traktor.tres")

static var engine_ussr_ht: EngineSounds = load("res://assets/sfx/tanks/engine/ussr_ht.tres")
static var engine_ussr_lt: EngineSounds = load("res://assets/sfx/tanks/engine/ussr_lt.tres")
static var engine_ussr_mt: EngineSounds = load("res://assets/sfx/tanks/engine/ussr_mt.tres")
static var engine_ussr_traktor: EngineSounds = load("res://assets/sfx/tanks/engine/ussr_traktor.tres")

static var tracks_ht: TrackSounds = load("res://assets/sfx/tanks/tracks/ht.tres")
static var tracks_lt: TrackSounds = load("res://assets/sfx/tanks/tracks/lt.tres")
static var tracks_mt: TrackSounds = load("res://assets/sfx/tanks/tracks/mt.tres")
static var tracks_traktor: TrackSounds = load("res://assets/sfx/tanks/tracks/traktor.tres")

static var tank_collision_light: StreamRandom = StreamRandom.new().with_streams(
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_01.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_02.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_03.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_05.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_07.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_light_hit_10.wav"), 
	)
static var tank_collision_heavy: StreamRandom = StreamRandom.new().with_streams(
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_heavy_hit_01.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_heavy_hit_02.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_heavy_hit_03.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_heavy_hit_04.wav"), 
		load("res://assets/sfx/tanks/collision/tanks_tanks_physics_common_tank_heavy_hit_05.wav"), 
	)

static var roughness_light: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/roughness_light_tank.wav")
static var roughness_medium: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/roughness_medium_tank.wav")
static var roughness_heavy: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/roughness_heavy_tank.wav")

static var roughness_light_inside: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/rougness_inside_light_tank.wav")
static var roughness_medium_inside: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/rougness_inside_medium_tank.wav")
static var roughness_heavy_inside: AudioStreamWAV = load("res://assets/sfx/tanks/roughness/rougness_inside_medium_tank.wav")

static var tracks_destroy: AudioStreamWAV = load("res://assets/sfx/tanks/tracks/hit_treads_02.wav")
static var tracks_fix: AudioStreamWAV = load("res://assets/sfx/tanks/tracks/tread_fixed_01.wav")

static var ui_install: AudioStream = load("res://assets/sfx/ui/module_install_01.wav")
static var ui_enter: AudioStream = load("res://assets/sfx/ui/enter_01.wav")
static var ui_select: AudioStream = load("res://assets/sfx/ui/select_01.wav")
static var ui_battle: AudioStream = load("res://assets/sfx/ui/start_battle.wav")
static var ui_buy: AudioStream = load("res://assets/sfx/ui/buy_01.wav")
static var ui_sell: AudioStream = load("res://assets/sfx/ui/sell_01.wav")
static var ui_notif: AudioStream = load("res://assets/sfx/ui/receive_news.wav")

static var ui_slide: AudioStream = load("res://assets/sfx/ui/filter_open.wav")
static var ui_slide2: AudioStream = load("res://assets/sfx/ui/filter_close.wav")

static var ui_drag: AudioStream = load("res://assets/sfx/ui/drag_01.wav")

static var ui_sniper_in: AudioStream = load("res://assets/sfx/ui/snipermode_on.wav")
static var ui_sniper_out: AudioStream = load("res://assets/sfx/ui/snipermode_off.wav")

static var ui_autoaim_on: AudioStream = load("res://assets/sfx/ui/auto_target_on.wav")
static var ui_autoaim_off: AudioStream = load("res://assets/sfx/ui/auto_target_off.wav")

static var ui_shell_select: AudioStream = load("res://assets/sfx/ui/shell_choose_01.wav")

static var ui_lamp: AudioStream = load("res://assets/sfx/ui/lamp_01.wav")
static var ui_countdown: AudioStream = load("res://assets/sfx/ui/timer.wav")


static var ui_cons_berserk_on: AudioStream = load("res://assets/sfx/ui/adrenalin.wav")
static var ui_cons_berserk_off: AudioStream = load("res://assets/sfx/ui/adrenalin_off.wav")
static var ui_cons_afterburner_on: AudioStream = load("res://assets/sfx/ui/furious.wav")
static var ui_cons_afterburner_off: AudioStream = load("res://assets/sfx/ui/furious_off.wav")
static var ui_cons_repair: AudioStream = load("res://assets/sfx/ui/repair_06.wav")


static var music_win: AudioStream = load("res://assets/sfx/music/aftershot/victory.mp3")
static var music_lose: AudioStream = load("res://assets/sfx/music/aftershot/defeat.mp3")
static var music_draw: AudioStream = load("res://assets/sfx/music/aftershot/draw.mp3")
static var music_buy_congrats: AudioStream = load("res://assets/sfx/music/aftershot/bought_module.mp3")


enum CrewMessage{
	BATTLE_START, 
	ALLY_KILLED, 

	ARMOR_NOT_PIERCE, 
	ARMOR_PIERCED, 
	ARMOR_NOT_HIT, 
	RICOSHET, 
	ENEMY_IGNITED, 
	ENEMY_KILLED, 

	FIRE_STARTED, 
	FIRE_STOPPED, 

	MODULE_TRACK_CRIT, 
	MODULE_TRACK_DESTROYED, 
	MODULE_TRACK_FIXED, 

	MODULE_AMMO_BAY_CRIT, 

	TANK_DESTROYED
}

static var crew_msg_to_stream: Dictionary[CrewMessage, StreamRandom] = {
	CrewMessage.BATTLE_START: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/start_battle_01.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_02.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_03.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_04.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_05.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_06.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_07.wav"), 
		load("res://assets/sfx/ui/crew/start_battle_08.wav"), 
	), 
	CrewMessage.ALLY_KILLED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/ally_killed_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/ally_killed_by_player_02.wav"), 
	), 

	CrewMessage.ARMOR_NOT_PIERCE: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/armor_not_pierced_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/armor_not_pierced_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/armor_not_pierced_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/armor_not_pierced_by_player_04.wav"), 
		load("res://assets/sfx/ui/crew/armor_not_pierced_by_player_05.wav"), 
	), 
	CrewMessage.ARMOR_PIERCED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_04.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_05.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_06.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_07.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_08.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_09.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_10.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_11.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_by_player_12.wav"), 
	), 
	CrewMessage.ARMOR_NOT_HIT: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_04.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_05.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_06.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_07.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_08.wav"), 
		load("res://assets/sfx/ui/crew/armor_pierced_crit_by_player_09.wav"), 
	), 
	CrewMessage.RICOSHET: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_04.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_05.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_06.wav"), 
		load("res://assets/sfx/ui/crew/armor_ricochet_by_player_07.wav"), 
	), 
	CrewMessage.ENEMY_IGNITED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/enemy_fire_started_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/enemy_fire_started_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/enemy_fire_started_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/enemy_fire_started_by_player_04.wav"), 
	), 
	CrewMessage.ENEMY_KILLED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_01.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_02.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_03.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_04.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_05.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_06.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_07.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_08.wav"), 
		load("res://assets/sfx/ui/crew/enemy_killed_by_player_09.wav"), 
	), 

	CrewMessage.FIRE_STARTED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/fire_started_01.wav"), 
		load("res://assets/sfx/ui/crew/fire_started_02.wav"), 
	), 
	CrewMessage.FIRE_STOPPED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/fire_started_01.wav"), 
		load("res://assets/sfx/ui/crew/fire_started_02.wav"), 
	), 

	CrewMessage.MODULE_TRACK_CRIT: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/track_damaged_01.wav"), 
		load("res://assets/sfx/ui/crew/track_damaged_02.wav"), 
		load("res://assets/sfx/ui/crew/track_damaged_03.wav"), 
		load("res://assets/sfx/ui/crew/track_damaged_04.wav"), 
	), 
	CrewMessage.MODULE_TRACK_DESTROYED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/track_destroyed_01.wav"), 
		load("res://assets/sfx/ui/crew/track_destroyed_02.wav"), 
		load("res://assets/sfx/ui/crew/track_destroyed_03.wav"), 
		load("res://assets/sfx/ui/crew/track_destroyed_04.wav"), 
	), 
	CrewMessage.MODULE_TRACK_FIXED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/track_functional_01.wav"), 
		load("res://assets/sfx/ui/crew/track_functional_02.wav"), 
		load("res://assets/sfx/ui/crew/track_functional_03.wav"), 
		load("res://assets/sfx/ui/crew/track_functional_04.wav"), 
	), 

	CrewMessage.MODULE_AMMO_BAY_CRIT: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/ammo_bay_damaged_01.wav"), 
		load("res://assets/sfx/ui/crew/ammo_bay_damaged_02.wav"), 
		load("res://assets/sfx/ui/crew/ammo_bay_damaged_03.wav"), 
	), 

	CrewMessage.TANK_DESTROYED: StreamRandom.new().with_streams(
		load("res://assets/sfx/ui/crew/vehicle_destroyed_01.wav"), 
		load("res://assets/sfx/ui/crew/vehicle_destroyed_02.wav"), 
		load("res://assets/sfx/ui/crew/vehicle_destroyed_03.wav"), 
	), 
}

static var crew_msg_onetimers: Array[CrewMessage] = [
	CrewMessage.ARMOR_NOT_HIT
]
static var crew_msg_top_priority: Array[CrewMessage] = [
	CrewMessage.MODULE_TRACK_CRIT, 
	CrewMessage.MODULE_TRACK_DESTROYED, 
	CrewMessage.MODULE_TRACK_FIXED, 
	CrewMessage.MODULE_AMMO_BAY_CRIT, 
	CrewMessage.FIRE_STARTED, 
	CrewMessage.FIRE_STOPPED, 
	CrewMessage.TANK_DESTROYED, 
]

static var crew_messages_scheduled: Array[CrewMessage] = []
func play_crew_message(msg: CrewMessage):
	var already_scheduled: int = 0
	for m in crew_messages_scheduled:
		if m == msg: already_scheduled += 1

	if already_scheduled > 0: return
	if crew_msg_top_priority.has(msg):
		crew_messages_scheduled.clear()

	crew_messages_scheduled.append(msg)



static var next_cmsg: float = 0
func process_crew_messages():
	if !crew_messages_scheduled.is_empty() and Util.curtime() >= next_cmsg:
		_play_crew_message(crew_messages_scheduled.pop_back())

func _play_crew_message(msg: CrewMessage):
	var stream_random: StreamRandom = crew_msg_to_stream[msg]
	var s: = stream_random.pick_random()

	next_cmsg = Util.curtime() + s.get_length() + 0.25

	await get_tree().create_timer(0.5).timeout
	play_sound2d(s)

static var info_to_gun_sound: Dictionary = {
	ModuleGun.ShootSound.shot_auto: gun_auto, 
	ModuleGun.ShootSound.shot_small: gun_small, 
	ModuleGun.ShootSound.shot_medium: gun_medium, 
	ModuleGun.ShootSound.shot_main: gun_main, 
	ModuleGun.ShootSound.shot_large: gun_large, 
	ModuleGun.ShootSound.shot_huge: gun_huge
}

static var info_to_engine_snd: Dictionary = {
	TankInfoMain.EngineSound.DE_HT: engine_de_ht, 
	TankInfoMain.EngineSound.DE_LT: engine_de_lt, 
	TankInfoMain.EngineSound.DE_MT: engine_de_mt, 
	TankInfoMain.EngineSound.DE_TRAKTOR: engine_de_traktor, 

	TankInfoMain.EngineSound.UK_HT: engine_uk_ht, 
	TankInfoMain.EngineSound.UK_LT: engine_uk_lt, 
	TankInfoMain.EngineSound.UK_MT: engine_uk_mt, 
	TankInfoMain.EngineSound.UK_TRAKTOR: engine_uk_traktor, 

	TankInfoMain.EngineSound.USA_HT: engine_usa_ht, 
	TankInfoMain.EngineSound.USA_LT: engine_usa_lt, 
	TankInfoMain.EngineSound.USA_MT: engine_usa_mt, 
	TankInfoMain.EngineSound.USA_TRAKTOR: engine_usa_traktor, 

	TankInfoMain.EngineSound.USSR_HT: engine_ussr_ht, 
	TankInfoMain.EngineSound.USSR_LT: engine_ussr_lt, 
	TankInfoMain.EngineSound.USSR_MT: engine_ussr_mt, 
	TankInfoMain.EngineSound.USSR_TRAKTOR: engine_ussr_traktor, 
}
static var info_to_track_snd: Dictionary = {
	TankInfoMain.TrackSound.HT: tracks_ht, 
	TankInfoMain.TrackSound.LT: tracks_lt, 
	TankInfoMain.TrackSound.MT: tracks_mt, 
	TankInfoMain.TrackSound.TRAKTOR: tracks_traktor, 
}

var active_players: Array[AudioStreamPlayer] = []
var active_players3d: Array[AudioStreamPlayer3D] = []

func get_gun_sound(gun_snd: ModuleGun.ShootSound) -> ExplosionSound:
	if !info_to_gun_sound.has(gun_snd): return gun_auto
	return info_to_gun_sound[gun_snd]

func get_engine_sound(tank_snd: TankInfoMain.EngineSound) -> EngineSounds:
	if !info_to_engine_snd.has(tank_snd): return engine_ussr_lt
	return info_to_engine_snd[tank_snd]
func get_track_sound(tank_snd: TankInfoMain.TrackSound) -> TrackSounds:
	if !info_to_track_snd.has(tank_snd): return tracks_lt
	return info_to_track_snd[tank_snd]

func apply_sound_settings() -> void :
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), VOL_MUSIC)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), VOL_SFX)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("UI"), VOL_UI)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Radio"), VOL_RADIO)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sniper"), 0)

func _process(delta: float) -> void :
	process_crew_messages()

func _ready() -> void :
	muffle_sfx(false)
	apply_sound_settings()
	LevelManager.level_changed.connect(clear_sounds)


func muffle_sfx(muffle: bool):
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	var sniper_bus: int = AudioServer.get_bus_index("Sniper")

	var tween1: Tween = create_tween()
	var tween2: Tween = create_tween()


	tween1.tween_method( func(i):
		AudioServer.set_bus_volume_linear(sfx_bus, i), 
		AudioServer.get_bus_volume_linear(sfx_bus), VOL_SFX * 0.85 if muffle else VOL_SFX, 0.3)
	tween2.tween_method( func(i):
		AudioServer.set_bus_volume_linear(sniper_bus, i), 
		AudioServer.get_bus_volume_linear(sniper_bus), VOL_SNIPER if muffle else 0, 0.3)





	AudioServer.set_bus_effect_enabled(sfx_bus, 0, muffle)

	AudioServer.set_bus_volume_linear(sniper_bus, VOL_SNIPER if muffle else 0)

func clear_sounds() -> void :
	for player in active_players:
		if !is_instance_valid(player): return
		player.queue_free()
	for player in active_players3d:
		if !is_instance_valid(player): return
		player.queue_free()

class AudioPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()


func play_sound3d(stream: AudioStream, vol: float = 1, pos: Vector3 = Vector3.ZERO, parent: Node3D = null, persist_on_level_switch: bool = false) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

	if parent:
		parent.add_child(player)
	else:
		add_child(player)

	player.volume_linear = vol
	player.stream = stream
	player.global_position = pos

	player.bus = "SFX"

	player.playing = true
	player.play()

	print("3d sound started: ", player)

	player.finished.connect(player.queue_free)

	if not persist_on_level_switch: active_players3d.push_back(player)

	return player

func stop_sound2d(stream: AudioStream):
	for ply in active_players:
		if !is_instance_valid(ply): continue
		if ply.stream == stream: ply.queue_free()

func play_sound2d(stream: AudioStream, bus: String = "UI", loop: bool = false, vol: float = 1, persist_on_level_switch: bool = false) -> AudioStreamPlayer:
	if !stream: return

	var player: = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream

	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD if loop else AudioStreamWAV.LoopMode.LOOP_DISABLED
	else:
		stream.loop = loop

	player.volume_linear = vol
	player.bus = bus

	player.playing = true
	player.play()

	player.finished.connect( func():
		if !is_instance_valid(player): return
		player.queue_free()
	)

	if not persist_on_level_switch: active_players.push_back(player)

	return player

func fade_out_player(player: AudioStreamPlayer, duration: float):
	if !player or !is_instance_valid(player): return

	var tween: Tween = get_tree().create_tween()
	tween.tween_method( func(i):
		if !player or !is_instance_valid(player): return
		player.volume_linear = i
	, player.volume_linear, 0, duration)
