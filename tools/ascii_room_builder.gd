@tool
extends EditorScript

## ASCII místnosti z LEVEL_*.md -> scény Room (+ scéna kapitoly). Spuštění: otevřít v editoru skriptů,
## File > Run (Ctrl+Shift+X). V .md souboru:
##   ### <room_id> ...      nadpis místnosti; první blok ``` pod ním = mřížka (1 znak = 1 dlaždice 16 px,
##                          pravítko sloupců "   0123..." a čísla řádků vlevo se odříznou, popisky vpravo taky)
##   ```props               volitelně pod mřížkou: řádky "<cíl> <vlastnost> = <hodnota v zápisu Godotu>",
##                          cíl = room | decor | znak legendy (všechny jeho uzly) | znak+pořadí (N2 = druhé N)
##   ```layout              kapitola: "chapter <res://...tscn>", "start_items <id> ...", "<room_id> <sx> <sy>"
##                          (sx, sy v obrazovkách 320x180; první místnost = start hráče)

## Kapitoly k sestavení: [blueprint .md, složka místností]
const CHAPTERS := [["res://LEVEL_c1.md", "res://levels/c1/"], ["res://LEVEL_c2.md", "res://levels/c2/"], ["res://LEVEL_c3.md", "res://levels/c3/"]]
const ONLY_ROOMS := [] # prázdné = všechny místnosti v souboru, jinak např. ["c1_a02"]
const OVERWRITE := false # true přepíše existující .tscn (ruční úpravy v nich se ztratí)

const TILE := 16
const SCREEN_TILES := Vector2i(20, 11)
const ROOM_SCRIPT := preload("res://mechanics/room.gd")
const CHAPTER_SCRIPT := preload("res://mechanics/chapter.gd")
const DECOR_SCRIPT := preload("res://mechanics/room_decor.gd")
const TILESET := preload("res://mechanics/room_tileset.tres")
const FAKE_WALL_SCRIPT := preload("res://mechanics/fake_wall.gd")
const PLAYER_SCENE := "res://player.tscn"
const AIR := ". "
## Styl pozadí (RoomDecor) podle předpony room_id; přebije ho "decor style = ..." v props
const DECOR_STYLE := {"c1": RoomDecor.STYLE_OUTPOST, "c2": RoomDecor.STYLE_VILLAGE, "c3": RoomDecor.STYLE_CITY}
## Horské kapitoly (stoupání): pozadí s výškou (RoomDecor.altitude)
const ALTITUDE_CHAPTERS := ["c2", "c3"]

