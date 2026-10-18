@tool
class_name ConveyorBelt
extends StaticBody2D

## Pás dopravníku: kdo na něm stojí (shora i s obrácenou gravitací zespodu), toho veze rychlostí
## `speed` (constant_linear_velocity); seskok do 0.1 s přičte rychlost pásu (player.set_lift_velocity).
## Šipky na pásu ukazují směr. Počátek = levý horní roh, `width` v dlaždicích, záporná `speed` = doleva.

const TILE := 16.0

@export var width: int = 4:
	set(val):
		width = maxi(1, val)
		queue_redraw()
@export var speed: float = 60.0

var rider_area: Area2D = null
var anim: float = 0.0

func _ready():
	if Engine.is_editor_hint():
		return
	collision_layer = 1
	constant_linear_velocity = Vector2(speed, 0.0)
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = Vector2(width * TILE, TILE)
	col.position = Vector2(width * TILE, TILE) / 2.0
	add_child(col)
	rider_area = Area2D.new()
	rider_area.collision_layer = 0
	rider_area.collision_mask = 1
	var rc := CollisionShape2D.new()
	rc.shape = RectangleShape2D.new()
	rc.shape.size = Vector2(width * TILE, TILE + 4.0)
	rc.position = Vector2(width * TILE, TILE) / 2.0
	rider_area.add_child(rc)
	add_child(rider_area)

func _physics_process(delta):
	anim += delta
	queue_redraw()
	if Engine.is_editor_hint():
		return
	var rider = HazardKill.player_in(rider_area)
	if rider and rider.is_on_floor():
		rider.set_lift_velocity(constant_linear_velocity)

func _draw():
	var w := width * TILE
	draw_rect(Rect2(0, 0, w, TILE), Color(0.25, 0.22, 0.24))
	draw_rect(Rect2(0, 0, w, 3), Color(0.4, 0.36, 0.34))
	# Šipky plují ve směru pásu
	var dir := signf(speed) if speed != 0.0 else 1.0
	var step := 10.0
	var shift := fposmod(anim * speed, step)
	var x := shift
	while x < w:
		var tip := Vector2(x + 3.0 * dir, 8)
		draw_polyline(PackedVector2Array([Vector2(x - 2.0 * dir, 5), tip, Vector2(x - 2.0 * dir, 11)]), Color(0.85, 0.65, 0.28), 1.0)
		x += step
	for rx in [4.0, w - 4.0]:
		draw_circle(Vector2(rx, 8), 3.0, Color(0.55, 0.4, 0.2))
