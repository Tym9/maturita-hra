@tool
class_name DampenerField
extends Node2D

## Tlumicí pole korporace: uvnitř obdélníku `size` hráč nemůže použít vybrané schopnosti
## (dash, hák, dvojskok, lezení). Šedofialový závoj s přeškrtnutými ikonami; když je hráč uvnitř,
## závoj zhoustne. Vstup do pole s blokovaným hákem hák pustí. Počátek = levý horní roh.

@export var size: Vector2 = Vector2(96, 96):
	set(val):
		size = val
		queue_redraw()
@export var block_dash: bool = true
@export var block_grapple: bool = true
@export var block_double_jump: bool = false
@export var block_climb: bool = false

var area: Area2D = null
var blocked_player: Node = null
var anim: float = 0.0

func _ready():
	if Engine.is_editor_hint():
		return
	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	col.position = size / 2.0
	area.add_child(col)
	add_child(area)

func _physics_process(delta):
	anim += delta
	queue_redraw()
	if Engine.is_editor_hint():
		return
	var player = HazardKill.player_in(area)
	if player == blocked_player:
		return
	_release()
	if player:
		player.set_abilities_blocked(self, abilities())
		if block_grapple and player.is_grappling:
			player.release_grapple()
		blocked_player = player

func abilities() -> Array:
	var list := []
	if block_dash:
		list.append(&"dash")
	if block_grapple:
		list.append(&"grapple")
	if block_double_jump:
		list.append(&"double_jump")
	if block_climb:
		list.append(&"climb")
	return list

func _release():
	if is_instance_valid(blocked_player):
		blocked_player.set_abilities_blocked(self, [])
	blocked_player = null

func _notification(what):
	# Vypnutá místnost (neaktivní soused) ani odstraněné pole nesmí hráče blokovat dál
	if what == NOTIFICATION_DISABLED or what == NOTIFICATION_EXIT_TREE:
		_release()

func _draw():
	var inside := blocked_player != null
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.45, 0.4, 0.55, 0.28 if inside else 0.16))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.6, 0.5, 0.75, 0.7), false, 1.0)
	# Vodorovné "rušení" plující polem
	for i in int(size.y / 12.0):
		var y := fmod(i * 12.0 + anim * 10.0, size.y)
		draw_line(Vector2(2, y), Vector2(size.x - 2, y), Color(0.7, 0.65, 0.8, 0.12), 1.0)
	# Přeškrtnuté ikony potlačených schopností v rohu
	var x := 6.0
	for ability in abilities():
		var c := Vector2(x, 8)
		draw_circle(c, 4.5, Color(0.2, 0.18, 0.25, 0.8))
		draw_string(ThemeDB.fallback_font, c + Vector2(-2.5, 3), {&"dash": "D", &"grapple": "H", &"double_jump": "2", &"climb": "L"}[ability], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.85, 0.8, 0.9))
		draw_line(c + Vector2(-4, 4), c + Vector2(4, -4), Color(1.0, 0.35, 0.3), 1.0)
		x += 11.0
