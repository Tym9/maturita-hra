@tool
class_name RespawnPoint
extends Marker2D

## Bod respawnu v místnosti (Room). Při vstupu do místnosti se použije ten nejbližší místu vstupu.

func _ready():
	add_to_group("spawn_points")
