extends Node

const insta_battle_debug: bool = false
const attach_ai_to_player: bool = false
const ai_enabled: bool = true
const save_battle_results: bool = false

static var dont_delete_temp_encrypted_resources: bool = OS.is_debug_build()

var battle_skip_countdown: bool = false
var battle_skip_intro: bool = false

var ai_debug: bool = false
var nav_debug: bool = false
var godmode: bool = false
var instakill: bool = false

var gold_price: int = 400

var current_account: Account
var hangar_ui: Control

func update_hangar(no_carousel: bool = false):
	if is_instance_valid(hangar_ui): hangar_ui.update_hangar(no_carousel)

var hangar_notifs: Array[Dictionary] = []
var hangar_transition_check_battles: bool = false

signal on_receive_hangar_notif
func receive_hangar_notif(text: String):
	var dt: Dictionary = Time.get_time_dict_from_system()

	var h: String = str(dt.hour)
	var m: String = str(dt.minute)

	if h.length() <= 1: h = "0" + h
	if m.length() <= 1: m = "0" + m

	Global.hangar_notifs.append({
		text = text, 
		time = "[" + h + ":" + m + "]", 
	})

	Util.timer(0.5, on_receive_hangar_notif.emit)


enum VersionType{
	BETA, RELEASE
}

var SNIPER_ALLOW_BUSH_FADE: bool = false

const VERSION: = "0.9.0b"
const VERSION_TYPE: VersionType = VersionType.BETA
var MAX_TEAM_TANKS: int = 7

var MAX_BATTLE_TIME_MIN: float = 7
const BASE_TANK: String = "base_tank"
const MAX_CONSUMABLES: int = 3

const encryption_key: String = "lfgn37ckq0jjncydbe8"

var bush_active_dist: float = 8


var DMG_DEVIATION: float = 0.25
var PEN_DEVIATION: float = 0.05

func get_dmg_min(dmg: int) -> int:
	return int(dmg * (1 - DMG_DEVIATION))
func get_dmg_max(dmg: int) -> int:
	return int(dmg * (1 + DMG_DEVIATION))

func get_pen_min(pen: int) -> int:
	return int(pen * (1 - PEN_DEVIATION))
func get_pen_max(pen: int) -> int:
	return int(pen * (1 + PEN_DEVIATION))

var FRIENDLY_FIRE: bool = false


var save_path: = "user://save/"
var save_main_path: = save_path + "main.tres"
var save_settings_path: = save_path + "settings.tres"
var PROJECTILES_GRAVITY_MUL: int = 1

const COLOR_ALLY: Color = Color(0.396, 0.867, 0.0, 1.0)
const COLOR_ENEMY: Color = Color(0.96, 0, 0, 1)
const COLOR_SELF: Color = Color(0.897, 0.427, 0.0, 1.0)



enum ResearchStatus{
	NOT_AVAILABLE, 
	AVAILABLE, 
	RESEARCHED, 
	INSTALLED_BOUGHT
}

static var mastery_exp_treshold: Array[int] = [
	500, 
]

class CollisionDamageRequest:
	var tank_a: BaseTank
	var tank_b: BaseTank
	var impulse_relative: float

	func _init(tank_a: BaseTank, tank_b: BaseTank, impulse_relative: float) -> void :
		self.tank_a = tank_a
		self.tank_b = tank_b
		self.impulse_relative = impulse_relative


static var ram_damage_requests: Array[CollisionDamageRequest] = []

static func calculate_ram_damage(weight_combined: float, weight_individual: float, relative_speed: float, spall_liner: bool = false) -> float:
	return (0.5 * weight_combined * relative_speed ** 2) * (1 - (weight_individual / weight_combined)) * (1 if !spall_liner else 0.85)

static func request_ram_damage(tank_my: BaseTank, tank_other: BaseTank, impulse_relative: float):




	if tank_my.team == tank_other.team && !Global.FRIENDLY_FIRE:
		return

	impulse_relative = absf(impulse_relative) * 0.25
	var request: CollisionDamageRequest = CollisionDamageRequest.new(tank_my, tank_other, impulse_relative)
	ram_damage_requests.append(request)

	for r in ram_damage_requests:
		if r.tank_a == tank_other and r.tank_b == tank_my:
			var best_request: CollisionDamageRequest = r if r.impulse_relative > impulse_relative else request

			var wcoeff: float = 0.00125
			var weight_combined: float = (best_request.tank_a.mass + best_request.tank_b.mass) * wcoeff
			var weight_a: float = best_request.tank_a.mass * wcoeff
			var weight_b: float = best_request.tank_b.mass * wcoeff

			var dmg_a: float = calculate_ram_damage(weight_combined, weight_a, impulse_relative, best_request.tank_a.has_equipment(TanksDataBase.eq_spallliner))
			var dmg_b: float = calculate_ram_damage(weight_combined, weight_b, impulse_relative, best_request.tank_b.has_equipment(TanksDataBase.eq_spallliner))









			Util.timer_curtime(randf_range(0.02, 0.033), func():
				var dinfo_a: DamageInfo = DamageInfo.new()
				dinfo_a.dmg_type = DamageInfo.DamageType.COLLISION
				dinfo_a.dmg = absi(dmg_b)
				dinfo_a.attacker = Battle.get_player_by_tank(best_request.tank_a)
				dinfo_a.attacker_tank = best_request.tank_a
				best_request.tank_b.receive_damage(dinfo_a)

				var dinfo_b: DamageInfo = DamageInfo.new()
				dinfo_b.dmg_type = DamageInfo.DamageType.COLLISION
				dinfo_b.dmg = absi(dmg_a)
				dinfo_b.attacker = Battle.get_player_by_tank(best_request.tank_b)
				dinfo_b.attacker_tank = best_request.tank_b
				best_request.tank_a.receive_damage(dinfo_b)
			)
			var i1: int = ram_damage_requests.find(request)
			var i2: int = ram_damage_requests.find(r)
			if Util.array_id_valid(ram_damage_requests, i1):
				ram_damage_requests.remove_at(i1)
			if Util.array_id_valid(ram_damage_requests, i2):
				ram_damage_requests.remove_at(i2)

