extends Control

## Hotbar v HUD: dva sloty výstroje [1] [2]. V každém může být kterýkoli nástroj (hasák, hák, cívka);
## LMB použije nástroj ve vybraném slotu. Nápověda ukazuje i počet lékárniček v batohu [Q].

@onready var slot_btns: Array = [$HBoxContainer/Slot1, $HBoxContainer/Slot2]
@onready var hint_label = $HintLabel

var player: CharacterBody2D = null

func _ready():
	player = owner as CharacterBody2D
	if not player and get_parent() is CanvasLayer:
		player = get_parent().get_parent() as CharacterBody2D
	$HBoxContainer/Slot3.visible = false # dřív třetí slot; hráč má naráz jen dva nástroje
	for i in slot_btns.size():
		slot_btns[i].pressed.connect(_on_slot_clicked.bind(i))
	var inv = player.get("grid_inventory") if is_instance_valid(player) else null
	if inv and not inv.inventory_changed.is_connected(update_ui):
		inv.inventory_changed.connect(update_ui)
	update_ui()

func _on_slot_clicked(slot_index: int):
	if is_instance_valid(player) and player.has_method("select_hotbar_slot"):
		player.select_hotbar_slot(slot_index)
	update_ui()

func update_ui():
	if not is_instance_valid(player):
		return
	var active_slot: int = player.get("active_slot") if player.get("active_slot") != null else 0
	var inv = player.get("grid_inventory")
	for i in slot_btns.size():
		var btn: Button = slot_btns[i]
		var item = inv.get_equipped(i) if inv else null
		var txt := "--"
		if item:
			txt = "%s %s" % [item.icon_symbol, item.name]
		if i == active_slot:
			btn.text = "▶ [%d] %s" % [i + 1, txt]
			btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
			btn.modulate = Color(1.25, 1.2, 0.9)
		else:
			btn.text = "[%d] %s" % [i + 1, txt]
			btn.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65) if item else Color(0.4, 0.4, 0.4))
			btn.modulate = Color(0.75, 0.75, 0.75) if item else Color(0.5, 0.5, 0.5)
	if hint_label and inv:
		var packs: int = inv.items.filter(func(it): return it["data"].id == "health_pack").size()
		hint_label.text = "[1-2]: slot | LMB: použít | RMB: hák | Tab: batoh" + (" | Q: lékárnička ×%d" % packs if packs > 0 else "")
