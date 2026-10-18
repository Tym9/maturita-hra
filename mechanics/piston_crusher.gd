@tool
class_name PistonCrusher
extends Node2D

## Pístový drtič: v rytmu sdílených hodin (BeatClock) prudce vysune hlavu o `reach` dlaždic,
## chvíli ji drží a pomalu zatáhne. 0.4 s předem se těleso třese a kontrolka bliká rudě.
## Zabíjí jen vysouvající se / vysunutý píst. Počátek = střed úchytu, `direction` = směr úderu.

const TILE := 16.0
const HOUSING := 16.0
const HEAD := 12.0
const HITBOX_MARGIN := 3.0

@export var period: float = 2.0
@export var offset: float = 0.0
## Délka úderu v dlaždicích (od spodní hrany tělesa ke spodní hraně hlavy)
@export var reach: int = 4:
	set(val):
		reach = maxi(1, val)
		queue_redraw()
## Šířka v dlaždicích
@export var width: int = 2:
	set(val):
		width = maxi(1, val)
		queue_redraw()
@export var direction: Vector2 = Vector2.DOWN:
	set(val):
		direction = val
		queue_redraw()
@export var warn_time: float = 0.4
@export var slam_time: float = 0.1
@export var hold_time: float = 0.35
@export var retract_time: float = 0.6

var extension: float = 0.0
var warning: bool = false
var dangerous: bool = false
var kill_area: Area2D = null
var kill_col: CollisionShape2D = null
var dust: CPUParticles2D = null
var was_closed: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	var pivot := Node2D.new()
	pivot.rotation = Vector2.DOWN.angle_to(direction)
	add_child(pivot)
	# Pevné těleso drtiče (dá se na něm stát / odrazit)
	var housing := StaticBody2D.new()
	var housing_col := CollisionShape2D.new()
	housing_col.shape = RectangleShape2D.new()
	housing_col.shape.size = Vector2(width * TILE, HOUSING)
	housing_col.position = Vector2(0, HOUSING / 2.0)
	housing.add_child(housing_col)
	pivot.add_child(housing)
	kill_area = Area2D.new()
	kill_area.collision_layer = 0
	kill_area.collision_mask = 1
	kill_col = CollisionShape2D.new()
	kill_col.shape = RectangleShape2D.new()
	kill_area.add_child(kill_col)
	pivot.add_child(kill_area)
	dust = CPUParticles2D.new()
	dust.one_shot = true
	dust.emitting = false
	dust.explosiveness = 1.0
	dust.amount = 10
	dust.lifetime = 0.4
	dust.spread = 80.0
	dust.direction = Vector2.UP
	dust.gravity = Vector2(0, 200)
	dust.initial_velocity_min = 30.0
	dust.initial_velocity_max = 70.0
	dust.color = Color(0.6, 0.55, 0.5)
	dust.position = Vector2(0, HOUSING + reach * TILE)
	pivot.add_child(dust)

func _physics_process(_delta):
	if Engine.is_editor_hint():
		return
	var p := BeatClock.phase(period, offset)
	var t_slam := warn_time
	var t_hold := t_slam + slam_time
	var t_retract := t_hold + hold_time
	var t_idle := t_retract + retract_time
	warning = p < t_slam
	if p < t_slam:
		extension = 0.0
	elif p < t_hold:
		extension = (p - t_slam) / slam_time
	elif p < t_retract:
		extension = 1.0
	elif p < t_idle:
		extension = 1.0 - (p - t_retract) / retract_time
	else:
		extension = 0.0
	dangerous = p >= t_slam and p < t_retract

	# Smrtící oblast = celá vysunutá část pod tělesem, o pár px menší než grafika
	var length := _head_top() + HEAD - HOUSING
	kill_col.shape.size = Vector2(width * TILE - 2.0 * HITBOX_MARGIN, maxf(1.0, length - 2.0 * HITBOX_MARGIN))
	kill_col.position = Vector2(0, HOUSING + length / 2.0)
	if dangerous:
		HazardKill.check(kill_area)

	var closed := extension >= 1.0
	if closed and not was_closed:
		dust.restart()
	was_closed = closed
	queue_redraw()

func _head_top() -> float:
	return HOUSING + extension * (reach * TILE - HEAD)

func _draw():
	draw_set_transform(Vector2.ZERO, Vector2.DOWN.angle_to(direction))
	var w := width * TILE
	if Engine.is_editor_hint():
		draw_rect(Rect2(-w / 2.0, HOUSING, w, reach * TILE), Color(1.0, 0.3, 0.2, 0.15))
	# Telegraf: těleso se třese a kontrolka bliká rudě
	var shake := Vector2(randf_range(-1.0, 1.0), 0.0) if warning else Vector2.ZERO
	var head_top := _head_top()
	draw_rect(Rect2(-3.0, HOUSING, 6.0, head_top - HOUSING), Color(0.45, 0.45, 0.5))
	draw_rect(Rect2(-w / 2.0, head_top, w, HEAD), Color(0.9, 0.35, 0.15))
	for x in range(int(-w / 2.0) + 2, int(w / 2.0) - 2, 6):
		draw_rect(Rect2(x, head_top + HEAD - 3.0, 3.0, 3.0), Color(0.3, 0.08, 0.05))
	draw_rect(Rect2(Vector2(-w / 2.0, 0.0) + shake, Vector2(w, HOUSING)), Color(0.2, 0.18, 0.2))
	draw_rect(Rect2(Vector2(-w / 2.0, 0.0) + shake, Vector2(w, HOUSING)), Color(0.85, 0.65, 0.28), false, 1.0)
	var blink := warning and fmod(BeatClock.time, 0.1) < 0.05 # v editoru je warning false
	var lamp := Color(1.0, 0.15, 0.1) if blink or dangerous else Color(0.95, 0.55, 0.15)
	draw_circle(Vector2(0.0, HOUSING / 2.0) + shake, 3.0, lamp)
