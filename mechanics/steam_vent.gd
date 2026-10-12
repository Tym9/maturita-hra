extends Area2D

## Časovaná parní tryska (SteamVent).
## Periodicky chrlí horkou páru, která hráče popálí (1 HP) a odhodí tlakem.
## Fáze: IDLE -> WARN (syčení/varování) -> BLAST (výtrysk páry).

enum State { IDLE, WARN, BLAST }

@export var idle_time: float = 2.0
@export var warn_time: float = 0.5
@export var blast_time: float = 1.0
@export var blast_length: float = 64.0
@export var blast_direction: Vector2 = Vector2.UP # UP, DOWN, LEFT, RIGHT

var current_state: State = State.IDLE
var timer: float = 0.0
var anim_time: float = 0.0

@onready var collision_shape = $CollisionShape2D

func _ready():
	add_to_group("hazards")
	blast_direction = blast_direction.normalized()
	body_entered.connect(_on_body_entered)
	_update_collision()

func _physics_process(delta):
	timer += delta
	anim_time += delta
	
	match current_state:
		State.IDLE:
			if timer >= idle_time:
				timer = 0.0
				current_state = State.WARN
				_update_collision()
		State.WARN:
			if timer >= warn_time:
				timer = 0.0
				current_state = State.BLAST
				_update_collision()
				_check_overlapping_bodies()
		State.BLAST:
			if timer >= blast_time:
				timer = 0.0
				current_state = State.IDLE
				_update_collision()
				
	queue_redraw()

func _update_collision():
	if not collision_shape:
		return
	collision_shape.disabled = (current_state != State.BLAST)

func _check_overlapping_bodies():
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_hit_player(body)

func _on_body_entered(body):
	if current_state == State.BLAST and body.is_in_group("player"):
		_hit_player(body)

func _hit_player(player: CharacterBody2D):
	if player.has_method("take_damage"):
		player.take_damage(1, global_position)
	player.velocity += blast_direction * 260.0

func _draw():
	# 1. Kovová tryska v podlaze (šířka 16, výška 6)
	var base_rect = Rect2(-8, -3, 16, 6)
	draw_rect(base_rect, Color(0.2, 0.16, 0.12, 1.0))
	draw_rect(Rect2(-7, -2, 14, 4), Color(0.65, 0.42, 0.22, 1.0))
	draw_rect(base_rect, Color(0.1, 0.08, 0.06, 1.0), false, 1.0)
	
	# Mřížka trysky
	draw_line(Vector2(-4, -2), Vector2(-4, 2), Color(0.1, 0.08, 0.06, 1.0), 1.0)
	draw_line(Vector2(0, -2), Vector2(0, 2), Color(0.1, 0.08, 0.06, 1.0), 1.0)
	draw_line(Vector2(4, -2), Vector2(4, 2), Color(0.1, 0.08, 0.06, 1.0), 1.0)
	
	match current_state:
		State.IDLE:
			# Drobné varovné unikání páry
			var puff_y = -4.0 - fmod(anim_time * 8.0, 10.0)
			var puff_alpha = 1.0 - (abs(puff_y) / 14.0)
			draw_circle(Vector2(0, puff_y), 2.5, Color(0.9, 0.95, 1.0, puff_alpha * 0.35))
			
		State.WARN:
			# Syčící varování (vibrace a tenké gejzíry)
			var shake = sin(anim_time * 30.0) * 1.5
			draw_line(Vector2(shake, -3), Vector2(shake * 1.5, -16), Color(1.0, 0.65, 0.3, 0.7), 1.5)
			draw_circle(Vector2(0, -5), 4.0, Color(1.0, 0.7, 0.3, 0.35))
			
		State.BLAST:
			# Masivní sloup horké páry
			var wave = sin(anim_time * 24.0) * 2.0
			var end_pt = blast_direction * blast_length
			
			# Vnitřní jádro horké páry
			draw_line(Vector2.ZERO, end_pt, Color(0.95, 0.98, 1.0, 0.85), 10.0)
			# Vnější chladnější plášť páry
			draw_line(Vector2.ZERO, end_pt + Vector2(wave, 0), Color(0.8, 0.88, 1.0, 0.45), 16.0)
			# Oblaka na vrcholu gejzíru
			draw_circle(end_pt, 7.0 + wave, Color(0.9, 0.95, 1.0, 0.5))
			draw_circle(end_pt * 0.6, 6.0 - wave, Color(0.9, 0.95, 1.0, 0.4))
