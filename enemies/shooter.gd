extends CharacterBody2D

# Typ 2: Střelec korporace (Steam Turret)
# Když hráče uvidí (v dosahu a bez překážky), zamíří varovným laserovým paprskem (`aim_duration`,
# telegraf ≥ 0.5 s) a vystřelí pomalý parní projektil - seknutí hasákem ho zničí a obnoví dash.
# Dopad shora = odraz + dash, boční dotyk zraní. Útoky hráče přes take_hit.

@export var max_health: int = 2
@export var detection_range: float = 210.0
@export var shoot_cooldown_time: float = 1.6
@export var aim_duration: float = 0.75

var health: int = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum State { PATROL, AIMING, COOLDOWN }
var current_state: State = State.PATROL

var aim_timer: float = 0.0
var cooldown_timer: float = 0.0
var hurt_timer: float = 0.0
var is_dead: bool = false
var aim_target_pos: Vector2 = Vector2.ZERO

const BULLET_SCENE = preload("res://enemies/steam_bullet.tscn")

@onready var sprite = $Sprite2D
@onready var hurt_area = get_node_or_null("HurtArea")

func _ready():
	add_to_group("enemies")
	health = max_health

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	# Gravitace
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Zpětný ráz / knockback
	if hurt_timer > 0:
		hurt_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 360.0 * delta)
		move_and_slide()
		return

	# Hledání hráče
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback vyhledání podle jména v rootu scény
		var p_node = get_parent().get_node_or_null("Player")
		if p_node:
			player = p_node

	if is_instance_valid(player):
		var dist_to_player = global_position.distance_to(player.global_position)
		var can_see_player = dist_to_player <= detection_range and _clear_line(player)
		
		# Otočení k hráči při detekci
		if can_see_player:
			var look_left = player.global_position.x < global_position.x
			if sprite:
				sprite.flip_h = look_left
				
		match current_state:
			State.PATROL:
				velocity.x = 0
				if sprite:
					sprite.frame = 0
				if can_see_player and cooldown_timer <= 0:
					current_state = State.AIMING
					aim_timer = aim_duration
					aim_target_pos = player.global_position
					queue_redraw()
					
			State.AIMING:
				velocity.x = 0
				aim_timer -= delta
				aim_target_pos = player.global_position # Sleduje hráče při míření
				queue_redraw()
				
				if aim_timer <= 0:
					_shoot(aim_target_pos)
					current_state = State.COOLDOWN
					cooldown_timer = shoot_cooldown_time
					queue_redraw()
					
			State.COOLDOWN:
				velocity.x = 0
				if sprite:
					sprite.frame = 0
				if cooldown_timer > 0:
					cooldown_timer -= delta
				else:
					current_state = State.PATROL
	else:
		velocity.x = 0

	move_and_slide()

	# Dotyk s hráčem: dopad shora = odraz + dash, jinak zásah
	if hurt_area and EnemyContact.resolve(self, hurt_area, Vector2.UP, hurt_timer <= 0) == EnemyContact.STOMP:
		take_hit(max_health, Vector2.DOWN)

## Mezi střelcem a hráčem není pevná překážka (nestřílí skrz zdi).
func _clear_line(player: Node2D) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1, [get_rid(), player.get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _shoot(target_pos: Vector2):
	if is_dead:
		return
	if sprite:
		sprite.frame = 1 # Výstřelový rámec se zpětným rázem a párou
		var tw = create_tween()
		tw.tween_interval(0.18)
		tw.tween_callback(func():
			if is_instance_valid(sprite):
				sprite.frame = 0
		)
		
	var muzzle_offset = Vector2(-12 if (sprite and sprite.flip_h) else 12, 0)
	var spawn_pos = global_position + muzzle_offset
	var shoot_dir = (target_pos - spawn_pos).normalized()
	if shoot_dir == Vector2.ZERO:
		shoot_dir = Vector2.LEFT if (sprite and sprite.flip_h) else Vector2.RIGHT
		
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = spawn_pos
	bullet.setup(shoot_dir)
	var p = get_parent()
	if p:
		p.add_child(bullet)
	else:
		add_child(bullet)

## Starší jméno zásahu (testy, starší kód).
func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	take_hit(amount, from_dir)

func take_hit(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
		
	health -= amount
	hurt_timer = 0.22
	
	# Zásah přeruší probíhající míření
	if current_state == State.AIMING:
		current_state = State.COOLDOWN
		cooldown_timer = 0.8
		
	if sprite:
		sprite.frame = 0
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(3.5, 0.3, 0.3), 0.08)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
		
	if from_dir != Vector2.ZERO:
		velocity = from_dir.normalized() * 160.0 + Vector2(0, -90.0)
	else:
		var dir_away = 1.0 if (sprite and sprite.flip_h) else -1.0
		velocity = Vector2(dir_away * 130.0, -90.0)
		
	queue_redraw()
	
	if health <= 0:
		_die()

func _die():
	is_dead = true
	Global.kill_count += 1
	
	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape:
		col_shape.set_deferred("disabled", true)
	if has_node("HurtArea"):
		$HurtArea.set_deferred("monitoring", false)
		
	velocity = Vector2(randf_range(-50, 50), -170.0)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "rotation", deg_to_rad(randf_range(90, 270)), 0.25)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.25)
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(queue_free)

func _draw():
	# 1. Varovný laserový paprsek při míření
	if current_state == State.AIMING and not is_dead:
		var muzzle = Vector2(-12 if (sprite and sprite.flip_h) else 12, 0)
		var local_target = to_local(aim_target_pos)
		var laser_col = Color(1.0, 0.3, 0.15, 0.5 + sin(aim_timer * 18.0) * 0.3)
		draw_line(muzzle, local_target, laser_col, 1.2)
		draw_circle(local_target, 2.0, Color(1.0, 0.2, 0.1, 0.8))
		
	# 2. Mini health-bar nad hlavou při zranění
	if health < max_health and health > 0 and not is_dead:
		var bar_w = 16.0
		var bar_h = 3.0
		var pos_y = -16.0
		
		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.12, 0.12, 0.12, 0.85))
		var ratio = clamp(float(health) / float(max_health), 0.0, 1.0)
		draw_rect(Rect2(-bar_w * 0.5 + 1.0, pos_y + 0.5, (bar_w - 2.0) * ratio, bar_h - 1.0), Color(0.95, 0.25, 0.2, 0.95))
		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.08, 0.08, 0.08, 0.9), false, 1.0)

