@tool
class_name MineCart
extends AnimatableBody2D

## Důlní vozík na kolejnici (zip mover z Celeste): když na něj hráč stoupne nebo se ho dotkne,
## vozík zarachotí (rozsvítí kolejnici) a rozjede se ke konci. Hráč jede s ním; skok během jízdy
## přičte rychlost vozíku (player.set_lift_velocity). Kdo na konci jen stojí, toho náraz vymrští
## (`fling_factor`). Pak se vozík pomalu vrátí. Počátek = střed vozíku na začátku kolejnice.
## Obnoví se při room_reset (skupina "room_reset").

enum State { IDLE, RATTLE, RUN, IMPACT, RETURN }

## Konec kolejnice relativně k začátku
@export var rail_end: Vector2 = Vector2(128, 0):
	set(val):
		rail_end = val
		queue_redraw()
@export var size: Vector2 = Vector2(48, 16):
	set(val):
		size = val
		queue_redraw()
@export var max_speed: float = 360.0
@export var accel: float = 900.0
@export var return_speed: float = 60.0
@export var rattle_time: float = 0.15
@export var end_wait: float = 0.5
## Kolik rychlosti vozíku dostane hráč, který na konci jen stojí
@export var fling_factor: float = 0.6

var state: State = State.IDLE
var timer: float = 0.0
var speed: float = 0.0
var travelled: float = 0.0
var cart_velocity: Vector2 = Vector2.ZERO
var home: Vector2 = Vector2.ZERO
var last_target: Vector2 = Vector2.ZERO
var touch_area: Area2D = null

func _ready():
	home = position
	last_target = position
	if Engine.is_editor_hint():
		return
	add_to_group("room_reset")
	sync_to_physics = true
	collision_layer = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	add_child(col)
	# O 2 px větší oblast: hráč stojící nahoře nebo držící se boku
	touch_area = Area2D.new()
	touch_area.collision_layer = 0
	touch_area.collision_mask = 1
	var touch_col := CollisionShape2D.new()
	touch_col.shape = RectangleShape2D.new()
	touch_col.shape.size = size + Vector2(4, 4)
	touch_area.add_child(touch_col)
	add_child(touch_area)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	var dir := rail_end.normalized()
	var length := rail_end.length()
	match state:
		State.IDLE:
			if HazardKill.player_in(touch_area):
				state = State.RATTLE
				timer = rattle_time
		State.RATTLE:
			timer -= delta
			if timer <= 0.0:
				state = State.RUN
				speed = 0.0
		State.RUN:
			speed = minf(speed + accel * delta, max_speed)
			travelled = minf(travelled + speed * delta, length)
			if travelled >= length:
				_impact(dir)
		State.IMPACT:
			timer -= delta
			if timer <= 0.0:
				state = State.RETURN
		State.RETURN:
			travelled = maxf(travelled - return_speed * delta, 0.0)
			if travelled <= 0.0:
				state = State.IDLE
	# Rychlost z cílové pozice: se sync_to_physics se `position` posune až po fyzikálním kroku
	var target := home + dir * travelled
	cart_velocity = (target - last_target) / delta
	last_target = target
	position = target
	if state == State.RUN:
		var rider = HazardKill.player_in(touch_area)
		if rider:
			rider.set_lift_velocity(cart_velocity)
	queue_redraw()

func _impact(dir: Vector2):
	state = State.IMPACT
	timer = end_wait
	var rider = HazardKill.player_in(touch_area)
	if rider and not rider.is_dying:
		rider.launch(dir * speed * fling_factor + Vector2(0, -120.0 * rider.gravity_dir), 0.15)
	speed = 0.0

func _draw():
	# Kolejnice je statická - kreslí se od výchozí pozice vůči skutečné pozici uzlu
	var dir := rail_end.normalized()
	var start := home - position
	var lit := state != State.IDLE
	draw_line(start, start + rail_end, Color(0.55, 0.4, 0.2), 2.0)
	for i in int(rail_end.length() / 16.0) + 1:
		var p := start + dir * i * 16.0
		draw_circle(p, 1.5, Color(1.0, 0.85, 0.4) if lit else Color(0.4, 0.3, 0.2))
	var shake := Vector2(randf_range(-1.0, 1.0), 0.0) if state == State.RATTLE or state == State.IMPACT else Vector2.ZERO
	var hs := size / 2.0
	draw_rect(Rect2(-hs + shake, size), Color(0.35, 0.22, 0.12))
	draw_rect(Rect2(-hs + shake, size), Color(0.85, 0.65, 0.28), false, 1.0)
	draw_rect(Rect2(Vector2(-hs.x + 3, -hs.y - 3) + shake, Vector2(size.x - 6, 3)), Color(0.25, 0.9, 0.75)) # náklad krystalů
	for x in [-hs.x + 7, hs.x - 7]:
		draw_circle(Vector2(x, hs.y) + shake, 3.0, Color(0.2, 0.18, 0.2))
