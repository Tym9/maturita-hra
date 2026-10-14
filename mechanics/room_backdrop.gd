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
const STYLE_WORKSHOP = 4
const STYLE_CRYSTAL_MINES = 5
const STYLE_REACTOR_CORE = 6

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

@export_enum("Industrial", "Surface", "Mine Entrance", "Mine Interior", "Workshop", "Crystal Mines", "Reactor Core") var style: int = 0:
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
		STYLE_WORKSHOP:
			_draw_workshop()
			_draw_title(Color(0.95, 0.78, 0.48, 0.65))
		STYLE_CRYSTAL_MINES:
			_draw_crystal_mines()
			_draw_title(Color(0.65, 0.90, 1.0, 0.70))
		STYLE_REACTOR_CORE:
			_draw_reactor_core()
			_draw_title(Color(0.40, 0.95, 0.90, 0.75))
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


# ---------------------------------------------------------------------------
# ETAPA 1: Staré dílny (Workshop & Foundry)
# Cihlové zdivo, masivní parní potrubí, ozubená kola, tlakoměry a lucerny
# ---------------------------------------------------------------------------

func _draw_workshop():
	# 1. Tmavé cihlové zdivo
	draw_rect(Rect2(0, 0, room_width, room_height), Color(0.08, 0.07, 0.09, 1.0))
	var mortar_col = Color(0.14, 0.11, 0.13, 0.45)
	for by in range(0, int(room_height), 12):
		draw_line(Vector2(0, float(by)), Vector2(room_width, float(by)), mortar_col, 1.0)
		var shift = 12.0 if (by / 12) % 2 == 0 else 0.0
		for bx in range(int(shift), int(room_width), 24):
			draw_line(Vector2(float(bx), float(by)), Vector2(float(bx), float(by + 12)), mortar_col, 1.0)
	
	# 2. Ocelový příhradový vazník podél stropu
	var truss_y = 18.0
	var truss_col = Color(0.20, 0.16, 0.18, 1.0)
	var truss_light = Color(0.42, 0.32, 0.26, 0.7)
	draw_line(Vector2(0, truss_y), Vector2(room_width, truss_y), truss_col, 2.0)
	draw_line(Vector2(0, truss_y + 10.0), Vector2(room_width, truss_y + 10.0), truss_col, 2.0)
	for tx in range(0, int(room_width), 20):
		draw_line(Vector2(float(tx), truss_y), Vector2(float(tx + 20), truss_y + 10.0), truss_light, 1.0)
		draw_line(Vector2(float(tx + 20), truss_y), Vector2(float(tx), truss_y + 10.0), truss_light, 1.0)
	
	# 3. Obří ozubená kola v pozadí (podle polohy místnosti)
	var gear_seed = float(room_x * 23 + room_y * 41)
	var gear1_x = 75.0 + _hash(gear_seed) * 80.0
	var gear1_y = 65.0 + _hash(gear_seed * 1.7) * 45.0
	var gear1_r = 26.0 + _hash(gear_seed * 2.3) * 12.0
	_draw_cogwheel(Vector2(gear1_x, gear1_y), gear1_r, 12, Color(0.18, 0.13, 0.15, 0.8))
	var gear2_r = gear1_r * 0.55
	var gear2_pos = Vector2(gear1_x + gear1_r + gear2_r - 2.0, gear1_y - 8.0)
	_draw_cogwheel(gear2_pos, gear2_r, 8, Color(0.24, 0.17, 0.18, 0.75))
	
	# 4. Měděné a bronzové parní potrubí s přírubami
	var pipe_y = 44.0 + _hash(gear_seed * 3.1) * 20.0
	draw_rect(Rect2(0, pipe_y, room_width, 6.0), COLOR_COPPER)
	draw_rect(Rect2(0, pipe_y, room_width, 1.0), Color(0.85, 0.55, 0.30, 1.0))
	draw_rect(Rect2(0, pipe_y + 5.0, room_width, 1.0), Color(0.30, 0.16, 0.08, 1.0))
	var fx = 24.0
	while fx < room_width:
		draw_rect(Rect2(fx, pipe_y - 2.0, 3.0, 10.0), Color(0.48, 0.28, 0.15, 1.0))
		fx += 48.0
	
	# Svislá odbočka potrubí
	var drop_x = 180.0 + _hash(gear_seed * 4.3) * 80.0
	draw_rect(Rect2(drop_x, pipe_y, 5.0, room_height - pipe_y), COLOR_COPPER)
	draw_rect(Rect2(drop_x, pipe_y, 1.0, room_height - pipe_y), Color(0.85, 0.55, 0.30, 1.0))
	
	# Tlakoměr (manometr) na potrubí
	var gauge_pos = Vector2(drop_x + 14.0, pipe_y + 16.0)
	draw_line(Vector2(drop_x + 5.0, pipe_y + 16.0), gauge_pos, Color(0.4, 0.25, 0.15, 1.0), 2.0)
	draw_circle(gauge_pos, 7.0, COLOR_BRASS)
	draw_circle(gauge_pos, 5.5, Color(0.92, 0.90, 0.82, 1.0))
	draw_line(gauge_pos, gauge_pos + Vector2(3.5, -2.5), Color(0.85, 0.15, 0.1, 1.0), 1.0)
	
	# Červený uzavírací ventil
	var valve_pos = Vector2(drop_x + 2.5, pipe_y + 36.0)
	draw_arc(valve_pos, 6.0, 0.0, TAU, 14, Color(0.75, 0.22, 0.16, 1.0), 2.0)
	draw_line(valve_pos - Vector2(6, 0), valve_pos + Vector2(6, 0), Color(0.75, 0.22, 0.16, 1.0), 1.0)
	draw_line(valve_pos - Vector2(0, 6), valve_pos + Vector2(0, 6), Color(0.75, 0.22, 0.16, 1.0), 1.0)
	
	# 5. Záře tavicí pece u spodních rohů
	_draw_glow(Vector2(40.0, 175.0), 45.0, Color(1.0, 0.45, 0.10, 0.10))
	_draw_glow(Vector2(280.0, 175.0), 40.0, Color(1.0, 0.45, 0.10, 0.08))
	
	# 6. Visící dílenské lucerny
	_draw_hanging_lantern(Vector2(60.0 + _hash(gear_seed * 5.1) * 30.0, truss_y + 10.0), 24.0)
	_draw_hanging_lantern(Vector2(240.0 + _hash(gear_seed * 6.7) * 40.0, truss_y + 10.0), 30.0)

