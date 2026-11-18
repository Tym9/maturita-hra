class_name ReactorWarden
extends Node2D

## Boss: Správce reaktoru (korporátní mech). Vznáší se a je pancéřovaný; počátek uzlu = jádro.
## Útoky: salva parních střel (míří, předem ukáže paprsek) a úder pístem (označí místo, spadne, po zemi
## vyšle dvě střely do stran). Po úderu je jádro chvíli odkryté: hasák / dash / hák ho zraní, nejvýš
## WINDOW_DAMAGE za jedno okno. Fáze 2 (půlka životů): Správce obrací gravitaci sálu, salvy jsou vějíře
## a všechno je rychlejší. Smrt hráče (room_reset) vrátí souboj na začátek aktuální fáze.

signal defeated

enum State { INTRO, HOVER, VOLLEY, SLAM_AIM, SLAM_DROP, EXPOSED, RISE, FLIP, DEAD }

const MAX_HP := 16
const PHASE2_HP := 8
const WINDOW_DAMAGE := 4
const FOOT := 16.0 # od jádra k patě pístů
const BAR_X := 70.0 # ukazatel životů: mezi srdci vlevo a počtem zabití vpravo
const BAR_Y := 12.0
const BAR_W := 180.0
const BAR_H := 5.0
const BULLET := preload("res://enemies/steam_bullet.tscn")
const CYCLES := {1: [State.VOLLEY, State.SLAM_AIM], 2: [State.FLIP, State.VOLLEY, State.SLAM_AIM, State.VOLLEY, State.SLAM_AIM]}

## Volný prostor sálu v souřadnicích rodiče (místnosti)
@export var arena := Rect2(16, 32, 288, 128)
@export_file("*.tscn") var end_scene := "res://ui/grand_summary_screen.tscn"

var hp := MAX_HP
var phase := 1
var state := State.INTRO
var timer := 1.5
var grav := 1.0 # gravitace sálu: 1 dolů, -1 nahoru
var step := 0
var window_damage := 0
var shots_left := 0
var landing_y := 0.0
var flash := 0.0
var msg := ""
var msg_timer := 0.0
var clock := 0.0
var start_pos := Vector2.ZERO
var player: Node2D = null
var hp_fill: ColorRect = null
var hp_lag: ColorRect = null

@onready var hurt_area: Area2D = $HurtArea

func _ready():
	start_pos = position
	Global.room_reset.connect(_reset)
	_build_hp_bar()

func _physics_process(delta):
	clock += delta
	flash = maxf(flash - delta, 0.0)
	msg_timer = maxf(msg_timer - delta, 0.0)
	queue_redraw()
	hp_fill.size.x = BAR_W * hp / MAX_HP
	hp_fill.color = Color(0.9, 0.3, 0.25) if phase == 1 else Color(0.75, 0.4, 0.95)
	hp_lag.size.x = maxf(hp_fill.size.x, hp_lag.size.x - 40.0 * delta)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	timer -= delta
	var fast := phase == 2
	match state:
		State.INTRO, State.HOVER:
			_hover(delta)
			if timer <= 0.0:
				_next_attack()
		State.VOLLEY:
			_hover(delta)
			if timer <= 0.0:
				_fire_volley()
				shots_left -= 1
				if shots_left > 0:
					timer = 0.7 if fast else 0.35
				else:
					_to_hover()
		State.SLAM_AIM:
			if timer > 0.25: # posledních 0.25 s už hráče nesleduje: dá se uhnout
				position.x = move_toward(position.x, clampf(_player_pos().x, arena.position.x + 22.0, arena.end.x - 22.0), 170.0 * delta)
			position.y = move_toward(position.y, _hover_y(), 120.0 * delta)
			landing_y = _find_landing()
			if timer <= 0.0:
				state = State.SLAM_DROP
		State.SLAM_DROP:
			position.y = move_toward(position.y, landing_y, 460.0 * delta)
			if is_equal_approx(position.y, landing_y):
				_shockwave()
				state = State.EXPOSED
				timer = 1.5 if fast else 1.8
				window_damage = 0
		State.EXPOSED:
			if timer <= 0.0:
				state = State.RISE
		State.RISE:
			position.y = move_toward(position.y, _hover_y(), 130.0 * delta)
			if is_equal_approx(position.y, _hover_y()):
				_to_hover()
		State.FLIP:
			_hover(delta)
			if timer <= 0.0:
				grav = -grav
				player.set_gravity_dir(grav)
				_to_hover()
		State.DEAD:
			position.y += 30.0 * grav * delta
			rotation += 0.6 * delta
			modulate.a = clampf(timer / 2.2, 0.0, 1.0)
			if timer <= 0.0:
				set_physics_process(false)
				defeated.emit()
				if end_scene != "":
					Global.finish_stage("", 0, "") # boss jako etapa v závěrečné tabulce (uloží i stav hráče)
					get_tree().change_scene_to_file(end_scene)
			return
	# Dotyk: pancíř i padající píst zraní; odkryté jádro ne (dá se k němu přijít), dopad na něj shora ho zraní
	var exposed := state == State.EXPOSED
	if EnemyContact.resolve(self, hurt_area, Vector2.ZERO, not exposed) == EnemyContact.STOMP and exposed:
		take_hit(2)

