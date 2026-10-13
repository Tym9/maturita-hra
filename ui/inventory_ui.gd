extends Control

@onready var slot1_btn = $HBoxContainer/Slot1
@onready var slot2_btn = $HBoxContainer/Slot2
@onready var slot3_btn = $HBoxContainer/Slot3
@onready var hint_label = $HintLabel

var player: CharacterBody2D = null

func _ready():
	player = owner as CharacterBody2D
	if not player and get_parent() is CanvasLayer:
		player = get_parent().get_parent() as CharacterBody2D
		
	if slot1_btn:
		slot1_btn.pressed.connect(func(): _on_slot_clicked(0))
	if slot2_btn:
		slot2_btn.pressed.connect(func(): _on_slot_clicked(1))
	if slot3_btn:
		slot3_btn.pressed.connect(func(): _on_slot_clicked(2))
		
	update_ui()

func _on_slot_clicked(slot_index: int):
	if is_instance_valid(player) and player.has_method("select_hotbar_slot"):
		player.select_hotbar_slot(slot_index)
	update_ui()

func update_ui():
	if not is_instance_valid(player):
		return
		
	var active_slot = player.get("active_slot")
	if active_slot == null:
		active_slot = 0
		
	var inv = player.get("grid_inventory")
	var eq0 = inv.get_equipped(0) if inv else null
	var eq1 = inv.get_equipped(1) if inv else null
	var eq2 = inv.get_equipped(2) if inv else null
	
	# Slot 1: 🔧 Hasák
	if slot1_btn:
		var txt1 = "🔧 " + eq0.name if eq0 else "--"
		if active_slot == 0:
			slot1_btn.text = "▶ [1] " + txt1
			slot1_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
			slot1_btn.modulate = Color(1.25, 1.2, 0.9)
		else:
			slot1_btn.text = "[1] " + txt1
			slot1_btn.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65) if eq0 else Color(0.4, 0.4, 0.4))
			slot1_btn.modulate = Color(0.75, 0.75, 0.75) if eq0 else Color(0.5, 0.5, 0.5)
			
	# Slot 2: 🪝 Hák
	if slot2_btn:
		var txt2 = "🪝 " + eq1.name if eq1 else "--"
		if active_slot == 1:
			slot2_btn.text = "▶ [2] " + txt2
			slot2_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
			slot2_btn.modulate = Color(1.25, 1.2, 0.9)
		else:
			slot2_btn.text = "[2] " + txt2
			slot2_btn.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65) if eq1 else Color(0.4, 0.4, 0.4))
			slot2_btn.modulate = Color(0.75, 0.75, 0.75) if eq1 else Color(0.5, 0.5, 0.5)
			
	# Slot 3: 🌀 Cívka / Výstroj
	if slot3_btn:
		var txt3 = "🌀 " + eq2.name if eq2 else "--"
		if active_slot == 2:
			slot3_btn.text = "▶ [3] " + txt3
			slot3_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
			slot3_btn.modulate = Color(1.25, 1.2, 0.9)
		else:
			slot3_btn.text = "[3] " + txt3
			slot3_btn.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65) if eq2 else Color(0.4, 0.4, 0.4))
			slot3_btn.modulate = Color(0.75, 0.75, 0.75) if eq2 else Color(0.5, 0.5, 0.5)
