@tool
class_name RoomBackdrop
extends Node2D

## Pozadí místnosti mřížky (320x180 px)
## Vykresluje atmosférické tmavé industriální pozadí s jemnou mřížkou 16x16 bodů.
## Další styly: povrch (steampunk/fantasy krajina), vchod do dolu a interiér šachty.

const STYLE_INDUSTRIAL = 0
const STYLE_SURFACE = 1
const STYLE_MINE_ENTRANCE = 2
const STYLE_MINE_INTERIOR = 3

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

@export_enum("Industrial", "Surface", "Mine Entrance", "Mine Interior") var style: int = 0:
	set(val):
		style = val
		queue_redraw()

## Výška země pro dekorace (lampy). Záporná hodnota = žádné lampy.
@export var ground_y: float = -1.0:
	set(val):
		ground_y = val
		queue_redraw()

## Lokální X pozice parních lamp stojících na zemi.
@export var lamp_xs: PackedFloat32Array = PackedFloat32Array():
	set(val):
		lamp_xs = val
		queue_redraw()

const COLOR_BG = Color(0.07, 0.07, 0.11, 1.0)
const COLOR_GRID_DOT = Color(0.13, 0.13, 0.18, 0.7)
const COLOR_BORDER = Color(0.10, 0.10, 0.15, 0.4)

const COLOR_WOOD = Color(0.34, 0.21, 0.11, 1.0)
const COLOR_WOOD_LIGHT = Color(0.52, 0.34, 0.18, 1.0)
const COLOR_WOOD_DARK = Color(0.16, 0.09, 0.05, 1.0)
const COLOR_BRASS = Color(0.88, 0.66, 0.28, 1.0)
const COLOR_COPPER = Color(0.62, 0.34, 0.18, 1.0)
const COLOR_LANTERN = Color(1.0, 0.80, 0.38, 1.0)

func _ready():
	z_index = -50
	_update_position()
	queue_redraw()

func _update_position():
	position = Vector2(float(room_x) * room_width, float(room_y) * room_height)

func _draw():
	match style:
		STYLE_SURFACE:
			_draw_surface(false)
			_draw_title(Color(1.0, 0.92, 0.78, 0.55))
		STYLE_MINE_ENTRANCE:
			_draw_surface(true)
			_draw_title(Color(1.0, 0.92, 0.78, 0.55))
		STYLE_MINE_INTERIOR:
			_draw_mine_interior()
			_draw_title(Color(0.85, 0.70, 0.50, 0.55))
		_:
			_draw_industrial()
			_draw_title(Color(0.25, 0.28, 0.38, 0.6))

func _draw_title(color: Color):
	# 4. Označení sektoru / místnosti v levém horním rohu
	if not room_title.is_empty():
		var font = ThemeDB.get_fallback_font()
		if font:
			draw_string(font, Vector2(10, 16), room_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, color)

func _draw_industrial():
	# 1. Základní výplň místnosti
	draw_rect(Rect2(0, 0, room_width, room_height), COLOR_BG)
	
	# 2. Jemná mřížka 16x16 bodů v pozadí
	var step = 16.0
	for x in range(16, int(room_width), 16):
		for y in range(16, int(room_height), 16):
			draw_rect(Rect2(float(x) - 0.5, float(y) - 0.5, 1.0, 1.0), COLOR_GRID_DOT)
	
	# 3. Jemný vnitřní obrys místnosti
	draw_rect(Rect2(0, 0, room_width, room_height), COLOR_BORDER, false, 1.0)

# ---------------------------------------------------------------------------
# Pomocné funkce
# ---------------------------------------------------------------------------

## Deterministický pseudo-náhodný hash (0..1), aby se dekorace nemění mezi překresleními.
func _hash(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)

## Světové X (kopce a hory navazují plynule přes hranice místností).
func _world_x(local_x: float) -> float:
	return float(room_x) * room_width + local_x

func _ridge_height(local_x: float, base: float, amp1: float, f1: float, amp2: float, f2: float, phase: float) -> float:
	var gx = _world_x(local_x)
	return base + sin(gx * f1 + phase) * amp1 + sin(gx * f2 + phase * 2.3) * amp2

