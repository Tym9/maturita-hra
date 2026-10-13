extends Control

## Hlavní menu hry (Nová hra, Pokračovat, Výběr kapitol, Konec).

@onready var btn_continue = $VBoxContainer/MainButtons/BtnContinue
@onready var btn_new_game = $VBoxContainer/MainButtons/BtnNewGame
@onready var btn_chapters = $VBoxContainer/MainButtons/BtnChapters
@onready var btn_quit = $VBoxContainer/MainButtons/BtnQuit
@onready var chapter_scroll = $VBoxContainer/ChapterScroll

func _ready():
	if btn_continue:
		btn_continue.disabled = not SaveManager.has_save_file()
		btn_continue.pressed.connect(_on_continue_pressed)
	if btn_new_game:
		btn_new_game.pressed.connect(_on_new_game_pressed)
	if btn_chapters:
		btn_chapters.pressed.connect(_on_toggle_chapters_pressed)
	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)
	if chapter_scroll:
		chapter_scroll.visible = false

func _on_new_game_pressed():
	Global.reset_all_stats()
	SaveManager.pending_load = false
	SaveManager.delete_save()
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

func _on_level1_pressed():
	_start_level("res://level1.tscn")

func _on_level2_pressed():
	_start_level("res://level2.tscn")

func _on_level3_pressed():
	_start_level("res://level3.tscn")

func _on_level4_pressed():
	_start_level("res://level4.tscn")

func _on_level5_pressed():
	_start_level("res://level5.tscn")

func _on_level6_pressed():
	_start_level("res://level6.tscn")

func _on_level7_pressed():
	_start_level("res://level7.tscn")

func _on_level8_pressed():
	_start_level("res://level8.tscn")

func _on_level9_pressed():
	_start_level("res://level9.tscn")

func _on_level10_pressed():
	_start_level("res://level10.tscn")

func _on_level11_pressed():
	_start_level("res://level11.tscn")

func _on_level12_pressed():
	_start_level("res://level12.tscn")

func _on_level13_pressed():
	_start_level("res://level13.tscn")

func _on_level14_pressed():
	_start_level("res://level14.tscn")

func _on_level15_pressed():
	_start_level("res://level15.tscn")

func _on_test_pressed():
	_start_level("res://test/test_movement.tscn")
