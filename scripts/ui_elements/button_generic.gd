extends Button
class_name ButtonCustom

enum Snd{
	SOUND_ENTER, SOUND_SELECT, SOUND_BATTLE, SOUND_SLIDE
}

@export var toggle_rect: Control
@export var snd_var: Snd
@export var snd_vol: float = 1.0
@export var toggle_sound: bool
@export var no_sound: bool = false

var sounds: Dictionary[Snd, AudioStream] = {
	Snd.SOUND_ENTER: Audio.ui_enter, 
	Snd.SOUND_SELECT: Audio.ui_select, 
	Snd.SOUND_BATTLE: Audio.ui_battle, 
	Snd.SOUND_SLIDE: Audio.ui_slide, 
}
var sounds_toggle_off: Dictionary[Snd, AudioStream] = {
	Snd.SOUND_ENTER: Audio.ui_enter, 
	Snd.SOUND_SELECT: Audio.ui_select, 
	Snd.SOUND_BATTLE: Audio.ui_battle, 
	Snd.SOUND_SLIDE: Audio.ui_slide2, 
}
var first: bool = true

func enable(on: bool):
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE if !on else Control.MOUSE_BEHAVIOR_INHERITED
	self.self_modulate.a = 1 if on else 0.5

func _toggled(on: bool) -> void :
	if toggle_rect:
		toggle_rect.visible = on

	if !self.toggle_mode or !toggle_sound:
		return

	Audio.play_sound2d(sounds[snd_var] if on else sounds_toggle_off[snd_var], "UI", false, 0.7 * snd_vol)

func fade(fade: bool):
	var sbox: StyleBox = self.get_theme_stylebox("normal")
	if !sbox: return

	sbox.bg_color.a = 0 if fade else 1

func _ready() -> void :
	pass

func _pressed() -> void :
	if !no_sound: Audio.play_sound2d(sounds[snd_var], "UI", false, 0.7 * snd_vol)
