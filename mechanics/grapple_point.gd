extends Node2D

# Kotva pro přitahovací hák. Hráč se k ní může přitáhnout klávesou E (hák),
# pokud je v dosahu a nic nestojí v cestě.

var highlighted: bool = false
var time: float = 0.0

func _ready():
	add_to_group("grapple_points")

func set_highlight(value: bool):
	highlighted = value
	queue_redraw()

func _process(delta):
	time += delta
	if highlighted:
		queue_redraw()

func _draw():
	var bronze = Color(0.8, 0.55, 0.2)
	var radius = 6.0
	if highlighted:
		bronze = Color(1.0, 0.85, 0.4)
		radius = 7.0 + sin(time * 8.0)
		draw_arc(Vector2.ZERO, radius + 4.0, 0.0, TAU, 24, Color(1.0, 0.9, 0.5, 0.6), 1.0)
	draw_circle(Vector2.ZERO, radius, Color(0.25, 0.15, 0.08))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, bronze, 2.0)
	# Ozubené "ozubené kolo" - čtyři zuby
	for i in 4:
		var angle = i * PI / 2.0 + time * 0.5
		draw_line(Vector2.RIGHT.rotated(angle) * radius, Vector2.RIGHT.rotated(angle) * (radius + 2.5), bronze, 2.0)
