extends Control

## Vizuální zobrazení a interakce pro mřížkový inventář (GridInventoryView).
## Kreslí políčka, barevné itemy, zvýraznění při najetí a podporuje zvednutí/položení a rotaci [R].

signal item_selected(item_entry)
signal item_moved(item_entry)

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")

@export var cell_size: float = 16.0
@export var title: String = "Batoh"

var inventory = null
var hovered_cell: Vector2i = Vector2i(-1, -1)

# Statická reference na globálně držený předmět pro přetahování mezi panely (např. Batoh <-> Truhla)
static var held_item_data = null
static var source_view: Control = null
static var original_pos: Vector2i = Vector2i.ZERO

func _ready():
	custom_minimum_size = Vector2(96, 64)
	focus_mode = Control.FOCUS_ALL

func setup(p_inventory: GridInventory, p_title: String = "Batoh"):
	inventory = p_inventory
	title = p_title
	if inventory:
		if not inventory.inventory_changed.is_connected(queue_redraw):
			inventory.inventory_changed.connect(queue_redraw)
		custom_minimum_size = Vector2(inventory.cols * cell_size, inventory.rows * cell_size)
		size = custom_minimum_size
	queue_redraw()

func _gui_input(event):
	if not inventory:
		return
		
	if event is InputEventMouseMotion:
		var cell_x = int(event.position.x / cell_size)
		var cell_y = int(event.position.y / cell_size)
		if inventory.is_valid_coord(cell_x, cell_y):
			hovered_cell = Vector2i(cell_x, cell_y)
		else:
			hovered_cell = Vector2i(-1, -1)
		queue_redraw()
		
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var cell_x = int(event.position.x / cell_size)
			var cell_y = int(event.position.y / cell_size)
			_handle_click(cell_x, cell_y)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Pravý klik může otočit držený předmět
			if held_item_data:
				_rotate_held_item()
				accept_event()

func _unhandled_input(event):
	# Rotace drženého předmětu klávesou R
	if held_item_data and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_rotate_held_item()
			get_viewport().set_input_as_handled()

func _rotate_held_item():
	if not held_item_data:
		return
	var temp = held_item_data.width
	held_item_data.width = held_item_data.height
	held_item_data.height = temp
	queue_redraw()

func _handle_click(cell_x: int, cell_y: int):
	if not inventory.is_valid_coord(cell_x, cell_y):
		return
		
	if held_item_data == null:
		# Zvednutí předmětu z mřížky
		var clicked_item = inventory.get_item_at(cell_x, cell_y)
		if not clicked_item.is_empty():
			held_item_data = clicked_item["data"]
			original_pos = Vector2i(clicked_item["x"], clicked_item["y"])
			source_view = self
			inventory.remove_item(clicked_item)
			item_selected.emit(clicked_item)
			queue_redraw()
	else:
		# Pokus o položení drženého předmětu do této mřížky
		if inventory.can_place_item(held_item_data, cell_x, cell_y):
			inventory.add_item(held_item_data, cell_x, cell_y)
			item_moved.emit({"data": held_item_data, "x": cell_x, "y": cell_y})
			held_item_data = null
			source_view = null
			queue_redraw()
		elif source_view == self and cell_x == original_pos.x and cell_y == original_pos.y:
			# Vrácení na původní pozici
			inventory.add_item(held_item_data, original_pos.x, original_pos.y)
			held_item_data = null
			source_view = null
			queue_redraw()

func return_held_item():
	if held_item_data and source_view == self:
		inventory.add_item(held_item_data, original_pos.x, original_pos.y)
		held_item_data = null
		source_view = null
		queue_redraw()

func _draw():
	if not inventory:
		return
		
	var w = inventory.cols * cell_size
	var h = inventory.rows * cell_size
	
	# 1. Pozadí a buňky mřížky
	draw_rect(Rect2(0, 0, w, h), Color(0.08, 0.07, 0.11, 0.95))
	
	for y in range(inventory.rows):
		for x in range(inventory.cols):
			var rx = x * cell_size
			var ry = y * cell_size
			var slot_rect = Rect2(rx + 1, ry + 1, cell_size - 2, cell_size - 2)
			draw_rect(slot_rect, Color(0.14, 0.12, 0.18, 0.8))
			draw_rect(Rect2(rx, ry, cell_size, cell_size), Color(0.05, 0.04, 0.07, 0.9), false, 1.0)
	
	# 2. Vykreslení položených předmětů
	for item in inventory.items:
		var data: ItemData = item["data"]
		var ix = float(item["x"]) * cell_size
		var iy = float(item["y"]) * cell_size
		var iw = float(data.width) * cell_size
		var ih = float(data.height) * cell_size
		
		var item_rect = Rect2(ix + 1.0, iy + 1.0, iw - 2.0, ih - 2.0)
		draw_rect(item_rect, data.color_main)
		
		# Horní a levý lesk
		draw_line(Vector2(ix + 1.0, iy + 1.0), Vector2(ix + iw - 2.0, iy + 1.0), data.color_accent, 1.0)
		draw_line(Vector2(ix + 1.0, iy + 1.0), Vector2(ix + 1.0, iy + ih - 2.0), data.color_accent, 1.0)
		# Tmavý okraj
		draw_rect(item_rect, Color(0.08, 0.06, 0.12, 0.95), false, 1.0)
		
		# Ikona a název uprostřed
		var font = ThemeDB.get_fallback_font()
		if font:
			var center_y = iy + ih * 0.5 + 3.0
			draw_string(font, Vector2(ix + 2.0, center_y), data.icon_symbol, HORIZONTAL_ALIGNMENT_CENTER, int(iw - 4.0), 9, Color.WHITE)
	
	# 3. Zvýraznění při přetahování (Ghost preview)
	if held_item_data and hovered_cell.x != -1 and hovered_cell.y != -1:
		var can_place = inventory.can_place_item(held_item_data, hovered_cell.x, hovered_cell.y)
		var hx = float(hovered_cell.x) * cell_size
		var hy = float(hovered_cell.y) * cell_size
		var hw = float(held_item_data.width) * cell_size
		var hh = float(held_item_data.height) * cell_size
		
		var preview_col = Color(0.2, 0.9, 0.4, 0.45) if can_place else Color(0.9, 0.2, 0.3, 0.45)
		var preview_rect = Rect2(hx + 1.0, hy + 1.0, hw - 2.0, hh - 2.0)
		draw_rect(preview_rect, preview_col)
		draw_rect(preview_rect, preview_col.lightened(0.3), false, 1.5)
