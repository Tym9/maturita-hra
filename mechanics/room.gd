@tool
class_name Room
extends Node2D

## Místnost kapitoly (Celeste): počátek uzlu = levý horní roh, velikost v celých obrazovkách.
## Obsahuje TileMapLayer s geometrií a 1+ RespawnPoint. Kapitola (Chapter) drží kameru v `bounds()`
## a mimo aktuální místnost a její sousedy ji vypíná.

const SCREEN := Vector2(320, 180)

@export var room_id: String = "":
	set(val):
		room_id = val
		queue_redraw()
@export var screens: Vector2i = Vector2i.ONE:
	set(val):
		screens = val.max(Vector2i.ONE)
		queue_redraw()
## Vstup do místnosti uloží hru (kapitola + místnost + bod respawnu)
@export var checkpoint: bool = false:
	set(val):
		checkpoint = val
		queue_redraw()

## Místnost, ve které uzel leží (null u starých levelů bez místností).
static func of(node: Node) -> Room:
	var n := node.get_parent()
	while n != null and not (n is Room):
		n = n.get_parent()
	return n as Room

func bounds() -> Rect2:
	return Rect2(global_position, Vector2(screens) * SCREEN)

func nearest_respawn(pos: Vector2) -> RespawnPoint:
	var best: RespawnPoint = null
	for n in find_children("*", "Marker2D", true, false):
		if n is RespawnPoint and (best == null or n.global_position.distance_to(pos) < best.global_position.distance_to(pos)):
			best = n
	return best

## Obrys a id v editoru; za běhu je kreslí ladicí vrstva kapitoly (F1).
func _draw():
	if Engine.is_editor_hint():
		draw_debug(self, Vector2.ZERO)

func draw_debug(canvas: CanvasItem, origin: Vector2):
	var col := Color(0.25, 0.95, 0.8) if checkpoint else Color(0.85, 0.65, 0.25)
	canvas.draw_rect(Rect2(origin, Vector2(screens) * SCREEN), col, false, 1.0)
	canvas.draw_string(ThemeDB.fallback_font, origin + Vector2(4, 12), room_id + (" [CP]" if checkpoint else ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col)