## Znak -> co vytvořit.
## Dlaždice: "tile" (atlas souřadnice), "layer": "back" = zadní vrstva bez kolize, volitelně "terrain"
## (+ "terrain_set") - použije se, jen když je tileset má. "fake_wall": buňka vrstvy FakeWall (dlaždice podle
## okolní zdi, aby tajná cesta nebyla vidět); "hidden" u uzlu = navíc ho zakryje falešná zeď.
## Uzly: "scene" (instance .tscn) nebo "type" + "script" (holý uzel se skriptem).
##   "anchor": center | floor | top | top_left | top_right | bottom_left (bod obdélníku buňky / běhu), "offset" v px.
##   "run": "h"/"v" spojí sousední stejné znaky do jednoho uzlu ("chunk" = max délka), délka jde do
##   "size_prop" (px) nebo "count_prop" (kusy). "props" = další vlastnosti, "name" = jméno uzlu.
const LEGEND := {
	# pevné dlaždice
	"#": {"tile": Vector2i(0, 0), "terrain": 0}, # kámen
	"B": {"tile": Vector2i(1, 0), "terrain": 1}, # mosaz
	"W": {"tile": Vector2i(2, 0)}, # prkna
	"Z": {"tile": Vector2i(3, 0)}, # rezavý plech
	"R": {"tile": Vector2i(4, 0)}, # střešní šindel
	"%": {"tile": Vector2i(5, 0)}, # zem s krystalovou nákazou
	"_": {"tile": Vector2i(6, 0)}, # hlína se suchou trávou
	"&": {"tile": Vector2i(7, 0)}, # cihly
	# zadní vrstva bez kolize (fasády domů)
	"w": {"tile": Vector2i(0, 1), "layer": "back"}, # dřevěná stěna
	"z": {"tile": Vector2i(1, 1), "layer": "back"}, # plechová stěna
	"o": {"tile": Vector2i(2, 1), "layer": "back"}, # rozsvícené okno
	"b": {"tile": Vector2i(3, 1), "layer": "back"}, # zatlučené okno
	"d": {"tile": Vector2i(4, 1), "layer": "back"}, # dveře
	"t": {"tile": Vector2i(5, 1), "layer": "back"}, # plachta odboje
	"q": {"tile": Vector2i(6, 1), "layer": "back"}, # cihlová stěna
	"k": {"tile": Vector2i(7, 1), "layer": "back"}, # tmavá skála
	"F": {"fake_wall": true},
	# dekorace bez kolize
	"l": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.LANTERN}, "name": "Lantern"},
	"f": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.BANNER}, "name": "Banner"},
	"a": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.ANTENNA}, "name": "Antenna"},
	"y": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.DEAD_TREE}, "name": "DeadTree"},
	"x": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.BLIGHT_CRYSTAL}, "name": "Blight"},
	"p": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.CORP_PYLON}, "name": "Pylon"},
	"h": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.FIRE}, "name": "Fire"},
	"g": {"type": "Node2D", "script": "res://mechanics/decor_prop.gd", "anchor": "floor", "props": {"kind": DecorProp.Kind.CORP_BANNER}, "name": "CorpBanner"},
	# hra
	"@": {"type": "Marker2D", "script": "res://mechanics/respawn_point.gd", "anchor": "floor", "offset": Vector2(0, -9), "name": "RespawnPoint"},
	"^": {"type": "Area2D", "script": "res://mechanics/grid_spikes.gd", "run": "h", "count_prop": "count", "anchor": "bottom_left", "props": {"orientation": GridSpikes.ORIENTATION_UP}, "name": "Spikes"},
	"v": {"type": "Area2D", "script": "res://mechanics/grid_spikes.gd", "run": "h", "count_prop": "count", "anchor": "top_left", "props": {"orientation": GridSpikes.ORIENTATION_DOWN}, "name": "Spikes"},
	"<": {"type": "Area2D", "script": "res://mechanics/grid_spikes.gd", "run": "v", "count_prop": "count", "anchor": "top_right", "props": {"orientation": GridSpikes.ORIENTATION_LEFT}, "name": "Spikes"},
	">": {"type": "Area2D", "script": "res://mechanics/grid_spikes.gd", "run": "v", "count_prop": "count", "anchor": "top_left", "props": {"orientation": GridSpikes.ORIENTATION_RIGHT}, "name": "Spikes"},
	# StepZone mřížky má pevných 30 px, proto delší běh = víc mřížek po 2 dlaždicích
	"=": {"scene": "res://mechanics/crumbling_platform.tscn", "run": "h", "chunk": 2, "size_prop": "width", "anchor": "top", "offset": Vector2(0, 5), "name": "Grate"},
	"~": {"scene": "res://mechanics/conveyor_belt.tscn", "run": "h", "count_prop": "width", "anchor": "top_left", "name": "Belt"},
	"S": {"scene": "res://mechanics/pressure_spring.tscn", "anchor": "floor", "name": "Spring"},
	"V": {"scene": "res://mechanics/steam_vent.tscn", "anchor": "floor", "name": "Vent"},
	# lis: řada P = těleso (šířka), hlava míří dolů o reach dlaždic (props "P reach = 3", "P2 offset = 0.7")
	"P": {"scene": "res://mechanics/piston_crusher.tscn", "run": "h", "count_prop": "width", "anchor": "top", "name": "Crusher"},
	"I": {"scene": "res://mechanics/crystal_spikes.tscn", "run": "h", "count_prop": "count", "anchor": "floor", "name": "CrystalSpikes"},
	"O": {"scene": "res://mechanics/falling_rock.tscn", "anchor": "top", "name": "Rock"},
	"G": {"scene": "res://enemies/patrol_guard.tscn", "anchor": "floor", "offset": Vector2(0, -12), "name": "Guard"},
	"T": {"scene": "res://enemies/shooter.tscn", "name": "Turret"},
	"D": {"scene": "res://enemies/drone.tscn", "name": "Drone"},
	"M": {"scene": "res://enemies/pressure_mine.tscn", "name": "Mine"},
	"C": {"scene": "res://mechanics/crystal.tscn", "name": "Crystal"},
	"c": {"scene": "res://mechanics/crystal.tscn", "name": "Crystal", "hidden": true}, # krystal schovaný za falešnou zdí
	"*": {"scene": "res://mechanics/dash_shard.tscn", "name": "Shard"},
	"K": {"scene": "res://mechanics/celeste_key.tscn", "name": "Key"},
	"L": {"scene": "res://mechanics/key_block.tscn", "run": "v", "size_prop": "block_height", "name": "KeyBlock"},
	"H": {"scene": "res://mechanics/health_pack.tscn", "name": "HealthPack"},
	"X": {"scene": "res://mechanics/chest.tscn", "anchor": "floor", "offset": Vector2(0, -10), "name": "Chest"},
	"N": {"scene": "res://npc/npc_base.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "NPC"},
	# postavy: dialogy přes props, např. "2 dialogue_pages = Array[String]([...])"
	"1": {"scene": "res://npc/otis.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Otis"},
	"2": {"scene": "res://npc/mira.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Mira"},
	"3": {"scene": "res://npc/brann.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Brann"},
	"4": {"scene": "res://npc/elda.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Elda"},
	"5": {"scene": "res://npc/tobi.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Tobi"},
	"6": {"scene": "res://npc/rusty.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Rusty"},
	"7": {"scene": "res://npc/vesper.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Vesper"},
	"8": {"scene": "res://npc/hron.tscn", "anchor": "floor", "offset": Vector2(0, -8), "name": "Hron"},
	"!": {"scene": "res://mechanics/event_trigger.tscn", "anchor": "floor", "offset": Vector2(0, -32), "name": "Event"},
	"E": {"scene": "res://level_end.tscn", "name": "LevelEnd"},
}

