@tool
class_name CollectibleCrystal
extends Area2D

## Sběratelský gravitační krystal (jahoda z Celeste).
## Po dotyku letí za hráčem ve frontě (player.crystal_trail); započítá se až po 0.15 s na pevné
## bezpečné zemi (ne na drolící se ani pohyblivé plošině). Smrt (room_reset) ho pošle zpět na místo.
## Id = room_id + pořadí v místnosti; sebraná id se ukládají trvale (SaveManager.progress) a příště
## se krystal ukáže jako průhledný duch, který jde sebrat, ale znovu se nezapočítá.

enum Variant { NORMAL, WINGED, HIDDEN, GRAND }

const SAFE_GROUND_TIME: float = 0.15
const GHOST_ALPHA: float = 0.4
const COLLECT_SOUND = preload("res://assets/placeholder/crystal_collect.wav")

## Ruční id; prázdné = room_id + pořadí v místnosti (u starých levelů bez místností název uzlu)
@export var crystal_id: String = ""
## WINGED uletí, když hráč v místnosti dashne; HIDDEN čeká na signál; GRAND = velké tajemství kapitoly
@export var variant: Variant = Variant.NORMAL:
	set(val):
		variant = val
		queue_redraw()
@export var crystal_color: Color = Color(0.25, 0.92, 1.0, 1.0) # Zářivá azurová / éter
@export var crystal_value: int = 1
## HIDDEN: krystal se zjeví, když uzel `reveal_source` vyšle signál `reveal_signal`
@export var reveal_source: NodePath
@export var reveal_signal: StringName = &"activated"

var id: String = ""
var ghost: bool = false
var time: float = 0.0
var base_y: float = 0.0
var is_collected: bool = false
var collecting_anim: float = 0.0
var follow_player: CharacterBody2D = null
var home_position: Vector2 = Vector2.ZERO
var flown: bool = false
var safe_time: float = 0.0 # jak dlouho hráč s tímto krystalem stojí na bezpečné zemi
var motion_tween: Tween = null

@onready var col_shape = get_node_or_null("CollisionShape2D")

func _ready():
	base_y = position.y
	home_position = position
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	add_to_group("collectibles")
	_ensure_collision()
	queue_redraw()
	if Engine.is_editor_hint():
		return
	id = _make_id()
	ghost = SaveManager.has_crystal(id)
	if ghost:
		modulate.a = GHOST_ALPHA
	Global.room_reset.connect(_on_room_reset)
	if variant == Variant.HIDDEN:
		visible = false
		monitoring = false
		var source := get_node_or_null(reveal_source)
		if source:
			source.connect(reveal_signal, _reveal)

func _make_id() -> String:
	if not crystal_id.is_empty():
		return crystal_id
	var room := Room.of(self)
	if room == null:
		return name
	var index := 0
	for c in room.find_children("*", "Area2D", true, false):
		if c == self:
			break
		if c is CollectibleCrystal:
			index += 1
	return "%s_%d" % [room.room_id, index]

func _ensure_collision():
	col_shape = get_node_or_null("CollisionShape2D")
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		var circle = CircleShape2D.new()
		circle.radius = 8.0
		col_shape.shape = circle
		add_child(col_shape)
		if Engine.is_editor_hint():
			col_shape.owner = get_tree().edited_scene_root if get_tree() else null

func _process(delta):
	time += delta
	queue_redraw()

	if is_collected:
		collecting_anim += delta * 3.5
		position.y -= delta * 40.0
		modulate.a = maxf(0.0, 1.0 - collecting_anim) * (GHOST_ALPHA if ghost else 1.0)
		scale = Vector2.ONE * (1.0 + collecting_anim * 0.7)
		if collecting_anim >= 1.0:
			hide() # zůstává ve skupině kvůli statistikám kapitoly v menu pauzy
			set_process(false)
		return

	if follow_player:
		# Fronta: první krystal letí za hráčem, každý další za předchozím
		var i: int = follow_player.crystal_trail.find(self)
		var leader: Node2D = follow_player if i <= 0 else follow_player.crystal_trail[i - 1]
		var side: float = 10.0 if follow_player.sprite.flip_h else -10.0
		var target: Vector2 = leader.global_position + Vector2(side, -14.0 * follow_player.gravity_dir if i <= 0 else -2.0)
		global_position = global_position.lerp(target, 1.0 - exp(-10.0 * delta))
		return

	if flown or (motion_tween and motion_tween.is_running()):
		return

	# Plynulá levitace (bobbing)
	position.y = base_y + sin(time * 3.2) * 3.0

func _physics_process(_delta):
	if Engine.is_editor_hint() or is_collected:
		return
	if follow_player:
		safe_time = safe_time + _delta if follow_player.safe_ground_time > 0.0 else 0.0
		if safe_time >= SAFE_GROUND_TIME:
			collect(follow_player)
	elif variant == Variant.WINGED and not flown and visible:
		var p = get_tree().get_first_node_in_group("player")
		if p and p.is_dashing and p.camera and p.camera.current_rect().has_point(global_position):
			_fly_away()

func _on_body_entered(body):
	if is_collected or follow_player or flown or (motion_tween and motion_tween.is_running()):
		return
	if body.name == "Player" or body.is_in_group("player"):
		start_follow(body)

func start_follow(player_node: CharacterBody2D):
	follow_player = player_node
	safe_time = 0.0
	player_node.crystal_trail.append(self)

func _leave_trail():
	if follow_player:
		follow_player.crystal_trail.erase(self)
		follow_player = null

