@tool
class_name RoomDecor
extends Node2D

## Pozadí místnosti (Room) bez kolize: zakouřená obloha, korporátní těžní věže a komíny, krajina
## popraskaná krystalovou nákazou, levitující trosky (gravitační anomálie) a styl kapitoly v popředí.
## Velikost bere z rodičovské Room, tvary podle světové x, takže na sebe sousední místnosti navazují.

const STYLE_OUTPOST = 0 # tábor odboje: domy z plechu a prken, antény, světýlka, korouhve
const STYLE_VILLAGE = 1 # Smallville: chalupy (i rozbité), krystalové jehly, korporátní stožáry
const STYLE_CITY = 2 # Parní město: cihlové továrny, mosazné kopule, komíny s párou, hodinová věž, vzducholoď

const BLIGHT = Color(0.62, 0.36, 1.0)
const CORP_RED = Color(1.0, 0.22, 0.2)
const RESIST_TEAL = Color(0.25, 0.85, 0.75)
const LAMP = Color(1.0, 0.78, 0.4)
const BRASS = Color(0.88, 0.66, 0.28)

@export_enum("Outpost", "Village", "City") var style: int = STYLE_OUTPOST:
	set(val):
		style = val
		queue_redraw()

## Nálet: oranžová záře požárů u obzoru a dým
@export var burning: bool = false:
	set(val):
		burning = val
		queue_redraw()

## Horská kapitola: obzor klesá s výškou místnosti (svět y < 0), takže vesnice při stoupání mizí pod hráčem.
@export var altitude: bool = false:
	set(val):
		altitude = val
		queue_redraw()

## Velikost mimo Room (staré mřížkové úrovně, např. konec tutoriálu); nula = jedna obrazovka.
@export var size := Vector2.ZERO:
	set(val):
		size = val
		queue_redraw()

func _ready():
	z_index = -9
	# Ořez na vlastní místnost: s altitude leží obzor pod místností a kreslil by přes místnost pod ní
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, Rect2(Vector2.ZERO, _size()))
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)
	queue_redraw()

func _size() -> Vector2:
	var room := get_parent() as Room
	if room:
		return Vector2(room.screens) * Room.SCREEN
	return size if size != Vector2.ZERO else Room.SCREEN

func _h(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)

func _wx(x: float) -> float:
	return global_position.x + x

func _draw():
	var s := _size()
	var horizon := s.y - 56.0
	if altitude:
		horizon += maxf(0.0, -global_position.y) * 0.035
	_draw_sky(s, horizon)
	_draw_far(s, horizon)
	_draw_debris(s, horizon)
	_draw_ridge(s, horizon)
	match style:
		STYLE_OUTPOST: _draw_shacks(s, horizon)
		STYLE_VILLAGE: _draw_cottages(s, horizon)
		STYLE_CITY: _draw_city(s, horizon)
	if burning:
		for i in 10:
			var t := float(i) / 10.0
			draw_rect(Rect2(0, horizon - 70.0 + t * 70.0, s.x, 8.0), Color(1.0, 0.35, 0.08, 0.025 + t * 0.05))
		for i in int(s.x / 70.0) + 1: # sloupy dýmu nad tábořištěm
			var seed := floorf(_wx(i * 70.0) / 70.0) + 700.0
			var x := i * 70.0 + _h(seed) * 40.0
			for k in 4:
				draw_circle(Vector2(x + k * 6.0, horizon - 20.0 - k * 16.0), 8.0 + k * 4.0, Color(0.05, 0.04, 0.04, 0.3 - k * 0.05))

func _draw_sky(s: Vector2, horizon: float):
	var top: Color = [Color(0.10, 0.08, 0.13), Color(0.11, 0.10, 0.15), Color(0.09, 0.09, 0.08)][style]
	var low: Color = [Color(0.46, 0.28, 0.19), Color(0.34, 0.31, 0.33), Color(0.42, 0.38, 0.20)][style] # město: žlutý smog
	var bands := 24
	for i in bands:
		var t := float(i) / bands
		var y0 := lerpf(horizon - 180.0, horizon, t)
		draw_rect(Rect2(0, y0, s.x, (horizon - (horizon - 180.0)) / bands + 1.0), top.lerp(low, t * t))
	draw_rect(Rect2(0, 0, s.x, maxf(0.0, horizon - 180.0)), top)
	draw_rect(Rect2(0, horizon, s.x, s.y - horizon), low.darkened(0.4))
	# Zastřené slunce za smogem
	var sun := Vector2(fposmod(-global_position.x * 0.1 + 220.0, maxf(s.x, 1.0)), horizon - 70.0)
	draw_circle(sun, 18.0, Color(0.95, 0.6, 0.35, 0.25))
	draw_circle(sun, 11.0, Color(1.0, 0.75, 0.45, 0.45))
	for i in 4: # pásy smogu
		var y := horizon - 40.0 - i * 26.0
		draw_rect(Rect2(0, y, s.x, 7.0 + i * 2.0), Color(0.05, 0.04, 0.05, 0.22))

