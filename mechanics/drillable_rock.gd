@tool
class_name DrillableRock
extends StaticBody2D

## Vrtatelná skála: pevný popraskaný blok, který hráč provrtá vrtákem (nástroj "drill" ve slotu, viz
## player.start_drill) - po 2 s vrtání se rozpadne. Bez vrtáku je to obyčejná zeď.
## Počátek = levý horní roh, `size` v dlaždicích. Obnoví se při room_reset (skupina "room_reset").

const TILE := 16.0

@export var size: Vector2i = Vector2i(1, 3):
	set(val):
		size = val
		queue_redraw()

var col: CollisionShape2D = null
var broken: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	add_to_group("room_reset")
	collision_layer = 1
	var px := Vector2(size) * TILE
	col = CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = px
	col.position = px / 2.0
	add_child(col)

func shatter():
	if broken:
		return
	broken = true
	col.disabled = true
	var debris := CPUParticles2D.new()
	debris.one_shot = true
	debris.explosiveness = 1.0
	debris.amount = 10 * size.x * size.y
	debris.lifetime = 0.6
	debris.spread = 180.0
	debris.gravity = Vector2(0, 400)
	debris.initial_velocity_min = 40.0
	debris.initial_velocity_max = 110.0
	debris.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	debris.emission_rect_extents = Vector2(size) * TILE / 2.0
	debris.position = Vector2(size) * TILE / 2.0
	debris.color = Color(0.35, 0.3, 0.32)
	add_child(debris)
	debris.emitting = true
	queue_redraw()

func _draw():
	if broken:
		return
	var px := Vector2(size) * TILE
	draw_rect(Rect2(Vector2.ZERO, px), Color(0.22, 0.2, 0.24))
	draw_rect(Rect2(Vector2.ZERO, px), Color(0.12, 0.1, 0.12), false, 1.0)
	# Praskliny po dlaždicích = čitelný signál "tohle jde prorazit"
	for x in size.x:
		for y in size.y:
			var o := Vector2(x, y) * TILE
			draw_line(o + Vector2(3, 4), o + Vector2(8, 8), Color(0.5, 0.45, 0.42), 1.0)
			draw_line(o + Vector2(8, 8), o + Vector2(6, 13), Color(0.5, 0.45, 0.42), 1.0)
			draw_line(o + Vector2(8, 8), o + Vector2(13, 6), Color(0.5, 0.45, 0.42), 1.0)