func _on_room_reset():
	if is_collected:
		return
	if follow_player:
		# Smrt před započítáním: krystal odplave zpět na své místo
		_leave_trail()
		_move_home(0.6)
	elif flown:
		flown = false
		_move_home(0.0)
		modulate.a = GHOST_ALPHA if ghost else 1.0
		set_deferred("monitoring", true)

func _move_home(duration: float):
	if motion_tween:
		motion_tween.kill()
	base_y = home_position.y
	if duration <= 0.0:
		position = home_position
		return
	motion_tween = create_tween()
	motion_tween.tween_property(self, "position", home_position, duration).set_trans(Tween.TRANS_SINE)

func _fly_away():
	flown = true
	set_deferred("monitoring", false)
	if motion_tween:
		motion_tween.kill()
	motion_tween = create_tween()
	motion_tween.tween_property(self, "position:y", position.y - 220.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	motion_tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)

func _reveal():
	if visible:
		return
	show()
	set_deferred("monitoring", true)
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sparkle()

func collect(player_node):
	if is_collected:
		return
	_leave_trail()
	is_collected = true
	set_deferred("monitoring", false)
	if id.is_empty():
		id = _make_id()
	if not ghost:
		SaveManager.record_crystal(id, variant == Variant.GRAND)
		# GRAND se počítá zvlášť (záznam "grand"), do běžného počítadla nepatří
		if variant != Variant.GRAND and player_node.has_method("add_crystal"):
			player_node.add_crystal(crystal_value, id)
	_sparkle()
	var sound := AudioStreamPlayer.new()
	sound.stream = COLLECT_SOUND
	sound.pitch_scale = 0.8 if variant == Variant.GRAND else 1.0
	sound.finished.connect(sound.queue_free)
	get_parent().add_child(sound)
	sound.play()

func _sparkle():
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 24 if variant == Variant.GRAND else 14
	p.lifetime = 0.5
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 90.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	p.color = _color()
	p.position = position
	get_parent().add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)

func _color() -> Color:
	return Color(1.0, 0.8, 0.3) if variant == Variant.GRAND else crystal_color

## Sebrané / celkové krystaly v aktuální scéně (kapitole) podle trvalých záznamů; GRAND zvlášť.
static func scene_stats(tree: SceneTree) -> Dictionary:
	var s := {"got": 0, "total": 0, "grand_got": 0, "grand_total": 0}
	for c in tree.get_nodes_in_group("collectibles"):
		if c is CollectibleCrystal:
			var pre := "grand_" if c.variant == Variant.GRAND else ""
			s[pre + "total"] += 1
			if SaveManager.has_crystal(c.id):
				s[pre + "got"] += 1
	return s

func _draw():
	var glow_pulse = 1.0 + sin(time * 5.0) * 0.12
	var r = 6.0 * glow_pulse * (1.6 if variant == Variant.GRAND else 1.0)
	var col := _color()

	# 0. Křídla (WINGED): mosazné trojúhelníky, které mávají
	if variant == Variant.WINGED:
		var flap := sin(time * 12.0) * 3.0
		var wing := Color(0.85, 0.65, 0.28)
		draw_colored_polygon(PackedVector2Array([Vector2(-r, 0.0), Vector2(-r - 9.0, -5.0 + flap), Vector2(-r - 3.0, 3.0)]), wing)
		draw_colored_polygon(PackedVector2Array([Vector2(r, 0.0), Vector2(r + 9.0, -5.0 + flap), Vector2(r + 3.0, 3.0)]), wing)

	# 1. Vnější pulzující záře (aura)
	draw_arc(Vector2.ZERO, r + 3.5, 0.0, TAU, 16, Color(col.r, col.g, col.b, 0.35), 1.5)
	draw_circle(Vector2.ZERO, r * 0.6, Color(col.r, col.g, col.b, 0.2))

	# 2. Vrcholy diamantu
	var p_top = Vector2(0.0, -r * 1.35)
	var p_bottom = Vector2(0.0, r * 1.35)
	var p_left = Vector2(-r, 0.0)
	var p_right = Vector2(r, 0.0)

	# 3. Levá fazeta (stín)
	draw_colored_polygon(PackedVector2Array([p_top, p_left, p_bottom]), col.darkened(0.3))
	# 4. Pravá fazeta (světlo)
	draw_colored_polygon(PackedVector2Array([p_top, p_right, p_bottom]), col)

	# 5. Vnitřní bílý odlesk fazety
	draw_colored_polygon(PackedVector2Array([p_top, Vector2(-r * 0.35, 0.0), Vector2(0.0, -r * 0.45)]), Color(1.0, 1.0, 1.0, 0.85))

	# 6. Tmavý tenký obrys
	draw_polyline(PackedVector2Array([p_top, p_left, p_bottom, p_right, p_top]), Color(0.06, 0.12, 0.22, 0.9), 1.0)

	# 7. Obíhající třpytivá jiskra
	var sparkle_angle = time * 2.8
	var sparkle_pos = Vector2(cos(sparkle_angle), sin(sparkle_angle)) * (r + 4.0)
	draw_rect(Rect2(sparkle_pos.x - 1.0, sparkle_pos.y - 1.0, 2.0, 2.0), Color.WHITE)

	# Druhá menší jiskra
	var sparkle2_pos = Vector2(cos(sparkle_angle + PI), sin(sparkle_angle + PI)) * (r + 3.0)
	draw_rect(Rect2(sparkle2_pos.x - 0.5, sparkle2_pos.y - 0.5, 1.0, 1.0), Color(0.8, 1.0, 1.0, 0.8))
