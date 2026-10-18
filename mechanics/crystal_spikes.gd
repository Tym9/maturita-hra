@tool
class_name CrystalSpikes
extends Node2D

## Nestabilní krystalové bodce: když se hráč přiblíží (pás `reach`+1 dlaždic před nimi, o dlaždici
## širší na každou stranu), prasklina 0.4 s rudě žhne a pak z povrchu vyrazí bodce o `reach` dlaždic.
## Po `out_time` se zatáhnou a `cooldown` s nereagují - okno pro průchod („vylákej, pak projdi“).
## Počátek = střed základny na povrchu, `direction` = kam bodce míří. Obnoví se při room_reset
## (skupina "room_reset": kamera je po smrti v místnosti postaví znovu ze scény).

const TILE := 16.0
const HITBOX_MARGIN := 3.0
const BURST_TIME := 0.08
const RETRACT_TIME := 0.25

enum State { IDLE, WARN, OUT, RETRACT, COOLDOWN }

## Šířka v dlaždicích
@export var count: int = 2:
	set(val):
		count = maxi(1, val)
		queue_redraw()
## Délka vyražených bodců v dlaždicích
@export var reach: int = 2:
	set(val):
		reach = maxi(1, val)
		queue_redraw()
@export var direction: Vector2 = Vector2.UP:
	set(val):
		direction = val
		queue_redraw()
@export var warn_time: float = 0.4
@export var out_time: float = 2.0
@export var cooldown: float = 1.0

var state: State = State.IDLE
var timer: float = 0.0
var extension: float = 0.0
var trigger: Area2D = null
var kill_area: Area2D = null
var kill_col: CollisionShape2D = null

func _ready():
	if Engine.is_editor_hint():
		return
	add_to_group("room_reset")
	var rot := Vector2.UP.angle_to(direction)
	trigger = Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 1
	trigger.rotation = rot
	var trigger_col := CollisionShape2D.new()
	trigger_col.shape = RectangleShape2D.new()
	trigger_col.shape.size = Vector2((count + 2) * TILE, (reach + 1) * TILE)
	trigger_col.position = Vector2(0.0, -(reach + 1) * TILE / 2.0)
	trigger.add_child(trigger_col)
	add_child(trigger)
	kill_area = Area2D.new()
	kill_area.collision_layer = 0
	kill_area.collision_mask = 1
	kill_area.rotation = rot
	kill_col = CollisionShape2D.new()
	kill_col.shape = RectangleShape2D.new()
	kill_area.add_child(kill_col)
	add_child(kill_area)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	match state:
		State.IDLE:
			if HazardKill.player_in(trigger):
				state = State.WARN
				timer = warn_time
		State.WARN:
			timer -= delta
			if timer <= 0.0:
				state = State.OUT
				timer = out_time
		State.OUT:
			extension = minf(1.0, extension + delta / BURST_TIME)
			timer -= delta
			if timer <= 0.0:
				state = State.RETRACT
		State.RETRACT:
			extension = maxf(0.0, extension - delta / RETRACT_TIME)
			if extension <= 0.0:
				state = State.COOLDOWN
				timer = cooldown
		State.COOLDOWN:
			timer -= delta
			if timer <= 0.0:
				state = State.IDLE
	if extension > 0.0:
		# Smrtící oblast = vyražené bodce, užší a kratší o pár px než grafika
		var length := extension * reach * TILE
		kill_col.shape.size = Vector2(count * TILE - 2.0 * HITBOX_MARGIN, maxf(1.0, length - HITBOX_MARGIN))
		kill_col.position = Vector2(0.0, -(length - HITBOX_MARGIN) / 2.0)
		HazardKill.check(kill_area)
	queue_redraw()

func _draw():
	draw_set_transform(Vector2.ZERO, Vector2.UP.angle_to(direction))
	var hw := count * TILE / 2.0
	if Engine.is_editor_hint():
		draw_rect(Rect2(-hw, -reach * TILE, count * TILE, reach * TILE), Color(1.0, 0.3, 0.3, 0.15))
	# Krystalové bodce: rudooranžové (smrtící), po dvou na dlaždici
	var height := extension * reach * TILE
	if height > 0.5:
		for i in count * 2:
			var x0 := -hw + i * TILE / 2.0
			var tip := Vector2(x0 + TILE / 4.0, -height * (0.85 if i % 2 else 1.0))
			draw_colored_polygon(PackedVector2Array([Vector2(x0, 0), tip, Vector2(x0 + TILE / 2.0, 0)]), Color(1.0, 0.3, 0.25, 0.85))
			draw_line(Vector2(x0 + 2.0, -1.0), tip, Color(1.0, 0.85, 0.8, 0.8), 1.0)
	# Základna s prasklinou; 0.4 s před výpadem praskliny rudě blikají (telegraf)
	draw_rect(Rect2(-hw, -2.0, count * TILE, 3.0), Color(0.35, 0.25, 0.4))
	var glowing := state == State.WARN and fmod(timer, 0.1) < 0.06
	var crack := Color(1.0, 0.2, 0.15) if glowing or state == State.OUT else Color(0.6, 0.3, 0.45)
	for i in count:
		var cx := -hw + i * TILE + TILE / 2.0
		draw_line(Vector2(cx - 5.0, -1.0), Vector2(cx, -3.0), crack, 1.0)
		draw_line(Vector2(cx, -3.0), Vector2(cx + 4.0, -1.0), crack, 1.0)