func _run() -> void:
	_self_check()
	for ch in CHAPTERS:
		print("ASCII rooms: %d scenes saved to %s" % [build_file(ch[0], ch[1], OVERWRITE), ch[1]])
	EditorInterface.get_resource_filesystem().scan()

## Postaví místnosti (všechny nebo ONLY_ROOMS) a kapitolu ze souboru; vrací počet uložených scén.
static func build_file(md_path: String, out_dir: String, overwrite: bool) -> int:
	var text := FileAccess.get_file_as_string(md_path)
	if text.is_empty():
		push_error("ASCII rooms: nelze číst " + md_path)
		return 0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var doc := parse_doc(text)
	var made := 0
	for id in doc.rooms:
		if ONLY_ROOMS.is_empty() or id in ONLY_ROOMS:
			made += int(build_room(id, doc.rooms[id], out_dir.path_join(id + ".tscn"), overwrite))
	if not doc.layout.is_empty():
		made += int(build_chapter(doc.layout, doc.rooms, out_dir, overwrite))
	return made

## { rooms: {room_id: {rows, props}}, layout: {chapter, start_items, rooms: [[id, Vector2i]]} }
static func parse_doc(text: String) -> Dictionary:
	var rooms := {}
	var layout := {}
	var id := ""
	var fence := "" # "" = mimo blok, jinak info řetězec bloku ("grid", "props", "layout", "other")
	var block := PackedStringArray()
	for line in text.split("\n"):
		line = line.trim_suffix("\r")
		if line.begins_with("```"):
			if fence == "":
				var info := line.substr(3).strip_edges()
				fence = info if info in ["props", "layout"] else ("grid" if info == "" and id != "" and not rooms.has(id) else "other")
				block.clear()
				continue
			if fence == "grid":
				rooms[id] = {"rows": grid_rows(block), "props": []}
			elif fence == "props" and rooms.has(id):
				rooms[id].props = parse_props(block)
			elif fence == "layout":
				layout = parse_layout(block)
			fence = ""
		elif fence != "":
			block.append(line)
		elif line.begins_with("### "):
			id = line.substr(4).strip_edges().get_slice(" ", 0)
			if not id.is_valid_filename():
				id = ""
	return {"rooms": rooms, "layout": layout}

## Odřízne pravítko, čísla řádků a popisky; blok bez pravítka bere celý.
static func grid_rows(block: PackedStringArray) -> PackedStringArray:
	var ruler := block[0].strip_edges() if block.size() > 0 else ""
	if ruler.is_empty() or not ruler.lstrip("0123456789").is_empty():
		return block
	var left := block[0].find(ruler)
	var rows := PackedStringArray()
	for i in range(1, block.size()):
		var label := block[i].substr(0, left).strip_edges()
		if block[i].length() > left and label.is_valid_int():
			rows.append(block[i].substr(left, ruler.length()))
	return rows

