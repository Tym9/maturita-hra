class_name SeamWalls
extends Node2D

## Zeď sousední místnosti, která začíná hned za okrajem obrazu, není vidět: hráč naráží do „neviditelné“ stěny.
## Jako v Celeste proto zeď do obrazu vyčnívá: kde je okrajová buňka místnosti volná a sousední místnost má
## hned za ní pevnou dlaždici, nakreslí se u okraje úzký pruh té dlaždice. Jen kresba, kolize se nemění
## (zeď je pořád za okrajem; pruh je užší než půlka hráče).

const TILE := 16
const STRIP := 6.0 # šířka vyčnívajícího pruhu (px)
const MARGIN := 4.0 # místnost má 176 px na 180px obrazovku: dole zbývá 4 px

var strips: Array = [] # [cílový obdélník (lokálně), výřez v atlasu]
var texture: Texture2D = null

## Ke každé místnosti přidá pruhy sousedních zdí.
static func add_to_rooms(rooms: Array[Room], room_at: Callable):
	for room in rooms:
		var tiles := room.get_node_or_null("Tiles") as TileMapLayer
		if tiles == null:
			continue
		var node := SeamWalls.new()
		node.texture = (tiles.tile_set.get_source(0) as TileSetAtlasSource).texture
		var size := room.bounds().size
		var cols := int(size.x / TILE)
		var rows := int((size.y - MARGIN) / TILE)
		var origin := room.global_position
		for r in rows:
			var y := r * TILE
			if not _solid(tiles, Vector2i(0, r)): # levý okraj: pravý kraj dlaždice souseda
				var a := _wall(room_at, [origin + Vector2(-2, y + 3), origin + Vector2(-2, y + 8), origin + Vector2(-2, y + 13)])
				if a.x >= 0:
					node.strips.append([Rect2(0, y, STRIP, TILE), Rect2(a.x * TILE + TILE - STRIP, a.y * TILE, STRIP, TILE)])
			if not _solid(tiles, Vector2i(cols - 1, r)): # pravý okraj
				var a := _wall(room_at, [origin + Vector2(size.x + 2, y + 3), origin + Vector2(size.x + 2, y + 8), origin + Vector2(size.x + 2, y + 13)])
				if a.x >= 0:
					node.strips.append([Rect2(size.x - STRIP, y, STRIP, TILE), Rect2(a.x * TILE, a.y * TILE, STRIP, TILE)])
		for c in cols:
			var x := c * TILE
			if not _solid(tiles, Vector2i(c, 0)): # strop: spodní kraj dlaždice místnosti nad (ta končí 4 px nad obrazem)
				var a := _wall(room_at, [origin + Vector2(x + 3, -MARGIN - 2), origin + Vector2(x + 8, -MARGIN - 2), origin + Vector2(x + 13, -MARGIN - 2)])
				if a.x >= 0:
					node.strips.append([Rect2(x, 0, TILE, STRIP), Rect2(a.x * TILE, a.y * TILE + TILE - STRIP, TILE, STRIP)])
			if not _solid(tiles, Vector2i(c, rows - 1)): # dno: horní kraj dlaždice místnosti pod (do 4px okraje a kousek nad něj)
				var a := _wall(room_at, [origin + Vector2(x + 3, size.y + 2), origin + Vector2(x + 8, size.y + 2), origin + Vector2(x + 13, size.y + 2)])
				if a.x >= 0:
					node.strips.append([Rect2(x, size.y - STRIP, TILE, STRIP), Rect2(a.x * TILE, a.y * TILE, TILE, STRIP)])
		if node.strips.is_empty():
			node.free()
		else:
			room.add_child(node)

static func _solid(tiles: TileMapLayer, cell: Vector2i) -> bool:
	return tiles.get_cell_source_id(cell) != -1

## Atlasová dlaždice zdi, která leží ve všech bodech (jinak (-1, -1): schod ve švu nebo průchod se nekreslí).
static func _wall(room_at: Callable, points: Array) -> Vector2i:
	var atlas := Vector2i(-1, -1)
	for p in points:
		var room: Room = room_at.call(p)
		var tiles := room.get_node_or_null("Tiles") as TileMapLayer if room else null
		if tiles == null:
			return Vector2i(-1, -1)
		var cell := tiles.local_to_map(tiles.to_local(p))
		if not _solid(tiles, cell):
			return Vector2i(-1, -1)
		atlas = tiles.get_cell_atlas_coords(cell)
	return atlas

func _draw():
	for s in strips:
		draw_texture_rect_region(texture, s[0], s[1])
		draw_rect(s[0], Color(0, 0, 0, 0.18)) # lehce ztmavit: zeď je „za rohem“
