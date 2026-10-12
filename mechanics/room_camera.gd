extends Camera2D

# Celeste-style Room Grid Camera:
# Rozděluje herní svět na mřížku místností o velikosti jedné obrazovky (320 x 180 px).
# Kamera zůstává ukotvená v aktuální buňce a při přechodu hranice plynule přejede na novou místnost.
# Zároveň nastavuje checkpoint (spawn_point) hráče pro okamžitý respawn v dané místnosti.

const ROOM_WIDTH: float = 320.0
const ROOM_HEIGHT: float = 180.0

var player: CharacterBody2D = null
var current_room: Vector2i = Vector2i(0, 0)
var target_pos: Vector2 = Vector2.ZERO
var is_transitioning: bool = false
var transition_speed: float = 16.0

func _ready():
	top_level = true # Pohybuje se v globálním prostoru nezávisle na mikro-pohybech hráče
	zoom = Vector2(1.0, 1.0) # Nativní rozlišení 320x180 (pixel-perfect)
	position_smoothing_enabled = false
	player = get_parent() as CharacterBody2D
	
	call_deferred("_init_room")

func _init_room():
	if not is_instance_valid(player):
		return
	var rx = int(floor(player.global_position.x / ROOM_WIDTH))
	var ry = int(floor(player.global_position.y / ROOM_HEIGHT))
	current_room = Vector2i(rx, ry)
	target_pos = _get_room_center(current_room)
	global_position = target_pos

func _process(delta):
	if not is_instance_valid(player):
		return
		
	var p_pos = player.global_position
	var rx = int(floor(p_pos.x / ROOM_WIDTH))
	var ry = int(floor(p_pos.y / ROOM_HEIGHT))
	var player_room = Vector2i(rx, ry)
	
	if player_room != current_room:
		_transition_to_room(player_room)
		
	# Plynulý přesun na střed místnosti (Celeste-style room slide)
	if global_position.distance_to(target_pos) > 0.5:
		global_position = global_position.lerp(target_pos, transition_speed * delta)
	else:
		global_position = target_pos
		is_transitioning = false

func _transition_to_room(new_room: Vector2i):
	current_room = new_room
	target_pos = _get_room_center(new_room)
	is_transitioning = true
	
	# Aktualizace záchytného bodu (checkpointu) pro respawn v nové místnosti
	if is_instance_valid(player):
		var entrance_pos = player.global_position
		# Zajistíme, že hráč nerespawnuje přímo na hraně mřížky
		var min_x = current_room.x * ROOM_WIDTH + 18.0
		var max_x = (current_room.x + 1) * ROOM_WIDTH - 18.0
		var min_y = current_room.y * ROOM_HEIGHT + 18.0
		var max_y = (current_room.y + 1) * ROOM_HEIGHT - 18.0
		entrance_pos.x = clamp(entrance_pos.x, min_x, max_x)
		entrance_pos.y = clamp(entrance_pos.y, min_y, max_y)
		player.spawn_point = entrance_pos

func _get_room_center(room: Vector2i) -> Vector2:
	return Vector2(
		room.x * ROOM_WIDTH + ROOM_WIDTH * 0.5,
		room.y * ROOM_HEIGHT + ROOM_HEIGHT * 0.5
	)

func reset_to_spawn():
	if not is_instance_valid(player):
		return
	var rx = int(floor(player.spawn_point.x / ROOM_WIDTH))
	var ry = int(floor(player.spawn_point.y / ROOM_HEIGHT))
	current_room = Vector2i(rx, ry)
	target_pos = _get_room_center(current_room)
	global_position = target_pos
	is_transitioning = false
