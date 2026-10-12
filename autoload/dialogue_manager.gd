extends Node

## Autoload správa dialogů (DialogueManager).
## Zobrazuje dialogové okno, blokuje pohyb hráče během rozhovoru a posouvá stránky.

signal dialogue_started(speaker_name)
signal dialogue_finished

const DIALOGUE_BOX_SCENE = preload("res://ui/dialogue_box.tscn")

var canvas_layer: CanvasLayer = null
var dialogue_box: Control = null
var is_active: bool = false
var on_complete_callback: Callable = Callable()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Vytvoření dedikované CanvasLayer vrstvy (layer 100) pro dialogy nad celou hrou
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "DialogueCanvas"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	canvas_layer.add_child(dialogue_box)
	dialogue_box.dialogue_finished.connect(_on_box_finished)

func start_dialogue(speaker_name: String, speaker_title: String, pages: Array, portrait_tex: Texture2D = null, on_complete: Callable = Callable()):
	if pages.is_empty():
		return
		
	is_active = true
	on_complete_callback = on_complete
	
	# Pozastavíme pohyb hráče během dialogu
	_set_player_talking(true)
	
	dialogue_box.start_dialogue(speaker_name, speaker_title, pages, portrait_tex)
	dialogue_started.emit(speaker_name)

func _unhandled_input(event):
	if not is_active:
		return
		
	# Postup v dialogu: Klávesa E, Mezerník, Enter nebo levé tlačítko myši
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]:
			dialogue_box.handle_input()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dialogue_box.handle_input()
			get_viewport().set_input_as_handled()

func _on_box_finished():
	is_active = false
	_set_player_talking(false)
	
	var cb = on_complete_callback
	on_complete_callback = Callable()
	if cb.is_valid():
		cb.call()
		
	dialogue_finished.emit()

func close_dialogue():
	if dialogue_box and is_active:
		dialogue_box._finish_dialogue()

func _set_player_talking(talking: bool):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if "is_talking" in p:
			p.is_talking = talking
			
	# Fallback pokud hráč není ve skupině "player"
	var p_node = get_tree().root.find_child("Player", true, false)
	if p_node and "is_talking" in p_node:
		p_node.is_talking = talking
