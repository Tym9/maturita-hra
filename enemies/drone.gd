extends CharacterBody2D

# Typ 3: Létající bezpečnostní dron (Security Drone)
# Vznáší se ve vzduchu nad propastmi a hlídá vzdušný prostor.
# Hráč ho může sestřelit z dálky hákem (RMB), nebo na něj shora skočit a odrazit se!

@export var max_health: int = 1
@export var hover_amplitude: float = 8.0
@export var hover_frequency: float = 3.2
@export var patrol_distance: float = 50.0
@export var patrol_speed: float = 32.0

var health: int = 1
var base_pos: Vector2 = Vector2.ZERO
var hover_time: float = 0.0
var patrol_dir: float = 1.0
var is_dead: bool = false
var hurt_timer: float = 0.0
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

	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	if hurt_timer > 0:
		hurt_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 350.0 * delta)
		move_and_slide()
		return

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

	move_and_slide()

	# Kontrola kontaktu s hráčem
	if hurt_area and hurt_timer <= 0:
		for body in hurt_area.get_overlapping_bodies():
			if body.name == "Player" and not is_dead:
				_damage_player(body)

func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
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

func _die():
	is_dead = true
	Global.kill_count += 1

	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape:
		col_shape.set_deferred("disabled", true)
	if has_node("StompArea"):
		$StompArea.set_deferred("monitoring", false)
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

func _damage_player(body: Node2D):
	if is_dead:
		return
	if body.name == "Player":
		if body.velocity.y <= 0 or body.global_position.y > global_position.y - 6:
			if body.has_method("take_damage"):
				body.take_damage(1, global_position)
			elif body.has_method("die"):
				body.die()

func _on_stomp_area_body_entered(body):
	if is_dead:
		return
	if body.name == "Player":
		# Pokud hráč padá shora na dron: odrazí se do výšky!
		if body.velocity.y > 0:
			body.velocity.y = -270.0 # Katapult přes propast
			take_damage(max_health, Vector2.DOWN)

func _on_hurt_area_body_entered(body):
	_damage_player(body)
