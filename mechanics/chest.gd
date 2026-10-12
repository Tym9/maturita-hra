extends Area2D

## Interaktivní steampunková truhla s mřížkovým inventářem (6x4).
## Při příchodu hráče zobrazí [E] Otevřít a po stisku klávesy E otevře Split-Screen UI
## pro přeskládání předmětů mezi batohem hráče a truhlou.

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")

@export var initial_items: Array[String] = ["wrench", "grapple_hook", "gravity_coil", "health_pack", "mine_key"]

var inventory = null
var is_open: bool = false
var player_in_range: CharacterBody2D = null
var is_window_active: bool = false

@onready var prompt = $InteractPrompt
@onready var chest_window = $CanvasLayer/ChestWindow

func _ready():
	z_index = 2
	inventory = GridInventory.new(6, 4)
	for item_id in initial_items:
		var item = ItemData.create(item_id)
		inventory.add_item_auto(item)
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt:
		prompt.visible = false
	if chest_window:
		chest_window.visible = false
		chest_window.closed.connect(_on_chest_window_closed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and player_in_range and not is_window_active:
			open_chest()
			get_viewport().set_input_as_handled()

func open_chest():
	is_open = true
	is_window_active = true
	if prompt:
		prompt.visible = false
	if chest_window and player_in_range:
		chest_window.open_window(player_in_range, self)
	queue_redraw()

func _on_chest_window_closed():
	is_window_active = false
	if player_in_range and prompt:
		prompt.visible = true
	queue_redraw()

func on_window_closed():
	_on_chest_window_closed()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		if prompt and not is_window_active:
			prompt.visible = true

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		if prompt:
			prompt.visible = false
		if is_window_active and chest_window:
			chest_window.close_window()

func _draw():
	# Kreslení truhly (šířka 24px, výška 18px)
	var base_rect = Rect2(-12, -4, 24, 14)
	# Tělo truhly - tmavé dřevo
	draw_rect(base_rect, Color(0.22, 0.14, 0.08, 1.0))
	draw_rect(Rect2(-10, -2, 20, 10), Color(0.38, 0.24, 0.14, 1.0))
	
	# Mosazné pásy a kování
	var brass_col = Color(0.88, 0.7, 0.28, 1.0)
	draw_line(Vector2(-12, 1), Vector2(12, 1), brass_col, 1.5)
	draw_rect(Rect2(-12, -4, 3, 14), brass_col)
	draw_rect(Rect2(9, -4, 3, 14), brass_col)
	
	if is_open:
		# Otevřené víko vyklopené nahoru
		var lid_rect = Rect2(-13, -12, 26, 8)
		draw_rect(lid_rect, Color(0.3, 0.18, 0.1, 1.0))
		draw_rect(lid_rect, brass_col, false, 1.0)
		
		# Zlatá záře ze vnitřku truhly
		draw_rect(Rect2(-8, -4, 16, 4), Color(1.0, 0.88, 0.35, 0.75))
		draw_circle(Vector2(0, -2), 6.0, Color(1.0, 0.9, 0.4, 0.3))
	else:
		# Zavřené víko
		var lid_rect = Rect2(-12, -10, 24, 7)
		draw_rect(lid_rect, Color(0.28, 0.18, 0.1, 1.0))
		draw_rect(lid_rect, brass_col, false, 1.0)
		# Zámeček
		draw_rect(Rect2(-2, -5, 4, 4), Color(1.0, 0.85, 0.3, 1.0))
