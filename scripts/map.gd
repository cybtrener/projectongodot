extends Node3D
class_name Map

enum GameMode{
	RANDOM, ENCOUNTER, TRAINING
}


static var music_america: AudioStream = load("res://assets/sfx/music/America.mp3")
static var music_dawn_over: AudioStream = load("res://assets/sfx/music/Dawn_over_Mountain_Pass.mp3")
static var music_japan: AudioStream = load("res://assets/sfx/music/Japan.mp3")
static var music_russian: AudioStream = load("res://assets/sfx/music/Russian_theme.mp3")
static var music_sands: AudioStream = load("res://assets/sfx/music/Sands_of_El_Halluf.mp3")
static var music_search_and_destroy: AudioStream = load("res://assets/sfx/music/Search_and_Destroy.mp3")
static var music_urge_to_win: AudioStream = load("res://assets/sfx/music/The_Urge_to_Win.mp3")

static var list: Dictionary[StringName, Map] = {}
static func get_(id: String) -> Map:
	if !list.has(id): return null

	return list[id]
static func get_random() -> Map:
	return list[list.keys().pick_random()]


static var RUDNIKI: Map = map_create(
	"rudniki", 
	"res://maps/rudniki/_rudniki.tscn", 
	"res://assets/gfx/ui/map_loading_screeens/rudniki_Out.png", 
	"res://assets/gfx/ui/map_minimaps/rudniki_Out.png", 
	music_urge_to_win
)
static var FORT: Map = map_create(
	"fort", 
	"res://maps/fort/_fort.tscn", 
	"res://assets/gfx/ui/map_loading_screeens/fort_Out.png", 
	"res://assets/gfx/ui/map_minimaps/fort_Out.png", 
	music_dawn_over
)
static var DESERT_TRAIN: Map = map_create(
	"desert_train", 
	"res://maps/desert_train/_desert_train.tscn", 
	"res://assets/gfx/ui/map_loading_screeens/desert_train_Out.png", 
	"res://assets/gfx/ui/map_minimaps/desert_train_Out.png", 
	music_sands
)

var name_display: = "Saratov"
var id: = "saratov"
var scene_path: = "res://maps/map_test.tscn"
var intro_music: AudioStream
var splash_texture: Texture2D = load("res://assets/gfx/ui/map_loading_screeens/tutorial_Out.png")
var minimap_texture: Texture2D
var game_mode: = GameMode.RANDOM
var origin_offset: Vector3 = Vector3()
var size: float = 600


var size_x: float
var size_y: float

func with_origin_offset(of: Vector3) -> Map:
	origin_offset = of
	return self
func with_size(new_size: float) -> Map:
	size = new_size
	return self

static func map_create(id: StringName, 
		scene: StringName, 
		splash_tex_path: String, 
		minimap_tex_path: String, 
		music: AudioStream, 
		mode: GameMode = GameMode.RANDOM, 
		size: float = 600
	) -> Map:

	var map: = Map.new()
	map.name_display = "map:" + id + "/name"
	map.id = id
	map.scene_path = scene
	if ResourceLoader.exists(splash_tex_path):
		map.splash_texture = load(splash_tex_path)
	if ResourceLoader.exists(minimap_tex_path):
		map.minimap_texture = load(minimap_tex_path)
	map.game_mode = mode
	map.size = size
	map.intro_music = music

	list[id] = map

	return map
