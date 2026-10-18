@tool
class_name BellowsWind
extends Node2D

## Měchy: proud vzduchu v obdélníku `size` posouvá hráče ve směru `direction` o `strength` px/s
## (posun, ne rychlost - ovládání zůstává, player.apply_wind). `period` > 0 = nárazy podle sdílených
## hodin: 0.4 s předem se měch nafukuje (telegraf), pak fouká `on_time` s. Počátek = levý horní roh.

@export var size: Vector2 = Vector2(96, 64):
	set(val):
		size = val
		queue_redraw()
@export var direction: Vector2 = Vector2.RIGHT:
	set(val):
		direction = val
		queue_redraw()
@export var strength: float = 90.0
## 0 = fouká pořád
@export var period: float = 0.0
@export var on_time: float = 1.5
@export var offset: float = 0.0
@export var warn_time: float = 0.4

var area: Area2D = null
var blowing: bool = true
var warning: bool = false
var anim: float = 0.0

func _ready():
	if Engine.is_editor_hint():
		return
	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	col.position = size / 2.0
	area.add_child(col)
	add_child(area)

func _physics_process(delta):
	anim += delta
	queue_redraw()
	if Engine.is_editor_hint():
		return
	if period > 0.0:
		var p := BeatClock.phase(period, offset)
		warning = p < warn_time
		blowing = p >= warn_time and p < warn_time + on_time
	if blowing:
		var player = HazardKill.player_in(area)
		if player:
			player.apply_wind(direction.normalized() * strength)

func _draw():
	var dir := direction.normalized()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.8, 0.85, 0.9, 0.06))
	# Proudnice plují po větru; mimo foukání jen slabě
	if blowing or Engine.is_editor_hint():
		for i in int(size.x * size.y / 400.0) + 2:
			var t := fmod(anim * strength / 60.0 + i * 0.37, 1.0)
			var base := Vector2(fmod(i * 41.0, size.x), fmod(i * 29.0, size.y))
			var p := base + dir * t * 40.0
			p = Vector2(fposmod(p.x, size.x), fposmod(p.y, size.y))
			draw_line(p, p + dir * 8.0, Color(0.9, 0.95, 1.0, 0.5 * (1.0 - t)), 1.0)
	# Mosazný měch na návětrné straně; při telegrafu se nafukuje
	var mouth := size / 2.0 - dir * (size / 2.0).length() * 0.9
	mouth = Vector2(clampf(mouth.x, 0.0, size.x), clampf(mouth.y, 0.0, size.y))
	var puff := 1.0 + (0.5 * sin(anim * 30.0) + 0.5 if warning else 0.0)
	draw_circle(mouth, 5.0 * puff, Color(0.55, 0.4, 0.2))
	draw_arc(mouth, 5.0 * puff, 0.0, TAU, 12, Color(0.85, 0.65, 0.28), 1.0)
