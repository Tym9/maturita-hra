extends Area2D

## Automatický příběhový spouštěč (EventTrigger).
## Spustí dialogovou scénu při vstupu hráče do oblasti.

@export var speaker_name: String = "Příběhová událost"
@export var speaker_title: String = ""
@export var portrait_texture: Texture2D = null
@export var dialogue_pages: Array[String] = []
@export var trigger_once: bool = true

var has_triggered: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if has_triggered:
		return
	if body.name == "Player" or body.is_in_group("player"):
		has_triggered = true
		if trigger_once:
			set_deferred("monitoring", false)
		DialogueManager.start_dialogue(speaker_name, speaker_title, dialogue_pages, portrait_texture)
