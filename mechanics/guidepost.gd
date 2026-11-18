@tool
class_name Guidepost
extends Node2D

## Dřevěný rozcestník (tutoriál): počátek uzlu = pata kůlu na zemi, na desce klávesa (`key_text`).
## Když hráč přijde blízko, nad cedulí se rozvine pergamen s návodem (`text`), po odchodu zmizí.

const POST_HEIGHT := 18.0
const BOARD_HEIGHT := 11.0
const SHOW_RANGE := Vector2(56.0, 72.0) # vodorovně / svisle od paty kůlu
const FADE_SPEED := 5.0
const WOOD := Color(0.36, 0.23, 0.13)
const WOOD_DARK := Color(0.22, 0.14, 0.08)
const BRASS := Color(0.88, 0.7, 0.28)
const INK := Color(0.25, 0.16, 0.08)

@export var key_text: String = "W":
	set(val):
		key_text = val
		queue_redraw()
@export_multiline var text: String = ""

var panel: Label = null

func _ready():
	z_index = -1 # za hráčem
	if Engine.is_editor_hint():
		return
	panel = Label.new()
	panel.text = text
	panel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_theme_font_size_override("font_size", 8)
	panel.add_theme_color_override("font_color", INK)
	panel.add_theme_constant_override("line_spacing", -3)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.93, 0.86, 0.66)
	paper.border_color = BRASS
	paper.set_border_width_all(1)
	paper.set_content_margin_all(2)
	panel.add_theme_stylebox_override("normal", paper)
	panel.modulate.a = 0.0
	panel.z_index = 10 # nad hráčem i dlaždicemi
	add_child(panel)
	var size := panel.get_combined_minimum_size()
	panel.size = size
	panel.position = Vector2(-size.x / 2.0, -POST_HEIGHT - BOARD_HEIGHT - 4.0 - size.y).round()
	panel.set_meta("home", panel.position)

func _process(delta):
	if Engine.is_editor_hint() or panel == null:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var d := player.global_position - global_position if player else SHOW_RANGE * 2.0
	var near := absf(d.x) < SHOW_RANGE.x and absf(d.y) < SHOW_RANGE.y
	panel.modulate.a = move_toward(panel.modulate.a, 1.0 if near else 0.0, FADE_SPEED * delta)
	# Pergamen nesmí vyjet z obrazu (cedule u kraje místnosti nebo vysoko pod stropem)
	var view := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect()
	var home: Vector2 = global_position + panel.get_meta("home")
	panel.global_position = Vector2(clampf(home.x, view.position.x + 2.0, view.end.x - panel.size.x - 2.0),
		maxf(home.y, view.position.y + 2.0)).round()

func _board_width() -> float:
	return maxf(16.0, key_text.length() * 5.0 + 6.0)

func _draw():
	draw_rect(Rect2(-1.5, -POST_HEIGHT, 3.0, POST_HEIGHT), WOOD_DARK)
	var w := _board_width()
	var board := Rect2(-w / 2.0, -POST_HEIGHT - BOARD_HEIGHT + 2.0, w, BOARD_HEIGHT)
	draw_rect(board, WOOD)
	draw_rect(board, BRASS, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(board.position.x, board.end.y - 3.0), key_text, HORIZONTAL_ALIGNMENT_CENTER, w, 8, Color(1.0, 0.92, 0.7))
