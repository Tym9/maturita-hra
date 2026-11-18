class_name Chapter
extends Node2D

## Kořen kapitoly (Celeste): místnosti (Room) jsou přímí potomci položení hranou k hraně ve světě.
## Hlídá přechody mezi místnostmi, neviditelné okraje, smrt propadem, aktivaci jen aktuální místnosti a sousedů
## a ukládání v checkpoint místnostech. Ladění: F1 hranice a id, F2 / Shift+F2 teleport
## na další / předchozí místnost, spuštění s `-- --room=<id>` teleportuje rovnou.

const TRANSITION_FREEZE: float = 0.3
const EDGE_HALF_WIDTH: float = 7.0 # polovina šířky hráče (player.tscn 14x18): tělo nevyjede z obrazu
const TOP_OVERSHOOT: float = 24.0
const ChestScene = preload("res://mechanics/chest.tscn")

## Předměty pro hráče, který je ještě nemá (výběr kapitoly z menu): leží v truhle u startu první místnosti,
## do batohu se nic nepřidává samo
@export var start_items: Array[String] = []
## Otvory ve stropě vedoucí do místnosti nad ní jemně svítí (UpExitHint), aby bylo vidět, že cesta vede nahoru
@export var hint_up_exits: bool = false

var rooms: Array[Room] = []
var current: Room = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var transitioning: bool = false
var debug_overlay := Node2D.new()

func _ready():
	for c in get_children():
		if c is Room:
			rooms.append(c)
	player = get_tree().get_first_node_in_group("player")
	camera = player.camera
	if hint_up_exits:
		UpExitHint.add_hints(rooms, _room_at)
	SeamWalls.add_to_rooms(rooms, _room_at) # zdi sousedních místností vyčnívají do obrazu
	var missing := start_items.filter(func(id): return not player.grid_inventory.has_item(id))
	if not missing.is_empty():
		var chest := ChestScene.instantiate()
		chest.name = "SupplyChest" # stálá cesta = uložený obsah truhly
		chest.initial_items.assign(missing)
		rooms[0].add_child(chest)
		var spawn := rooms[0].nearest_respawn(player.global_position)
		chest.global_position = spawn.global_position if spawn else player.global_position
	camera.chapter = self
	camera.process_mode = Node.PROCESS_MODE_ALWAYS # kamera klouže i během zmrazení přechodu
	var start := _room_at(player.global_position)
	if start == null:
		# Uložená pozice už neleží v žádné místnosti (změněný layout) - použij uloženou místnost
		start = _find(str(SaveManager.current_save_data.get("room_id", "")))
		if start == null:
			start = rooms[0]
		_place_player(start)
	_set_current(start)

	debug_overlay.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	debug_overlay.visible = false
	debug_overlay.draw.connect(func():
		for r in rooms:
			r.draw_debug(debug_overlay, debug_overlay.to_local(r.global_position)))
	add_child(debug_overlay)

	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--room="):
			teleport_to.call_deferred(arg.trim_prefix("--room="))

func _physics_process(_delta):
	if transitioning or player.is_dying:
		return
	var b := current.bounds()
	var pos: Vector2 = player.global_position
	if not b.has_point(pos):
		var target := _room_at(pos)
		if target:
			_transition(target)
			return
		var g: float = player.gravity_dir
		if (g > 0.0 and pos.y >= b.end.y) or (g < 0.0 and pos.y < b.position.y):
			player.die() # propad dnem tam, kde žádná místnost nepokračuje
			return
	_hold_inside(b, pos)

