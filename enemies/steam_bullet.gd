extends Area2D

# Parní / energetický projektil vystřelený střelcem korporace.
# Lze se mu vyhnout, nebo ho zničit seknutím hasáku - to hráči obnoví dash.

@export var speed: float = 175.0
@export var damage: int = 1
@export var lifetime: float = 3.5

var direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0

@onready var sprite = $Sprite2D

func setup(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("enemy_projectiles")
	add_to_group("enemies") # Umožní zásah hráčovým hasákem / hákem

func _physics_process(delta):
	position += direction * speed * delta
	timer += delta
	if timer >= lifetime:
		_destroy()

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
		_destroy()
	elif not body.is_in_group("enemies"): # Neruší se o střelce samotného
		_destroy()

func _on_area_entered(area):
	# Pokud projektil trefí oblast seknutí nebo hák
	if area.is_in_group("player_attacks"):
		_destroy()

func take_hit(_amount: int = 1, _from_dir: Vector2 = Vector2.ZERO):
	# Zásah hasákem nebo hákem zničí střelu a obnoví hráči dash
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.refill_dash()
	_destroy()

## Starší jméno zásahu.
func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	take_hit(amount, from_dir)

func _destroy():
	# Parní rozpad
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.1)
	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.chain().tween_callback(queue_free)
