extends CharacterBody2D

# Typ 3: Létající bezpečnostní dron (Security Drone)
# Hlídkuje ve vzduchu nad propastmi. Když hráče uvidí (paprsek bez překážky, do `sight_range`),
# zamkne se: `lock_time` s rudě bliká a míří (telegraf), pak vyrazí rovně na místo, kde hráč byl.
# Po nárazu do zdi je `stun_time` s omráčený (neškodný), pak se vrátí na hlídku.
# Dopad shora (vůči gravitaci hráče) = odraz + dash a dron padá; boční dotyk zraní.
# Útoky hráče přes take_hit - hák ho sestřelí z dálky.

enum State { PATROL, LOCK, CHARGE, STUNNED, RETURN }

@export var max_health: int = 1
@export var hover_amplitude: float = 8.0
@export var hover_frequency: float = 3.2
@export var patrol_distance: float = 50.0
@export var patrol_speed: float = 32.0
## Dohled pro zamčení na hráče (0 = jen hlídkuje jako dřív)
@export var sight_range: float = 120.0
@export var lock_time: float = 0.5
@export var charge_speed: float = 260.0
@export var max_charge_distance: float = 240.0
@export var stun_time: float = 1.0
@export var return_speed: float = 70.0

var state: State = State.PATROL
var state_timer: float = 0.0
var charge_dir: Vector2 = Vector2.ZERO
var charge_target: Vector2 = Vector2.ZERO
var charge_travelled: float = 0.0
var health: int = 1
var base_pos: Vector2 = Vector2.ZERO
var hover_time: float = 0.0
var patrol_dir: float = 1.0
var is_dead: bool = false
var hurt_timer: float = 0.0
var ignored_player: Node = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Sprite2D
@onready var hurt_area = get_node_or_null("HurtArea")

func _ready():
	add_to_group("enemies")
	health = max_health
	base_pos = global_position
	# Náhodný offset fázování pro přirozený pohyb více dronů
	hover_time = randf_range(0.0, TAU)

func _physics_process(delta):
	hover_time += delta
	queue_redraw()

	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	if hurt_timer > 0:
		hurt_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 350.0 * delta)
		move_and_slide()
		return

	var player = get_tree().get_first_node_in_group("player")
	if player and ignored_player != player:
		add_collision_exception_with(player) # průlet hráčem ho neodstrčí; dotyk řeší EnemyContact
		ignored_player = player

	match state:
		State.PATROL:
			_patrol()
			if player and _sees(player):
				state = State.LOCK
				state_timer = lock_time
		State.LOCK:
			velocity = Vector2.ZERO
			if player:
				charge_target = player.global_position
			state_timer -= delta
			if state_timer <= 0.0:
				charge_dir = (charge_target - global_position).normalized()
				charge_travelled = 0.0
				state = State.CHARGE
		State.CHARGE:
			velocity = charge_dir * charge_speed
		State.STUNNED:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				state = State.RETURN
		State.RETURN:
			var to_home := base_pos - global_position
			if to_home.length() <= return_speed * delta:
				velocity = to_home / delta
				state = State.PATROL
			else:
				velocity = to_home.normalized() * return_speed

	move_and_slide()

	if state == State.CHARGE:
		charge_travelled += charge_speed * delta
		if _hit_wall():
			state = State.STUNNED
			state_timer = stun_time
			velocity = -charge_dir * 40.0
		elif charge_travelled >= max_charge_distance:
			state = State.RETURN

	# Dotyk s hráčem: omráčený neškodí, ale dá se na něj skočit
	if hurt_area and EnemyContact.resolve(self, hurt_area, Vector2.ZERO, state != State.STUNNED) == EnemyContact.STOMP:
		take_hit(max_health, Vector2.DOWN)

func _patrol():
	# Vznášení se ve vzduchu (vertikální sinusoida + horizontální patrola)
	var target_y = base_pos.y + sin(hover_time * hover_frequency) * hover_amplitude
	if patrol_distance > 0:
		velocity.x = patrol_dir * patrol_speed
		if abs(global_position.x - base_pos.x) >= patrol_distance:
			patrol_dir = -sign(global_position.x - base_pos.x)
			if sprite:
				sprite.flip_h = patrol_dir < 0
	else:
		velocity.x = 0
	velocity.y = (target_y - global_position.y) * 8.0

## Hráč v dohledu a nic mezi nimi (paprsek jen proti pevné geometrii).
func _sees(player: Node2D) -> bool:
	if sight_range <= 0.0 or global_position.distance_to(player.global_position) > sight_range:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1, [get_rid(), player.get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _hit_wall() -> bool:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and not collider.is_in_group("player"):
			return true
	return false

func take_hit(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return

	health -= amount
	hurt_timer = 0.18

	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(3.5, 0.3, 0.3), 0.08)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if from_dir != Vector2.ZERO:
		velocity = from_dir.normalized() * 180.0
	else:
		velocity = Vector2(randf_range(-80, 80), -100.0)

	if health <= 0:
		_die()

## Starší jméno zásahu (testy, starší kód).
func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	take_hit(amount, from_dir)

func _die():
	is_dead = true
	Global.kill_count += 1

	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape:
		col_shape.set_deferred("disabled", true)
	if has_node("HurtArea"):
		$HurtArea.set_deferred("monitoring", false)

	# Vzdušný rozpad a pád dolů
	velocity = Vector2(randf_range(-60, 60), -120.0)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "rotation", deg_to_rad(randf_range(180, 540)), 0.3)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.chain().tween_callback(queue_free)

func _draw():
	if is_dead:
		return
	match state:
		State.LOCK:
			# Telegraf: rudé zaměřovací paprsky na hráče a blikající oko
			var blink := fmod(state_timer, 0.12) < 0.06
			draw_line(Vector2.ZERO, to_local(charge_target), Color(1.0, 0.2, 0.15, 0.7 if blink else 0.3), 1.0)
			draw_circle(Vector2(0, -1), 3.0, Color(1.0, 0.15, 0.1) if blink else Color(1.0, 0.6, 0.2))
		State.STUNNED:
			# Omráčení: kroužící jiskry nad dronem
			for i in 3:
				var a := hover_time * 6.0 + i * TAU / 3.0
				draw_circle(Vector2(cos(a) * 7.0, -10.0 + sin(a) * 2.0), 1.2, Color(1.0, 0.9, 0.4))
