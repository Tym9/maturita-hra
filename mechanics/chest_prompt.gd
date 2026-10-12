extends Node2D

## Vykresluje plovoucí pixel-art odznak [E] Otevřít nad truhlou

func _draw():
	var rect = Rect2(-20.0, -6.0, 40.0, 12.0)
	# Tmavý stín
	draw_rect(Rect2(-19.0, -5.0, 40.0, 12.0), Color(0.04, 0.04, 0.06, 0.7))
	# Tělo odznaku
	draw_rect(rect, Color(0.12, 0.10, 0.16, 0.95))
	# Mosazný rámeček
	draw_rect(rect, Color(0.95, 0.75, 0.35, 1.0), false, 1.0)
	
	# Text
	var font = ThemeDB.get_fallback_font()
	if font:
		draw_string(font, Vector2(-18.0, 3.0), "[E] Otevřít", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(1.0, 0.9, 0.5))