func _draw_far(s: Vector2, horizon: float):
	var sil := Color(0.12, 0.09, 0.11)
	var x := -fposmod(_wx(0.0), 96.0)
	while x < s.x + 96.0:
		var seed := floorf((_wx(x)) / 96.0)
		var kind := int(_h(seed) * 4.0)
		var bx := x + _h(seed + 1.0) * 40.0
		if kind == 0: # těžní věž s mřížovím a výstražným světlem
			var h := 60.0 + _h(seed + 2.0) * 50.0
			draw_rect(Rect2(bx, horizon - h, 10, h), sil)
			for k in int(h / 10.0):
				draw_line(Vector2(bx, horizon - k * 10.0), Vector2(bx + 10, horizon - k * 10.0 - 10.0), sil.lightened(0.08), 1.0)
			draw_rect(Rect2(bx + 3, horizon - h - 3, 4, 3), CORP_RED)
		elif kind == 1: # komín s kouřovou vlečkou
			var h := 45.0 + _h(seed + 3.0) * 40.0
			draw_rect(Rect2(bx, horizon - h, 8, h), sil)
			for k in 5:
				draw_circle(Vector2(bx + 4 + k * 9.0, horizon - h - 6.0 - k * 7.0), 5.0 + k * 2.5, Color(0.08, 0.07, 0.08, 0.35 - k * 0.05))
		elif kind == 2: # vrtná souprava (trojúhelník)
			var h := 50.0 + _h(seed + 4.0) * 30.0
			draw_colored_polygon(PackedVector2Array([Vector2(bx, horizon), Vector2(bx + 14, horizon - h), Vector2(bx + 28, horizon)]), sil)
			draw_line(Vector2(bx + 14, horizon - h), Vector2(bx + 14, horizon + 6.0), CORP_RED.darkened(0.3), 1.0)
		x += 96.0

func _draw_debris(s: Vector2, horizon: float):
	for i in int(s.x / 80.0) + 1:
		var seed := floorf(_wx(i * 80.0) / 80.0) + 50.0
		if _h(seed) < 0.45:
			continue
		var p := Vector2(i * 80.0 + _h(seed + 1.0) * 60.0, horizon - 90.0 - _h(seed + 2.0) * 60.0)
		var r := 3.0 + _h(seed + 3.0) * 5.0
		draw_circle(p + Vector2(0, r * 0.8), r * 1.3, Color(BLIGHT, 0.15)) # záře anomálie pod kamenem
		draw_colored_polygon(PackedVector2Array([p + Vector2(-r, 0), p + Vector2(-r * 0.4, -r), p + Vector2(r, -r * 0.5), p + Vector2(r * 0.6, r * 0.6)]), Color(0.16, 0.13, 0.16))

func _ridge_y(x: float, horizon: float) -> float:
	var w := _wx(x)
	return horizon - 14.0 - sin(w * 0.011) * 10.0 - sin(w * 0.031 + 1.7) * 5.0

func _draw_ridge(s: Vector2, horizon: float):
	var pts := PackedVector2Array([Vector2(0, s.y)])
	var x := 0.0
	while x <= s.x:
		pts.append(Vector2(x, _ridge_y(x, horizon)))
		x += 8.0
	pts.append(Vector2(s.x, s.y))
	draw_colored_polygon(pts, Color(0.15, 0.12, 0.13))
	# Praskliny s krystalovou nákazou
	for i in int(s.x / 60.0) + 1:
		var seed := floorf(_wx(i * 60.0) / 60.0) + 90.0
		var cx := i * 60.0 + _h(seed) * 40.0
		var y := _ridge_y(cx, horizon) + 6.0
		var p := PackedVector2Array([Vector2(cx, y), Vector2(cx + 5, y + 6), Vector2(cx + 2, y + 12), Vector2(cx + 8, y + 20)])
		draw_polyline(p, Color(BLIGHT, 0.55), 1.0)

