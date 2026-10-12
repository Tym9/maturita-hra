extends Control

## Celková souhrnná tabulka po dohrání hry (Grand Total Summary / Game Completed).
## Zobrazuje:
## - Celkový herní čas
## - Celkový počet sebraných krystalů (X / 11)
## - Celkový počet úmrtí hráče
## - Celkový počet eliminovaných nepřátel
## - Detailní rozpad statistik po jednotlivých etapách (Etapa 1, 2, 3, Boss)
## - Tlačítko pro návrat do hlavního menu.
##
## POZNÁMKA: Tato obrazovka se zapojí do hry až po poražení finálního bosse!

@onready var total_time_val = $CenterContainer/Panel/Margin/VBox/TotalStats/TimeVal
@onready var total_crystals_val = $CenterContainer/Panel/Margin/VBox/TotalStats/CrystalsVal
@onready var total_deaths_val = $CenterContainer/Panel/Margin/VBox/TotalStats/DeathsVal
@onready var total_kills_val = $CenterContainer/Panel/Margin/VBox/TotalStats/KillsVal
@onready var stage_rows_container = $CenterContainer/Panel/Margin/VBox/StageRows
@onready var btn_main_menu = $CenterContainer/Panel/Margin/VBox/BtnMainMenu

func _ready():
	_populate_grand_summary()
	if btn_main_menu:
		btn_main_menu.pressed.connect(_on_main_menu_pressed)
		btn_main_menu.grab_focus()

func _populate_grand_summary():
	if total_time_val:
		total_time_val.text = Global.format_time(Global.total_time)
	if total_crystals_val:
		total_crystals_val.text = "%d / 11 💎" % Global.total_crystals
	if total_deaths_val:
		total_deaths_val.text = "%d 💀" % Global.death_count
	if total_kills_val:
		total_kills_val.text = "%d ⚔️" % Global.kill_count
		
	# Vyplnění řádků pro jednotlivé etapy
	if stage_rows_container:
		for child in stage_rows_container.get_children():
			child.queue_free()
			
		var stages = Global.completed_stages
		if stages.is_empty():
			stages = [
				{"stage_index": 1, "title": "Etapa 1: Staré dílny", "time": 95.0, "crystals": 5, "max_crystals": 5, "deaths": 1},
				{"stage_index": 2, "title": "Etapa 2: Krystalové doly", "time": 140.0, "crystals": 3, "max_crystals": 3, "deaths": 2},
				{"stage_index": 3, "title": "Etapa 3: Předpolí reaktoru", "time": 175.0, "crystals": 3, "max_crystals": 3, "deaths": 3}
			]
			
		for st in stages:
			var row = HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var lbl_name = Label.new()
			lbl_name.text = st.get("title", "Etapa")
			lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl_name.set("theme_override_font_sizes/font_size", 7)
			row.add_child(lbl_name)
			
			var lbl_cryst = Label.new()
			lbl_cryst.text = "%d/%d 💎" % [st.get("crystals", 0), st.get("max_crystals", 0)]
			lbl_cryst.set("theme_override_font_sizes/font_size", 7)
			lbl_cryst.set("theme_override_colors/font_color", Color(0.3, 0.9, 1.0))
			row.add_child(lbl_cryst)
			
			var lbl_time = Label.new()
			lbl_time.text = Global.format_time(st.get("time", 0.0))
			lbl_time.set("theme_override_font_sizes/font_size", 7)
			lbl_time.set("theme_override_colors/font_color", Color(0.95, 0.85, 0.4))
			row.add_child(lbl_time)
			
			stage_rows_container.add_child(row)

func _on_main_menu_pressed():
	Global.reset_all_stats()
	get_tree().change_scene_to_file("res://main_menu.tscn")
