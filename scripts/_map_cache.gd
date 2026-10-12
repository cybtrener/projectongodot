extends Node

signal map_sampled()

const map_cache_dir: String = "res://cache/maps"

class MapCacheResource extends Resource:
	var map_sample_points: Array[MapPosition] = []

class MapPosition extends Resource:
	var position: Vector3
	var observers: Array[MapPosition] = []
	var observers_vec: PackedVector3Array = []

	func add_observer(p: MapPosition):
		observers.append(p)
		observers_vec.append(p.position)



	func _init(pos: Vector3) -> void :
		position = pos



var map_sample_points: Array[MapPosition] = []
var good_hiding_spots: Array[MapPosition] = []
func sample_current_map():
	map_sample_points.clear()

	print("MapCache: map sampling started!")
	for c in LevelManager.current_scene.get_children(true):
		if c is NavigationRegion3D: sample_nmesh((c as NavigationRegion3D).navigation_mesh)
	map_sampled.emit()
	print("MapCache: map sampled!")

func sample_nmesh(nmesh: NavigationMesh):
	print("polygons: ", nmesh.get_polygon_count())































func get_closest_pos_to_observe_pos_from(p: Vector3) -> Vector3:
	var mpos: MapPosition = get_mappos_close_to_pos(p)

	var dist_min: float
	var best_pos: Vector3 = Vector3()
	for ob in mpos.observers:
		var d: float = ob.position.distance_squared_to(p)
		if !dist_min or d < dist_min:
			dist_min = d
			best_pos = ob.position

	return best_pos

func get_mappos_close_to_pos(p: Vector3) -> MapPosition:
	if map_sample_points.is_empty():
		printerr("MapCache: trying to sample points on map that wasnt sampled yet!")
		return null

	var dist_min: float
	var best_pos: MapPosition
	for pos in map_sample_points:
		var d: float = pos.position.distance_squared_to(p)
		if !dist_min or d < dist_min:
			dist_min = d
			best_pos = pos

	return best_pos

func init_map_cache():
	var cache_dir: = ProjectSettings.globalize_path(map_cache_dir)
	if !DirAccess.dir_exists_absolute(cache_dir):
		DirAccess.make_dir_recursive_absolute(cache_dir)
