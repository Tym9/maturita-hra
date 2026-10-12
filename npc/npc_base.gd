@tool
class_name NPCBase
extends CharacterBody2D

## Základní komponenta pro přátelská NPC (nehráčské postavy).
## Zahrnuje detekční zónu hráče, plovoucí nápovědu [E] Mluvit,
## natáčení za hráčem a spuštění dialogu přes DialogueManager.

@export var npc_name: String = "Postava"
@export var npc_title: String = "Obyvatel"
@export var portrait_texture: Texture2D = null
@export var sprite_texture: Texture2D = null:
	set(val):
		sprite_texture = val
		if sprite:
			sprite.texture = sprite_texture
		queue_redraw()

@export var dialogue_pages: Array[String] = []
@export var repeat_dialogue_pages: Array[String] = []
@export var sprite_flip_h: bool = false:
	set(val):
		sprite_flip_h = val
		if sprite:
			sprite.flip_h = sprite_flip_h

var is_player_nearby: bool = false
var has_talked: bool = false
var nearby_player: Node2D = null
var time: float = 0.0

@onready var sprite = $Sprite2D
@onready var prompt = $PromptNode
@onready var interact_area = $InteractionArea

func _ready():
	if sprite and sprite_texture:
		sprite.texture = sprite_texture
		sprite.flip_h = sprite_flip_h
		
	if not Engine.is_editor_hint():
		if interact_area:
			interact_area.body_entered.connect(_on_body_entered)
			interact_area.body_exited.connect(_on_body_exited)
		if prompt:
			prompt.visible = false

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
		
	time += delta
	# Jemná gravitace k usazení na podlahu
	if not is_on_floor():
		velocity.y += 600.0 * delta
		move_and_slide()
		
	# Jemné dýchání spritu (idle bob)
	if sprite and not DialogueManager.is_active:
		sprite.position.y = sin(time * 3.0) * 0.8
		
	# Plovoucí nápověda nad hlavou
	if prompt and prompt.visible:
		prompt.position.y = -22.0 + sin(time * 4.0) * 2.0

func _unhandled_input(event):
	if not is_player_nearby:
		return
	if DialogueManager.is_active:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			talk()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Pokud hráč klikne poblíž NPC, zahájí rozhovor
			var mpos = get_global_mouse_position()
			if global_position.distance_to(mpos) < 36.0:
				talk()
				get_viewport().set_input_as_handled()

func talk():
	if DialogueManager.is_active:
		return
		
	# Otočíme se směrem k hráči
	if nearby_player and sprite:
		sprite.flip_h = (nearby_player.global_position.x < global_position.x)
		
	var pages_to_use = dialogue_pages
	if has_talked and not repeat_dialogue_pages.is_empty():
		pages_to_use = repeat_dialogue_pages
		
	DialogueManager.start_dialogue(npc_name, npc_title, pages_to_use, portrait_texture, Callable(self, "_on_talk_finished"))

func _on_talk_finished():
	has_talked = true

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		is_player_nearby = true
		nearby_player = body
		if prompt:
			prompt.visible = true

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		is_player_nearby = false
		nearby_player = null
		if prompt:
			prompt.visible = false