## Řádky "<cíl> <vlastnost> = <hodnota>" -> [[cíl, vlastnost, hodnota]].
static func parse_props(block: PackedStringArray) -> Array:
	var out := []
	for line in block:
		var eq := line.find("=")
		var head := line.substr(0, eq).strip_edges().split(" ", false)
		if eq < 0 or head.size() != 2:
			continue
		var value_text := line.substr(eq + 1).strip_edges()
		var value = str_to_var(value_text)
		if value == null and value_text != "null":
			push_warning("ASCII rooms: neplatná hodnota '%s'" % line)
			continue
		out.append([head[0], head[1], value])
	return out

static func parse_layout(block: PackedStringArray) -> Dictionary:
	var layout := {"chapter": "", "start_items": [], "rooms": []}
	for line in block:
		var p := line.strip_edges().split(" ", false)
		if p.size() >= 2 and p[0] == "chapter":
			layout.chapter = p[1]
		elif p.size() >= 1 and p[0] == "start_items":
			layout.start_items = Array(p.slice(1))
		elif p.size() == 3 and p[1].is_valid_int() and p[2].is_valid_int():
			layout.rooms.append([p[0], Vector2i(int(p[1]), int(p[2]))])
	return layout

static func build_room(id: String, room_data: Dictionary, path: String, overwrite: bool) -> bool:
	if FileAccess.file_exists(path) and not overwrite:
		push_warning("ASCII rooms: %s existuje, přeskočeno (OVERWRITE = true ho přepíše)" % path)
		return false
	var rows: PackedStringArray = room_data.rows
	var grid := Vector2i(0, rows.size())
	for r in rows:
		grid.x = maxi(grid.x, r.length())
	var screens := Vector2i(ceili(grid.x / float(SCREEN_TILES.x)), ceili(grid.y / float(SCREEN_TILES.y))).max(Vector2i.ONE)
	if grid.x % SCREEN_TILES.x != 0 or grid.y % SCREEN_TILES.y != 0:
		push_warning("ASCII rooms: %s má %dx%d dlaždic, není to násobek 20x11" % [id, grid.x, grid.y])

	var room := Node2D.new()
	room.set_script(ROOM_SCRIPT)
	room.name = id
	room.set("room_id", id)
	room.set("screens", screens)
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(screens) * Room.SCREEN
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.color = Color(0.09, 0.08, 0.11, 1)
	bg.z_index = -10
	_add(room, bg)
	var decor := Node2D.new()
	decor.set_script(DECOR_SCRIPT)
	decor.name = "Decor"
	decor.set("style", DECOR_STYLE.get(id.get_slice("_", 0), RoomDecor.STYLE_OUTPOST))
	decor.set("altitude", id.get_slice("_", 0) in ALTITUDE_CHAPTERS)
	_add(room, decor)
	var back := _layer(room, "Back")
	back.collision_enabled = false
	back.z_index = -2
	var tiles := _layer(room, "Tiles")

	var use_terrains := TILESET.get_terrain_sets_count() > 0
	var terrain_cells := {} # Vector2i(terrain_set, terrain) -> Array[Vector2i]
	var fake_cells: Array[Vector2i] = []
	var used := {}
	var unknown := {}
	var spawned := {} # znak -> [uzly] v pořadí řádků
	for y in rows.size():
		for x in rows[y].length():
			var cell := Vector2i(x, y)
			var ch := rows[y][x]
			if used.has(cell) or AIR.contains(ch):
				continue
			if not LEGEND.has(ch):
				unknown[ch] = true
				continue
			var e: Dictionary = LEGEND[ch]
			if e.has("tile"):
				if e.get("layer", "") == "back":
					back.set_cell(cell, 0, e["tile"])
				elif use_terrains and e.has("terrain"):
					var key := Vector2i(e.get("terrain_set", 0), e["terrain"])
					if not terrain_cells.has(key):
						var cells: Array[Vector2i] = []
						terrain_cells[key] = cells
					terrain_cells[key].append(cell)
				else:
					tiles.set_cell(cell, 0, e["tile"])
			elif e.has("fake_wall"):
				fake_cells.append(cell)
			else:
				if not spawned.has(ch):
					spawned[ch] = []
				spawned[ch].append(_spawn(room, rows, cell, ch, e, used))
				_fill_back(back, rows, cell)
				if e.get("hidden", false):
					fake_cells.append(cell)
					spawned[ch].back().z_index = -1 # pod dlaždicemi: záře nepřesahuje přes okolní zeď
	if not fake_cells.is_empty():
		var fake := _layer(room, "FakeWall", FAKE_WALL_SCRIPT)
		var tile_of := {} # celá oblast jednou dlaždicí, jinak by remíza sousedů udělala šev
		for cell in fake_cells:
			if not tile_of.has(cell):
				var region: Array = _fake_region(rows, cell)
				for c in region[0]:
					tile_of[c] = region[1]
			fake.set_cell(cell, 0, tile_of[cell])
	for key in terrain_cells:
		tiles.set_cells_terrain_connect(terrain_cells[key], key.x, key.y)
	if not unknown.is_empty():
		push_warning("ASCII rooms: %s - neznámé znaky %s (doplň LEGEND)" % [id, "".join(PackedStringArray(unknown.keys()))])
	for p in room_data.props:
		_apply_prop(id, room, decor, spawned, p[0], p[1], p[2])
	return _save(room, path)

