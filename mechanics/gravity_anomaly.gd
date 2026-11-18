extends Area2D

# Energetická (gravitační) anomálie.
# TOGGLE       - při vstupu prohodí gravitaci (nahoru <-> dolů)
# WHILE_INSIDE - gravitace je obrácená jen dokud je hráč uvnitř anomálie

enum Mode { TOGGLE, WHILE_INSIDE }

@export var mode: Mode = Mode.TOGGLE
## Gravitační pole (c7): size > 0 = obdélník od levého horního rohu, gravitace obrácená jen uvnitř
@export var size: Vector2 = Vector2.ZERO

var cooldown: float = 0.0
var time: float = 0.0

func _ready():
	if size != Vector2.ZERO:
		mode = Mode.WHILE_INSIDE
		var shape := RectangleShape2D.new()
		shape.size = size
		$CollisionShape2D.shape = shape
		$CollisionShape2D.position = size / 2.0
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	time += delta
	if cooldown > 0.0:
		cooldown -= delta
	queue_redraw()

func _on_body_entered(body):
	if body.name != "Player" or not body.has_method("set_gravity_dir"):
		return
	match mode:
		Mode.TOGGLE:
			if cooldown <= 0.0:
				body.set_gravity_dir(-body.gravity_dir)
				cooldown = 0.6
		Mode.WHILE_INSIDE:
			body.set_gravity_dir(-1.0)

func _on_body_exited(body):
	if body.name != "Player" or not body.has_method("set_gravity_dir"):
		return
	if mode == Mode.WHILE_INSIDE:
		body.set_gravity_dir(1.0)

func _draw():
	if size != Vector2.ZERO: # pole: fialový závoj, tyrkysové jiskry stoupají (směr gravitace uvnitř)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.5, 0.25, 0.9, 0.14 + sin(time * 3.0) * 0.03))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.75, 0.5, 1.0, 0.7), false, 1.0)
		for i in int(size.x * size.y / 260.0):
			var x := fmod(i * 37.3, size.x)
			var y := size.y - fmod(i * 23.7 + time * (18.0 + (i % 3) * 9.0), size.y)
			draw_line(Vector2(x, y), Vector2(x, maxf(y - 4.0, 0.0)), Color(0.4, 1.0, 0.9, 0.55), 1.0)
		return
	var pulse = 1.0 + sin(time * 4.0) * 0.12
	draw_circle(Vector2.ZERO, 16.0 * pulse, Color(0.5, 0.2, 0.9, 0.25))
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.7, 0.4, 1.0, 0.5))
	draw_arc(Vector2.ZERO, 16.0 * pulse, 0.0, TAU, 32, Color(0.85, 0.6, 1.0, 0.9), 1.5)
	# Šipky naznačující změnu směru gravitace
	draw_line(Vector2(-4, 4), Vector2(0, -4), Color(1, 1, 1, 0.9), 1.5)
	draw_line(Vector2(0, -4), Vector2(4, 4), Color(1, 1, 1, 0.9), 1.5)
