@tool
class_name CogSaw
extends Node2D

## Ozubená pila na kolejnici: jezdí tam a zpět po bodech `rail` (nebo dokola, `loop`) podle sdílených
## hodin (BeatClock). Kolejnice je vidět celá; na každém konci pila 0.4 s stojí, roztáčí se a jiskří,
## než se rozjede zpět. Zabíjí při každém dotyku.

const HITBOX_MARGIN := 3.0

## Body kolejnice relativně k uzlu
@export var rail: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(64, 0)]):
	set(val):
		rail = val
		queue_redraw()
## true = objíždí kolejnici dokola (poslední bod se spojí s prvním), jinak tam a zpět
@export var loop: bool = false:
	set(val):
		loop = val
		queue_redraw()
## Délka jednoho celého cyklu v sekundách
@export var period: float = 3.0
@export var offset: float = 0.0
@export var radius: float = 10.0
## Stání na koncích kolejnice (varování před rozjezdem); jen u jízdy tam a zpět
@export var dwell: float = 0.4

var blade: Area2D = null
var spin: float = 0.0
var revving: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	blade = Area2D.new()
	blade.collision_layer = 0
	blade.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = radius - HITBOX_MARGIN
	blade.add_child(col)
	blade.draw.connect(_draw_blade)
	add_child(blade)
	blade.position = point_at(0.0)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	var p := BeatClock.phase(period, offset)
	var s := 0.0
	revving = false
	if loop:
		s = p / period
	else:
		var travel := maxf(0.01, (period - 2.0 * dwell) / 2.0)
		if p < travel:
			s = p / travel
		elif p < travel + dwell:
			s = 1.0
			revving = true
		elif p < 2.0 * travel + dwell:
			s = 1.0 - (p - travel - dwell) / travel
		else:
			revving = true
	blade.position = point_at(s)
	spin += delta * (30.0 if revving else 12.0)
	blade.rotation = spin
	HazardKill.check(blade)
	blade.queue_redraw()

## Bod na kolejnici v poměru délky s (0..1).
func point_at(s: float) -> Vector2:
	var pts := Array(rail)
	if loop and pts.size() > 1:
		pts.append(pts[0])
	if pts.size() < 2:
		return pts[0] if pts.size() == 1 else Vector2.ZERO
	var total := 0.0
	for i in pts.size() - 1:
		total += pts[i].distance_to(pts[i + 1])
	var left := clampf(s, 0.0, 1.0) * total
	for i in pts.size() - 1:
		var seg: float = pts[i].distance_to(pts[i + 1])
		if left <= seg or i == pts.size() - 2:
			return pts[i].lerp(pts[i + 1], clampf(left / maxf(seg, 0.001), 0.0, 1.0))
		left -= seg
	return pts[-1]

func _draw():
	# Kolejnice: mosazná dráha s jemnou září, aby byla cesta pily čitelná dopředu
	var pts := rail.duplicate()
	if loop and pts.size() > 1:
		pts.append(pts[0])
	if pts.size() > 1:
		draw_polyline(pts, Color(1.0, 0.55, 0.2, 0.25), 5.0)
		draw_polyline(pts, Color(0.55, 0.4, 0.2), 2.0)
	for pt in rail:
		draw_circle(pt, 2.0, Color(0.85, 0.65, 0.28))
	if Engine.is_editor_hint() and rail.size() > 0:
		draw_circle(rail[0], radius, Color(0.9, 0.3, 0.15, 0.6))

func _draw_blade():
	var teeth := PackedVector2Array()
	for i in 24:
		var a := i * TAU / 24.0
		teeth.append(Vector2.RIGHT.rotated(a) * (radius if i % 2 == 0 else radius - 3.0))
	blade.draw_colored_polygon(teeth, Color(0.9, 0.35, 0.15))
	blade.draw_circle(Vector2.ZERO, radius * 0.45, Color(0.3, 0.25, 0.25))
	blade.draw_circle(Vector2.ZERO, 2.0, Color(0.85, 0.65, 0.28))
	# Jiskry: víc při roztáčení na konci kolejnice
	for i in (6 if revving else 2):
		var a := randf() * TAU
		var from := Vector2.RIGHT.rotated(a) * radius
		blade.draw_line(from, from + Vector2.RIGHT.rotated(a + randf_range(-0.5, 0.5)) * randf_range(3.0, 7.0), Color(1.0, 0.85, 0.4), 1.0)
