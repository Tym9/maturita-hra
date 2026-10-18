@tool
class_name MoltenSlag
extends Node2D

## Roztavená struska: smrtící jezírko. Počátek = střed hladiny, `size` = šířka a hloubka v px.
## Volitelně stoupá (`rise_speed` > 0): když je hráč v její místnosti, po `rise_delay` začne hladina
## stoupat až o `max_rise` px; 0.4 s předem víc bublá a vlní se (telegraf). room_reset ji vrátí dolů.
## `direction` = směr stoupání (UP; LEFT/RIGHT pro žhavou stěnu, která se valí do strany).

const HITBOX_MARGIN := 3.0

@export var size: Vector2 = Vector2(64, 32):
	set(val):
		size = val
		queue_redraw()
@export var direction: Vector2 = Vector2.UP:
	set(val):
		direction = val
		queue_redraw()
## Rychlost stoupání v px/s (0 = klidné jezírko)
@export var rise_speed: float = 0.0
@export var rise_delay: float = 1.0
@export var max_rise: float = 64.0:
	set(val):
		max_rise = val
		queue_redraw()
@export var warn_time: float = 0.4

var risen: float = 0.0
var timer: float = 0.0
var warning: bool = false
var anim: float = 0.0
var kill_area: Area2D = null
var kill_col: CollisionShape2D = null

func _ready():
	if Engine.is_editor_hint():
		return
	kill_area = Area2D.new()
	kill_area.collision_layer = 0
	kill_area.collision_mask = 1
	kill_area.rotation = Vector2.UP.angle_to(direction)
	kill_col = CollisionShape2D.new()
	kill_col.shape = RectangleShape2D.new()
	kill_area.add_child(kill_col)
	add_child(kill_area)
	Global.room_reset.connect(func():
		risen = 0.0
		timer = 0.0)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	anim += delta
	warning = false
	if rise_speed > 0.0 and _player_in_room():
		timer += delta
		warning = timer >= rise_delay - warn_time and timer < rise_delay
		if timer >= rise_delay:
			risen = minf(risen + rise_speed * delta, max_rise)
	# Smrtící oblast = celé jezírko, hladina o pár px níž a boky o pár px užší než grafika
	var top := -risen + HITBOX_MARGIN
	kill_col.shape.size = Vector2(size.x - 2.0 * HITBOX_MARGIN, size.y - top)
	kill_col.position = Vector2(0.0, (top + size.y) / 2.0)
	HazardKill.check(kill_area)
	queue_redraw()

func _player_in_room() -> bool:
	var p = get_tree().get_first_node_in_group("player")
	return p != null and p.camera != null and p.camera.current_rect().has_point(global_position)

func _draw():
	draw_set_transform(Vector2.ZERO, Vector2.UP.angle_to(direction))
	var hw := size.x / 2.0
	if Engine.is_editor_hint() and rise_speed > 0.0:
		draw_rect(Rect2(-hw, -max_rise, size.x, max_rise), Color(1.0, 0.45, 0.1, 0.15))
	var wobble := 1.5 if warning else 0.5
	var surface := -risen
	draw_rect(Rect2(-hw, surface - 6.0, size.x, 6.0), Color(1.0, 0.45, 0.1, 0.18)) # žár nad hladinou
	draw_rect(Rect2(-hw, surface, size.x, size.y + risen), Color(0.7, 0.16, 0.05))
	var wave := PackedVector2Array()
	for x in range(0, int(size.x) + 1, 4):
		wave.append(Vector2(-hw + x, surface + sin(anim * 4.0 + x * 0.4) * wobble))
	draw_polyline(wave, Color(1.0, 0.7, 0.2), 2.0)
	# Bubliny; při telegrafu víc a větší
	var bubbles := int(size.x / 12.0) * (2 if warning else 1)
	for i in bubbles:
		var cycle := fmod(anim * (1.5 if warning else 0.8) + i * 0.37, 1.0)
		var bx := -hw + fmod(i * 23.0, maxf(size.x - 4.0, 1.0)) + 2.0
		draw_circle(Vector2(bx, surface + 6.0 - cycle * 6.0), 1.0 + cycle * (2.5 if warning else 1.5), Color(1.0, 0.6, 0.15, 1.0 - cycle))
