extends TabContainer
class_name TabContainerCustom

@export var buttons: Array[Button] = []


func to_screen(s: int):
	if self.get_children().is_empty():
		return
	self.current_tab = clampi(s, 0, self.get_children().size() - 1)

	for bb in buttons:
		bb.button_pressed = false

	buttons[self.current_tab].button_pressed = true

func _ready() -> void :
	self.tabs_visible = false
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if buttons.is_empty(): return

	for i in range(buttons.size()):
		var b: Button = buttons[i]
		b.toggle_mode == true

		var id: int = i

		b.pressed.connect( func():
			self.current_tab = id
			for bb in buttons:
				bb.button_pressed = false

			b.button_pressed = true
		)

	Util.timer(1, func(): buttons[0].button_pressed = true)