var save_main: SaveMain
var save_settings: SaveSettings

func get_current_player() -> Account:
	return save_main.get_current_account()

func fullscreen(on: bool):
	await get_tree().physics_frame

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)


const hangar_path: String = "res://maps/hangar_low.tscn"
var in_hangar: bool:
	get():
		return is_instance_valid(LevelManager.current_scene) && LevelManager.current_scene.scene_file_path == hangar_path


func to_login():
	UIGlobal.loading_screen_toggle(true)
	LevelManager.switch_scene("res://maps/_login_screen.tscn")

func save():
	save_main.save(save_main_path, save_path)
	save_settings.save(save_settings_path, save_path)

func to_hangar(check_battles: bool = false):
	UIGlobal.please_wait_toggle(true)

	hangar_transition_check_battles = check_battles

	Audio.crew_messages_scheduled.clear()
	LevelManager.switch_scene(hangar_path)
	Battle.status = Battle.Status.FINISHING
	if save_main and save_settings:
		save()

	Util.mouse_lock(false)


func _ready() -> void :
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, OS.is_debug_build())

	save_main = load_save_validate_sav_main(save_main_path, SaveMain.new())

	save_main.load_accounts_encrypted()
	current_account = save_main.get_current_account()

	if current_account: current_account.on_load()

	save_settings = load_save_validate(save_settings_path, SaveSettings.new())
	apply_settings()

	if !(insta_battle_debug && !OS.has_feature("standalone")):
		print(current_account)
		if save_settings.skip_login and !save_main.accounts.is_empty() && current_account != null:
			current_account.log_in()
			to_hangar()
		else:
			to_login()
	else:
		LevelManager.change_map(Map.FORT)



static var on_exit_notification: Dictionary = {
	int(NOTIFICATION_WM_CLOSE_REQUEST): true, 
	int(NOTIFICATION_WM_GO_BACK_REQUEST): true, 
	int(NOTIFICATION_APPLICATION_PAUSED): true, 
	int(NOTIFICATION_CRASH): true, 
	int(NOTIFICATION_EXIT_TREE): true, 
}

func _notification(what):
	if on_exit_notification.has(what) and on_exit_notification[what]:
		_on_exit_game()

func on_hangar_enter():
	pass

func _on_exit_game() -> void :
	if get_current_player():
		get_current_player().log_out()

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

	save_main.save(save_main_path, save_path)
	save_settings.save(save_settings_path, save_path)

func exit_game() -> void :
	_on_exit_game()
	get_tree().quit(0)

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("fullscreen"):
		save_settings.fullscreen = !save_settings.fullscreen

func apply_settings():
	TranslationServer.set_locale(save_settings.language)

	var dev_to_float: Dictionary[int, float] = {
		SaveSettings.DEV_0: 0, 
		SaveSettings.DEV_5: 0.05, 
		SaveSettings.DEV_15: 0.15, 
		SaveSettings.DEV_25: 0.25, 
	}

	DMG_DEVIATION = dev_to_float[save_settings.dmg_deviation]
	PEN_DEVIATION = dev_to_float[save_settings.pen_deviation]

	PROJECTILES_GRAVITY_MUL = save_settings.battle_mechanics_projectiles_gravity_mul
	MAX_TEAM_TANKS = {
		SaveSettings.TEAMSIZE_1X1: 1, 
		SaveSettings.TEAMSIZE_2X2: 2, 
		SaveSettings.TEAMSIZE_5X5: 5, 
		SaveSettings.TEAMSIZE_7X7: 7, 
		SaveSettings.TEAMSIZE_10X10: 10
	}[save_settings.matchmaker_team_size]

	MAX_BATTLE_TIME_MIN = {
		SaveSettings.TIME_5: 5, 
		SaveSettings.TIME_7: 7, 
		SaveSettings.TIME_15: 15, 
		SaveSettings.TIME_INF: INF
	}[save_settings.battle_max_time]

func load_save_validate(path: String, new_save: SaveBase):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(save_path)

	var sav: SaveBase
	if !ResourceLoader.exists(path):
		sav = new_save
	else:
		sav = load(path) as SaveBase
	sav.save(path, save_path)
	return sav

func load_save_validate_sav_main(path: String, new_save: SaveMain):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(save_path)

	var sav: SaveMain
	if !ResourceLoader.exists(path):
		sav = new_save
	else:
		sav = load(path) as SaveMain

	return sav

static var _popup_template: PackedScene = load("res://assets/gfx/ui/popup_generic.tscn")

func create_popup(header: String, main_text: String, simple: bool, on_accept: Callable = func(): pass) -> Control:
	var popup: Control = _popup_template.instantiate()
	if simple:
		popup.init_simple(header, main_text)
	else:
		popup.init(header, main_text, on_accept)

	UIGlobal.display_popup(popup)
	return popup
