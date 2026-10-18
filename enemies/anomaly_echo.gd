class_name AnomalyEcho
extends Node2D

## Anomální ozvěna: stín, který o `delay` s později přesně opakuje hráčovu cestu (každý fyzikální
## snímek si zapíše jeho pozici). Startuje, když hráč opustí vyznačenou startovní oblast;
## posledních 0.5 s před startem se na začátku cesty zhmotňuje (telegraf). Dotyk zabíjí, útoky jí
## projdou (take_hit nic nedělá). Když cesta opustí místnost ozvěny, ozvěna se rozplyne.
## room_reset ji vrátí do čekání (skupina "room_reset"). Počátek = levý horní roh startovní oblasti.

enum State { WAITING, RECORDING, CHASING, DONE }

const TELEGRAPH := 0.5
const HITBOX := Vector2(8, 12) # hráč je 14x18 - smrtící stín o 3 px z každé strany menší

@export var start_size: Vector2 = Vector2(48, 128)
@export var delay: float = 1.5

var state: State = State.WAITING
var armed: bool = false
var path: Array[Vector2] = []
var flips: Array[Vector2] = [] # (gravitace, otočení) hráče v daném snímku - kvůli kresbě stínu
var shadow_pos: Vector2 = Vector2.ZERO
var shadow_flip: Vector2 = Vector2.ONE
var alpha: float = 0.0
var start_area: Area2D = null
var kill_area: Area2D = null

func _ready():
	add_to_group("room_reset")
	start_area = _area(start_size)
	start_area.position = start_size / 2.0
	kill_area = _area(HITBOX)

func _area(size: Vector2) -> Area2D:
	var a := Area2D.new()
	a.collision_layer = 0
	a.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	a.add_child(col)
	add_child(a)
	return a

func _physics_process(delta):
	queue_redraw()
	var player = get_tree().get_first_node_in_group("player")
	if player == null or player.is_dying:
		return
	var delay_frames := int(round(delay * Engine.physics_ticks_per_second))
	match state:
		State.WAITING:
			var inside := HazardKill.player_in(start_area) != null
			armed = armed or inside
			if armed and not inside:
				state = State.RECORDING
				_record(player)
				shadow_pos = path[0]
		State.RECORDING, State.CHASING:
			_record(player)
			if path.size() > delay_frames:
				state = State.CHASING
				shadow_pos = path.pop_front()
				shadow_flip = flips.pop_front()
				alpha = 1.0
				kill_area.global_position = shadow_pos
				HazardKill.check(kill_area)
				var room := Room.of(self)
				if room and not room.bounds().has_point(shadow_pos):
					state = State.DONE
			else:
				# Telegraf: posledních 0.5 s před startem se stín zhmotňuje na začátku cesty
				alpha = clampf(1.0 - (delay_frames - path.size()) / (TELEGRAPH * Engine.physics_ticks_per_second), 0.0, 1.0)
		State.DONE:
			alpha = maxf(0.0, alpha - delta * 3.0)

func _record(player: Node2D):
	path.append(player.global_position)
	flips.append(Vector2(player.gravity_dir, -1.0 if player.sprite and player.sprite.flip_h else 1.0))

## Útoky stínem projdou.
func take_hit(_damage: int = 1, _direction: Vector2 = Vector2.ZERO):
	pass

func _draw():
	# Vyznačená startová oblast
	var c := Color(0.6, 0.4, 0.85, 0.35)
	for x in range(0, int(start_size.x), 6):
		draw_line(Vector2(x, 0), Vector2(x + 3, 0), c, 1.0)
		draw_line(Vector2(x, start_size.y), Vector2(x + 3, start_size.y), c, 1.0)
	for y in range(0, int(start_size.y), 6):
		draw_line(Vector2(0, y), Vector2(0, y + 3), c, 1.0)
		draw_line(Vector2(start_size.x, y), Vector2(start_size.x, y + 3), c, 1.0)
	if alpha <= 0.0:
		return
	# Stín hráče (temně fialová silueta se žhnoucím okem), otočený podle zaznamenané gravitace
	var o := to_local(shadow_pos)
	draw_rect(Rect2(o + Vector2(-7, -9), Vector2(14, 18)), Color(0.25, 0.08, 0.35, 0.8 * alpha))
	draw_rect(Rect2(o + Vector2(-7, -9), Vector2(14, 18)), Color(0.85, 0.3, 0.9, alpha), false, 1.0)
	draw_circle(o + Vector2(3.0 * shadow_flip.y, -4.0 * shadow_flip.x), 1.5, Color(1.0, 0.3, 0.3, alpha))
