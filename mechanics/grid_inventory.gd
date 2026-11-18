class_name GridInventory
extends RefCounted

## Logika mřížkového inventáře (Grid Inventory Controller).
## Spravuje matici obsazených buněk, kolize předmětů různých rozměrů a ukládání.

signal inventory_changed

const ItemData = preload("res://mechanics/item_data.gd")

var cols: int = 6
var rows: int = 4
var items: Array[Dictionary] = [] # Položky: {"data": RefCounted, "x": int, "y": int}

# 2 sloty výstroje (hotbar [1] [2]): do každého jde kterýkoli nástroj (hasák, hák, cívka, vrták). Nástroj funguje,
# jen když je ve slotu, takže hráč má naráz jen dva; mění je v batohu [Tab] nebo u truhly.
const SLOT_COUNT := 2
const EQUIPPABLE := ["wrench", "grapple_hook", "gravity_coil", "drill"]
var equipped_slots: Array = [null, null]
var has_equip_slots: bool = false

func _init(p_cols: int = 6, p_rows: int = 4, p_has_equip_slots: bool = false):
	cols = p_cols
	rows = p_rows
	has_equip_slots = p_has_equip_slots

func is_equippable(item_id: String) -> bool:
	return item_id in EQUIPPABLE

## První volný slot, -1 když jsou oba plné.
func free_slot() -> int:
	return equipped_slots.find(null)

## Slot, ve kterém předmět je (-1 = není vybaven).
func slot_of(item_id: String) -> int:
	for i in equipped_slots.size():
		if equipped_slots[i] != null and equipped_slots[i].id == item_id:
			return i
	return -1

## Vybaví předmět do slotu (bez slotu = první volný); předmět, který tam byl, přepíše.
func equip_item(data, slot_idx: int = -1) -> bool:
	if data == null or not is_equippable(data.id):
		return false
	if slot_idx < 0:
		slot_idx = free_slot()
	if slot_idx < 0 or slot_idx >= equipped_slots.size():
		return false
	equipped_slots[slot_idx] = data
	inventory_changed.emit()
	return true

func unequip_item(slot_idx: int):
	if slot_idx < 0 or slot_idx >= equipped_slots.size():
		return null
	var old_item = equipped_slots[slot_idx]
	equipped_slots[slot_idx] = null
	inventory_changed.emit()
	return old_item

func get_equipped(slot_idx: int):
	if slot_idx >= 0 and slot_idx < equipped_slots.size():
		return equipped_slots[slot_idx]
	return null

func is_equipped(item_id: String) -> bool:
	for slot in equipped_slots:
		if slot != null and slot.id == item_id:
			return true
	return false

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
	# Pokud má inventář equip sloty a její hotbar slot je volný, automaticky ji vybavíme!
	if has_equip_slots and is_equippable(data.id) and free_slot() != -1:
		return equip_item(data)

	# Jinak najde první volné místo v mřížce pro daný tvar předmětu
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
	for slot in equipped_slots:
		if slot != null and slot.id == item_id:
			return true
	for item in items:
		var data: ItemData = item["data"]
		if data.id == item_id:
			return true
	return false

func clear():
	items.clear()
	equipped_slots = [null, null]
	inventory_changed.emit()

func to_save_data() -> Array:
	var result = []
	for slot_idx in range(equipped_slots.size()):
		var data = equipped_slots[slot_idx]
		if data != null:
			result.append({
				"id": data.id,
				"name": data.name,
				"width": data.width,
				"height": data.height,
				"x": -1,
				"y": -1,
				"equipped_slot": slot_idx
			})
	for item in items:
		var data: ItemData = item["data"]
		result.append({
			"id": data.id,
			"name": data.name,
			"width": data.width,
			"height": data.height,
			"x": item["x"],
			"y": item["y"],
			"equipped_slot": -1
		})
	return result

func load_save_data(data: Array):
	clear()
	for entry in data:
		var item_id = str(entry.get("id", ""))
		if item_id.is_empty():
			continue
		var item_data = ItemData.create(item_id)
		# Zachováme rozměry v případě rotace
		if entry.has("width"):
			item_data.width = int(entry["width"])
		if entry.has("height"):
			item_data.height = int(entry["height"])
		var eq_slot = int(entry.get("equipped_slot", -1))
		if eq_slot >= 0 and eq_slot < equipped_slots.size() and equipped_slots[eq_slot] == null and is_equippable(item_id):
			equipped_slots[eq_slot] = item_data
		else:
			var x = int(entry.get("x", 0))
			var y = int(entry.get("y", 0))
			if x < 0 or y < 0 or not add_item(item_data, x, y): # i předmět ze 3. slotu starého uložení
				add_item_auto(item_data)
	inventory_changed.emit()
