extends Area2D

## Celeste-style létající klíč (CelesteKey).
## Vznáší se na místě, po dotyku následuje hráče jako společník.
## Pokud hráč zemře před odemčením brány, klíč se vrátí na svou výchozí pozici.
## Při příchodu ke klíčovému bloku (KeyBlock) vletí do dírky a odemkne průchod.

signal collected(player)
signal returned_to_spawn

enum State { IDLE, FOLLOWING, UNLOCKING }

var state: State = State.IDLE
var initial_position: Vector2 = Vector2.ZERO
var target_player: CharacterBody2D = null

var hover_time: float = 0.0
var trail_positions: Array[Vector2] = []
const MAX_TRAIL: int = 5

@onready var collision_shape = $CollisionShape2D

func _ready():
	add_to_group("celeste_keys")
	initial_position = global_position
	body_entered.connect(_on_body_entered)
	z_index = 8

func _process(delta):
	hover_time += delta
	
	match state:
		State.IDLE:
			# Jemné levitování na výchozím místě
			position.y = initial_position.y + sin(hover_time * 3.5) * 3.5
			rotation = sin(hover_time * 2.0) * 0.08
			queue_redraw()
			
		State.FOLLOWING:
			if not is_instance_valid(target_player):
				reset_to_spawn()
				return
				
			# Cíl: mírně za zády a nad hlavou hráče
			var facing_dir = -1.0
			if target_player.get_node_or_null("Sprite2D"):
				facing_dir = 1.0 if target_player.get_node("Sprite2D").flip_h else -1.0
			var offset = Vector2(facing_dir * 18.0, -12.0)
			var target_pos = target_player.global_position + offset + Vector2(0, sin(hover_time * 4.5) * 3.0)
			
			# Plynulé následování (elastický lerp)
			var prev_pos = global_position
			global_position = global_position.lerp(target_pos, clamp(delta * 7.5, 0.0, 1.0))
			
			# Náklon podle pohybu
			var vel = global_position - prev_pos
			var target_rot = clamp(vel.x * 0.12, -0.4, 0.4)
			rotation = lerp_angle(rotation, target_rot, delta * 12.0)
			
			# Záznam stopy
			trail_positions.push_front(global_position)
			if trail_positions.size() > MAX_TRAIL:
				trail_positions.pop_back()
				
			queue_redraw()
			
		State.UNLOCKING:
			queue_redraw()

func _on_body_entered(body):
	if state == State.IDLE and body.is_in_group("player"):
		collect(body)

func collect(player: CharacterBody2D):
	state = State.FOLLOWING
	target_player = player
	collected.emit(player)
	_play_collect_fx()

func on_player_died():
	if state == State.FOLLOWING:
		reset_to_spawn()

func reset_to_spawn():
	state = State.IDLE
	target_player = null
	global_position = initial_position
	rotation = 0.0
	trail_positions.clear()
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	returned_to_spawn.emit()
	_play_return_fx()

func start_unlock(target_pos: Vector2, on_complete: Callable):
	state = State.UNLOCKING
	target_player = null
	trail_positions.clear()
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# 1. Dolet do dírky
	tw.tween_property(self, "global_position", target_pos, 0.35)
	tw.parallel().tween_property(self, "rotation", 0.0, 0.25)
	# 2. Otočení jako v zámku
	tw.tween_property(self, "rotation", deg_to_rad(90.0), 0.22)
	# 3. Zmenšení a zmizení
	tw.tween_property(self, "scale", Vector2.ZERO, 0.18)
	tw.tween_callback(func():
		on_complete.call()
		queue_free()
	)

func _play_collect_fx():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.35, 1.35), 0.1)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _play_return_fx():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.4, 1.4), 0.12)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _draw():
	# 1. Zlatá záře na pozadí
	var pulse = (sin(hover_time * 5.0) + 1.0) * 0.5
	var aura_col = Color(1.0, 0.85, 0.3, 0.2 + pulse * 0.15)
	draw_circle(Vector2.ZERO, 8.0 + pulse * 2.0, aura_col)
	
	# 2. Tělo klíče (mosazný pixel-art)
	var brass_main = Color(1.0, 0.85, 0.28, 1.0)
	var brass_dark = Color(0.65, 0.45, 0.12, 1.0)
	var brass_light = Color(1.0, 0.96, 0.65, 1.0)
	
	# Kruhová hlava klíče (ozubená)
	draw_arc(Vector2(-4, 0), 4.5, 0.0, TAU, 16, brass_dark, 2.5)
	draw_arc(Vector2(-4, 0), 4.0, 0.0, TAU, 16, brass_main, 1.5)
	draw_circle(Vector2(-4, 0), 1.5, Color(0.12, 0.1, 0.16, 0.9))
	
	# Dřík klíče
	draw_line(Vector2(0, 0), Vector2(7, 0), brass_main, 2.0)
	draw_line(Vector2(0, -0.5), Vector2(7, -0.5), brass_light, 1.0)
	
	# Zoubky klíče
	draw_line(Vector2(4, 0), Vector2(4, 3.5), brass_main, 1.5)
	draw_line(Vector2(6, 0), Vector2(6, 4.5), brass_main, 1.5)
	draw_line(Vector2(4, 3), Vector2(4, 3.5), brass_light, 1.0)
	draw_line(Vector2(6, 4), Vector2(6, 4.5), brass_light, 1.0)