func _draw_ridge(base: float, amp1: float, f1: float, amp2: float, f2: float, phase: float, color: Color, rim: Color, from_x: float = 0.0):
	var step = 4.0
	var x = from_x
	while x < room_width:
		var h = _ridge_height(x, base, amp1, f1, amp2, f2, phase)
		draw_rect(Rect2(x, h, step + 0.5, room_height - h), color)
		if rim.a > 0.0:
			draw_rect(Rect2(x, h, step + 0.5, 1.0), rim)
		x += step

func _draw_glow(center: Vector2, radius: float, color: Color):
	for i in range(4):
		var t = float(i) / 3.0
		var c = color
		c.a = color.a * (0.35 + 0.65 * t)
		draw_circle(center, radius * (1.0 - t * 0.7), c)

# ---------------------------------------------------------------------------
# Povrch: steampunk / fantasy krajina za soumraku
# ---------------------------------------------------------------------------

func _draw_surface(entrance: bool):
	_draw_sky()
	_draw_sun()
	_draw_clouds()
	_draw_airships()
	
	# Vzdálené hory, střední pohoří a blízké zalesněné kopce
	_draw_ridge(100.0, 26.0, 0.0105, 9.0, 0.031, 0.7, Color(0.33, 0.25, 0.40, 1.0), Color(0.98, 0.66, 0.52, 0.55))
	_draw_ridge(124.0, 14.0, 0.017, 6.0, 0.045, 2.1, Color(0.21, 0.20, 0.31, 1.0), Color(0.90, 0.55, 0.48, 0.30))
	_draw_ridge(142.0, 8.0, 0.024, 3.0, 0.060, 4.0, Color(0.11, 0.17, 0.20, 1.0), Color(0.0, 0.0, 0.0, 0.0))
	
	var tree_limit = 100.0 if entrance else room_width
	_draw_pines(142.0, 8.0, 0.024, 3.0, 0.060, 4.0, tree_limit)
	
	if entrance:
		_draw_mountain_entrance()
	
	_draw_lamps()

func _draw_sky():
	var bands = 24
	var top = Color(0.09, 0.13, 0.28, 1.0)
	var mid = Color(0.58, 0.34, 0.46, 1.0)
	var low = Color(0.98, 0.70, 0.40, 1.0)
	var band_h = room_height / float(bands)
	for i in range(bands):
		var t = float(i) / float(bands - 1)
		var c: Color
		if t < 0.55:
			c = top.lerp(mid, t / 0.55)
		else:
			c = mid.lerp(low, (t - 0.55) / 0.45)
		draw_rect(Rect2(0, float(i) * band_h, room_width, band_h + 1.0), c)
	
	# První hvězdy v horní tmavé části oblohy
	for i in range(14):
		var sx = _hash(float(room_x * 31 + i)) * room_width
		var sy = _hash(float(room_x * 57 + i) * 3.1) * room_height * 0.38
		var alpha = 0.30 + 0.45 * _hash(float(i + room_x * 7))
		draw_rect(Rect2(sx, sy, 1.0, 1.0), Color(1.0, 0.98, 0.88, alpha))

func _draw_sun():
	# Zapadající slunce má pevnou světovou pozici (X = 560) a svítí přes hranici místností
	var local_x = 560.0 - float(room_x) * room_width
	if local_x < -50.0 or local_x > room_width + 50.0:
		return
	var c = Vector2(local_x, 108.0)
	draw_circle(c, 38.0, Color(1.0, 0.72, 0.38, 0.10))
	draw_circle(c, 29.0, Color(1.0, 0.75, 0.40, 0.16))
	draw_circle(c, 21.0, Color(1.0, 0.86, 0.52, 1.0))
	draw_circle(c, 15.0, Color(1.0, 0.94, 0.72, 1.0))

func _draw_clouds():
	for i in range(3):
		var cx = _hash(float(room_x * 13 + i) * 1.7) * (room_width - 40.0) + 20.0
		var cy = 26.0 + _hash(float(room_x * 29 + i) * 2.3) * 46.0
		for k in range(5):
			var px = cx + float(k) * 9.0 - 18.0
			var py = cy + sin(float(k) * 1.6) * 3.0
			var r = 7.0 + float((k * 5 + i * 3) % 4)
			draw_circle(Vector2(px, py), r, Color(1.0, 0.82, 0.78, 0.17))
			draw_circle(Vector2(px, py + 2.0), r * 0.7, Color(0.95, 0.72, 0.72, 0.12))

