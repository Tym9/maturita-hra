extends CharacterBody2D

# Typ 1: Pozemní stráž (Patrol Guard)
# Klasická hlídka pochodující po plošině s otáčením u zdi a okraje srázu.

@export var speed: float = 55.0
@export var max_health: int = 2
var health: int = 2
var direction: int = -1 # Začíná vlevo
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var hurt_timer: float = 0.0
var is_dead: bool = false

@onready var sprite = $Sprite2D
@onready var raycast_floor = $RayCast2D
@onready var hurt_area = get_node_or_null("HurtArea")

func _ready():
	add_to_group("enemies")
	health = max_health

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	if hurt_timer > 0:
		hurt_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 360.0 * delta)
	else:
		velocity.x = direction * speed
		
	move_and_slide()
	
	if is_on_wall():
		turn_around()
		
	if is_on_floor() and not raycast_floor.is_colliding():
		turn_around()
		
	if hurt_area and hurt_timer <= 0:
		for body in hurt_area.get_overlapping_bodies():
			if body.name == "Player" and not is_dead:
				_damage_player(body)

func turn_around():
	direction *= -1
	if sprite:
		sprite.flip_h = (direction > 0)
	if raycast_floor:
		raycast_floor.position.x = direction * 12

func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
		
	health -= amount
	hurt_timer = 0.22
	
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
		
	velocity = Vector2(randf_range(-50, 50), -170.0)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "rotation", deg_to_rad(randf_range(90, 270)), 0.25)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.25)
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(queue_free)

func _draw():
	if health < max_health and health > 0 and not is_dead:
		var bar_w = 16.0
		var bar_h = 3.0
		var pos_y = -14.0
		
		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.12, 0.12, 0.12, 0.85))
		var ratio = clamp(float(health) / float(max_health), 0.0, 1.0)
		draw_rect(Rect2(-bar_w * 0.5 + 1.0, pos_y + 0.5, (bar_w - 2.0) * ratio, bar_h - 1.0), Color(0.95, 0.25, 0.2, 0.95))
		draw_rect(Rect2(-bar_w * 0.5, pos_y, bar_w, bar_h), Color(0.08, 0.08, 0.08, 0.9), false, 1.0)

func _damage_player(body: Node2D):
	if is_dead:
		return
	if body.name == "Player":
		if body.velocity.y <= 0 or body.global_position.y > global_position.y - 8:
			if body.has_method("take_damage"):
				body.take_damage(1, global_position)
			elif body.has_method("die"):
				body.die()

func _on_stomp_area_body_entered(body):
	if is_dead:
		return
	if body.name == "Player":
		if body.velocity.y > 0:
			body.velocity.y = -250.0
			take_damage(max_health, Vector2.DOWN)

func _on_hurt_area_body_entered(body):
	_damage_player(body)
