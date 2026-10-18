@tool
class_name PressureSpring
extends Node2D

## Tlaková pružina: dotyk hráče ho vymrští ve směru `direction` a obnoví mu dash.
## Svislá pružina zachová vodorovnou rychlost, boční a šikmá chvíli nedovolí vstupu rychlost ubrat,
## takže hybnost nese do dalšího skoku (player.launch). Počátek = střed základny, `direction` = kam míří.

@export var direction: Vector2 = Vector2.UP:
	set(val):
		direction = val
		queue_redraw()
## Rychlost výstřelu v px/s (420 ≈ 5.6 dlaždice nahoru, skok je 3)
@export var strength: float = 420.0
## Jak dlouho po boční / šikmé pružině vstup neubírá vodorovnou rychlost
@export var side_lock: float = 0.2
@export var cooldown: float = 0.25

var area: Area2D = null
var compress: float = 0.0
var cool: float = 0.0

func _ready():
	if Engine.is_editor_hint():
		return
	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.rotation = Vector2.UP.angle_to(direction)
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = Vector2(14, 8)
	col.position = Vector2(0, -6)
	area.add_child(col)
	add_child(area)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	cool -= delta
	compress = maxf(0.0, compress - delta * 6.0)
	if cool <= 0.0:
		var player = HazardKill.player_in(area)
		if player and not player.is_dying:
			_launch(player)
	queue_redraw()

func _launch(player):
	var dir := direction.normalized()
	var v := dir * strength
	var lock := side_lock
	if absf(dir.y) < 0.3:
		v.y = -160.0 * player.gravity_dir # boční pružina: k tomu malý výskok proti gravitaci hráče
	elif absf(dir.x) < 0.3:
		v.x = player.velocity.x # svislá pružina zachová vodorovnou rychlost
		lock = 0.0
	player.launch(v, lock)
	player.refill_dash()
	compress = 1.0
	cool = cooldown

func _draw():
	# Mosazná pružina (pomocný prvek): základna, cívka, která se při výstřelu stlačí, horní deska
	draw_set_transform(Vector2.ZERO, Vector2.UP.angle_to(direction))
	draw_rect(Rect2(-8, -3, 16, 3), Color(0.55, 0.4, 0.2))
	var top := -4.0 - 8.0 * (1.0 - compress * 0.7)
	var pts := PackedVector2Array()
	for i in 7:
		pts.append(Vector2(-5.0 if i % 2 else 5.0, lerpf(-3.0, top, i / 6.0)))
	draw_polyline(pts, Color(0.85, 0.65, 0.28), 1.5)
	draw_rect(Rect2(-8, top - 3.0, 16, 3), Color(0.25, 0.9, 0.75))
