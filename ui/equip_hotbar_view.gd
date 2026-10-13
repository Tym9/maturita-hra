extends Control

## UI Komponenta Hotbaru / Vybavených zbraní (Equip Slots).
## Umožňuje hráči v batohu a truhle vybavit Hasák, Hák nebo Gravity Coil do slotů [1], [2], [3].

signal item_selected(item_entry)

const GridInventoryView = preload("res://ui/grid_inventory_view.gd")
const ItemData = preload("res://mechanics/item_data.gd")

var inventory = null

@onready var slot0_btn = $HBox/Slot0
@onready var slot1_btn = $HBox/Slot1
@onready var slot2_btn = $HBox/Slot2

func _ready():
	custom_minimum_size = Vector2(96, 22)
	if slot0_btn:
		slot0_btn.pressed.connect(func(): _on_slot_pressed(0))
		slot0_btn.mouse_entered.connect(func(): _on_slot_hovered(0))
	if slot1_btn:
		slot1_btn.pressed.connect(func(): _on_slot_pressed(1))
		slot1_btn.mouse_entered.connect(func(): _on_slot_hovered(1))
	if slot2_btn:
		slot2_btn.pressed.connect(func(): _on_slot_pressed(2))
		slot2_btn.mouse_entered.connect(func(): _on_slot_hovered(2))

func setup(p_inventory):
	inventory = p_inventory
	if inventory:
		if not inventory.inventory_changed.is_connected(update_slots):
			inventory.inventory_changed.connect(update_slots)
	update_slots()

func update_slots():
	if not is_instance_valid(inventory):
		return
		
	var eq0 = inventory.get_equipped(0)
	var eq1 = inventory.get_equipped(1)
	var eq2 = inventory.get_equipped(2)
	
	_style_slot(slot0_btn, 0, "🔧 Hasák", eq0)
	_style_slot(slot1_btn, 1, "🪝 Hák", eq1)
	_style_slot(slot2_btn, 2, "🌀 Cívka", eq2)

func _style_slot(btn: Button, slot_idx: int, default_label: String, item: ItemData):
	if not btn:
		return
	if item != null:
		btn.text = "[%d] %s" % [slot_idx + 1, item.name]
		btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		btn.modulate = Color(1.15, 1.1, 0.95, 1.0)
	else:
		btn.text = "[%d] --" % [slot_idx + 1]
		btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6, 0.8))
		btn.modulate = Color(0.7, 0.7, 0.75, 0.9)

func _on_slot_pressed(slot_idx: int):
	if not inventory:
		return
		
	var held = GridInventoryView.held_item_data
	var current_eq = inventory.get_equipped(slot_idx)
	
	if held != null:
		var def_slot = inventory.get_default_slot_for(held.id)
		if def_slot == slot_idx or (def_slot != -1 and inventory.get_equipped(def_slot) == null):
			var target = slot_idx if def_slot == slot_idx else def_slot
			inventory.equip_item(held, target)
			GridInventoryView.held_item_data = current_eq
			GridInventoryView.source_view = null
			update_slots()
		elif def_slot != -1:
			var prev_item = inventory.get_equipped(def_slot)
			inventory.equip_item(held, def_slot)
			GridInventoryView.held_item_data = prev_item
			GridInventoryView.source_view = null
			update_slots()
	else:
		if current_eq != null:
			GridInventoryView.held_item_data = inventory.unequip_item(slot_idx)
			GridInventoryView.source_view = null
			update_slots()
		else:
			for item in inventory.items:
				if inventory.get_default_slot_for(item["data"].id) == slot_idx:
					var data = item["data"]
					inventory.remove_item(item)
					inventory.equip_item(data, slot_idx)
					update_slots()
					break

func _on_slot_hovered(slot_idx: int):
	if not inventory:
		return
	var item = inventory.get_equipped(slot_idx)
	if item != null:
		item_selected.emit({"data": item, "x": -1, "y": -1, "equipped_slot": slot_idx})
