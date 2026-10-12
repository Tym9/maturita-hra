extends Node2D

# Vizuální a zásahový efekt seknutí hasákem / parního úderu na blízko.
# Vytvoří se na hráči a švihne obloukem ve směru míření myši.

var lifetime: float = 0.14
var timer: float = 0.0
var aim_angle: float = 0.0
var arc_span: float = 1.8 # cca 100 stupňů
var attack_radius: float = 38.0

func setup(direction: Vector2):
	aim_angle = direction.angle()
	rotation = aim_angle
	z_index = 15

func _process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw():
	var progress = timer / lifetime
	var alpha = 1.0 - progress
	
	# Počáteční a koncový úhel oblouku švihu podle průběhu času
	var start_a = -arc_span * 0.5 + progress * arc_span * 0.3
	var end_a = -arc_span * 0.5 + (progress + 0.4) * arc_span
	end_a = min(end_a, arc_span * 0.5)
	
	# Parní bronzovo-modrý záblesk
	var col_outer = Color(0.9, 0.75, 0.3, alpha * 0.95)
	var col_inner = Color(1.0, 1.0, 1.0, alpha)
	var col_steam = Color(0.3, 0.85, 1.0, alpha * 0.7)
	
	draw_arc(Vector2.ZERO, attack_radius, start_a, end_a, 16, col_outer, 3.5)
	draw_arc(Vector2.ZERO, attack_radius - 2.0, start_a + 0.1, end_a - 0.1, 14, col_inner, 2.0)
	draw_arc(Vector2.ZERO, attack_radius - 5.0, start_a + 0.2, end_a - 0.2, 12, col_steam, 1.5)
	
	# Jiskra na špičce švihu
	var tip = Vector2.RIGHT.rotated(end_a) * attack_radius
	draw_circle(tip, 2.5 * alpha, col_inner)
