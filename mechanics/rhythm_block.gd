@tool
class_name RhythmBlock
extends StaticBody2D

## Rytmický blok: dvě sady (A / B) se v rytmu sdílených hodin střídají pevné / duch: sada A je
## pevná v první půlce cyklu `period`, sada B ve druhé. 0.4 s před přepnutím bloky blikají.
## Blok nezpevní, dokud v něm hráč je (jako kazetové bloky v Celeste). Počátek = levý horní roh.

const TILE := 16.0

@export var size: Vector2i = Vector2i(2, 1):
	set(val):
		size = val
		queue_redraw()
@export var set_b: bool = false:
	set(val):
		set_b = val
		queue_redraw()
@export var period: float = 2.0
@export var offset: float = 0.0
@export var warn_time: float = 0.4

var col: CollisionShape2D = null
var overlap: Area2D = null
var solid: bool = true
var warning: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	collision_layer = 1
	var px := Vector2(size) * TILE
	col = CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = px
	col.position = px / 2.0
	add_child(col)
	overlap = Area2D.new()
	overlap.collision_layer = 0
	overlap.collision_mask = 1
	var oc := CollisionShape2D.new()
	oc.shape = RectangleShape2D.new()
	oc.shape.size = px - Vector2(2, 2)
	oc.position = px / 2.0
	overlap.add_child(oc)
	add_child(overlap)

func _physics_process(_delta):
	if Engine.is_editor_hint():
		return
	var half := period / 2.0
	var p := BeatClock.phase(period, offset)
	var should_be_solid := (p < half) != set_b
	warning = fmod(p, half) > half - warn_time
	if should_be_solid and not solid and HazardKill.player_in(overlap):
		should_be_solid = false # počká, až hráč odejde
	if should_be_solid != solid:
		solid = should_be_solid
		col.disabled = not solid
	queue_redraw()

func _draw():
	var px := Vector2(size) * TILE
	var base := Color(0.25, 0.9, 0.75) if set_b else Color(0.85, 0.65, 0.28)
	var blink := warning and fmod(BeatClock.time if not Engine.is_editor_hint() else 0.0, 0.1) < 0.05
	if solid or Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, px), base.darkened(0.45 if blink else 0.25))
		draw_rect(Rect2(Vector2.ZERO, px), base, false, 1.0)
	else:
		# Duch: čárkovaný obrys; před zpevněním bliká
		var c := Color(base.r, base.g, base.b, 0.8 if blink else 0.35)
		for x in range(0, int(px.x), 4):
			draw_line(Vector2(x, 0), Vector2(x + 2, 0), c, 1.0)
			draw_line(Vector2(x, px.y - 1), Vector2(x + 2, px.y - 1), c, 1.0)
		for y in range(0, int(px.y), 4):
			draw_line(Vector2(0, y), Vector2(0, y + 2), c, 1.0)
			draw_line(Vector2(px.x - 1, y), Vector2(px.x - 1, y + 2), c, 1.0)