static func build_chapter(layout: Dictionary, rooms: Dictionary, out_dir: String, overwrite: bool) -> bool:
	var path: String = layout.chapter
	if path.is_empty() or layout.rooms.is_empty():
		push_error("ASCII rooms: layout potřebuje 'chapter <cesta>' a aspoň jednu místnost")
		return false
	if FileAccess.file_exists(path) and not overwrite:
		push_warning("ASCII rooms: %s existuje, přeskočeno (OVERWRITE = true ho přepíše)" % path)
		return false
	var chapter := Node2D.new()
	chapter.set_script(CHAPTER_SCRIPT)
	chapter.name = path.get_file().get_basename().to_pascal_case()
	var items: Array[String] = []
	items.assign(layout.start_items)
	chapter.set("start_items", items)
	var start := Vector2.ZERO
	for entry in layout.rooms:
		var room_path := out_dir.path_join(entry[0] + ".tscn")
		var scene := ResourceLoader.load(room_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
		if scene == null:
			push_error("ASCII rooms: chybí %s" % room_path)
			chapter.free()
			return false
		var room := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node2D
		room.position = Vector2(entry[1]) * Room.SCREEN
		_add(chapter, room)
		if entry == layout.rooms[0]: # hráč na první RespawnPoint startovní místnosti (pořadí řádků)
			start = room.position + Room.SCREEN / 2.0
			for c in room.get_children():
				if c is RespawnPoint:
					start = room.position + c.position
					break
	var player := (load(PLAYER_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node2D
	player.position = start
	_add(chapter, player)
	return _save(chapter, path)

static func _save(root: Node, path: String) -> bool:
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	root.free()
	if err != OK:
		push_error("ASCII rooms: %s se nepodařilo uložit (%s)" % [path, error_string(err)])
		return false
	print("  ", path)
	return true

static func _layer(room: Node2D, layer_name: String, script: Script = null) -> TileMapLayer:
	var layer := TileMapLayer.new()
	if script:
		layer.set_script(script)
	layer.name = layer_name
	layer.tile_set = TILESET
	_add(room, layer)
	return layer

## Předmět před fasádou: zadní dlaždice pod ním se doplní od souseda, aby v domě nezůstala díra.
static func _fill_back(back: TileMapLayer, rows: PackedStringArray, cell: Vector2i) -> void:
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]:
		var e: Dictionary = LEGEND.get(_at(rows, cell + d), {})
		if e.get("layer", "") == "back":
			back.set_cell(cell, 0, e["tile"])
			return

## Souvislá oblast F/c od `start` a dlaždice zdi kolem ní (nejčastější pevný soused), aby falešná zeď
## vypadala stejně jako okolí. Vrací [buňky, dlaždice].
static func _fake_region(rows: PackedStringArray, start: Vector2i) -> Array:
	var counts := {}
	var seen := {start: true}
	var cells: Array[Vector2i] = [start]
	var todo: Array[Vector2i] = [start]
	while not todo.is_empty():
		var c: Vector2i = todo.pop_back()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			seen[n] = true
			var e: Dictionary = LEGEND.get(_at(rows, n), {})
			if e.has("fake_wall") or e.get("hidden", false):
				todo.append(n)
				cells.append(n)
			elif e.has("tile") and e.get("layer", "") != "back":
				counts[e["tile"]] = counts.get(e["tile"], 0) + 1
	var best := Vector2i(0, 0) # kámen, když kolem žádná zeď není
	for t in counts:
		if counts[t] > counts.get(best, 0):
			best = t
	return [cells, best]

static func _apply_prop(id: String, room: Node2D, decor: Node2D, spawned: Dictionary, target: String, prop: String, value) -> void:
	var nodes := []
	if target == "room":
		nodes = [room]
	elif target == "decor":
		nodes = [decor]
	elif spawned.has(target.left(1)):
		nodes = spawned[target.left(1)]
		if target.length() > 1:
			var i := int(target.substr(1)) - 1
			nodes = [nodes[i]] if i >= 0 and i < nodes.size() else []
	if nodes.is_empty():
		push_warning("ASCII rooms: %s - props cíl '%s' nenalezen" % [id, target])
	if value is String and value.begins_with("res://") and prop.ends_with("texture"):
		value = load(value) # portrait_texture = "res://assets/npc/mira_portrait.png"
	for n in nodes:
		if not prop in n:
			push_warning("ASCII rooms: %s - %s nemá vlastnost '%s'" % [id, n.name, prop])
		n.set(prop, value)

static func _spawn(room: Node2D, rows: PackedStringArray, cell: Vector2i, ch: String, e: Dictionary, used: Dictionary) -> Node2D:
	var dir := Vector2i.ZERO
	match e.get("run", ""):
		"h": dir = Vector2i.RIGHT
		"v": dir = Vector2i.DOWN
	var chunk: int = e.get("chunk", 0)
	var n := 1
	while dir != Vector2i.ZERO and _at(rows, cell + dir * n) == ch and (chunk == 0 or n < chunk):
		n += 1
	for i in n:
		used[cell + dir * i] = true
	var rect := Rect2(Vector2(cell * TILE), Vector2(TILE, TILE) + Vector2(dir * TILE * (n - 1)))

	var node: Node2D
	if e.has("scene"):
		node = (load(e["scene"]) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	else:
		node = ClassDB.instantiate(e["type"]) as Node2D
		node.set_script(load(e["script"]))
	var props: Dictionary = e.get("props", {})
	for p in props:
		node.set(p, props[p])
	if e.has("size_prop"):
		node.set(e["size_prop"], float(n * TILE))
	if e.has("count_prop"):
		node.set(e["count_prop"], n)
	node.position = _anchor(rect, e.get("anchor", "center")) + e.get("offset", Vector2.ZERO)
	node.name = e.get("name", node.name)
	_add(room, node)
	return node

static func _anchor(r: Rect2, anchor: String) -> Vector2:
	match anchor:
		"floor": return Vector2(r.get_center().x, r.end.y)
		"top": return Vector2(r.get_center().x, r.position.y)
		"top_left": return r.position
		"top_right": return Vector2(r.end.x, r.position.y)
		"bottom_left": return Vector2(r.position.x, r.end.y)
	return r.get_center()

static func _at(rows: PackedStringArray, c: Vector2i) -> String:
	if c.y < 0 or c.y >= rows.size() or c.x < 0 or c.x >= rows[c.y].length():
		return ""
	return rows[c.y][c.x]

## Uzel se uloží do scény jen s owner = kořen; vnitřek instancí si drží vlastní scéna.
static func _add(root: Node, node: Node) -> void:
	root.add_child(node, true)
	node.owner = root

static func _self_check() -> void:
	var doc := parse_doc("## Map\n```\n[a01]\n```\n### r1 — x\n```\n   0123\n 1 #@.^   ← a\n 0 ####\n     ↓\n```\n```props\nroom checkpoint = true\nN2 npc_name = \"Mira\"\n```\n```layout\nchapter res://c.tscn\nstart_items wrench\nr1 0 -1\n```\n")
	assert(doc.rooms.size() == 1 and doc.rooms.has("r1"), "parse_doc: mřížka jen pod ###")
	assert(doc.rooms["r1"].rows == PackedStringArray(["#@.^", "####"]), "grid_rows: pravítko, čísla řádků a popisky pryč")
	assert(doc.rooms["r1"].props == [["room", "checkpoint", true], ["N2", "npc_name", "Mira"]], "parse_props")
	assert(doc.layout.chapter == "res://c.tscn" and doc.layout.start_items == ["wrench"] and doc.layout.rooms == [["r1", Vector2i(0, -1)]], "parse_layout")
	assert(_anchor(Rect2(16, 0, 32, 16), "floor") == Vector2(32, 16))
	assert(_fake_region(PackedStringArray(["&&&&", "&Fc&", "&&#&"]), Vector2i(1, 1)) == [[Vector2i(1, 1), Vector2i(2, 1)], Vector2i(7, 0)], "_fake_region: oblast F/c a dlaždice okolních cihel")
