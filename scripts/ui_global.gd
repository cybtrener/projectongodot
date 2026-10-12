extends CanvasLayer

var current_popup: Control
var please_wait: Control
var loading_screen: Control

func _ready() -> void :
	please_wait = load("res://maps/please_wait.tscn").instantiate()
	add_child(please_wait)
	please_wait.z_index = 1
	please_wait.hide()

	loading_screen = load("res://maps/loading_screen.tscn").instantiate()
	add_child(loading_screen)
	loading_screen.z_index = 1
	loading_screen.hide()

func loading_screen_toggle(on: bool):
	if !loading_screen:
		return
	loading_screen.visible = on
func please_wait_toggle(on: bool):
	if !please_wait:
		return
	please_wait.visible = on

func clear():
	for c in self.get_children():
		if is_instance_valid(c): c.queue_free()

func display_popup(p: Control):
	if is_instance_valid(current_popup):
		current_popup.queue_free()

	add_child(p)
	current_popup = p
