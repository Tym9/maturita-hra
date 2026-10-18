extends Control

## UI komponenta pro počítadlo sebraných krystalů v HUDu
## Jako v Celeste je schované za levým okrajem a vyjede jen při sebrání krystalu.

var collected: int = 0
var total: int = 5
var pulse_timer: float = 0.0
var shown_x: float = 0.0
var initialized: bool = false
var slide_tween: Tween = null

@onready var label = $Label

func _ready():
	shown_x = position.x
	position.x = -size.x - 20.0

func set_crystals(count: int, max_count: int):
	if count > collected and initialized:
		pulse_timer = 0.4
		_slide_in()
	initialized = true
	collected = count
	total = max_count
	if label:
		label.text = "%d/%d" % [collected, total]
	queue_redraw()

func _slide_in():
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	slide_tween.tween_property(self, "position:x", shown_x, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	slide_tween.tween_interval(2.0)
	slide_tween.tween_property(self, "position:x", -size.x - 20.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _process(delta):
	if pulse_timer > 0.0:
		pulse_timer -= delta
		queue_redraw()

func _draw():
	# Kreslíme zářící diamantovou ikonu krystalu v HUDu
	var scale_mult = 1.0 + (sin(pulse_timer * 12.0) * 0.35 if pulse_timer > 0.0 else 0.0)
	var r = 3.5 * scale_mult
	var center = Vector2(6.0, 6.0)
	var col = Color(0.25, 0.92, 1.0, 1.0)
	if pulse_timer > 0.0:
		col = Color(0.7, 1.0, 1.0, 1.0)
	
	var p_top = center + Vector2(0.0, -r * 1.35)
	var p_bottom = center + Vector2(0.0, r * 1.35)
	var p_left = center + Vector2(-r, 0.0)
	var p_right = center + Vector2(r, 0.0)
	
	# Fazety
	draw_colored_polygon(PackedVector2Array([p_top, p_left, p_bottom]), col.darkened(0.3))
	draw_colored_polygon(PackedVector2Array([p_top, p_right, p_bottom]), col)
	draw_polyline(PackedVector2Array([p_top, p_left, p_bottom, p_right, p_top]), Color(0.06, 0.12, 0.22, 0.95), 1.0)
	draw_circle(center + Vector2(-0.8, -0.8), 0.8, Color.WHITE)
