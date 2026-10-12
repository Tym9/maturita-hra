extends Control

## UI Dialogové okno v retro steampunk / pixel-art stylu.
## Podporuje psací stroj (typewriter effect), portrét mluvčího, jméno a plynulé přepínání stránek.

signal dialogue_finished

@onready var panel_bg = $Panel
@onready var name_label = $NameBadge/NameLabel
@onready var portrait_rect = $PortraitFrame/Portrait
@onready var text_label = $TextLabel
@onready var prompt_label = $PromptLabel

var current_pages: Array = []
var current_page_idx: int = 0
var is_typing: bool = false
var type_timer: float = 0.0
var visible_chars_count: float = 0.0
const CHARS_PER_SECOND: float = 40.0

var prompt_blink: float = 0.0

func _ready():
	visible = false

func start_dialogue(speaker_name: String, speaker_title: String, pages: Array, portrait_tex: Texture2D = null):
	current_pages = pages
	current_page_idx = 0
	
	if speaker_title.is_empty():
		name_label.text = speaker_name
	else:
		name_label.text = "%s  •  %s" % [speaker_name, speaker_title]
		
	if portrait_tex:
		portrait_rect.texture = portrait_tex
		portrait_rect.visible = true
	else:
		portrait_rect.visible = false
	
	visible = true
	_show_page(0)

func _show_page(idx: int):
	if idx >= current_pages.size():
		_finish_dialogue()
		return
		
	current_page_idx = idx
	var page_text = str(current_pages[idx])
	text_label.text = page_text
	text_label.visible_characters = 0
	visible_chars_count = 0.0
	is_typing = true
	prompt_label.visible = false

func _process(delta):
	if not visible:
		return
		
	prompt_blink += delta * 4.0
	if prompt_label.visible:
		prompt_label.modulate.a = 0.5 + 0.5 * sin(prompt_blink)
		
	if is_typing:
		visible_chars_count += CHARS_PER_SECOND * delta
		text_label.visible_characters = int(visible_chars_count)
		
		if text_label.visible_characters >= text_label.text.length():
			text_label.visible_characters = -1
			is_typing = false
			prompt_label.visible = true

func handle_input():
	if not visible:
		return
		
	if is_typing:
		# Přeskočit animaci psacího stroje a zobrazit celý text okamžitě
		text_label.visible_characters = -1
		is_typing = false
		prompt_label.visible = true
	else:
		# Přejít na další stránku nebo ukončit dialog
		if current_page_idx + 1 < current_pages.size():
			_show_page(current_page_idx + 1)
		else:
			_finish_dialogue()

func _finish_dialogue():
	visible = false
	current_pages = []
	current_page_idx = 0
	dialogue_finished.emit()

func _draw():
	if not visible:
		return
	# Vykreslení mosazných nýtů a vnějšího rámu kolem panelu
	var rect = Rect2(0, 0, size.x, size.y)
	var bronze = Color(0.85, 0.65, 0.28, 1.0)
	var bronze_d = Color(0.4, 0.28, 0.12, 1.0)
	
	# Rohové nýty
	draw_rect(Rect2(3, 3, 2, 2), bronze)
	draw_rect(Rect2(size.x - 5, 3, 2, 2), bronze)
	draw_rect(Rect2(3, size.y - 5, 2, 2), bronze)
	draw_rect(Rect2(size.x - 5, size.y - 5, 2, 2), bronze)
