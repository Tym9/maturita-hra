extends Camera2D

# Celeste-style Room Camera:
# Herní svět je mřížka buněk o velikosti jedné obrazovky (320 x 180 px).
# Buňky se stejnou room_group tvoří jednu velkou místnost - kamera v ní plynule jede za hráčem
# a drží se uvnitř jejích hranic. Samostatná buňka = klasická místnost na jednu obrazovku.
# Při přechodu do jiné místnosti kamera plynule přejede a nastaví checkpoint (spawn_point) hráče.
# Zabezpečuje, že hráč nikdy neopustí platnou mřížku místností (okamžitá detekce pádu mimo mapu).
# Režim kapitoly: když scénu řídí Chapter (mechanics/chapter.gd), kamera jen sleduje hráče v `room_rect`
# a přechody, smrt mimo mapu i checkpointy řeší kapitola.

const ROOM_WIDTH: float = 320.0
const ROOM_HEIGHT: float = 180.0

var player: CharacterBody2D = null
var current_room: Vector2i = Vector2i(0, 0)
var current_group: String = ""
var target_pos: Vector2 = Vector2.ZERO
var is_transitioning: bool = false
var transition_speed: float = 16.0
var valid_rooms: Array[Vector2i] = []
var cell_groups: Dictionary = {} # Vector2i -> String
var group_rects: Dictionary = {} # String -> Rect2 (světové hranice místnosti)
var reset_entries: Array[Dictionary] = [] # výchozí stav nepřátel a uzlů ze skupiny "room_reset"
var reset_snapshot_taken: bool = false
var chapter: Node = null # Chapter, pokud scénu tvoří místnosti Room; jinak mřížka RoomBackdrop
var room_rect: Rect2 = Rect2() # hranice aktuální místnosti v režimu kapitoly

func _ready():
	top_level = true
	zoom = Vector2(1.0, 1.0)
	position_smoothing_enabled = false
	player = get_parent() as CharacterBody2D
	Global.room_reset.connect(_reset_room)
	call_deferred("_init_room")

func _init_room():
	if not is_inside_tree() or not is_instance_valid(player):
		return
	_discover_valid_rooms()
	current_room = _cell_of(player.global_position)
	current_group = _group_of(current_room)
	target_pos = _target_for(player.global_position)
	global_position = target_pos
	_snapshot_resettables()

## Celeste: smrt vrátí nepřátele a drolící se plošiny aktuální místnosti do výchozího stavu.
## Zapamatuje si scénu, rodiče, transformaci a exportované proměnné, při resetu uzel vytvoří znovu.
func _snapshot_resettables():
	if reset_snapshot_taken:
		return
	reset_snapshot_taken = true
	var nodes: Dictionary = {}
	for n in get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("room_reset"):
		if n is Node2D and not n.scene_file_path.is_empty() and not n.is_in_group("enemy_projectiles"):
			nodes[n] = true
	for n in nodes:
		var props: Dictionary = {}
		for p in n.get_property_list():
			if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.usage & PROPERTY_USAGE_STORAGE:
				props[p.name] = n.get(p.name)
		reset_entries.append({"node": n, "scene": n.scene_file_path, "parent": n.get_parent(), "name": n.name, "transform": n.transform, "home": n.global_position, "props": props})

func _reset_room():
	get_tree().call_group("enemy_projectiles", "queue_free")
	var rect: Rect2 = current_rect()
	for e in reset_entries:
		if not rect.has_point(e.home) or not is_instance_valid(e.parent):
			continue
		if is_instance_valid(e.node): # zabitý nepřítel už je uvolněný
			var old: Node = e.node
			if old.get_parent():
				old.get_parent().remove_child(old)
			old.queue_free()
		var fresh: Node2D = load(e.scene).instantiate()
		for key in e.props:
			fresh.set(key, e.props[key])
		fresh.name = e.name
		fresh.transform = e.transform
		e.parent.add_child(fresh)
		e["node"] = fresh

func is_valid_room(room: Vector2i) -> bool:
	if valid_rooms.is_empty():
		_discover_valid_rooms()
	return valid_rooms.has(room)