## Celeste: otevřený bok nebo strop bez sousední místnosti je neviditelná stěna (místnost nemusí být
## uzavřená krabice). Nad strop (proti gravitaci) smí hráč vyskočit o TOP_OVERSHOOT mimo obraz.
func _hold_inside(b: Rect2, pos: Vector2):
	var held := pos
	var y := clampf(pos.y, b.position.y, b.end.y - 1.0)
	if pos.x < b.position.x + EDGE_HALF_WIDTH and _room_at(Vector2(b.position.x - 1.0, y)) == null:
		held.x = b.position.x + EDGE_HALF_WIDTH
		player.velocity.x = maxf(player.velocity.x, 0.0)
	elif pos.x > b.end.x - EDGE_HALF_WIDTH and _room_at(Vector2(b.end.x + 1.0, y)) == null:
		held.x = b.end.x - EDGE_HALF_WIDTH
		player.velocity.x = minf(player.velocity.x, 0.0)
	var x := clampf(held.x, b.position.x, b.end.x - 1.0)
	if player.gravity_dir > 0.0 and pos.y < b.position.y - TOP_OVERSHOOT and _room_at(Vector2(x, b.position.y - 1.0)) == null:
		held.y = b.position.y - TOP_OVERSHOOT
		player.velocity.y = maxf(player.velocity.y, 0.0)
	elif player.gravity_dir < 0.0 and pos.y > b.end.y + TOP_OVERSHOOT and _room_at(Vector2(x, b.end.y + 1.0)) == null:
		held.y = b.end.y + TOP_OVERSHOOT
		player.velocity.y = minf(player.velocity.y, 0.0)
	if held != pos:
		player.global_position = held

func _transition(target: Room):
	transitioning = true
	var old_rect := current.bounds()
	var pos: Vector2 = player.global_position
	var spawn := target.nearest_respawn(pos)
	player.spawn_point = spawn.global_position if spawn else pos
	player.awaiting_room_spawn = spawn == null
	# Výskok do místnosti nad hráčem (proti gravitaci) dostane odraz, aby doskočil na římsu (Celeste)
	var g: float = player.gravity_dir
	if (g > 0.0 and pos.y < old_rect.position.y) or (g < 0.0 and pos.y >= old_rect.end.y):
		player.velocity.y = minf(player.velocity.y * g, player.JUMP_VELOCITY) * g
	_set_current(target)
	if target.checkpoint:
		SaveManager.save_game(player, scene_file_path, target.room_id)
	# Krátké zmrazení, kamera mezitím dojede; rychlost hráče zůstává zachována
	get_tree().paused = true
	await get_tree().create_timer(TRANSITION_FREEZE).timeout
	get_tree().paused = false
	transitioning = false

func _set_current(room: Room):
	if current:
		Global.room_exited.emit(current.room_id)
	current = room
	camera.room_rect = room.bounds()
	# Zpracovává se jen aktuální místnost a její sousedé (dotýkají se hranou nebo rohem)
	var near := room.bounds().grow(1.0)
	for r in rooms:
		r.process_mode = Node.PROCESS_MODE_INHERIT if near.intersects(r.bounds()) else Node.PROCESS_MODE_DISABLED
	Global.room_entered.emit(room.room_id)

## Po respawnu (volá kamera v reset_to_spawn): místnost podle pozice hráče.
func sync_to_player():
	var room := _room_at(player.global_position)
	if room and room != current:
		_set_current(room)

func teleport_to(room_id: String) -> bool:
	var room := _find(room_id)
	if room == null:
		push_warning("Chapter: místnost '%s' neexistuje" % room_id)
		return false
	_place_player(room)
	_set_current(room)
	camera.reset_to_spawn()
	return true

func _place_player(room: Room):
	var spawn := room.nearest_respawn(room.bounds().get_center())
	var pos: Vector2 = spawn.global_position if spawn else room.bounds().get_center()
	player.global_position = pos
	player.velocity = Vector2.ZERO
	player.spawn_point = pos
	player.awaiting_room_spawn = spawn == null

func _unhandled_input(event):
	if not OS.is_debug_build() or not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F1:
		debug_overlay.visible = not debug_overlay.visible
		debug_overlay.queue_redraw()
	elif event.keycode == KEY_F2:
		var i := rooms.find(current) + (-1 if event.shift_pressed else 1)
		teleport_to(rooms[posmod(i, rooms.size())].room_id)

func _room_at(pos: Vector2) -> Room:
	for r in rooms:
		if r.bounds().has_point(pos):
			return r
	return null

func _find(room_id: String) -> Room:
	for r in rooms:
		if r.room_id == room_id:
			return r
	return null