## Zásah hráčem (hasák, dash, hák): mimo okno po úderu ho pancíř odrazí.
func take_hit(amount: int = 1, _from_dir: Vector2 = Vector2.ZERO):
	if state == State.DEAD:
		return
	if state != State.EXPOSED:
		_say("PANCÍŘ!")
		return
	hp -= amount
	window_damage += amount
	flash = 0.12
	if hp <= 0:
		hp = 0
		_die()
	elif phase == 1 and hp <= PHASE2_HP:
		hp = PHASE2_HP
		phase = 2
		step = 0
		state = State.RISE
		_say("PŘETÍŽENÍ JÁDRA!", 1.6)
	elif window_damage >= WINDOW_DAMAGE:
		state = State.RISE

## Starší jméno zásahu.
func take_damage(amount: int = 1, from_dir: Vector2 = Vector2.ZERO):
	take_hit(amount, from_dir)

func _next_attack():
	# Do skupiny až po úvodu: kamera si při startu pamatuje "enemies" a po smrti hráče je vytváří znovu,
	# tím by se ztratila fáze. Správce se vrací sám (_reset).
	add_to_group("enemies")
	var cycle: Array = CYCLES[phase]
	state = cycle[step % cycle.size()]
	step += 1
	match state:
		State.VOLLEY:
			timer = 0.7 # paprsek míří, pak první výstřel
			shots_left = 2 if phase == 2 else 3
		State.SLAM_AIM:
			timer = 0.8 if phase == 2 else 1.0
			landing_y = _find_landing()
		State.FLIP:
			timer = 1.1
			_say("GRAVITACE!", 1.1)

func _to_hover():
	state = State.HOVER
	timer = 0.7 if phase == 2 else 1.2

func _hover_y() -> float:
	return arena.get_center().y - 32.0 * grav

func _hover(delta: float):
	var target := Vector2(arena.get_center().x + 90.0 * sin(clock * 0.7), _hover_y() + 4.0 * sin(clock * 3.0))
	position = position.move_toward(target, 80.0 * delta)

func _player_pos() -> Vector2:
	return get_parent().to_local(player.global_position)

## Kam píst dopadne: první pevný povrch ve směru gravitace (lávka nebo podlaha / strop).
func _find_landing() -> float:
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 240.0 * grav), 1, [player.get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	var surface: float = get_parent().to_local(hit.position).y if not hit.is_empty() else (arena.end.y if grav > 0.0 else arena.position.y)
	return surface - FOOT * grav

func _fire_volley():
	var dir := (_player_pos() - position).normalized()
	for angle in ([-0.32, 0.0, 0.32] if phase == 2 else [0.0]):
		_spawn_bullet(position + dir * 20.0, dir.rotated(angle), 175.0)

func _shockwave():
	for side in [-1.0, 1.0]:
		_spawn_bullet(position + Vector2(22.0 * side, (FOOT - 6.0) * grav), Vector2(side, 0.0), 210.0 if phase == 2 else 170.0)

func _spawn_bullet(pos: Vector2, dir: Vector2, speed: float):
	var bullet := BULLET.instantiate()
	bullet.position = pos
	bullet.speed = speed
	bullet.setup(dir)
	get_parent().add_child(bullet)

func _clear_bullets():
	for b in get_tree().get_nodes_in_group("enemy_projectiles"):
		b.queue_free()

func _say(text: String, time: float = 0.6):
	msg = text
	msg_timer = time

## Smrt hráče: souboj začne znovu od začátku aktuální fáze (hráči respawn vrátí normální gravitaci).
func _reset():
	if state == State.DEAD:
		return
	hp = MAX_HP if phase == 1 else PHASE2_HP
	grav = 1.0
	step = 0
	state = State.INTRO
	timer = 1.2
	position = start_pos
	_clear_bullets()

func _die():
	state = State.DEAD
	timer = 2.2
	Global.kill_count += 1
	_clear_bullets()
	if is_instance_valid(player):
		player.set_gravity_dir(1.0)
	_say("JÁDRO ZNIČENO", 2.2)

func _build_hp_bar():
	# Nahoře uprostřed (ve stropě sálu): dole by ho zakryly sloty výstroje.
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "SPRÁVCE REAKTORU"
	title.position = Vector2(BAR_X, 0)
	title.size = Vector2(BAR_W, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	title.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.1))
	title.add_theme_constant_override("outline_size", 3)
	layer.add_child(title)
	var frame := ColorRect.new()
	frame.color = Color(0.72, 0.55, 0.25)
	frame.position = Vector2(BAR_X - 2, BAR_Y - 2)
	frame.size = Vector2(BAR_W + 4, BAR_H + 4)
	layer.add_child(frame)
	var back := ColorRect.new()
	back.color = Color(0.08, 0.06, 0.1)
	back.position = Vector2(BAR_X - 1, BAR_Y - 1)
	back.size = Vector2(BAR_W + 2, BAR_H + 2)
	layer.add_child(back)
	hp_lag = ColorRect.new() # právě ubraný kus: chvíli svítí bíle a dojíždí
	hp_lag.color = Color(1, 0.95, 0.8)
	hp_lag.position = Vector2(BAR_X, BAR_Y)
	hp_lag.size = Vector2(BAR_W, BAR_H)
	layer.add_child(hp_lag)
	hp_fill = ColorRect.new()
	hp_fill.color = Color(0.9, 0.3, 0.25)
	hp_fill.position = Vector2(BAR_X, BAR_Y)
	hp_fill.size = Vector2(BAR_W, BAR_H)
	layer.add_child(hp_fill)
	var mark := ColorRect.new() # hranice fáze 2
	mark.color = Color(1, 1, 1, 0.8)
	mark.position = Vector2(BAR_X + BAR_W * PHASE2_HP / MAX_HP, BAR_Y - 1)
	mark.size = Vector2(1, BAR_H + 2)
	layer.add_child(mark)