func _draw_cogwheel(center: Vector2, radius: float, teeth: int, color: Color):
	# Střed a náboj
	draw_circle(center, radius * 0.35, color)
	draw_circle(center, radius * 0.15, Color(0.08, 0.07, 0.09, 1.0))
	# Vnější věnec
	draw_arc(center, radius, 0.0, TAU, teeth * 3, color, 3.0)
	# Zuby po obvodu
	for i in range(teeth):
		var ang = float(i) / float(teeth) * TAU
		var tooth_dir = Vector2(cos(ang), sin(ang))
		var p_base1 = center + tooth_dir * radius + Vector2(-tooth_dir.y, tooth_dir.x) * 2.5
		var p_base2 = center + tooth_dir * radius - Vector2(-tooth_dir.y, tooth_dir.x) * 2.5
		var p_tip1 = center + tooth_dir * (radius + 4.5) + Vector2(-tooth_dir.y, tooth_dir.x) * 2.0
		var p_tip2 = center + tooth_dir * (radius + 4.5) - Vector2(-tooth_dir.y, tooth_dir.x) * 2.0
		draw_colored_polygon(PackedVector2Array([p_base1, p_tip1, p_tip2, p_base2]), color)
	# Loukotě (paprsky kola)
	for i in range(4):
		var ang = float(i) / 4.0 * PI
		var dir = Vector2(cos(ang), sin(ang))
		draw_line(center - dir * radius, center + dir * radius, color, 2.0)

