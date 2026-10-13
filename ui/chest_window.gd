extends Control

## Okno truhly se split-screen rozložením (vlevo batoh hráče, vpravo obsah truhly).
## Umožňuje obousměrný přesun a rotaci předmětů mezi kontejnery.

signal closed

const ItemData = preload("res://mechanics/item_data.gd")

@onready var player_grid_view = $CenterContainer/Panel/VBoxContainer/SplitHBox/LeftContainer/PlayerGridView
@onready var player_equip_view = $CenterContainer/Panel/VBoxContainer/SplitHBox/LeftContainer/PlayerEquipView
@onready var chest_grid_view = $CenterContainer/Panel/VBoxContainer/SplitHBox/RightContainer/ChestGridView
@onready var info_label = $CenterContainer/Panel/VBoxContainer/InfoLabel
@onready var btn_close = $CenterContainer/Panel/VBoxContainer/Header/BtnClose

var current_chest = null
var current_player = null

func _ready():
	visible = false
	if btn_close:
		btn_close.pressed.connect(close_window)
	if player_grid_view:
		player_grid_view.item_selected.connect(_on_item_selected)
	if player_equip_view:
		player_equip_view.item_selected.connect(_on_item_selected)
	if chest_grid_view:
		chest_grid_view.item_selected.connect(_on_item_selected)

func open_window(player_node, chest_node):
	current_player = player_node
	current_chest = chest_node
	visible = true
	
	if current_player and current_player.grid_inventory:
		if player_grid_view:
			player_grid_view.setup(current_player.grid_inventory, "Batoh")
		if player_equip_view:
			player_equip_view.setup(current_player.grid_inventory)
		
	if current_chest and current_chest.inventory and chest_grid_view:
		chest_grid_view.setup(current_chest.inventory, "Truhla")
		
	if info_label:
		info_label.text = "Klikněte na předmět pro přenesení mezi batohem a truhlou."

func close_window():
	if player_grid_view:
		player_grid_view.return_held_item()
	if chest_grid_view:
		chest_grid_view.return_held_item()
	visible = false
	if current_chest and current_chest.has_method("on_window_closed"):
		current_chest.on_window_closed()
	closed.emit()

func _unhandled_input(event):
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_E, KEY_I, KEY_TAB]:
			close_window()
			get_viewport().set_input_as_handled()

func _on_item_selected(item_entry):
	if info_label and not item_entry.is_empty():
		var data: ItemData = item_entry["data"]
		info_label.text = "%s (%dx%d): %s" % [data.name, data.width, data.height, data.description]
