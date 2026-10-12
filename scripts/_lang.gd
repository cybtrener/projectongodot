extends Node

func _ready() -> void :
	language_new("ru")
	language_new("en")

	add_string("ru", "map:rudniki/name", "Рудники")
	add_string("en", "map:rudniki/name", "Mines")


class Language:
	var dict: Dictionary = {}
	func add_string(id: StringName, str: String):
		self.dict[id] = str
	func get_string(id: StringName):
		return self.dict[id] if self.dict.has(id) else id

var languages: Dictionary = {}

func language_new(id: StringName):
	if languages.has(id):
		printerr("Lang: trying to add language with already existing id: " + id)
		return
	languages[id] = Language.new()

func add_string(lang: StringName, id: StringName, str: String):
	if languages.has(lang):
		languages[lang].add_string(id, str)
	else:
		printerr("Lang: trying to add strig for non-existend language! lang= " + lang)

func get_string(id: StringName):
	return _get_string(Global.save_settings.language, id)

func _get_string(lang: StringName, id: StringName):
	if languages.has(lang):
		return languages[lang].get_string(id)
	else:
		printerr("Lang: trying to get strig for non-existend language! lang= " + lang)
		return id