# ---------------------------------------------------------------------------
# ETAPA 2: Krystalové doly (Crystal Mines & Geodes)
# Hlubinné jeskynní stěny, zářící krystaly, dřevěné vzpěry a důlní vozíkové koleje
# ---------------------------------------------------------------------------

func _draw_crystal_mines():
	# 1. Hlubinná temná skalní jeskyně
	draw_rect(Rect2(0, 0, room_width, room_height), Color(0.05, 0.045, 0.075, 1.0))
	
	# Skalní vrstvy a pukliny
	for i in range(50):
		var rx = _hash(float(i) * 3.3 + float(room_x * 19)) * room_width
		var ry = _hash(float(i) * 5.7 + float(room_y * 23)) * room_height
		var rw = 6.0 + _hash(float(i) * 2.1) * 24.0
		draw_rect(Rect2(rx, ry, rw, 2.0), Color(0.10, 0.08, 0.14, 0.6))
		draw_rect(Rect2(rx, ry, rw * 0.6, 1.0), Color(0.18, 0.14, 0.24, 0.4))
	
	# Skalní krápníky (stalaktity) na stropě
	var stal_step = 28.0
	var sx = 10.0
	while sx < room_width:
		var sh = 8.0 + _hash(sx * 1.7 + float(room_x * 7)) * 16.0
		var sw = 6.0 + _hash(sx * 3.1) * 6.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(sx - sw * 0.5, 0), Vector2(sx + sw * 0.5, 0), Vector2(sx, sh)
		]), Color(0.12, 0.10, 0.16, 1.0))
		sx += stal_step
	
	# 2. Zářící krystalové shluky (azurové, fialové a smaragdové)
	var cry_seed = float(room_x * 31 + room_y * 17)
	var clusters = [
		Vector2(45.0 + _hash(cry_seed) * 30.0, 40.0 + _hash(cry_seed * 1.3) * 30.0),
		Vector2(160.0 + _hash(cry_seed * 2.1) * 40.0, 70.0 + _hash(cry_seed * 2.7) * 40.0),
		Vector2(265.0 + _hash(cry_seed * 3.3) * 35.0, 35.0 + _hash(cry_seed * 3.9) * 35.0),
		Vector2(95.0 + _hash(cry_seed * 4.5) * 40.0, 130.0 + _hash(cry_seed * 5.1) * 30.0)
	]
	for idx in range(clusters.size()):
		var cpos = clusters[idx]
		var hue_type = int(idx + room_x) % 3
		_draw_crystal_cluster(cpos, hue_type, 4 + int(_hash(float(idx * 7)) * 3), 1.0)
	
	# 3. Důlní dřevěná výdřeva (štolové rámy)
	for fx in [55.0, 180.0, 290.0]:
		_draw_timber_post(Rect2(fx - 4.0, 0, 8.0, room_height))
		# Horní spojovací trám
		draw_rect(Rect2(fx - 24.0, 18.0, 48.0, 8.0), COLOR_WOOD)
		draw_rect(Rect2(fx - 24.0, 18.0, 48.0, 1.0), COLOR_WOOD_LIGHT)
		draw_rect(Rect2(fx - 24.0, 18.0, 48.0, 8.0), COLOR_WOOD_DARK, false, 1.0)
		# Šikmé vzpěry
		draw_line(Vector2(fx - 16, 26), Vector2(fx - 4, 38), COLOR_WOOD, 2.0)
		draw_line(Vector2(fx + 16, 26), Vector2(fx + 4, 38), COLOR_WOOD, 2.0)
	
	# 4. Důlní koleje v pozadí
	var rail_y = 158.0
	draw_line(Vector2(0, rail_y), Vector2(room_width, rail_y), Color(0.28, 0.22, 0.20, 1.0), 2.0)
	draw_line(Vector2(0, rail_y + 4.0), Vector2(room_width, rail_y + 4.0), Color(0.28, 0.22, 0.20, 1.0), 2.0)
	for rx in range(8, int(room_width), 16):
		draw_rect(Rect2(float(rx), rail_y - 2.0, 4.0, 8.0), COLOR_WOOD_DARK)
	
	# 5. Závěsné hornické lampy v kleci
	_draw_hanging_lantern(Vector2(85.0 + _hash(cry_seed * 6.1) * 30.0, 26.0), 22.0)
	_draw_hanging_lantern(Vector2(220.0 + _hash(cry_seed * 7.3) * 30.0, 26.0), 26.0)

