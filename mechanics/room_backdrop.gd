@tool
class_name RoomBackdrop
extends Node2D

## Pozadí místnosti mřížky (320x180 px)
## Vykresluje atmosférické tmavé industriální pozadí s jemnou mřížkou 16x16 bodů.

@export var room_x: int = 0:
	set(val):
		room_x = val
		_update_position()
		queue_redraw()

@export var room_y: int = 0:
	set(val):
		room_y = val
		_update_position()
		queue_redraw()

@export var room_width: float = 320.0
@export var room_height: float = 180.0
@export var room_title: String = "":
	set(val):
		room_title = val
		queue_redraw()

const COLOR_BG = Color(0.07, 0.07, 0.11, 1.0)
const COLOR_GRID_DOT = Color(0.13, 0.13, 0.18, 0.7)
const COLOR_BORDER = Color(0.10, 0.10, 0.15, 0.4)

func _ready():
	z_index = -50
	_update_position()
	queue_redraw()

func _update_position():
	position = Vector2(float(room_x) * room_width, float(room_y) * room_height)

func _draw():
	# 1. Základní výplň místnosti
	draw_rect(Rect2(0, 0, room_width, room_height), COLOR_BG)
	
	# 2. Jemná mřížka 16x16 bodů v pozadí
	var step = 16.0
	for x in range(16, int(room_width), 16):
		for y in range(16, int(room_height), 16):
			draw_rect(Rect2(float(x) - 0.5, float(y) - 0.5, 1.0, 1.0), COLOR_GRID_DOT)
	
	# 3. Jemný vnitřní obrys místnosti
	draw_rect(Rect2(0, 0, room_width, room_height), COLOR_BORDER, false, 1.0)
	
	# 4. Označení sektoru / místnosti v levém horním rohu
	if not room_title.is_empty():
		var font = ThemeDB.get_fallback_font()
		if font:
			draw_string(font, Vector2(10, 16), room_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.25, 0.28, 0.38, 0.6))
