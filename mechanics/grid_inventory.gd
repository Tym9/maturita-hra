class_name GridInventory
extends RefCounted

## Logika mřížkového inventáře (Grid Inventory Controller).
## Spravuje matici obsazených buněk, kolize předmětů různých rozměrů a ukládání.

signal inventory_changed

const ItemData = preload("res://mechanics/item_data.gd")

var cols: int = 6
var rows: int = 4
var items: Array[Dictionary] = [] # Položky: {"data": RefCounted, "x": int, "y": int}

func _init(p_cols: int = 6, p_rows: int = 4):
	cols = p_cols
	rows = p_rows

func is_valid_coord(x: int, y: int) -> bool:
	return x >= 0 and x < cols and y >= 0 and y < rows

func can_place_item(data, at_x: int, at_y: int, ignore_item = null) -> bool:
	if at_x < 0 or at_y < 0:
		return false
	if at_x + data.width > cols or at_y + data.height > rows:
		return false
		
	# Kontrola kolize s ostatními předměty
	for item in items:
		if item == ignore_item:
			continue
		var other_data = item["data"]
		var ox: int = item["x"]
		var oy: int = item["y"]
		
		# AABB překryv dvou obdélníků v mřížce
		if not (at_x + data.width <= ox or at_x >= ox + other_data.width or \
				at_y + data.height <= oy or at_y >= oy + other_data.height):
			return false
			
	return true

func add_item(data, at_x: int, at_y: int) -> bool:
	if not can_place_item(data, at_x, at_y):
		return false
		
	var item_entry = {
		"data": data,
		"x": at_x,
		"y": at_y
	}
	items.append(item_entry)
	inventory_changed.emit()
	return true

func add_item_auto(data) -> bool:
	# Najde první volné místo v mřížce pro daný tvar předmětu
	for y in range(rows - data.height + 1):
		for x in range(cols - data.width + 1):
			if can_place_item(data, x, y):
				return add_item(data, x, y)
	return false

func remove_item(item_entry: Dictionary) -> bool:
	var idx = items.find(item_entry)
	if idx != -1:
		items.remove_at(idx)
		inventory_changed.emit()
		return true
	return false

func get_item_at(x: int, y: int) -> Dictionary:
	for item in items:
		var data: ItemData = item["data"]
		var ix: int = item["x"]
		var iy: int = item["y"]
		if x >= ix and x < ix + data.width and y >= iy and y < iy + data.height:
			return item
	return {}

func has_item(item_id: String) -> bool:
	for item in items:
		var data: ItemData = item["data"]
		if data.id == item_id:
			return true
	return false

func clear():
	items.clear()
	inventory_changed.emit()

func to_save_data() -> Array:
	var result = []
	for item in items:
		var data: ItemData = item["data"]
		result.append({
			"id": data.id,
			"name": data.name,
			"width": data.width,
			"height": data.height,
			"x": item["x"],
			"y": item["y"]
		})
	return result

func load_save_data(data: Array):
	clear()
	for entry in data:
		var item_id = str(entry.get("id", ""))
		var item_data = ItemData.create(item_id)
		# Zachováme rozměry v případě rotace
		if entry.has("width"):
			item_data.width = int(entry["width"])
		if entry.has("height"):
			item_data.height = int(entry["height"])
		var x = int(entry.get("x", 0))
		var y = int(entry.get("y", 0))
		add_item(item_data, x, y)