func _draw():
	var brass := Color(0.72, 0.55, 0.25) if phase == 1 else Color(0.62, 0.42, 0.7)
	var iron := Color(0.28, 0.28, 0.34)
	var warn := Color(1.0, 0.25, 0.2, 0.35 + 0.3 * sin(clock * 20.0))
	# Varování před útokem
	if state == State.SLAM_AIM or state == State.SLAM_DROP:
		var foot := landing_y - position.y + FOOT * grav
		draw_rect(Rect2(-18, minf(0.0, foot), 36, absf(foot)), Color(1.0, 0.25, 0.2, 0.12))
		draw_line(Vector2(-22, foot), Vector2(22, foot), warn, 2.0)
	elif state == State.VOLLEY and is_instance_valid(player):
		draw_line(Vector2.ZERO, to_local(player.global_position), warn, 1.0)
	elif state == State.FLIP:
		var a := Rect2(arena.position - position, arena.size)
		draw_rect(a, Color(0.7, 0.4, 1.0, 0.1 + 0.08 * sin(clock * 16.0)))
		for i in 5: # šipky ukazují, kam gravitace přepadne
			var p := Vector2(a.position.x + a.size.x * (i + 0.5) / 5.0, a.get_center().y)
			draw_line(p + Vector2(-6, 4 * grav), p + Vector2(0, -6 * grav), Color(0.8, 0.6, 1.0, 0.8), 2.0)
			draw_line(p + Vector2(6, 4 * grav), p + Vector2(0, -6 * grav), Color(0.8, 0.6, 1.0, 0.8), 2.0)
	# Tělo (písty míří po směru gravitace sálu)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, grav))
	var leg := FOOT - 8.0 if state in [State.SLAM_DROP, State.EXPOSED] else 4.0
	for x in [-14.0, 9.0]:
		draw_rect(Rect2(x, 8, 5, leg), iron)
		draw_rect(Rect2(x - 1, 8 + leg - 2, 7, 2), brass)
	draw_rect(Rect2(-18, -12, 36, 22), brass)
	draw_rect(Rect2(-18, -12, 36, 22), iron, false, 1.0)
	draw_rect(Rect2(-23, -8, 5, 12), iron)
	draw_rect(Rect2(18, -8, 5, 12), iron)
	draw_rect(Rect2(-10, -9, 20, 4), Color(0.08, 0.06, 0.1))
	var eye_x := clampf(to_local(player.global_position).x * 0.1, -7.0, 7.0) if is_instance_valid(player) else 0.0
	draw_rect(Rect2(eye_x - 2, -8, 4, 2), Color(1.0, 0.3, 0.2))
	if state == State.EXPOSED:
		draw_circle(Vector2(0, 3), 6.0 + sin(clock * 14.0), Color(0.3, 0.95, 0.85))
		draw_circle(Vector2(0, 3), 2.5, Color.WHITE)
	else:
		draw_circle(Vector2(0, 3), 6.0, iron)
		draw_line(Vector2(-5, 3), Vector2(5, 3), Color(0.3, 0.95, 0.85, 0.6), 1.0)
	if flash > 0.0:
		draw_rect(Rect2(-18, -12, 36, 22), Color(1, 1, 1, 0.7))
	draw_set_transform(Vector2.ZERO)
	if msg_timer > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(-50, -20 if grav > 0.0 else 30), msg, HORIZONTAL_ALIGNMENT_CENTER, 100, 8, Color(1, 0.9, 0.5))
