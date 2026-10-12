extends StaticBody2D

## Padající / drolící se plošina (CrumblingPlatform).
## Když na ni hráč dopadne, začne se 0.5 s třást, poté se zřítí (ztratí kolizi).
## Po 2.5 s se automaticky obnoví na původním místě.

@export var width: float = 32.0
@export var height: float = 10.0
@export var collapse_delay: float = 0.5
@export var respawn_delay: float = 2.5

enum State { SOLID, SHAKING, FALLEN, RESPAWNING }

var state: State = State.SOLID
var shake_timer: float = 0.0
var respawn_timer: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

@onready var collision_shape = $CollisionShape2D
@onready var step_zone = $StepZone

func _ready():
	add_to_group("platforms")
	if step_zone:
		step_zone.body_entered.connect(_on_step_zone_entered)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.size = Vector2(width, height)

func _physics_process(delta):
	match state:
		State.SOLID:
			shake_offset = Vector2.ZERO
		State.SHAKING:
			shake_timer -= delta
			# Třesení ze strany na stranu
			shake_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-0.5, 0.5))
			if shake_timer <= 0:
				_collapse()
		State.FALLEN:
			respawn_timer -= delta
			if respawn_timer <= 0:
				_respawn()
				
	queue_redraw()

func _on_step_zone_entered(body):
	if state == State.SOLID and body.is_in_group("player"):
		state = State.SHAKING
		shake_timer = collapse_delay

func _collapse():
	state = State.FALLEN
	respawn_timer = respawn_delay
	shake_offset = Vector2.ZERO
	if collision_shape:
		collision_shape.disabled = true
	if step_zone:
		step_zone.monitoring = false

func _respawn():
	state = State.SOLID
	shake_offset = Vector2.ZERO
	if collision_shape:
		collision_shape.disabled = false
	if step_zone:
		step_zone.monitoring = true
	
	# Plynulé obnovení
	modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)

func _draw():
	if state == State.FALLEN:
		return
		
	var half_w = width * 0.5
	var half_h = height * 0.5
	var rect = Rect2(-half_w + shake_offset.x, -half_h + shake_offset.y, width, height)
	
	# 1. Základní kamenné/kovové tělo
	draw_rect(rect, Color(0.28, 0.24, 0.22, 1.0))
	draw_rect(Rect2(-half_w + 1 + shake_offset.x, -half_h + 1 + shake_offset.y, width - 2, height - 2), Color(0.42, 0.36, 0.32, 1.0))
	draw_rect(rect, Color(0.14, 0.12, 0.10, 1.0), false, 1.0)
	
	# 2. Praskliny (Cracks)
	var crack_col = Color(0.85, 0.45, 0.2, 0.9) if state == State.SHAKING else Color(0.2, 0.16, 0.14, 0.8)
	var cx = shake_offset.x
	var cy = shake_offset.y
	draw_line(Vector2(-8 + cx, -half_h + 1 + cy), Vector2(-4 + cx, 2 + cy), crack_col, 1.0)
	draw_line(Vector2(-4 + cx, 2 + cy), Vector2(0 + cx, -half_h + 3 + cy), crack_col, 1.0)
	draw_line(Vector2(6 + cx, -half_h + 1 + cy), Vector2(10 + cx, 3 + cy), crack_col, 1.0)
