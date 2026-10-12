@tool
class_name CollectibleCrystal
extends Area2D

## Sběratelský éterický / parní krystal
## Umísťuje se na těžko dostupná místa (styl jahod v Celeste).
## Zářící diamantový vizuál, sinusová levitace a animace sebrání.

@export var crystal_id: String = ""
@export var crystal_color: Color = Color(0.25, 0.92, 1.0, 1.0) # Zářivá azurová / éter
@export var crystal_value: int = 1

var time: float = 0.0
var base_y: float = 0.0
var is_collected: bool = false
var collecting_anim: float = 0.0

@onready var col_shape = get_node_or_null("CollisionShape2D")

func _ready():
	base_y = position.y
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	add_to_group("collectibles")
	_ensure_collision()
	queue_redraw()

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
	
	if is_collected:
		collecting_anim += delta * 3.5
		position.y -= delta * 40.0
		modulate.a = maxf(0.0, 1.0 - collecting_anim)
		scale = Vector2.ONE * (1.0 + collecting_anim * 0.7)
		if collecting_anim >= 1.0:
			queue_free()
		queue_redraw()
		return
	
	# Plynulá levitace (bobbing)
	position.y = base_y + sin(time * 3.2) * 3.0
	queue_redraw()

func _on_body_entered(body):
	if is_collected:
		return
	if body.name == "Player" or body.is_in_group("player"):
		collect(body)

func collect(player_node):
	is_collected = true
	if player_node.has_method("add_crystal"):
		var effective_id = crystal_id if not crystal_id.is_empty() else name
		player_node.add_crystal(crystal_value, effective_id)
	queue_redraw()

func _draw():
	var glow_pulse = 1.0 + sin(time * 5.0) * 0.12
	var r = 6.0 * glow_pulse
	
	# 1. Vnější pulzující záře (aura)
	draw_arc(Vector2.ZERO, r + 3.5, 0.0, TAU, 16, Color(crystal_color.r, crystal_color.g, crystal_color.b, 0.35), 1.5)
	draw_circle(Vector2.ZERO, r * 0.6, Color(crystal_color.r, crystal_color.g, crystal_color.b, 0.2))
	
	# 2. Vrcholy diamantu
	var p_top = Vector2(0.0, -r * 1.35)
	var p_bottom = Vector2(0.0, r * 1.35)
	var p_left = Vector2(-r, 0.0)
	var p_right = Vector2(r, 0.0)
	
	# 3. Levá fazeta (stín)
	draw_colored_polygon(PackedVector2Array([p_top, p_left, p_bottom]), crystal_color.darkened(0.3))
	# 4. Pravá fazeta (světlo)
	draw_colored_polygon(PackedVector2Array([p_top, p_right, p_bottom]), crystal_color)
	
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
