@tool
class_name AnomalyWall
extends StaticBody2D

## Anomální zeď (dream block z Celeste): normálně pevná, ale kdo do ní dashne, proletí jí rovně
## rychlostí `glide_speed` ve směru dashe (bez gravitace a ovládání) a na druhé straně dostane
## dash zpět. Když průlet něco zastaví (zablokovaný výstup), hráč zemře. Tyrkysová hvězdná pole;
## když má hráč dash, zeď jasněji září (dá se vstoupit). Počátek = levý horní roh.

const ENTRY_MARGIN := 10.0 # dash urazí ~7 px za snímek - průlet začne dřív, než o zeď zastaví

@export var size: Vector2 = Vector2(64, 64):
	set(val):
		size = val
		queue_redraw()
@export var glide_speed: float = 300.0

var entry_area: Area2D = null
var inner_area: Area2D = null
var glider: CharacterBody2D = null
var entered: bool = false
var glide_frames: int = 0
var anim: float = 0.0
var bright: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	collision_layer = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	col.position = size / 2.0
	add_child(col)
	entry_area = _area(size + Vector2.ONE * 2.0 * ENTRY_MARGIN)
	inner_area = _area(size)

func _area(area_size: Vector2) -> Area2D:
	var a := Area2D.new()
	a.collision_layer = 0
	a.collision_mask = 1
	var c := CollisionShape2D.new()
	c.shape = RectangleShape2D.new()
	c.shape.size = area_size
	c.position = size / 2.0
	a.add_child(c)
	add_child(a)
	return a

func _physics_process(delta):
	anim += delta
	queue_redraw()
	if Engine.is_editor_hint():
		return
	if glider:
		if not is_instance_valid(glider) or not glider.is_gliding or glider.is_dying:
			glider = null
			return
		var inside := HazardKill.player_in(inner_area) != null
		entered = entered or inside
		glide_frames += 1
		# Zablokovaný průlet (narazil na pevnou překážku) = smrt
		if glide_frames > 1 and glider.get_real_velocity().length() < glide_speed * 0.5:
			glider.die()
			glider = null
		elif (entered and not inside) or glide_frames > 120:
			glider.end_glide()
			glider = null
		return
	var player = HazardKill.player_in(entry_area)
	bright = player != null and player.can_dash
	if player and player.is_dashing and player.velocity != Vector2.ZERO:
		# Jen dash mířící do zdi (bod kousek před hráčem leží uvnitř), ne klouzání podél ní
		var ahead: Vector2 = player.global_position + player.velocity.normalized() * 16.0
		if Rect2(global_position, size).has_point(ahead):
			glider = player
			entered = false
			glide_frames = 0
			player.start_glide(player.velocity.normalized() * glide_speed, self)

func _draw():
	var glow := 1.0 if bright or glider else 0.6
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.18, 0.2, 0.92))
	# Hvězdy pomalu plují; poloha je pseudonáhodná, ale stálá
	for i in int(size.x * size.y / 120.0):
		var sx := fmod(i * 37.3 + anim * (4.0 + i % 3), size.x)
		var sy := fmod(i * 23.7 + i * i * 0.31, size.y)
		draw_rect(Rect2(sx, sy, 1, 1), Color(0.4, 1.0, 0.9, glow * (0.4 + 0.6 * float(i % 2))))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.95, 0.85, glow), false, 1.0)