func _draw_shacks(s: Vector2, horizon: float):
	var sil := Color(0.10, 0.08, 0.09)
	var x := -fposmod(_wx(0.0), 52.0)
	var lamps := PackedVector2Array()
	while x < s.x + 52.0:
		var seed := floorf(_wx(x) / 52.0) + 200.0
		var w := 24.0 + _h(seed) * 18.0
		var h := 14.0 + _h(seed + 1.0) * 16.0
		var base := _ridge_y(x + w * 0.5, horizon) + 4.0
		draw_rect(Rect2(x, base - h, w, h), sil)
		# Šikmá střecha z plechu, občas druhé patro z kontejneru
		draw_colored_polygon(PackedVector2Array([Vector2(x - 2, base - h), Vector2(x + w + 2, base - h - 5.0), Vector2(x + w + 2, base - h)]), sil.lightened(0.05))
		if _h(seed + 2.0) > 0.6:
			draw_rect(Rect2(x + 4, base - h - 12.0, w * 0.6, 8), sil)
		if _h(seed + 3.0) > 0.4: # okno
			draw_rect(Rect2(x + w * 0.3, base - h * 0.6, 4, 4), Color(LAMP, 0.85))
		if _h(seed + 4.0) > 0.55: # anténa s modrozeleným světlem odboje
			draw_line(Vector2(x + w - 4, base - h), Vector2(x + w - 4, base - h - 18.0), sil, 1.0)
			draw_rect(Rect2(x + w - 5, base - h - 20.0, 3, 2), RESIST_TEAL)
		if _h(seed + 5.0) > 0.8: # větrník z plechu
			var c := Vector2(x + 6, base - h - 16.0)
			draw_line(c, Vector2(x + 6, base - h), sil, 1.0)
			for k in 3:
				draw_line(c, c + Vector2.from_angle(k * TAU / 3.0 + seed) * 7.0, sil.lightened(0.1), 2.0)
		lamps.append(Vector2(x + w * 0.5, base - h - 2.0))
		x += w + 6.0 + _h(seed + 6.0) * 10.0
	for i in lamps.size() - 1: # řetězy světýlek mezi střechami
		var a := lamps[i]
		var b := lamps[i + 1]
		for k in range(1, 6):
			var t := k / 6.0
			draw_rect(Rect2(a.lerp(b, t) + Vector2(0, sin(t * PI) * 6.0), Vector2(1.5, 1.5)), Color(LAMP, 0.9))

func _draw_cottages(s: Vector2, horizon: float):
	var sil := Color(0.11, 0.09, 0.10)
	var x := -fposmod(_wx(0.0), 60.0)
	while x < s.x + 60.0:
		var seed := floorf(_wx(x) / 60.0) + 400.0
		var w := 26.0 + _h(seed) * 16.0
		var h := 14.0 + _h(seed + 1.0) * 10.0
		var base := _ridge_y(x + w * 0.5, horizon) + 4.0
		var broken := _h(seed + 2.0) > 0.65
		draw_rect(Rect2(x, base - h, w, h), sil)
		var peak := Vector2(x + w * 0.5, base - h - 12.0)
		if broken: # propadlá střecha
			draw_colored_polygon(PackedVector2Array([Vector2(x - 2, base - h), peak, Vector2(peak.x + 2, base - h - 4.0)]), sil)
		else:
			draw_colored_polygon(PackedVector2Array([Vector2(x - 2, base - h), peak, Vector2(x + w + 2, base - h)]), sil)
			draw_rect(Rect2(x + w * 0.7, base - h - 12.0, 4, 8), sil) # komín
			if _h(seed + 3.0) > 0.5:
				draw_rect(Rect2(x + w * 0.25, base - h * 0.6, 4, 4), Color(LAMP, 0.7))
		if _h(seed + 4.0) > 0.6: # krystalová jehla prorážející zem
			var cx := x + w + 6.0
			var ch := 16.0 + _h(seed + 5.0) * 22.0
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 4, base), Vector2(cx, base - ch), Vector2(cx + 4, base)]), Color(BLIGHT, 0.75))
			draw_line(Vector2(cx, base - ch), Vector2(cx, base), Color(0.85, 0.7, 1.0, 0.6), 1.0)
		elif _h(seed + 6.0) > 0.6: # suchý strom
			var t := Vector2(x + w + 8.0, base)
			draw_line(t, t + Vector2(0, -20), sil, 2.0)
			draw_line(t + Vector2(0, -12), t + Vector2(-6, -18), sil, 1.0)
			draw_line(t + Vector2(0, -16), t + Vector2(5, -22), sil, 1.0)
		x += w + 10.0 + _h(seed + 7.0) * 12.0
	# Korporátní stožár s kabely přes celou místnost
	var px := fposmod(-_wx(0.0), 240.0) + 40.0
	if px < s.x:
		var top := Vector2(px, horizon - 70.0)
		draw_line(Vector2(px - 6, horizon), top, sil, 2.0)
		draw_line(Vector2(px + 6, horizon), top, sil, 2.0)
		draw_rect(Rect2(top + Vector2(-1, -3), Vector2(3, 3)), CORP_RED)
		draw_line(top + Vector2(0, 2), top + Vector2(-px - 10.0, 10.0), Color(sil, 0.8), 1.0)
		draw_line(top + Vector2(0, 2), top + Vector2(s.x - px + 10.0, 10.0), Color(sil, 0.8), 1.0)