func _discover_valid_rooms():
	valid_rooms.clear()
	cell_groups.clear()
	group_rects.clear()
	if chapter or not is_inside_tree():
		return
	var candidates: Array[Node] = []
	if get_tree() and get_tree().current_scene:
		candidates.append(get_tree().current_scene)
	var curr: Node = self
	while curr != null:
		if not candidates.has(curr):
			candidates.append(curr)
		curr = curr.get_parent()

	for root in candidates:
		for child in root.find_children("*", "", true, false):
			if child is RoomBackdrop or (child.get("room_x") != null and child.get("room_y") != null):
				var r = Vector2i(child.room_x, child.room_y)
				if not valid_rooms.has(r):
					valid_rooms.append(r)
					var g = child.get("room_group")
					cell_groups[r] = g if g is String and not g.is_empty() else str(r)
		if not valid_rooms.is_empty():
			break

	for r in valid_rooms:
		var cell_rect = Rect2(r.x * ROOM_WIDTH, r.y * ROOM_HEIGHT, ROOM_WIDTH, ROOM_HEIGHT)
		var g = cell_groups[r]
		group_rects[g] = group_rects[g].merge(cell_rect) if group_rects.has(g) else cell_rect

func _cell_of(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / ROOM_WIDTH)), int(floor(pos.y / ROOM_HEIGHT)))

func _group_of(room: Vector2i) -> String:
	return cell_groups.get(room, str(room))

func _group_rect(group: String, room: Vector2i) -> Rect2:
	return group_rects.get(group, Rect2(room.x * ROOM_WIDTH, room.y * ROOM_HEIGHT, ROOM_WIDTH, ROOM_HEIGHT))

func current_rect() -> Rect2:
	return room_rect if chapter else _group_rect(current_group, current_room)

## Kamera sleduje hráče, ale nikdy neukáže nic mimo hranice aktuální místnosti.
func _target_for(pos: Vector2) -> Vector2:
	var rect = current_rect()
	var half = Vector2(ROOM_WIDTH, ROOM_HEIGHT) * 0.5
	return Vector2(
		clamp(pos.x, rect.position.x + half.x, rect.end.x - half.x),
		clamp(pos.y, rect.position.y + half.y, rect.end.y - half.y)
	)

func _process(delta):
	if not is_instance_valid(player):
		return

	if not chapter:
		var player_room = _cell_of(player.global_position)

		# Pokud hráč vypadl mimo jakoukoliv platnou místnost v levelu, okamžitě ho vrátíme na bezpečný spawn
		if not valid_rooms.is_empty() and not valid_rooms.has(player_room):
			if player.has_method("die"):
				player.die()
			return

		if player_room != current_room:
			_transition_to_room(player_room)

	target_pos = _target_for(player.global_position)
	if global_position.distance_to(target_pos) > 0.5:
		global_position = global_position.lerp(target_pos, transition_speed * delta)
	else:
		global_position = target_pos
		is_transitioning = false

func _transition_to_room(new_room: Vector2i):
	if not valid_rooms.is_empty() and not valid_rooms.has(new_room):
		return
	current_room = new_room
	var new_group = _group_of(new_room)
	if new_group == current_group:
		return # Pohyb uvnitř velké místnosti - žádný přechod ani nový checkpoint
	current_group = new_group
	is_transitioning = true

	# Checkpoint = vchod do nové místnosti: nejbližší spawn marker (Marker2D ve skupině "spawn_points"),
	# jinak bod vstupu uvnitř místnosti, který hráč upřesní prvním bezpečným přistáním
	if is_instance_valid(player):
		var room_rect: Rect2 = _group_rect(current_group, current_room)
		var marker: Node2D = null
		for m in get_tree().get_nodes_in_group("spawn_points"):
			if room_rect.has_point(m.global_position) and (marker == null or m.global_position.distance_to(player.global_position) < marker.global_position.distance_to(player.global_position)):
				marker = m
		if marker:
			player.spawn_point = marker.global_position
			player.awaiting_room_spawn = false
			return
		var rect = room_rect.grow(-20.0)
		var entrance_pos = player.global_position
		entrance_pos.x = clamp(entrance_pos.x, rect.position.x, rect.end.x)
		entrance_pos.y = clamp(entrance_pos.y, rect.position.y, rect.end.y)
		player.spawn_point = entrance_pos
		player.awaiting_room_spawn = true

func reset_to_spawn():
	if not is_instance_valid(player):
		return
	if chapter:
		chapter.sync_to_player()
	else:
		current_room = _cell_of(player.spawn_point)
		current_group = _group_of(current_room)
	target_pos = _target_for(player.spawn_point)
	global_position = target_pos
	is_transitioning = false
