extends Control

## Hlavní menu hry (Nová hra, Pokračovat, Výběr kapitol, Konec).

@onready var btn_continue = $VBoxContainer/MainButtons/BtnContinue
@onready var btn_new_game = $VBoxContainer/MainButtons/BtnNewGame
@onready var btn_chapters = $VBoxContainer/MainButtons/BtnChapters
@onready var btn_quit = $VBoxContainer/MainButtons/BtnQuit
@onready var chapter_scroll = $VBoxContainer/ChapterScroll
@onready var btn_grab_mode = $VBoxContainer/MainButtons/BtnGrabMode

func _ready():
	if btn_continue:
		btn_continue.disabled = not SaveManager.has_save_file()
		btn_continue.pressed.connect(_on_continue_pressed)
	if btn_new_game:
		btn_new_game.pressed.connect(_on_new_game_pressed)
	if btn_chapters:
		btn_chapters.pressed.connect(_on_toggle_chapters_pressed)
	if btn_grab_mode:
		btn_grab_mode.text = Global.grab_mode_label()
		btn_grab_mode.pressed.connect(func():
			Global.toggle_grab_mode()
			btn_grab_mode.text = Global.grab_mode_label())
	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)
	if chapter_scroll:
		chapter_scroll.visible = false

func _on_new_game_pressed():
	Global.reset_all_stats()
	SaveManager.pending_load = false
	SaveManager.delete_save()
	SaveManager.reset_progress()
	_start_level("res://tutorial_level.tscn")

func _on_continue_pressed():
	SaveManager.continue_game()

func _on_toggle_chapters_pressed():
	if chapter_scroll:
		chapter_scroll.visible = not chapter_scroll.visible

func _on_quit_pressed():
	get_tree().quit()

func _start_level(scene_path: String):
	Global.death_count = 0
	Global.kill_count = 0
	get_tree().change_scene_to_file(scene_path)

func _on_tutorial_pressed():
	_start_level("res://tutorial_level.tscn")

func _on_outpost_pressed():
	_start_level("res://levels/c1/chapter1.tscn")

func _on_smallville_pressed():
	_start_level("res://levels/c2/chapter2.tscn")

func _on_steam_city_pressed():
	_start_level("res://levels/c3/chapter3.tscn")

func _on_level1_pressed():
	_start_level("res://level1.tscn")

func _on_level2_pressed():
	_start_level("res://level2.tscn")

func _on_level3_pressed():
	_start_level("res://level3.tscn")