func _draw_city(s: Vector2, horizon: float):
	var sil := Color(0.12, 0.10, 0.10)
	var x := -fposmod(_wx(0.0), 48.0)
	while x < s.x + 48.0:
		var seed := floorf(_wx(x) / 48.0) + 600.0
		var w := 22.0 + _h(seed) * 20.0
		var h := 30.0 + _h(seed + 1.0) * 55.0
		var base := _ridge_y(x + w * 0.5, horizon) + 6.0
		draw_rect(Rect2(x, base - h, w, h), sil)
		for wy in int(h / 9.0) - 1: # řady oken továren, část svítí
			for wx in int((w - 4.0) / 6.0):
				if _h(seed + wy * 7.0 + wx * 13.0) > 0.72:
					draw_rect(Rect2(x + 3.0 + wx * 6.0, base - h + 5.0 + wy * 9.0, 2, 3), Color(LAMP, 0.6))
		var roof := _h(seed + 2.0)
		if roof > 0.65: # mosazná kopule
			var c := Vector2(x + w * 0.5, base - h)
			var pts := PackedVector2Array()
			for k in 9:
				pts.append(c + Vector2.from_angle(PI + k * PI / 8.0) * w * 0.38)
			draw_colored_polygon(pts, BRASS.darkened(0.6))
			draw_line(c - Vector2(0, w * 0.38), c - Vector2(0, w * 0.38 + 8.0), sil, 1.0)
		elif roof > 0.25: # komín s bílou párou
			var cx := x + 4.0 + _h(seed + 3.0) * (w - 10.0)
			draw_rect(Rect2(cx, base - h - 18.0, 6, 18), sil)
			for k in 5:
				draw_circle(Vector2(cx + 3.0 + k * 8.0, base - h - 24.0 - k * 8.0), 4.0 + k * 2.5, Color(0.75, 0.72, 0.62, 0.22 - k * 0.035))
		x += w + 2.0 + _h(seed + 4.0) * 8.0
	# Potrubí mezi továrnami
	var py := horizon - 22.0
	draw_rect(Rect2(0, py, s.x, 3), BRASS.darkened(0.65))
	for i in int(s.x / 32.0) + 1:
		draw_rect(Rect2(i * 32.0 - fposmod(_wx(0.0), 32.0), py - 1.0, 3, 5), BRASS.darkened(0.5))
	# Hodinová věž korporace s rudým majákem
	var tx := fposmod(-_wx(0.0), 360.0) + 140.0
	if tx < s.x:
		var top := Vector2(tx, horizon - 130.0)
		var tower := sil.lightened(0.07)
		draw_rect(Rect2(tx - 10.0, top.y, 20, 136), tower)
		draw_colored_polygon(PackedVector2Array([top + Vector2(-12, 0), top + Vector2(0, -22), top + Vector2(12, 0)]), tower)
		draw_circle(top + Vector2(0, 18), 7.0, Color(LAMP, 0.55))
		draw_line(top + Vector2(0, 18), top + Vector2(0, 13), sil, 1.0)
		draw_line(top + Vector2(0, 18), top + Vector2(4, 19), sil, 1.0)
		draw_rect(Rect2(top + Vector2(-1, -25), Vector2(3, 3)), CORP_RED)
	# Korporátní vzducholoď
	var ax := fposmod(-_wx(0.0) * 0.6 + 60.0, maxf(s.x + 120.0, 1.0)) - 60.0
	var ay := horizon - 120.0
	draw_colored_polygon(PackedVector2Array([Vector2(ax - 30, ay), Vector2(ax - 18, ay - 9), Vector2(ax + 22, ay - 9), Vector2(ax + 32, ay), Vector2(ax + 22, ay + 8), Vector2(ax - 18, ay + 8)]), Color(0.16, 0.13, 0.13))
	draw_rect(Rect2(ax - 6, ay + 8, 14, 5), Color(0.13, 0.11, 0.11))
	draw_rect(Rect2(ax + 28, ay - 1, 2, 2), CORP_RED)
	draw_line(Vector2(ax + 6, ay + 13), Vector2(ax - 4, horizon), Color(1.0, 0.9, 0.6, 0.06), 10.0) # reflektor
