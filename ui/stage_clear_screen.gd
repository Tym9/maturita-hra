extends Control

## Obrazovka dokončení etapy (Stage Clear / Chapter Completed).
## Zobrazuje souhrnné statistiky za odehranou etapu:
## - Doba průchodu (Čas)
## - Sebrané krystaly (X / Max)
## - Počet úmrtí hráče
## - Počet poražených nepřátel
## Následně umožňuje pokračovat do další části hry.

@onready var title_label = $CenterContainer/Panel/Margin/VBox/TitleLabel
@onready var subtitle_label = $CenterContainer/Panel/Margin/VBox/SubtitleLabel
@onready var time_value = $CenterContainer/Panel/Margin/VBox/StatsGrid/TimeValue
@onready var crystals_value = $CenterContainer/Panel/Margin/VBox/StatsGrid/CrystalsValue
@onready var deaths_value = $CenterContainer/Panel/Margin/VBox/StatsGrid/DeathsValue
@onready var kills_value = $CenterContainer/Panel/Margin/VBox/StatsGrid/KillsValue
@onready var crystal_badge = $CenterContainer/Panel/Margin/VBox/CrystalBadge
@onready var btn_continue = $CenterContainer/Panel/Margin/VBox/BtnContinue

func _ready():
	_display_stats()
	if btn_continue:
		btn_continue.pressed.connect(_on_continue_pressed)
		btn_continue.grab_focus()

func _display_stats():
	var res = Global.last_stage_result
	if res.is_empty():
		# Fallback pro přímé testování scény
		res = {
			"stage_index": 1,
			"title": "ETAPA 1: STARÉ DÍLNY",
			"time": 74.3,
			"deaths": 1,
			"kills": 4,
			"crystals": 5,
			"max_crystals": 5,
			"next_scene": "res://level2.tscn"
		}
	
	if subtitle_label:
		subtitle_label.text = res.get("title", "DOKONČENÁ ETAPA")
		
	if time_value:
		time_value.text = Global.format_time(res.get("time", 0.0))
		
	var c_got = res.get("crystals", 0)
	var c_max = res.get("max_crystals", 5)
	if crystals_value:
		crystals_value.text = "%d / %d" % [c_got, c_max]
		
	if crystal_badge:
		if c_got >= c_max and c_max > 0:
			crystal_badge.text = "★ VŠECHNY KRYSTALY SEBRÁNY! ★"
			crystal_badge.visible = true
		else:
			crystal_badge.visible = false
			
	if deaths_value:
		deaths_value.text = str(res.get("deaths", 0))
		
	if kills_value:
		kills_value.text = str(res.get("kills", 0))

var is_continuing: bool = false

func _unhandled_input(event):
	if is_continuing:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE, KEY_ENTER]):
		var vp = get_viewport()
		if vp:
			vp.set_input_as_handled()
		_on_continue_pressed()

func _on_continue_pressed():
	if is_continuing:
		return
	is_continuing = true
	var next_scene = Global.pending_next_scene
	if next_scene.is_empty() or not ResourceLoader.exists(next_scene):
		next_scene = "res://main_menu.tscn"
	get_tree().change_scene_to_file(next_scene)
