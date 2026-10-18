class_name PressureMine
extends Node2D

## Tlaková mina: když se hráč přiblíží (`trigger_radius`), `inflate_time` s se nafukuje a rudě bliká
## (telegraf), pak praskne: hráče v `burst_radius` odhodí od sebe (player.launch) a obnoví mu dash -
## na výbuchu se dá svézt, dopad shora = odraz nahoru. Dotyk nebo zásah útokem (take_hit) ji odpálí
## hned. Za `respawn_time` s se znovu složí (posledních 0.5 s probleskuje).

enum State { IDLE, INFLATE, GONE }

const BODY_RADIUS := 7.0

@export var trigger_radius: float = 40.0
@export var burst_radius: float = 36.0
@export var inflate_time: float = 0.5
@export var launch_speed: float = 330.0
@export var respawn_time: float = 3.0

var state: State = State.IDLE
var timer: float = 0.0
var flash: float = 0.0
var anim: float = 0.0
var body_area: Area2D = null

func _ready():
	add_to_group("enemies")
	body_area = Area2D.new()
	body_area.collision_layer = 2 # vrstva nepřátel: hák ji zasáhne
	body_area.collision_mask = 1
	var col := CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = BODY_RADIUS
	body_area.add_child(col)
	add_child(body_area)

func _physics_process(delta):
	anim += delta
	flash = maxf(0.0, flash - delta * 4.0)
	var player = get_tree().get_first_node_in_group("player")
	match state:
		State.IDLE:
			if HazardKill.player_in(body_area):
				_burst()
			elif player and global_position.distance_to(player.global_position) <= trigger_radius:
				state = State.INFLATE
				timer = inflate_time
		State.INFLATE:
			timer -= delta
			if timer <= 0.0 or HazardKill.player_in(body_area):
				_burst()
		State.GONE:
			timer -= delta
			if timer <= 0.0:
				state = State.IDLE
				body_area.collision_layer = 2
	queue_redraw()

func _burst():
	state = State.GONE
	timer = respawn_time
	flash = 1.0
	body_area.set_deferred("collision_layer", 0) # prasklou minu hák nenajde
	var player = get_tree().get_first_node_in_group("player")
	if player and not player.is_dying and global_position.distance_to(player.global_position) <= burst_radius:
		var dir: Vector2 = (player.global_position - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2(0.0, -player.gravity_dir)
		player.launch(dir * launch_speed + Vector2(0.0, -80.0 * player.gravity_dir), 0.15)
		player.refill_dash()

func take_hit(_damage: int = 1, _direction: Vector2 = Vector2.ZERO):
	if state != State.GONE:
		_burst()

func _draw():
	if flash > 0.0:
		draw_arc(Vector2.ZERO, burst_radius * (1.0 - flash * 0.5), 0.0, TAU, 24, Color(1.0, 0.6, 0.2, flash), 2.0)
	if state == State.GONE:
		if timer < 0.5 and fmod(timer, 0.1) < 0.05:
			draw_arc(Vector2.ZERO, BODY_RADIUS, 0.0, TAU, 12, Color(1.0, 0.5, 0.2, 0.5), 1.0)
		return
	var swell := 1.0
	var col := Color(0.85, 0.35, 0.15)
	if state == State.INFLATE:
		swell = 1.0 + 0.6 * (1.0 - timer / inflate_time)
		if fmod(timer, 0.1) < 0.05:
			col = Color(1.0, 0.15, 0.1)
	var r := BODY_RADIUS * swell
	for i in 8:
		var a := i * TAU / 8.0 + anim * 0.5
		draw_line(Vector2.RIGHT.rotated(a) * r, Vector2.RIGHT.rotated(a) * (r + 3.0), Color(0.3, 0.12, 0.08), 2.0)
	draw_circle(Vector2.ZERO, r, col)
	draw_circle(Vector2(-2, -2) * swell, 1.5, Color(1.0, 0.85, 0.6))
