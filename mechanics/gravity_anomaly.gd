extends Area2D

# Energetická (gravitační) anomálie.
# TOGGLE       - při vstupu prohodí gravitaci (nahoru <-> dolů)
# WHILE_INSIDE - gravitace je obrácená jen dokud je hráč uvnitř anomálie

enum Mode { TOGGLE, WHILE_INSIDE }

@export var mode: Mode = Mode.TOGGLE

var cooldown: float = 0.0
var time: float = 0.0

func _ready():
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
	var pulse = 1.0 + sin(time * 4.0) * 0.12
	draw_circle(Vector2.ZERO, 16.0 * pulse, Color(0.5, 0.2, 0.9, 0.25))
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.7, 0.4, 1.0, 0.5))
	draw_arc(Vector2.ZERO, 16.0 * pulse, 0.0, TAU, 32, Color(0.85, 0.6, 1.0, 0.9), 1.5)
	# Šipky naznačující změnu směru gravitace
	draw_line(Vector2(-4, 4), Vector2(0, -4), Color(1, 1, 1, 0.9), 1.5)
	draw_line(Vector2(0, -4), Vector2(4, 4), Color(1, 1, 1, 0.9), 1.5)