func _draw_crystal_cluster(pos: Vector2, hue: int, count: int, sc: float):
	var glow_col: Color
	var base_col: Color
	var mid_col: Color
	var tip_col: Color
	
	match hue:
		0: # Azur / Éterický safír (Hlavní krystal hry)
			glow_col = Color(0.25, 0.85, 1.0, 0.16)
			base_col = Color(0.10, 0.38, 0.65, 1.0)
			mid_col = Color(0.25, 0.80, 0.98, 1.0)
			tip_col = Color(0.85, 0.98, 1.0, 1.0)
		1: # Ametyst / Fialový geod
			glow_col = Color(0.75, 0.35, 0.95, 0.15)
			base_col = Color(0.32, 0.12, 0.50, 1.0)
			mid_col = Color(0.68, 0.32, 0.88, 1.0)
			tip_col = Color(0.92, 0.78, 1.0, 1.0)
		_: # Smaragd / Zelený minerál
			glow_col = Color(0.25, 0.90, 0.45, 0.15)
			base_col = Color(0.12, 0.40, 0.22, 1.0)
			mid_col = Color(0.28, 0.82, 0.44, 1.0)
			tip_col = Color(0.82, 1.0, 0.88, 1.0)
	
	# 1. Světelná aura
	_draw_glow(pos, 28.0 * sc, glow_col)
	
	# 2. Jednotlivé fazetované krystalové hroty
	for i in range(count):
		var ang = -PI * 0.5 + float(i - count / 2) * 0.42
		var dir = Vector2(cos(ang), sin(ang))
		var norm = Vector2(-dir.y, dir.x)
		var h = (12.0 + float((i * 7) % 8)) * sc
		var w = (3.5 + float((i * 3) % 3)) * sc
		var p_root1 = pos + norm * w * 0.5
		var p_root2 = pos - norm * w * 0.5
		var p_mid1 = pos + dir * h * 0.65 + norm * w * 0.6
		var p_mid2 = pos + dir * h * 0.65 - norm * w * 0.6
		var p_tip = pos + dir * h
		# Levá stinná fazeta
		draw_colored_polygon(PackedVector2Array([p_root1, p_mid1, p_tip, pos]), base_col)
		# Pravá osvětlená fazeta
		draw_colored_polygon(PackedVector2Array([pos, p_tip, p_mid2, p_root2]), mid_col)
		# Zářící hrana / špička
		draw_line(pos, p_tip, tip_col, 1.0)
	
	# 3. Třpytivé minerální jiskry okolo
	for k in range(3):
		var jx = pos.x + cos(float(k) * 2.1) * 16.0 * sc
		var jy = pos.y + sin(float(k) * 2.1) * 12.0 * sc
		draw_rect(Rect2(jx, jy, 1.5, 1.5), tip_col)

# ---------------------------------------------------------------------------
# ETAPA 3: Jádro reaktoru (Reactor Core & High-Tech Velín)
# Masivní reaktorové sloupy, pulzující plazmová vedení, turbínové ventilátory,
# analogové manometry, bezpečnostní šrafování a kontrolní pulty
# ---------------------------------------------------------------------------

