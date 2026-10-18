extends Control

## Samostatné okno batohu hráče (otevírá se klávesou I / Tab).
## Zobrazuje mřížku batohu, informace o předmětu a ovládání rotace.

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")

@onready var grid_view = $CenterContainer/Panel/VBoxContainer/GridInventoryView
@onready var equip_view = $CenterContainer/Panel/VBoxContainer/EquipHotbarView
@onready var info_label = $CenterContainer/Panel/VBoxContainer/InfoLabel
@onready var btn_close = $CenterContainer/Panel/VBoxContainer/Header/BtnClose

var player_inventory = null

func _ready():
	visible = false
	if btn_close:
		btn_close.pressed.connect(close_backpack)
	if grid_view:
		grid_view.item_selected.connect(_on_item_selected)
	if equip_view:
		equip_view.item_selected.connect(_on_item_selected)

func setup(inv: GridInventory):
	player_inventory = inv
	if grid_view:
		grid_view.setup(player_inventory, "Batoh")
	if equip_view:
		equip_view.setup(player_inventory)

func open_backpack():
	visible = true
	if player_inventory:
		if grid_view:
			grid_view.setup(player_inventory, "Batoh")
		if equip_view:
			equip_view.setup(player_inventory)
	if info_label:
		var crystal: ItemData = ItemData.create("gravity_crystal")
		info_label.text = "%s %s: %d   Velké: %d
Vyberte předmět pro zobrazení detailů." % [crystal.icon_symbol, crystal.name, SaveManager.progress.crystals.size(), SaveManager.progress.grand.size()]

func close_backpack():
	if grid_view:
		grid_view.return_held_item()
	visible = false

func toggle_backpack():
	if visible:
		close_backpack()
	else:
		open_backpack()

func _on_item_selected(item_entry):
	if info_label and not item_entry.is_empty():
		var data: ItemData = item_entry["data"]
		info_label.text = "%s (%dx%d): %s" % [data.name, data.width, data.height, data.description]
