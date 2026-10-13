extends Area2D

@export var stage_title: String = "ETAPA 1: STARÉ DÍLNY"
@export var stage_index: int = 1
@export var max_stage_crystals: int = 5
@export_file("*.tscn") var next_level: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		if Global and Global.has_method("save_player_state"):
			Global.save_player_state(body)
		if next_level != "":
			if Global and Global.has_method("finish_stage"):
				Global.finish_stage(stage_title, max_stage_crystals, next_level)
				get_tree().call_deferred("change_scene_to_file", "res://ui/stage_clear_screen.tscn")
			else:
				get_tree().call_deferred("change_scene_to_file", next_level)
		else:
			print("Není nastavena další úroveň (next_level)!")