func _draw_reactor_core():
	# 1. Tmavý grafitový technický bulkhead
	draw_rect(Rect2(0, 0, room_width, room_height), Color(0.035, 0.045, 0.065, 1.0))
	
	# Vertikální ocelové výztuhy s nýty
	var rib_col = Color(0.09, 0.12, 0.17, 1.0)
	var rivet_col = Color(0.20, 0.28, 0.36, 1.0)
	for rx in range(0, int(room_width), 32):
		draw_line(Vector2(float(rx), 0), Vector2(float(rx), room_height), rib_col, 2.0)
		for ry in range(16, int(room_height), 28):
			draw_rect(Rect2(float(rx) - 1.0, float(ry) - 1.0, 2.0, 2.0), rivet_col)
	
	var r_seed = float(room_x * 43 + room_y * 29)
	
	# 2. Masivní reaktorový sloup / cylindrická nádoba jádra
	var col_x = 90.0 + _hash(r_seed) * 140.0
	var col_w = 40.0
	draw_rect(Rect2(col_x, 0, col_w, room_height), Color(0.08, 0.11, 0.16, 1.0))
	draw_rect(Rect2(col_x, 0, 2.0, room_height), Color(0.18, 0.25, 0.34, 1.0))
	draw_rect(Rect2(col_x + col_w - 2.0, 0, 2.0, room_height), Color(0.05, 0.07, 0.10, 1.0))
	
	# Magnetické izolační prstence reaktoru
	for cy in range(10, int(room_height), 26):
		draw_rect(Rect2(col_x - 3.0, float(cy), col_w + 6.0, 5.0), COLOR_COPPER)
		draw_rect(Rect2(col_x - 3.0, float(cy), col_w + 6.0, 1.0), Color(0.9, 0.6, 0.3, 1.0))
	
	# Vertikální plazmové okno reaktoru s pulzujícím světlem
	var core_cx = col_x + col_w * 0.5
	_draw_glow(Vector2(core_cx, room_height * 0.5), 36.0, Color(0.20, 0.90, 0.85, 0.18))
	draw_rect(Rect2(core_cx - 3.0, 10.0, 6.0, room_height - 20.0), Color(0.15, 0.70, 0.80, 0.85))
	draw_rect(Rect2(core_cx - 1.0, 12.0, 2.0, room_height - 24.0), Color(0.80, 1.0, 0.98, 1.0))
	
	# 3. Turbínový ventilátor v krytu
	var turb_x = 260.0 if col_x < 160.0 else 45.0
	var turb_y = 70.0 + _hash(r_seed * 1.9) * 40.0
	_draw_turbine(Vector2(turb_x, turb_y), 24.0)
	
	# 4. Vysokonapěťová plazmová vedení a kabely podél stropu
	var cable_y = 20.0
	draw_line(Vector2(0, cable_y), Vector2(room_width, cable_y), Color(0.12, 0.15, 0.20, 1.0), 3.0)
	# Svítící neonový cyan vodič
	draw_line(Vector2(0, cable_y + 4.0), Vector2(room_width, cable_y + 4.0), Color(0.25, 0.92, 0.85, 0.75), 1.0)
	_draw_glow(Vector2(room_width * 0.5, cable_y + 4.0), 20.0, Color(0.20, 0.85, 0.80, 0.10))
	
	# Keramické talířové izolátory
	for ix in range(30, int(room_width), 60):
		for iy in range(3):
			draw_rect(Rect2(float(ix) - 4.0, cable_y + float(iy) * 3.0, 8.0, 2.0), Color(0.35, 0.45, 0.55, 1.0))
	
	# 5. Bezpečnostní žluto-černé šrafování (Hazard Stripes) na nosníku
	var haz_y = 135.0
	var haz_h = 6.0
	draw_rect(Rect2(col_x - 30.0, haz_y, col_w + 60.0, haz_h), Color(0.10, 0.10, 0.12, 1.0))
	for hx in range(int(col_x - 30.0), int(col_x + col_w + 30.0), 8):
		draw_colored_polygon(PackedVector2Array([
			Vector2(float(hx), haz_y),
			Vector2(float(hx + 4), haz_y),
			Vector2(float(hx), haz_y + haz_h),
			Vector2(float(hx - 4), haz_y + haz_h)
		]), Color(0.95, 0.75, 0.20, 0.9))
	
	# 6. Kontrolní pult s LED indikátory a manometry
	var panel_x = turb_x - 18.0
	var panel_y = turb_y + 34.0
	if panel_y + 24.0 < room_height:
		draw_rect(Rect2(panel_x, panel_y, 36.0, 22.0), Color(0.10, 0.13, 0.18, 1.0))
		draw_rect(Rect2(panel_x, panel_y, 36.0, 22.0), COLOR_BRASS, false, 1.0)
		# LED diody (zelená, žlutá, azurová)
		var leds = [Color(0.2, 0.9, 0.3, 1.0), Color(1.0, 0.8, 0.2, 1.0), Color(0.2, 0.8, 1.0, 1.0)]
		for li in range(3):
			var led_c = leds[li]
			draw_circle(Vector2(panel_x + 6.0 + float(li) * 7.0, panel_y + 6.0), 2.0, led_c)
			_draw_glow(Vector2(panel_x + 6.0 + float(li) * 7.0, panel_y + 6.0), 6.0, led_c * 0.35)
		# Miniaturní manometr na pultu
		draw_circle(Vector2(panel_x + 28.0, panel_y + 11.0), 5.0, COLOR_COPPER)
		draw_circle(Vector2(panel_x + 28.0, panel_y + 11.0), 3.8, Color(0.9, 0.9, 0.85, 1.0))
		draw_line(Vector2(panel_x + 28.0, panel_y + 11.0), Vector2(panel_x + 30.5, panel_y + 9.0), Color(0.85, 0.15, 0.1, 1.0), 1.0)

