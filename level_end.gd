extends Area2D

@export_file("*.tscn") var next_level: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if next_level != "":
			get_tree().change_scene_to_file(next_level)
		else:
			print("Není nastavena další úroveň (next_level)!")
