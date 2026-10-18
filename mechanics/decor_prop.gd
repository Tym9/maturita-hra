@tool
class_name DecorProp
extends Node2D

## Dekorace bez kolize (placeholder tvary). Počátek = podlaha pod předmětem, střed buňky.

enum Kind { LANTERN, BANNER, ANTENNA, DEAD_TREE, BLIGHT_CRYSTAL, CORP_PYLON, FIRE, CORP_BANNER }

const BRASS = Color(0.88, 0.66, 0.28)
const LAMP = Color(1.0, 0.8, 0.4)
const TEAL = Color(0.25, 0.85, 0.75)
const BLIGHT = Color(0.62, 0.36, 1.0)
const CORP_RED = Color(1.0, 0.22, 0.2)
const DARK = Color(0.14, 0.11, 0.12)

@export var kind: Kind = Kind.LANTERN:
	set(val):
		kind = val
		queue_redraw()

var t := 0.0

func _ready():
	z_index = -1
	set_process(kind in [Kind.LANTERN, Kind.ANTENNA, Kind.BLIGHT_CRYSTAL, Kind.CORP_PYLON, Kind.FIRE] and not Engine.is_editor_hint())

func _process(delta):
	t += delta
	queue_redraw()

func _draw():
	match kind:
		Kind.LANTERN: # sloupek s parní lucernou
			draw_rect(Rect2(-1, -22, 2, 22), DARK)
			draw_rect(Rect2(-3, -28, 6, 7), BRASS.darkened(0.3))
			draw_rect(Rect2(-2, -27, 4, 5), LAMP)
			draw_circle(Vector2(0, -24), 10.0, Color(LAMP, 0.10 + 0.03 * sin(t * 5.0)))
		Kind.BANNER: # korouhev odboje (ozubené kolo na modrozelené)
			draw_rect(Rect2(-1, -32, 2, 32), DARK)
			draw_colored_polygon(PackedVector2Array([Vector2(1, -31), Vector2(14, -31), Vector2(11, -25), Vector2(14, -19), Vector2(1, -19)]), TEAL.darkened(0.25))
			draw_circle(Vector2(7, -25), 3.0, BRASS)
			draw_circle(Vector2(7, -25), 1.2, TEAL.darkened(0.25))
		Kind.ANTENNA: # svépomocí slepená anténa s parabolou
			draw_line(Vector2(0, 0), Vector2(0, -34), DARK, 1.0)
			draw_line(Vector2(-6, 0), Vector2(0, -16), DARK, 1.0)
			draw_line(Vector2(6, 0), Vector2(0, -16), DARK, 1.0)
			draw_arc(Vector2(-3, -26), 5.0, -0.6, 1.6, 6, BRASS.darkened(0.2), 1.0)
			if fmod(t, 1.4) < 0.7:
				draw_rect(Rect2(-1, -36, 3, 2), TEAL)
		Kind.DEAD_TREE:
			draw_line(Vector2(0, 0), Vector2(1, -26), DARK, 3.0)
			draw_line(Vector2(1, -14), Vector2(-8, -22), DARK, 2.0)
			draw_line(Vector2(1, -20), Vector2(9, -30), DARK, 2.0)
			draw_line(Vector2(-5, -20), Vector2(-7, -28), DARK, 1.0)
		Kind.BLIGHT_CRYSTAL: # krystalová nákaza prorůstající zemí
			var glow := 0.25 + 0.1 * sin(t * 3.0)
			draw_circle(Vector2(0, -6), 9.0, Color(BLIGHT, glow * 0.5))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, 0), Vector2(-3, -14), Vector2(0, 0)]), BLIGHT.darkened(0.2))
			draw_colored_polygon(PackedVector2Array([Vector2(-2, 0), Vector2(2, -20), Vector2(5, 0)]), BLIGHT)
			draw_colored_polygon(PackedVector2Array([Vector2(3, 0), Vector2(7, -9), Vector2(8, 0)]), BLIGHT.darkened(0.35))
			draw_line(Vector2(2, -20), Vector2(1, -4), Color(0.9, 0.8, 1.0, 0.7), 1.0)
		Kind.FIRE: # hořící trosky (nálet na tábor) - jen dekorace, nezraňuje
			var f := sin(t * 11.0) * 1.5
			draw_circle(Vector2(0, -6), 12.0, Color(1.0, 0.45, 0.1, 0.12))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, 0), Vector2(-2 + f, -16), Vector2(2, -6), Vector2(5 - f, -13), Vector2(7, 0)]), Color(0.95, 0.35, 0.08))
			draw_colored_polygon(PackedVector2Array([Vector2(-4, 0), Vector2(0 - f, -10), Vector2(4, 0)]), Color(1.0, 0.8, 0.3))
			for k in 3: # jiskry
				var y := -fposmod(t * 20.0 + k * 9.0, 28.0)
				draw_rect(Rect2(Vector2(sin(t * 3.0 + k) * 5.0, y - 14.0), Vector2(1, 1)), Color(1.0, 0.7, 0.3, 0.8))
		Kind.CORP_PYLON: # korporátní sonda / stožár s rudým okem
			draw_rect(Rect2(-3, -30, 6, 30), Color(0.22, 0.2, 0.24))
			draw_rect(Rect2(-5, -32, 10, 4), Color(0.3, 0.28, 0.32))
			draw_rect(Rect2(-2, -24, 4, 4), CORP_RED if fmod(t, 1.0) < 0.6 else CORP_RED.darkened(0.6))
			draw_line(Vector2(-3, -10), Vector2(3, -16), Color(0.4, 0.38, 0.42), 1.0)
		Kind.CORP_BANNER: # propagandistický prapor korporace (rudý s mosazným kruhem)
			draw_rect(Rect2(-1, -34, 2, 34), DARK)
			draw_rect(Rect2(-7, -33, 14, 2), BRASS.darkened(0.3))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -31), Vector2(6, -31), Vector2(6, -14), Vector2(0, -10), Vector2(-6, -14)]), CORP_RED.darkened(0.35))
			draw_arc(Vector2(0, -22), 3.5, 0.0, TAU, 10, BRASS, 1.0)
			draw_line(Vector2(0, -26), Vector2(0, -18), BRASS, 1.0)