func _draw_turbine(center: Vector2, radius: float):
	var casing_col = Color(0.18, 0.22, 0.28, 1.0)
	var blade_col = Color(0.12, 0.16, 0.22, 1.0)
	var blade_edge = Color(0.28, 0.35, 0.44, 1.0)
	
	# Vnější kryt turbíny
	draw_circle(center, radius, casing_col)
	draw_arc(center, radius, 0.0, TAU, 24, COLOR_BRASS, 2.0)
	draw_circle(center, radius - 2.0, Color(0.05, 0.07, 0.10, 1.0))
	
	# 8 lopatek turbíny
	for i in range(8):
		var ang = float(i) / 8.0 * TAU
		var p_hub = center + Vector2(cos(ang), sin(ang)) * (radius * 0.3)
		var p_tip1 = center + Vector2(cos(ang + 0.25), sin(ang + 0.25)) * (radius - 3.0)
		var p_tip2 = center + Vector2(cos(ang - 0.10), sin(ang - 0.10)) * (radius - 3.0)
		draw_colored_polygon(PackedVector2Array([center, p_hub, p_tip1, p_tip2]), blade_col)
		draw_line(center, p_tip1, blade_edge, 1.0)
	
	# Středový kužel
	draw_circle(center, radius * 0.30, casing_col)
	draw_circle(center, radius * 0.16, COLOR_BRASS)
	
	# Ochranná mřížka přes turbínu
	for line_i in range(-2, 3):
		var dy = float(line_i) * (radius * 0.35)
		var dx_limit = sqrt(max(0.0, radius * radius - dy * dy)) * 0.95
		draw_line(center + Vector2(-dx_limit, dy), center + Vector2(dx_limit, dy), Color(0.25, 0.32, 0.40, 0.45), 1.0)
