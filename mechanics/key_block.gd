extends StaticBody2D

## Klíčový blok / brána ve stylu Celeste (KeyBlock).
## Pevný blok v prostředí s klíčovou dírkou.
## Když se přiblíží hráč s letícím CelesteKey, klíč vletí do dírky, odemkne ho a blok zmizí.

signal unlocked

@export var block_width: float = 16.0
@export var block_height: float = 32.0

var is_unlocked: bool = false
var is_unlocking: bool = false
var glow_time: float = 0.0

@onready var collision_shape = $CollisionShape2D
@onready var trigger_zone = $TriggerZone

func _ready():
	add_to_group("key_blocks")
	if trigger_zone:
		trigger_zone.body_entered.connect(_on_trigger_body_entered)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.size = Vector2(block_width, block_height)

func _process(delta):
	if is_unlocked:
		return
	glow_time += delta
	queue_redraw()

func _on_trigger_body_entered(body):
	if is_unlocked or is_unlocking:
		return
	if body.is_in_group("player"):
		_check_for_key(body)

func _check_for_key(player: CharacterBody2D):
	var keys = get_tree().get_nodes_in_group("celeste_keys")
	for key in keys:
		if is_instance_valid(key) and key.state == 1 and key.target_player == player: # State.FOLLOWING = 1
			is_unlocking = true
			var hole_pos = global_position
			key.start_unlock(hole_pos, Callable(self, "_on_key_unlocked"))
			break

func _on_key_unlocked():
	is_unlocked = true
	is_unlocking = false
	if collision_shape:
		collision_shape.disabled = true
	unlocked.emit()
	_play_unlock_fx()

func _play_unlock_fx():
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12)
	tw.tween_property(self, "modulate", Color(1.8, 1.5, 0.8, 0.0), 0.35)
	tw.chain().tween_callback(queue_free)

func _draw():
	if is_unlocked:
		return
		
	var half_w = block_width * 0.5
	var half_h = block_height * 0.5
	var rect = Rect2(-half_w, -half_h, block_width, block_height)
	
	# 1. Tělo ocelového bloku
	draw_rect(rect, Color(0.16, 0.14, 0.22, 1.0))
	draw_rect(Rect2(-half_w + 1, -half_h + 1, block_width - 2, block_height - 2), Color(0.24, 0.21, 0.32, 1.0))
	
	# 2. Mosazné kování a nýty
	var brass_col = Color(0.85, 0.65, 0.25, 1.0)
	var dark_edge = Color(0.1, 0.08, 0.14, 1.0)
	draw_rect(rect, dark_edge, false, 1.0)
	draw_rect(Rect2(-half_w + 2, -half_h + 2, block_width - 4, block_height - 4), brass_col, false, 1.0)
	
	# 3. Mosazná destička zámku uprostřed
	var lock_rect = Rect2(-5, -6, 10, 12)
	draw_rect(lock_rect, Color(0.12, 0.1, 0.16, 1.0))
	draw_rect(lock_rect, brass_col, false, 1.0)
	
	# 4. Klíčová dírka (Keyhole)
	var hole_glow = (sin(glow_time * 4.0) + 1.0) * 0.5
	if is_unlocking:
		# Silná záře při odemykání
		draw_circle(Vector2(0, -2), 6.0, Color(1.0, 0.9, 0.4, 0.6))
	else:
		draw_circle(Vector2(0, -2), 3.0, Color(1.0, 0.85, 0.3, 0.2 + hole_glow * 0.2))
		
	# Tmavá štěrbina dírky
	draw_circle(Vector2(0, -2), 2.0, Color(0.04, 0.03, 0.06, 1.0))
	# Dolní výřez dírky
	var tri_points = PackedVector2Array([
		Vector2(-1.5, -1.0),
		Vector2(1.5, -1.0),
		Vector2(2.0, 3.5),
		Vector2(-2.0, 3.5)
	])
	draw_colored_polygon(tri_points, Color(0.04, 0.03, 0.06, 1.0))
