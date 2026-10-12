extends SaveBase
class_name SaveSettings

static var languages = ["en", "ru"]
func set_language(newlang: String):
	if not languages.has(newlang):
		printerr("SaveBase: trying to switch to non-existing language: '" + newlang + "'!")
		return
	self.language = newlang

enum {
	CAM_VANILLA, CAM_MODERN, 

	CAMS_BELOW, CAMS_ACCURATE, CAMS_ABOVE, 

	MM_VANILLA_1_5, MM_ALL_LOYAL_3_8, 

	TEAMSIZE_1X1, TEAMSIZE_2X2, TEAMSIZE_5X5, TEAMSIZE_7X7, TEAMSIZE_10X10, 

	TIME_5, TIME_7, TIME_15, TIME_INF, 

	DEV_25, DEV_15, DEV_5, DEV_0, 
}


@export var mouse_sens: float = 0.6:
	set(a):
		mouse_sens = clampf(a, 0.05, 8)

@export var mouse_sens_sniper: float = 0.3:
	set(a):
		mouse_sens_sniper = clampf(a, 0.05, 8)

@export var language: String = "en"
@export var skip_login: bool = false
@export var show_mobile_controls: bool = false

@export var fullscreen: bool = false:
	set(a):
		fullscreen = a

		Global.fullscreen(a)



@export var battle_max_time: int = TIME_7:
	set(a):
		battle_max_time = clampi(a, TIME_5, TIME_INF)

@export var battle_mechanics_projectiles_gravity_mul: float = 1:
	set(a):
		battle_mechanics_projectiles_gravity_mul = clampf(a, 0.1, 5)

@export var battle_mechanics_no_aim_time: bool = false:
	set(a):
		if Battle.is_ongoing(): return
		battle_mechanics_no_aim_time = a
@export var battle_mechanics_no_disp: bool = false:
	set(a):
		if Battle.is_ongoing(): return
		battle_mechanics_no_disp = a
@export var battle_spotting_delay: float = 0.25:
	set(a):
		if Battle.is_ongoing(): return
		battle_spotting_delay = clampf(a, 0.1, 0.5)
@export var matchmaker_mode: int = MM_VANILLA_1_5:
	set(a):
		matchmaker_mode = clampi(a, MM_VANILLA_1_5, MM_ALL_LOYAL_3_8)
@export var matchmaker_team_size: int = TEAMSIZE_7X7:
	set(a):
		matchmaker_team_size = clampi(a, TEAMSIZE_1X1, TEAMSIZE_10X10)
@export var dmg_deviation: int = DEV_25:
	set(a):
		dmg_deviation = clampi(a, DEV_25, DEV_0)
@export var pen_deviation: int = DEV_5:
	set(a):
		pen_deviation = clampi(a, DEV_25, DEV_0)
@export var battle_friendly_fire: bool = false
@export var map_loading_screen_timer_mul: float = 1:
	set(a):
		map_loading_screen_timer_mul = clampf(a, 0.2, 3)
@export var camera_mode: int = CAM_MODERN:
	set(a):
		camera_mode = clampi(a, CAM_VANILLA, CAM_MODERN)
@export var camera_sniper_mode: int = CAMS_ACCURATE:
	set(a):
		camera_sniper_mode = clampi(a, CAMS_BELOW, CAMS_ABOVE)



@export var camera_smoothing: bool = false

@export var camera_len_min: float = 1
@export var camera_len_max: float = 30
@export var camera_len_step: float = 3
