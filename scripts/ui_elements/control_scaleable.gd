extends Control

@export var size_add: float = 0
@export var text_size: float = 20
@export var label: Label

func _ready() -> void :
	self.custom_minimum_size.x = label.text.length() * text_size + size_add
