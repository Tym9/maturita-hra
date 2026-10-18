extends CharacterBody2D

# Typ 1: Pozemní stráž (Clockwork Guard)
# Hlídka pochodující po plošině. U zdi nebo okraje srázu se zastaví, natáhne klíček
# (`turn_pause` s, cvakání = telegraf) a otočí se. Dopad shora (vůči gravitaci hráče) = odraz
# + dash a stráž padá; boční dotyk zraní. Útoky hráče přes take_hit.

enum State { PATROL, TURN, HURT, DEAD }

@export var speed: float = 55.0
@export var max_health: int = 2
@export var turn_pause: float = 0.4

var state: State = State.PATROL
var state_timer: float = 0.0
var health: int = 2
var direction: int = -1 # Začíná vlevo
var is_dead: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Sprite2D
@onready var raycast_floor = $RayCast2D
@onready var hurt_area = get_node_or_null("HurtArea")

func _ready():
	add_to_group("enemies")
	health = max_health

func _physics_process(delta):
	if not is_on_floor() or state == State.DEAD:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	match state:
		State.PATROL:
			velocity.x = direction * speed
		State.TURN:
			velocity.x = 0
			state_timer -= delta
			queue_redraw()
			if state_timer <= 0.0:
				_turn_around()
				state = State.PATROL
		State.HURT:
			velocity.x = move_toward(velocity.x, 0, 360.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				state = State.PATROL
		State.DEAD:
			move_and_slide()
			return

	move_and_slide()

	if state == State.PATROL and (is_on_wall() or (is_on_floor() and not raycast_floor.is_colliding())):
		state = State.TURN
		state_timer = turn_pause

	if hurt_area and EnemyContact.resolve(self, hurt_area, Vector2.UP, state != State.HURT) == EnemyContact.STOMP:
		take_hit(max_health, Vector2.DOWN)

func _turn_around():
	direction *= -1
	if sprite:
		sprite.flip_h = (direction > 0)
	if raycast_floor:
		raycast_floor.position.x = direction * 12

func take_hit(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return

	health -= amount
	state = State.HURT
	state_timer = 0.22

	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(3.5, 0.3, 0.3), 0.08)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)

	if from_dir != Vector2.ZERO:
		velocity = from_dir.normalized() * 160.0 + Vector2(0, -90.0)
	else:
		velocity = Vector2(-direction * 130.0, -90.0)

	queue_redraw()

	if health <= 0:
		_die()

## Starší jméno zásahu (testy, starší kód).
func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	take_hit(amount, from_dir)

func _die():
	is_dead = true
	state = State.DEAD
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
	# Telegraf otočky: natahovací klíček na zádech se točí
	if state == State.TURN:
		var key_pos := Vector2(-direction * 9.0, -6.0)
		var a := (turn_pause - state_timer) * 20.0
		draw_line(key_pos + Vector2.RIGHT.rotated(a) * 4.0, key_pos - Vector2.RIGHT.rotated(a) * 4.0, Color(0.85, 0.65, 0.28), 2.0)
		draw_circle(key_pos, 1.5, Color(0.55, 0.4, 0.2))

	if health < max_health and health > 0 and not is_dead:
		var bar_w = 16.0
		var bar_h = 3.0
		var pos_y = -14.0

		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.12, 0.12, 0.12, 0.85))
		var ratio = clamp(float(health) / float(max_health), 0.0, 1.0)
		draw_rect(Rect2(-bar_w * 0.5 + 1.0, pos_y + 0.5, (bar_w - 2.0) * ratio, bar_h - 1.0), Color(0.95, 0.25, 0.2, 0.95))
		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.08, 0.08, 0.08, 0.9), false, 1.0)
