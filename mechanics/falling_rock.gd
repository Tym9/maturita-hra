@tool
class_name FallingRock
extends Node2D

## Padající kámen: visí ve stropě; když hráč vstoupí do sloupce pod ním (`trigger_length` dlaždic),
## 0.4 s se třese a sype prach, pak padá ve směru `direction` a při dopadu se rozbije.
## Zabíjí jen během pádu. Počátek = horní střed kamene. Obnoví se při room_reset
## (skupina "room_reset": kamera ho po smrti v místnosti postaví znovu ze scény).

const TILE := 16.0
const HITBOX_MARGIN := 3.0

enum State { IDLE, SHAKING, FALLING, GONE }

@export var size: Vector2 = Vector2(16, 16):
	set(val):
		size = val
		queue_redraw()
@export var direction: Vector2 = Vector2.DOWN:
	set(val):
		direction = val
		queue_redraw()
## Délka spouštěcího sloupce pod kamenem v dlaždicích
@export var trigger_length: int = 8:
	set(val):
		trigger_length = maxi(1, val)
		queue_redraw()
@export var shake_time: float = 0.4
@export var fall_gravity: float = 900.0
@export var max_speed: float = 360.0

var state: State = State.IDLE
var timer: float = 0.0
var speed: float = 0.0
var travelled: float = 0.0
var pivot: Node2D = null
var rock: Area2D = null
var dust: CPUParticles2D = null

func _ready():
	if Engine.is_editor_hint():
		return
	add_to_group("room_reset")
	pivot = Node2D.new()
	pivot.rotation = Vector2.DOWN.angle_to(direction)
	add_child(pivot)
	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 1
	var trigger_col := CollisionShape2D.new()
	trigger_col.shape = RectangleShape2D.new()
	trigger_col.shape.size = Vector2(size.x, trigger_length * TILE)
	trigger_col.position = Vector2(0.0, size.y + trigger_length * TILE / 2.0)
	trigger.add_child(trigger_col)
	pivot.add_child(trigger)
	trigger.body_entered.connect(func(body):
		if state == State.IDLE and body.is_in_group("player"):
			state = State.SHAKING
			timer = shake_time
			dust.emitting = true)
	rock = Area2D.new()
	rock.collision_layer = 0
	rock.collision_mask = 1
	var rock_col := CollisionShape2D.new()
	rock_col.shape = RectangleShape2D.new()
	rock_col.shape.size = size - Vector2.ONE * 2.0 * HITBOX_MARGIN
	rock_col.position = Vector2(0.0, size.y / 2.0)
	rock.add_child(rock_col)
	pivot.add_child(rock)
	dust = CPUParticles2D.new()
	dust.emitting = false
	dust.amount = 8
	dust.lifetime = 0.5
	dust.direction = Vector2.DOWN
	dust.spread = 20.0
	dust.gravity = Vector2(0, 150)
	dust.initial_velocity_min = 5.0
	dust.initial_velocity_max = 20.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(size.x / 2.0, 1.0)
	dust.position = Vector2(0.0, size.y)
	dust.color = Color(0.6, 0.55, 0.5)
	pivot.add_child(dust)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	match state:
		State.SHAKING:
			timer -= delta
			if timer <= 0.0:
				state = State.FALLING
				dust.emitting = false
		State.FALLING:
			speed = minf(speed + fall_gravity * delta, max_speed)
			var step: float = speed * delta
			var bottom := pivot.to_global(Vector2(0.0, travelled + size.y))
			var hit := _world_hit(bottom, bottom + direction.normalized() * step)
			travelled += hit.distance if hit.has("distance") else step
			rock.position.y = travelled
			HazardKill.check(rock)
			if hit.has("distance") or travelled > 2000.0:
				_shatter()
	queue_redraw()

## Pevná geometrie ve směru pádu (hráče ignoruje - toho řeší smrtící oblast).
func _world_hit(from: Vector2, to: Vector2) -> Dictionary:
	var exclude: Array[RID] = []
	for p in get_tree().get_nodes_in_group("player"):
		exclude.append(p.get_rid())
	var result := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from, to, 1, exclude))
	return {"distance": from.distance_to(result.position)} if result else {}

func _shatter():
	state = State.GONE
	rock.set_deferred("monitoring", false)
	dust.amount = 14
	dust.one_shot = true
	dust.explosiveness = 1.0
	dust.direction = Vector2.UP
	dust.spread = 70.0
	dust.initial_velocity_max = 60.0
	dust.position = Vector2(0.0, travelled + size.y)
	dust.restart()

func _draw():
	draw_set_transform(Vector2.ZERO, Vector2.DOWN.angle_to(direction))
	if Engine.is_editor_hint():
		draw_rect(Rect2(-size.x / 2.0, size.y, size.x, trigger_length * TILE), Color(1.0, 0.5, 0.2, 0.12))
	if state == State.GONE:
		return
	var shake := Vector2(randf_range(-1.5, 1.5), 0.0) if state == State.SHAKING else Vector2.ZERO
	var o := Vector2(0.0, travelled) + shake
	var hw := size.x / 2.0
	var poly := PackedVector2Array([o + Vector2(-hw, 0), o + Vector2(hw, 0), o + Vector2(hw - 2, size.y * 0.7),
		o + Vector2(hw * 0.3, size.y), o + Vector2(-hw * 0.4, size.y - 1), o + Vector2(-hw + 1, size.y * 0.6)])
	draw_colored_polygon(poly, Color(0.42, 0.36, 0.33))
	draw_polyline(poly + PackedVector2Array([poly[0]]), Color(0.2, 0.15, 0.13), 1.0)
	# Žhavé praskliny: nebezpečný předmět = oranžová
	var crack := Color(1.0, 0.45, 0.15) if state != State.IDLE else Color(0.75, 0.35, 0.15)
	draw_line(o + Vector2(-hw * 0.5, size.y * 0.3), o + Vector2(0, size.y * 0.55), crack, 1.0)
	draw_line(o + Vector2(0, size.y * 0.55), o + Vector2(hw * 0.4, size.y * 0.35), crack, 1.0)
