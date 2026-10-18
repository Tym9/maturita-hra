class_name CaveCrawler
extends Node2D

## Jeskynní lezec: leze po povrchu (podlaha, stěny, strop), ve vnitřním rohu vyleze na stěnu,
## na vnější hraně ji obtočí; směr drží (`clockwise`). Cvakající nohy a žhnoucí oči (zjasní,
## když je hráč blízko). Dotyk zraní; skočit na něj jde jen z jeho vnější strany vůči gravitaci
## hráče - lezce na stropě zašlápne hráč s obrácenou gravitací. Počátek = střed těla,
## `surface_normal` = směr od povrchu, na kterém začíná.

enum State { CRAWL, DEAD }

const HALF_LEN := 6.0
const HALF_H := 4.0

@export var speed: float = 30.0
@export var surface_normal: Vector2 = Vector2.UP
@export var clockwise: bool = true
@export var max_health: int = 1

var state: State = State.CRAWL
var up: Vector2 = Vector2.UP
var forward: Vector2 = Vector2.RIGHT
var health: int = 1
var anim: float = 0.0
var hit_area: Area2D = null

func _ready():
	add_to_group("enemies")
	health = max_health
	up = surface_normal.normalized()
	forward = up.rotated(PI / 2.0 if clockwise else -PI / 2.0)
	hit_area = Area2D.new()
	hit_area.collision_layer = 2 # vrstva nepřátel: hák ho zasáhne
	hit_area.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = Vector2(HALF_LEN * 2.0, HALF_H * 2.0)
	hit_area.add_child(col)
	add_child(hit_area)
	_snap()
	rotation = Vector2.UP.angle_to(up)

func _physics_process(delta):
	anim += delta
	match state:
		State.CRAWL:
			_crawl(speed * delta)
			rotation = Vector2.UP.angle_to(up)
			if EnemyContact.resolve(self, hit_area, up) == EnemyContact.STOMP:
				take_hit(max_health, -up)
		State.DEAD:
			pass
	queue_redraw()

func _crawl(step: float):
	if _ray(global_position, forward * (HALF_LEN + step + 1.0)):
		# Vnitřní roh: stěna před sebou → vylézt na ni
		var old_up := up
		up = -forward
		forward = old_up
		_snap()
		return
	global_position += forward * step
	if _ray(global_position, -up * (HALF_H + 3.0)).is_empty():
		# Vnější roh: povrch skončil → obtočit hranu na boční stěnu
		var old_up := up
		var old_forward := forward
		up = old_forward
		forward = -old_up
		global_position += old_forward * HALF_H - old_up * 2.0 * HALF_H
	_snap()

## Přichytí tělo k povrchu pod sebou (ve směru -up).
func _snap():
	var hit := _ray(global_position, -up * (HALF_H + 6.0))
	if not hit.is_empty():
		global_position = hit.position + up * HALF_H

func _ray(from: Vector2, vec: Vector2) -> Dictionary:
	var exclude: Array[RID] = []
	for p in get_tree().get_nodes_in_group("player"):
		exclude.append(p.get_rid())
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from, from + vec, 1, exclude))

func take_hit(damage: int = 1, _direction: Vector2 = Vector2.ZERO):
	if state == State.DEAD:
		return
	health -= damage
	modulate = Color(3.0, 0.5, 0.4)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	if health <= 0:
		state = State.DEAD
		Global.kill_count += 1
		hit_area.set_deferred("collision_layer", 0)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)

func _draw():
	# Místní souřadnice: povrch je pod tělem (+y), dopředu je ±x podle směru lezení
	var front := 1.0 if clockwise else -1.0
	for i in 3:
		var lx := -4.0 + i * 4.0
		var lift := 1.5 if int(anim * 12.0 + i) % 2 == 0 else 0.0 # cvakání nohou
		draw_line(Vector2(lx, 2), Vector2(lx - 1.5 * front, HALF_H - lift), Color(0.3, 0.2, 0.18), 1.0)
	draw_rect(Rect2(-HALF_LEN, -HALF_H, HALF_LEN * 2.0, HALF_H * 1.6), Color(0.35, 0.22, 0.2))
	draw_rect(Rect2(-HALF_LEN, -HALF_H, HALF_LEN * 2.0, HALF_H * 1.6), Color(0.15, 0.08, 0.06), false, 1.0)
	var player = get_tree().get_first_node_in_group("player") if is_inside_tree() else null
	var near: bool = player != null and global_position.distance_to(player.global_position) < 48.0
	var eye := Color(1.0, 0.35, 0.15) if near else Color(0.8, 0.45, 0.2)
	draw_circle(Vector2(4.0 * front, -2.0), 1.5 if near else 1.0, eye)
	draw_circle(Vector2(2.0 * front, -2.0), 1.5 if near else 1.0, eye)
