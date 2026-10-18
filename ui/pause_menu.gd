extends Control

## UI Menu pauzy (vyvolá se klávesou ESC).
## Umožňuje pokračovat ve hře, uložit hru (SaveManager), vrátit se na checkpoint nebo odejít do menu.

@onready var status_label = $CenterContainer/Panel/VBoxContainer/StatusLabel
@onready var btn_resume = $CenterContainer/Panel/VBoxContainer/BtnResume
@onready var btn_save = $CenterContainer/Panel/VBoxContainer/BtnSave
@onready var btn_checkpoint = $CenterContainer/Panel/VBoxContainer/BtnCheckpoint
@onready var btn_menu = $CenterContainer/Panel/VBoxContainer/BtnMainMenu
@onready var btn_grab_mode = $CenterContainer/Panel/VBoxContainer/BtnGrabMode
@onready var crystals_label = $CenterContainer/Panel/VBoxContainer/CrystalsLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if btn_resume:
		btn_resume.pressed.connect(_on_resume_pressed)
	if btn_save:
		btn_save.pressed.connect(_on_save_pressed)
	if btn_checkpoint:
		btn_checkpoint.pressed.connect(_on_checkpoint_pressed)
	if btn_grab_mode:
		btn_grab_mode.text = Global.grab_mode_label()
		btn_grab_mode.pressed.connect(func():
			Global.toggle_grab_mode()
			btn_grab_mode.text = Global.grab_mode_label())
	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			# Pokud je otevřen dialog nebo inventář, ESC je může zavřít přednostně
			if DialogueManager.is_active:
				DialogueManager.close_dialogue()
				get_viewport().set_input_as_handled()
				return
			toggle_pause()
			get_viewport().set_input_as_handled()

func toggle_pause():
	var new_state = not get_tree().paused
	get_tree().paused = new_state
	visible = new_state
	if visible and status_label:
		status_label.text = ""
	if visible and crystals_label:
		# Krystaly této kapitoly podle trvalých záznamů (velké tajemství zvlášť)
		var s := CollectibleCrystal.scene_stats(get_tree())
		crystals_label.text = "Krystaly: %d/%d" % [s.got, s.total] + ("   Velký: %d/%d" % [s.grand_got, s.grand_total] if s.grand_total > 0 else "")
		crystals_label.visible = s.total + s.grand_total > 0

func _on_resume_pressed():
	toggle_pause()

func _on_save_pressed():
	var ok = SaveManager.save_game()
	if status_label:
		if ok:
			status_label.text = "✓ HRA ULOŽENA!"
			status_label.modulate = Color(0.4, 1.0, 0.4)
		else:
			status_label.text = "✗ CHYBA PŘI UKLÁDÁNÍ"
			status_label.modulate = Color(1.0, 0.4, 0.4)

func _on_checkpoint_pressed():
	toggle_pause()
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		# Jako Retry v Celeste: počítá se jako smrt (vrátí krystaly, klíče a resetuje místnost)
		players[0].die()

func _on_menu_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