func _draw_airships():
	# Vzducholodě s pevnými světovými pozicemi (steampunk atmosféra)
	var ships = [Vector2(1100.0, 46.0), Vector2(2050.0, 38.0), Vector2(380.0, 54.0)]
	for s in ships:
		var local_x = s.x - float(room_x) * room_width
		if local_x > -60.0 and local_x < room_width + 60.0:
			_draw_airship(Vector2(local_x, s.y))

func _draw_airship(pos: Vector2):
	var hull = Color(0.24, 0.15, 0.21, 1.0)
	# Balón
	var pts = PackedVector2Array()
	for a in range(24):
		var ang = float(a) / 24.0 * TAU
		pts.append(pos + Vector2(cos(ang) * 28.0, sin(ang) * 12.0))
	draw_colored_polygon(pts, hull)
	# Mosazné pásy a švy
	draw_arc(pos, 12.0, -0.9, 0.9, 10, COLOR_BRASS, 1.0)
	draw_line(pos + Vector2(-26, 0), pos + Vector2(26, 0), Color(0.75, 0.50, 0.26, 0.8), 1.0)
	draw_line(pos + Vector2(-10, -11), pos + Vector2(-10, 11), Color(0.75, 0.50, 0.26, 0.6), 1.0)
	draw_line(pos + Vector2(10, -11), pos + Vector2(10, 11), Color(0.75, 0.50, 0.26, 0.6), 1.0)
	# Lana a gondola
	draw_line(pos + Vector2(-8, 10), pos + Vector2(-6, 17), hull, 1.0)
	draw_line(pos + Vector2(8, 10), pos + Vector2(6, 17), hull, 1.0)
	draw_rect(Rect2(pos.x - 9, pos.y + 17, 18, 7), hull)
	draw_rect(Rect2(pos.x - 7, pos.y + 19, 3, 2), COLOR_LANTERN)
	# Vrtule a parní oblak
	draw_rect(Rect2(pos.x + 28, pos.y - 1, 3, 3), COLOR_BRASS)
	draw_line(pos + Vector2(30, -6), pos + Vector2(30, 7), Color(0.9, 0.7, 0.4, 0.6), 1.0)
	for k in range(3):
		draw_circle(pos + Vector2(-32.0 - float(k) * 7.0, 2.0 + float(k)), 2.5 + float(k), Color(1.0, 0.9, 0.85, 0.20 - float(k) * 0.05))

func _draw_pines(base: float, amp1: float, f1: float, amp2: float, f2: float, phase: float, limit_x: float):
	var x = 6.0
	var idx = 0
	while x < limit_x:
		var jitter = _hash(float(room_x * 101 + idx)) * 14.0
		var tx = x + jitter
		if tx < limit_x:
			var ground = _ridge_height(tx, base, amp1, f1, amp2, f2, phase) + 2.0
			var h = 14.0 + _hash(float(room_x * 53 + idx) * 1.3) * 10.0
			var w = h * 0.42
			var col = Color(0.07, 0.15, 0.15, 1.0)
			var col_light = Color(0.12, 0.24, 0.20, 1.0)
			draw_rect(Rect2(tx - 1.0, ground - 3.0, 2.0, 4.0), COLOR_WOOD_DARK)
			for tier in range(3):
				var ty = ground - 3.0 - float(tier) * h * 0.26
				var tw = w * (1.0 - float(tier) * 0.28)
				var th = h * 0.42
				draw_colored_polygon(PackedVector2Array([
					Vector2(tx - tw, ty), Vector2(tx + tw, ty), Vector2(tx, ty - th)
				]), col)
				draw_line(Vector2(tx, ty - th), Vector2(tx + tw * 0.8, ty - 1.0), col_light, 1.0)
		x += 22.0
		idx += 1

func _draw_lamps():
	if ground_y < 0.0:
		return
	for lx in lamp_xs:
		_draw_steam_lamp(Vector2(lx, ground_y))

