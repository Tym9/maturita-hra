class_name Chapter
extends Node2D

## Kořen kapitoly (Celeste): místnosti (Room) jsou přímí potomci položení hranou k hraně ve světě.
## Hlídá přechody mezi místnostmi, smrt mimo mapu, aktivaci jen aktuální místnosti a sousedů
## a ukládání v checkpoint místnostech. Ladění: F1 hranice a id, F2 / Shift+F2 teleport
## na další / předchozí místnost, spuštění s `-- --room=<id>` teleportuje rovnou.

const TRANSITION_FREEZE: float = 0.3
const ItemData = preload("res://mechanics/item_data.gd")

## Předměty, které hráč dostane, pokud je ještě nemá (výběr kapitoly z menu, testovací kapitola)
@export var start_items: Array[String] = []

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
	for id in start_items:
		if not player.grid_inventory.has_item(id):
			player.grid_inventory.add_item_auto(ItemData.create(id))
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
	if transitioning or player.is_dying or current.bounds().has_point(player.global_position):
		return
	var target := _room_at(player.global_position)
	if target == null:
		player.die() # odešel z místnosti tam, kde žádná nepokračuje
	else:
		_transition(target)

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
