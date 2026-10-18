@tool
class_name DashShard
extends Node2D

## Krystal dashe: dotyk obnoví hráči dash (jen když ho nemá, jinak se nespotřebuje).
## Pak pohasne a za `regrow_time` doroste; posledních 0.4 s se rozsvěcuje (telegraf návratu).
## room_reset ho obnoví hned.

const WARN_TIME := 0.4

@export var regrow_time: float = 2.5

var area: Area2D = null
var used: bool = false
var timer: float = 0.0
var anim: float = 0.0

func _ready():
	if Engine.is_editor_hint():
		return
	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = 9.0 # pomocný prvek: o kousek větší než grafika
	area.add_child(col)
	add_child(area)
	Global.room_reset.connect(func():
		used = false)

func _physics_process(delta):
	anim += delta
	queue_redraw()
	if Engine.is_editor_hint():
		return
	if used:
		timer -= delta
		if timer <= 0.0:
			used = false
	else:
		var player = HazardKill.player_in(area)
		if player and player.refill_dash():
			used = true
			timer = regrow_time

func _draw():
	var bob := sin(anim * 3.0) * 1.5
	var col := Color(0.25, 0.95, 0.8)
	if used:
		# Pohaslý obrys; před návratem se rozsvěcuje
		var a := 0.25 + (0.6 * (1.0 - timer / WARN_TIME) if timer < WARN_TIME else 0.0)
		col = Color(col.r, col.g, col.b, a)
	else:
		draw_circle(Vector2(0, bob), 9.0, Color(0.25, 0.95, 0.8, 0.18))
	var pts := PackedVector2Array([Vector2(0, -7 + bob), Vector2(5, bob), Vector2(0, 7 + bob), Vector2(-5, bob), Vector2(0, -7 + bob)])
	if used:
		draw_polyline(pts, col, 1.0)
	else:
		draw_colored_polygon(pts, col)
		draw_line(Vector2(0, -5 + bob), Vector2(-2, bob), Color.WHITE, 1.0)