## Litinová parní lampa s ozubeným kolem a hřejivě zářící lucernou.
func _draw_steam_lamp(base: Vector2):
	var iron = Color(0.17, 0.12, 0.10, 1.0)
	draw_rect(Rect2(base.x - 1.5, base.y - 34.0, 3.0, 34.0), iron)
	draw_rect(Rect2(base.x - 4.0, base.y - 3.0, 8.0, 3.0), iron)
	# Ozubené kolo na sloupu
	draw_arc(base + Vector2(0, -16), 4.0, 0.0, TAU, 12, COLOR_BRASS, 1.0)
	for k in range(6):
		var ang = float(k) / 6.0 * TAU
		draw_line(base + Vector2(0, -16) + Vector2(cos(ang), sin(ang)) * 4.0, base + Vector2(0, -16) + Vector2(cos(ang), sin(ang)) * 6.0, COLOR_BRASS, 1.0)
	# Rameno a lucerna
	draw_line(base + Vector2(0, -34), base + Vector2(7, -34), iron, 2.0)
	var lamp_pos = base + Vector2(7, -30)
	_draw_glow(lamp_pos, 30.0, Color(1.0, 0.78, 0.36, 0.14))
	draw_rect(Rect2(lamp_pos.x - 3.0, lamp_pos.y - 4.0, 6.0, 8.0), iron)
	draw_rect(Rect2(lamp_pos.x - 2.0, lamp_pos.y - 3.0, 4.0, 6.0), COLOR_LANTERN)

# ---------------------------------------------------------------------------
# Vchod do dolu: skalní masiv s dřevěně vyztuženým portálem
# ---------------------------------------------------------------------------

func _draw_mountain_entrance():
	var cliff_x = 128.0
	var step = 4.0
	var x = cliff_x
	var rock = Color(0.20, 0.17, 0.19, 1.0)
	var rock_light = Color(0.30, 0.25, 0.26, 1.0)
	# Skalní stěna s nerovným horním okrajem
	while x < room_width:
		var top = 8.0 + sin(_world_x(x) * 0.07) * 5.0 + sin(_world_x(x) * 0.19) * 2.0
		draw_rect(Rect2(x, top, step + 0.5, room_height - top), rock)
		draw_rect(Rect2(x, top, step + 0.5, 1.0), rock_light)
		x += step
	# Struktura kamene
	for i in range(34):
		var rx = cliff_x + _hash(float(i) * 2.9 + 4.0) * (room_width - cliff_x)
		var ry = 16.0 + _hash(float(i) * 5.3 + 1.0) * (room_height - 20.0)
		var rw = 6.0 + _hash(float(i) * 1.1) * 14.0
		draw_rect(Rect2(rx, ry, rw, 3.0), Color(0.12, 0.10, 0.12, 0.45))
		draw_rect(Rect2(rx + 1.0, ry - 1.0, rw * 0.5, 1.0), Color(0.40, 0.33, 0.32, 0.25))
	
	# Tmavý vstupní tunel (stoupající temnota směrem dovnitř)
	var tunnel = Rect2(cliff_x, 80.0, room_width - cliff_x, room_height - 80.0)
	draw_rect(tunnel, Color(0.035, 0.025, 0.04, 1.0))
	for i in range(6):
		var t = float(i) / 5.0
		draw_rect(Rect2(cliff_x, 80.0, 44.0 * (1.0 - t), room_height - 80.0), Color(0.45, 0.30, 0.18, 0.05))
	
	# Dřevěné vzpěry portálu
	_draw_timber_post(Rect2(118.0, 96.0, 8.0, 48.0))
	_draw_timber_post(Rect2(196.0, 96.0, 8.0, 80.0))
	# Šikmé zavětrování pod trámem
	draw_line(Vector2(126, 124), Vector2(146, 98), COLOR_WOOD, 3.0)
	draw_line(Vector2(126, 124), Vector2(146, 98), COLOR_WOOD_LIGHT, 1.0)
	draw_line(Vector2(196, 124), Vector2(176, 98), COLOR_WOOD, 3.0)
	draw_line(Vector2(196, 124), Vector2(176, 98), COLOR_WOOD_LIGHT, 1.0)
	
	# Visící lucerny u vchodu
	_draw_hanging_lantern(Vector2(150.0, 97.0), 12.0)
	_draw_hanging_lantern(Vector2(232.0, 97.0), 20.0)

func _draw_timber_post(rect: Rect2):
	draw_rect(rect, COLOR_WOOD)
	draw_rect(Rect2(rect.position.x, rect.position.y, 1.0, rect.size.y), COLOR_WOOD_LIGHT)
	draw_rect(Rect2(rect.position.x + rect.size.x - 1.0, rect.position.y, 1.0, rect.size.y), COLOR_WOOD_DARK)
	draw_rect(rect, COLOR_WOOD_DARK, false, 1.0)
	var ny = rect.position.y + 6.0
	while ny < rect.position.y + rect.size.y - 3.0:
		draw_rect(Rect2(rect.position.x + rect.size.x * 0.5 - 0.5, ny, 1.0, 1.0), COLOR_BRASS)
		ny += 14.0

