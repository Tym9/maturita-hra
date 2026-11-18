extends Control

## Sloty výstroje v okně truhly: dva sloty [1] [2], do každého jde kterýkoli nástroj (hasák, hák, cívka).
## Klik s drženým nástrojem ho do slotu vloží (a vezme do ruky ten, který tam byl), klik bez předmětu nástroj vyjme.

signal item_selected(item_entry)

const GridInventoryView = preload("res://ui/grid_inventory_view.gd")
const ItemData = preload("res://mechanics/item_data.gd")

var inventory = null

@onready var slot_btns: Array = [$HBox/Slot0, $HBox/Slot1]

func _ready():
	custom_minimum_size = Vector2(96, 22)
	$HBox/Slot2.visible = false # dřív třetí slot; hráč má naráz jen dva nástroje
	var title := get_node_or_null("Label") as Label
	if title:
		title.text = "VÝSTROJ [1-2], jen dva nástroje:"
	for i in slot_btns.size():
		slot_btns[i].pressed.connect(_on_slot_pressed.bind(i))
		slot_btns[i].mouse_entered.connect(_on_slot_hovered.bind(i))

func setup(p_inventory):
	inventory = p_inventory
	if inventory:
		if not inventory.inventory_changed.is_connected(update_slots):
			inventory.inventory_changed.connect(update_slots)
	update_slots()

func update_slots():
	if not is_instance_valid(inventory):
		return
	for i in slot_btns.size():
		var btn: Button = slot_btns[i]
		var item: ItemData = inventory.get_equipped(i)
		if item != null:
			btn.text = "[%d] %s" % [i + 1, item.name]
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
			btn.modulate = Color(1.15, 1.1, 0.95, 1.0)
		else:
			btn.text = "[%d] --" % [i + 1]
			btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6, 0.8))
			btn.modulate = Color(0.7, 0.7, 0.75, 0.9)

func _on_slot_pressed(slot_idx: int):
	if not inventory:
		return
	var held = GridInventoryView.held_item_data
	var current = inventory.get_equipped(slot_idx)
	if held != null:
		if not inventory.is_equippable(held.id):
			return # lékárnička, vrták, klíč: do slotu nepatří, fungují z batohu
		inventory.equip_item(held, slot_idx)
		GridInventoryView.held_item_data = current
		GridInventoryView.source_view = null
	elif current != null:
		GridInventoryView.held_item_data = inventory.unequip_item(slot_idx)
		GridInventoryView.source_view = null
	update_slots()

func _on_slot_hovered(slot_idx: int):
	if not inventory:
		return
	var item = inventory.get_equipped(slot_idx)
	if item != null:
		item_selected.emit({"data": item, "x": -1, "y": -1, "equipped_slot": slot_idx})
