extends Control

# Vykresluje ukazatel životů (HP srdíčka) v retro pixel-art stylu.
# Podporuje otřes při zásahu (shake) a zlaté/zelené bliknutí při vyléčení.

@export var max_hearts: int = 3
var current_hearts: int = 3
var shake_timer: float = 0.0
var flash_timer: float = 0.0

const HEART_SPACING: float = 14.0

func set_hearts(current: int, maximum: int):
	if current < current_hearts:
		# Zásah: otřes a červený puls
		shake_timer = 0.25
	elif current > current_hearts:
		# Léčení: zlatý záblesk
		flash_timer = 0.35
		
	current_hearts = current
	max_hearts = maximum
	queue_redraw()

func _process(delta):
	var needs_redraw = false
	if shake_timer > 0:
		shake_timer -= delta
		needs_redraw = true
	if flash_timer > 0:
		flash_timer -= delta
		needs_redraw = true
	if needs_redraw:
		queue_redraw()

func _draw():
	var shake_offset = Vector2.ZERO
	if shake_timer > 0:
		shake_offset = Vector2(randf_range(-1.2, 1.2), randf_range(-1.2, 1.2))
		
	for i in range(max_hearts):
		var pos = Vector2(i * HEART_SPACING + 7.0, 7.0) + shake_offset
		var is_full = i < current_hearts
		_draw_heart(pos, is_full)

func _draw_heart(center: Vector2, full: bool):
	var r: float = 3.2
	var left_lobe = center + Vector2(-2.4, -1.6)
	var right_lobe = center + Vector2(2.4, -1.6)
	var bottom_tip = center + Vector2(0.0, 5.0)
	var left_side = center + Vector2(-5.0, -0.6)
	var right_side = center + Vector2(5.0, -0.6)
	
	var col_outline = Color(0.18, 0.05, 0.05, 0.95)
	var col_fill = Color(0.95, 0.18, 0.22, 1.0)
	var col_empty = Color(0.15, 0.12, 0.12, 0.4)
	var col_empty_border = Color(0.42, 0.38, 0.38, 0.75)
	
	if flash_timer > 0 and full:
		col_fill = Color(1.0, 0.88, 0.35, 1.0)
		
	if full:
		# Obrys
		draw_circle(left_lobe, r + 0.8, col_outline)
		draw_circle(right_lobe, r + 0.8, col_outline)
		draw_colored_polygon(PackedVector2Array([left_side + Vector2(-0.8, -0.6), right_side + Vector2(0.8, -0.6), bottom_tip + Vector2(0, 0.9)]), col_outline)
		
		# Výplň srdce
		draw_circle(left_lobe, r, col_fill)
		draw_circle(right_lobe, r, col_fill)
		draw_colored_polygon(PackedVector2Array([left_side, right_side, bottom_tip]), col_fill)
		
		# Bílý pixelový odlesk
		draw_circle(left_lobe + Vector2(-0.9, -0.9), 0.9, Color(1.0, 1.0, 1.0, 0.85))
	else:
		# Vyprázdněné srdce
		draw_circle(left_lobe, r + 0.6, col_empty_border)
		draw_circle(right_lobe, r + 0.6, col_empty_border)
		draw_colored_polygon(PackedVector2Array([left_side, right_side, bottom_tip]), col_empty_border)
		
		draw_circle(left_lobe, r - 0.5, col_empty)
		draw_circle(right_lobe, r - 0.5, col_empty)
		draw_colored_polygon(PackedVector2Array([left_side + Vector2(0.8, 0), right_side + Vector2(-0.8, 0), bottom_tip + Vector2(0, -0.8)]), col_empty)
