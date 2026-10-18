@tool
extends Node2D

# Kotva pro přitahovací hák. Hráč se k ní může přitáhnout klávesou E (hák),
# pokud je v dosahu a nic nestojí v cestě.
# Pohyblivá (`rail_end` ≠ 0): jezdí tam a zpět podle sdílených hodin, hák ji sleduje a odskok
# z háku přičte její rychlost. Křehká (`breakable`): `break_delay` s po zachycení praskne a hák pustí.
# room_reset křehkou kotvu obnoví.

@export var rail_end: Vector2 = Vector2.ZERO:
	set(val):
		rail_end = val
		queue_redraw()
@export var period: float = 3.0
@export var offset: float = 0.0
@export var breakable: bool = false:
	set(val):
		breakable = val
		queue_redraw()
@export var break_delay: float = 0.6

var highlighted: bool = false
var time: float = 0.0
var home: Vector2 = Vector2.ZERO
var crack_timer: float = -1.0
var grappler: CharacterBody2D = null

func _ready():
	home = position
	if Engine.is_editor_hint():
		return
	add_to_group("grapple_points")
	Global.room_reset.connect(_restore)

func set_highlight(value: bool):
	highlighted = value
	queue_redraw()

func _process(delta):
	time += delta
	if highlighted or rail_end != Vector2.ZERO or crack_timer >= 0.0:
		queue_redraw()

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	var hooked: bool = is_instance_valid(grappler) and grappler.grapple_anchor == self
	if rail_end != Vector2.ZERO:
		var prev := position
		var u := BeatClock.phase(period, offset) / period
		position = home + rail_end * (1.0 - absf(2.0 * u - 1.0))
		if hooked:
			grappler.set_lift_velocity((position - prev) / delta)
	if crack_timer >= 0.0:
		crack_timer -= delta
		if crack_timer < 0.0:
			# Ulomí se: z háku se pustí, hák ji už nenajde
			remove_from_group("grapple_points")
			hide()
			if hooked:
				grappler.release_grapple()

## Volá hráč při zachycení háku.
func on_grappled(player: CharacterBody2D):
	grappler = player
	if breakable and crack_timer < 0.0 and visible:
		crack_timer = break_delay

func _restore():
	crack_timer = -1.0
	show()
	if not is_in_group("grapple_points"):
		add_to_group("grapple_points")

func _draw():
	if rail_end != Vector2.ZERO:
		draw_line(home - position, home + rail_end - position, Color(0.55, 0.4, 0.2, 0.6), 1.0)
	var bronze = Color(0.8, 0.55, 0.2)
	var radius = 6.0
	var shake := Vector2.ZERO
	if crack_timer >= 0.0:
		shake = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if highlighted:
		bronze = Color(1.0, 0.85, 0.4)
		radius = 7.0 + sin(time * 8.0)
		draw_arc(shake, radius + 4.0, 0.0, TAU, 24, Color(1.0, 0.9, 0.5, 0.6), 1.0)
	draw_circle(shake, radius, Color(0.25, 0.15, 0.08))
	draw_arc(shake, radius, 0.0, TAU, 24, bronze, 2.0)
	# Ozubené "ozubené kolo" - čtyři zuby
	for i in 4:
		var angle = i * PI / 2.0 + time * 0.5
		draw_line(shake + Vector2.RIGHT.rotated(angle) * radius, shake + Vector2.RIGHT.rotated(angle) * (radius + 2.5), bronze, 2.0)
	if breakable:
		# Křehká kotva: praskliny; po zachycení rudě žhnou (telegraf ulomení)
		var crack := Color(1.0, 0.3, 0.2) if crack_timer >= 0.0 else Color(0.5, 0.35, 0.25)
		draw_line(shake + Vector2(-4, -3), shake + Vector2(0, 1), crack, 1.0)
		draw_line(shake + Vector2(0, 1), shake + Vector2(3, -2), crack, 1.0)
		draw_line(shake + Vector2(0, 1), shake + Vector2(1, 5), crack, 1.0)
