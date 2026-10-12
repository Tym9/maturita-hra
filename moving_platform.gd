extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(200, 0)
@export var duration: float = 2.0

var start_pos: Vector2
var tween: Tween

func _ready():
	start_pos = global_position
	start_moving()

func start_moving():
	tween = create_tween().set_loops()
	tween.tween_property(self, "global_position", start_pos + move_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
