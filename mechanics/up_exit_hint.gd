class_name UpExitHint
extends Node2D

## Jemná nápověda „cesta vede nahoru“ (Chapter.hint_up_exits): otvorem ve stropě, který vede do místnosti
## nad ní, padá slabé světlo a stoupají jiskry. Široký otvor (otevřené nebe) má jen jiskry.
## Kreslí se za dlaždicemi, před pozadím a zadní stěnou.

const TILE := 16
const DEPTH := 80.0 # jak hluboko do místnosti světlo a jiskry sahají (px)
const BEAM_MAX_WIDTH := 8 * TILE
const COLOR := Color(1.0, 0.94, 0.78)

var width: float = 48.0
var t: float = 0.0

## Ke každé místnosti přidá nápovědu nad souvislé úseky horní řady, které jsou volné až do místnosti nad ní.
static func add_hints(rooms: Array[Room], room_at: Callable):
	for room in rooms:
		var tiles := room.get_node_or_null("Tiles") as TileMapLayer
		if tiles == null:
			continue
		var cols := int(room.bounds().size.x / TILE)
		var start := -1
		for col in cols + 1:
			var open := col < cols and _open_up(room, tiles, col, room_at)
			if open and start < 0:
				start = col
			elif not open and start >= 0:
				var hint := UpExitHint.new()
				hint.position = Vector2(start * TILE, 0)
				hint.width = (col - start) * TILE
				room.add_child(hint)
				room.move_child(hint, tiles.get_index())
				start = -1

static func _open_up(room: Room, tiles: TileMapLayer, col: int, room_at: Callable) -> bool:
	if _solid(tiles, Vector2i(col, 0)):
		return false
	var x := room.global_position.x + col * TILE + TILE / 2.0
	var above: Room = room_at.call(Vector2(x, room.global_position.y - 1.0))
	if above == null:
		return false
	var at := above.get_node_or_null("Tiles") as TileMapLayer
	# spodní řada místnosti nad (místnosti mají 176 px na 180px obrazovku, mezera 4 px je prázdná)
	return at == null or not _solid(at, at.local_to_map(at.to_local(Vector2(x, room.global_position.y - 12.0))))

static func _solid(layer: TileMapLayer, cell: Vector2i) -> bool:
	var data := layer.get_cell_tile_data(cell)
	return data != null and data.get_collision_polygons_count(0) > 0

func _process(delta):
	t += delta
	queue_redraw()

func _draw():
	if width <= BEAM_MAX_WIDTH:
		var top := COLOR
		top.a = 0.2 + 0.05 * sin(t * 1.7)
		var bottom := COLOR
		bottom.a = 0.0
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(width, 0), Vector2(width + 10.0, DEPTH), Vector2(-10.0, DEPTH)]),
			PackedColorArray([top, top, bottom, bottom]))
	var motes := clampi(int(width / 20.0), 2, 12)
	for i in motes:
		var phase := fmod(t * (0.22 + 0.05 * (i % 3)) + i * 0.618, 1.0) # 0 dole -> 1 u otvoru
		var x := fposmod(i * 37.0 + sin(t * 1.3 + i) * 3.0, width)
		var c := COLOR
		c.a = sin(phase * PI) * 0.8
		draw_rect(Rect2(x, DEPTH * (1.0 - phase), 2.0, 2.0), c)
