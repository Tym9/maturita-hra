@tool
class_name GridSpikes
extends Area2D

## Modulární čtvercové nebezpečné bodáky (16x16 px)
## Vysoký vizuální kontrast (karmínové a oranžové hroty), okamžitá smrt při dotyku.

const ORIENTATION_UP = 0
const ORIENTATION_DOWN = 1
const ORIENTATION_LEFT = 2
const ORIENTATION_RIGHT = 3

@export var count: int = 1:
	set(val):
		count = maxi(1, val)
		_update_collision()
		queue_redraw()

@export_enum("UP", "DOWN", "LEFT", "RIGHT") var orientation: int = 0:
	set(val):
		orientation = val
		_update_collision()
		queue_redraw()

@export var cell_size: int = 16:
	set(val):
		cell_size = maxi(8, val)
		_update_collision()
		queue_redraw()

var col_shape: CollisionShape2D = null

const COLOR_BASE = Color(0.18, 0.10, 0.14, 1.0)
const COLOR_SPIKE = Color(0.92, 0.18, 0.22, 1.0)
const COLOR_TIP = Color(1.0, 0.82, 0.35, 1.0)
const COLOR_OUTLINE = Color(0.10, 0.04, 0.06, 1.0)

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	_update_collision()
	queue_redraw()

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		if body.has_method("die"):
			body.die()

func _update_collision():
	col_shape = get_node_or_null("CollisionShape2D")
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		add_child(col_shape)
		if Engine.is_editor_hint() and is_inside_tree() and get_tree():
			col_shape.owner = get_tree().edited_scene_root
	
	var rect_shape = col_shape.shape as RectangleShape2D
	if not rect_shape:
		rect_shape = RectangleShape2D.new()
		col_shape.shape = rect_shape
	
	# Férový hitbox: mírně zmenšený oproti vizuálu, aby trestal jen reálný náraz
	match orientation:
		ORIENTATION_UP:
			rect_shape.size = Vector2(count * cell_size - 4.0, 10.0)
			col_shape.position = Vector2(count * cell_size * 0.5, cell_size - 5.0)
		ORIENTATION_DOWN:
			rect_shape.size = Vector2(count * cell_size - 4.0, 10.0)
			col_shape.position = Vector2(count * cell_size * 0.5, 5.0)
		ORIENTATION_LEFT:
			rect_shape.size = Vector2(10.0, count * cell_size - 4.0)
			col_shape.position = Vector2(cell_size - 5.0, count * cell_size * 0.5)
		ORIENTATION_RIGHT:
			rect_shape.size = Vector2(10.0, count * cell_size - 4.0)
			col_shape.position = Vector2(5.0, count * cell_size * 0.5)

func _draw():
	var tooth_w = cell_size / 2.0
	var total_teeth = count * 2
	
	for i in range(total_teeth):
		var offset = float(i) * tooth_w
		var p1 = Vector2.ZERO
		var p2 = Vector2.ZERO
		var p_tip = Vector2.ZERO
		
		match orientation:
			ORIENTATION_UP:
				p1 = Vector2(offset, cell_size)
				p2 = Vector2(offset + tooth_w, cell_size)
				p_tip = Vector2(offset + tooth_w * 0.5, 2.0)
			ORIENTATION_DOWN:
				p1 = Vector2(offset, 0.0)
				p2 = Vector2(offset + tooth_w, 0.0)
				p_tip = Vector2(offset + tooth_w * 0.5, cell_size - 2.0)
			ORIENTATION_LEFT:
				p1 = Vector2(cell_size, offset)
				p2 = Vector2(cell_size, offset + tooth_w)
				p_tip = Vector2(2.0, offset + tooth_w * 0.5)
			ORIENTATION_RIGHT:
				p1 = Vector2(0.0, offset)
				p2 = Vector2(0.0, offset + tooth_w)
				p_tip = Vector2(cell_size - 2.0, offset + tooth_w * 0.5)
		
		# Tělo bodáku
		draw_colored_polygon(PackedVector2Array([p1, p2, p_tip]), COLOR_SPIKE)
		
		# Ostrá špička (zvýraznění)
		var mid_l = p1.lerp(p_tip, 0.6)
		var mid_r = p2.lerp(p_tip, 0.6)
		draw_colored_polygon(PackedVector2Array([mid_l, mid_r, p_tip]), COLOR_TIP)
		
		# Tmavá spodní základna
		draw_line(p1, p2, COLOR_BASE, 2.0)
		
		# Obrys
		draw_polyline(PackedVector2Array([p1, p_tip, p2]), COLOR_OUTLINE, 1.0)