func _draw_hanging_lantern(anchor: Vector2, chain_len: float):
	var pos = anchor + Vector2(0, chain_len)
	_draw_glow(pos, 38.0, Color(1.0, 0.72, 0.30, 0.16))
	draw_line(anchor, pos - Vector2(0, 4.0), Color(0.20, 0.15, 0.12, 1.0), 1.0)
	draw_rect(Rect2(pos.x - 3.0, pos.y - 4.0, 6.0, 9.0), Color(0.16, 0.11, 0.09, 1.0))
	draw_rect(Rect2(pos.x - 2.0, pos.y - 3.0, 4.0, 7.0), COLOR_LANTERN)
	draw_rect(Rect2(pos.x - 3.0, pos.y - 5.0, 6.0, 1.0), COLOR_BRASS)

# ---------------------------------------------------------------------------
# Interiér šachty: dřevěné podpěry, měděné potrubí a lucerny
# ---------------------------------------------------------------------------

func _draw_mine_interior():
	draw_rect(Rect2(0, 0, room_width, room_height), Color(0.055, 0.04, 0.055, 1.0))
	
	# Struktura skály
	for i in range(70):
		var rx = _hash(float(i) * 3.7 + 1.0) * room_width
		var ry = _hash(float(i) * 6.1 + 2.0) * room_height
		var rw = 5.0 + _hash(float(i) * 1.9) * 20.0
		var rh = 2.0 + _hash(float(i) * 2.7) * 5.0
		draw_rect(Rect2(rx, ry, rw, rh), Color(0.11, 0.085, 0.10, 0.55))
		draw_rect(Rect2(rx, ry, rw, 1.0), Color(0.19, 0.14, 0.14, 0.35))
	
	# Světelný sloup padající z otvoru nad schodištěm
	draw_colored_polygon(PackedVector2Array([
		Vector2(208, 0), Vector2(304, 0), Vector2(300, 140), Vector2(170, 140)
	]), Color(1.0, 0.85, 0.55, 0.07))
	
	# Měděné potrubí podél stropu s přírubami a ventilem
	draw_rect(Rect2(0, 38, room_width, 5), COLOR_COPPER)
	draw_rect(Rect2(0, 38, room_width, 1), Color(0.88, 0.56, 0.32, 1.0))
	draw_rect(Rect2(0, 42, room_width, 1), Color(0.30, 0.16, 0.09, 1.0))
	var fx = 20.0
	while fx < room_width:
		draw_rect(Rect2(fx, 36, 3, 9), Color(0.45, 0.25, 0.14, 1.0))
		fx += 52.0
	draw_arc(Vector2(120, 48), 6.0, 0.0, TAU, 14, Color(0.75, 0.25, 0.20, 1.0), 2.0)
	draw_line(Vector2(114, 48), Vector2(126, 48), Color(0.75, 0.25, 0.20, 1.0), 1.0)
	draw_line(Vector2(120, 42), Vector2(120, 54), Color(0.75, 0.25, 0.20, 1.0), 1.0)
	
	# Dřevěné podpěrné rámy
	for fx_center in [56.0, 178.0, 294.0]:
		_draw_support_frame(fx_center)
	
	# Visící lucerny osvětlující sestup
	_draw_hanging_lantern(Vector2(76.0, 40.0), 18.0)
	_draw_hanging_lantern(Vector2(250.0, 40.0), 44.0)
	_draw_hanging_lantern(Vector2(150.0, 40.0), 70.0)

func _draw_support_frame(cx: float):
	_draw_timber_post(Rect2(cx - 16.0, 0.0, 6.0, room_height))
	_draw_timber_post(Rect2(cx + 10.0, 0.0, 6.0, room_height))
	draw_rect(Rect2(cx - 20.0, 20.0, 40.0, 8.0), COLOR_WOOD)
	draw_rect(Rect2(cx - 20.0, 20.0, 40.0, 1.0), COLOR_WOOD_LIGHT)
	draw_rect(Rect2(cx - 20.0, 20.0, 40.0, 8.0), COLOR_WOOD_DARK, false, 1.0)
	draw_line(Vector2(cx - 10.0, 28.0), Vector2(cx - 4.0, 36.0), COLOR_WOOD, 3.0)
	draw_line(Vector2(cx + 10.0, 28.0), Vector2(cx + 4.0, 36.0), COLOR_WOOD, 3.0)
