@tool
class_name TeslaArc
extends Node2D

## Tesla oblouk: mezi dvěma cívkami v rytmu sdílených hodin (BeatClock) přeskakuje smrtící výboj.
## 0.4 s předem cívky zjasní a jiskří (ještě bez nebezpečí). Počátek = první cívka, druhá leží
## `length` dlaždic ve směru `direction`.

const TILE := 16.0
const BEAM_HITBOX := 4.0 # tloušťka smrtící oblasti (výboj se kreslí ~8 px)
const HITBOX_MARGIN := 3.0

@export var length: int = 4:
	set(val):
		length = maxi(1, val)
		queue_redraw()
@export var direction: Vector2 = Vector2.RIGHT:
	set(val):
		direction = val
		queue_redraw()
@export var period: float = 2.0
@export var on_time: float = 1.0
@export var offset: float = 0.0
@export var warn_time: float = 0.4

var warning: bool = false
var dangerous: bool = false
var kill_area: Area2D = null

func _ready():
	if Engine.is_editor_hint():
		return
	kill_area = Area2D.new()
	kill_area.collision_layer = 0
	kill_area.collision_mask = 1
	kill_area.rotation = Vector2.RIGHT.angle_to(direction)
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = Vector2(length * TILE - 2.0 * HITBOX_MARGIN, BEAM_HITBOX)
	col.position = Vector2(length * TILE / 2.0, 0.0)
	kill_area.add_child(col)
	add_child(kill_area)

func _physics_process(_delta):
	if Engine.is_editor_hint():
		return
	var p := BeatClock.phase(period, offset)
	warning = p < warn_time
	dangerous = p >= warn_time and p < warn_time + on_time
	if dangerous:
		HazardKill.check(kill_area)
	queue_redraw()

func _draw():
	draw_set_transform(Vector2.ZERO, Vector2.RIGHT.angle_to(direction))
	var end := Vector2(length * TILE, 0.0)
	if dangerous:
		# Klikatý výboj, každý snímek jiný
		var pts := PackedVector2Array([Vector2.ZERO])
		for i in range(1, length * 2):
			pts.append(Vector2(i * TILE / 2.0, randf_range(-4.0, 4.0)))
		pts.append(end)
		draw_polyline(pts, Color(1.0, 0.35, 0.1, 0.6), 4.0)
		draw_polyline(pts, Color(1.0, 0.9, 0.7), 1.5)
	elif warning:
		# Telegraf: krátké jiskry u cívek
		for c in [Vector2.ZERO, end]:
			for i in 3:
				var a := randf() * TAU
				draw_line(c, c + Vector2.RIGHT.rotated(a) * randf_range(3.0, 8.0), Color(1.0, 0.6, 0.2), 1.0)
	var glow := Color(1.0, 0.95, 0.8) if dangerous else (Color(1.0, 0.55, 0.15) if warning else Color(0.55, 0.4, 0.2))
	for c in [Vector2.ZERO, end]:
		draw_circle(c, 5.0, Color(0.2, 0.18, 0.2))
		draw_arc(c, 5.0, 0.0, TAU, 12, Color(0.85, 0.65, 0.28), 1.5)
		draw_circle(c, 2.5, glow)
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, end, Color(1.0, 0.35, 0.1, 0.4), 1.0)
