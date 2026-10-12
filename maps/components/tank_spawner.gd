class_name TankSpawner
extends Marker3D

@onready var root: = $".."
@export var team: BaseTank.Team = BaseTank.Team.TEAM_A


func _ready() -> void :
	self.add_to_group("tank_spawners")
	$tonk.queue_free()
