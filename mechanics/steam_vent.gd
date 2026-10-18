extends Area2D

## Časovaná parní tryska (SteamVent).
## Periodicky chrlí horkou páru, která hráče popálí (1 HP) a odhodí tlakem.
## Fáze ze sdílených hodin (BeatClock): IDLE -> WARN (syčení/varování) -> BLAST (výtrysk páry);
## trysky se stejným `offset` jsou synchronní a po room_reset začínají znovu od IDLE.

enum State { IDLE, WARN, BLAST }

const HITBOX_MARGIN := 3.0

@export var idle_time: float = 2.0
@export var warn_time: float = 0.5
@export var blast_time: float = 1.0
@export var offset: float = 0.0
@export var blast_length: float = 64.0
@export var blast_direction: Vector2 = Vector2.UP # UP, DOWN, LEFT, RIGHT

var current_state: State = State.IDLE
var anim_time: float = 0.0
var player_was_hit: bool = false

@onready var collision_shape = $CollisionShape2D

func _ready():
	add_to_group("hazards")
	blast_direction = blast_direction.normalized()
	# Oblast páry podle směru a délky výtrysku, o pár px užší než kreslený sloup (16 px).
	# Vlastní tvar: sdílený zdroj ze scény by změna velikosti přepsala všem tryskám.
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(16.0 - 2.0 * HITBOX_MARGIN, blast_length - HITBOX_MARGIN)
	collision_shape.rotation = Vector2.UP.angle_to(blast_direction)
	collision_shape.position = blast_direction * (blast_length / 2.0)

func _physics_process(delta):
	anim_time += delta
	var p := BeatClock.phase(idle_time + warn_time + blast_time, offset)
	if p < idle_time:
		current_state = State.IDLE
	elif p < idle_time + warn_time:
		current_state = State.WARN
	else:
		current_state = State.BLAST
	# Zásah jen při vstupu do páry (ne každý snímek), jinak by se odhoz sčítal
	var player = HazardKill.player_in(self) if current_state == State.BLAST else null
	if player and not player_was_hit:
		_hit_player(player)
	player_was_hit = player != null
	queue_redraw()

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
