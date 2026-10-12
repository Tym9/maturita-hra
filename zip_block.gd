extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(0, -400)
@export var speed_fast: float = 0.2
@export var speed_slow: float = 2.0

var start_pos: Vector2
var active: bool = false
var returning: bool = false
var tween: Tween

@onready var area = $Area2D

func _ready():
	start_pos = global_position
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not active and not returning:
		activate()

func activate():
	active = true
	if tween:
		tween.kill()
	tween = create_tween()
	# Rychlý přesun (vystřelení)
	tween.tween_property(self, "global_position", start_pos + move_offset, speed_fast).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Pauza na konci
	tween.tween_interval(0.5)
	# Callback
	tween.tween_callback(func(): returning = true; active = false)
	# Pomalý návrat
	tween.tween_property(self, "global_position", start_pos, speed_slow).set_trans(Tween.TRANS_LINEAR)
	# Hotovo
	tween.tween_callback(func(): returning = false)
