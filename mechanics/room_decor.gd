@tool
class_name RoomDecor
extends Node2D

## Pozadí místnosti (Room) bez kolize: zakouřená obloha, korporátní těžní věže a komíny, krajina
## popraskaná krystalovou nákazou, levitující trosky (gravitační anomálie) a styl kapitoly v popředí.
## Velikost bere z rodičovské Room, tvary podle světové x, takže na sebe sousední místnosti navazují.

const STYLE_OUTPOST = 0 # tábor odboje: domy z plechu a prken, antény, světýlka, korouhve
const STYLE_VILLAGE = 1 # Smallville: chalupy (i rozbité), krystalové jehly, korporátní stožáry
const STYLE_CITY = 2 # Parní město: cihlové továrny, mosazné kopule, komíny s párou, hodinová věž, vzducholoď
const STYLE_MOUNTAIN = 3 # Severní stěna: zasněžené štíty, moře mraků nad městem, lanovka, světla sídla ve skále
const STYLE_MINES = 5 # Krystalové doly: tmavá sloj, výdřeva starých štol, žíly krystalů svítící ze skály
const STYLE_REACTOR = 6 # Těžební komplex: stejná šachta jako slévárna, ale chladná, s fialovou září anomálií místo žáru
const STYLE_FOUNDRY = 4 # Slévárna: nitro velké šachty pod sídlem, patra pecí ve vzdálené stěně, řetězy, proudy strusky; čím hlouběji, tím víc žáru

const BLIGHT = Color(0.62, 0.36, 1.0)
const CORP_RED = Color(1.0, 0.22, 0.2)
const RESIST_TEAL = Color(0.25, 0.85, 0.75)
const LAMP = Color(1.0, 0.78, 0.4)
const BRASS = Color(0.88, 0.66, 0.28)

@export_enum("Outpost", "Village", "City", "Mountain", "Foundry", "Mines", "Reactor") var style: int = STYLE_OUTPOST:
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
	if style == STYLE_FOUNDRY or style == STYLE_REACTOR:
		_draw_foundry(s)
		return
	if style == STYLE_MINES:
		_draw_mines(s)
		return
	var horizon := s.y - 56.0
	if altitude:
		horizon += maxf(0.0, -global_position.y) * 0.035
	_draw_sky(s, horizon)
	if style == STYLE_MOUNTAIN:
		_draw_peaks(s, horizon)
		_draw_debris(s, horizon)
		_draw_clouds(s, horizon)
		_draw_cableway(s, horizon)
		return
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
	var top: Color = [Color(0.10, 0.08, 0.13), Color(0.11, 0.10, 0.15), Color(0.09, 0.09, 0.08), Color(0.06, 0.07, 0.13)][style]
	var low: Color = [Color(0.46, 0.28, 0.19), Color(0.34, 0.31, 0.33), Color(0.42, 0.38, 0.20), Color(0.42, 0.44, 0.55)][style] # město: žlutý smog, hory: mrazivá modř
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
	if style == STYLE_MOUNTAIN:
		return # nad smogem je vzduch čistý
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
	var bottom := maxf(s.y, horizon + 20.0) # s výškou leží obzor pod místností: dno pod hřebenem, jinak se polygon překříží
	var pts := PackedVector2Array([Vector2(0, bottom)])
	var x := 0.0
	while x <= s.x:
		pts.append(Vector2(x, _ridge_y(x, horizon)))
		x += 8.0
	pts.append(Vector2(s.x, bottom))
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

## Hory: vzdálené štíty se sněhem; na některých svítí okna a rudé majáky sídla vytesaného do skály.
func _draw_peaks(s: Vector2, horizon: float):
	var rock := Color(0.17, 0.18, 0.26)
	var x := -fposmod(_wx(0.0), 70.0) - 70.0
	var bottom := maxf(s.y, horizon + 1.0) # obzor pod místností: dno pod údolími, jinak se polygon překříží
	var pts := PackedVector2Array([Vector2(x, bottom)])
	var tops: Array[Vector3] = [] # x, y vrcholu, polovina šířky
	while x < s.x + 140.0:
		var seed := floorf(_wx(x) / 70.0) + 900.0
		var h := 40.0 + _h(seed) * 80.0
		pts.append(Vector2(x, horizon - 10.0 - _h(seed + 1.0) * 20.0))
		pts.append(Vector2(x + 35.0, horizon - h))
		tops.append(Vector3(x + 35.0, horizon - h, h))
		x += 70.0
	pts.append(Vector2(x, horizon))
	pts.append(Vector2(x, bottom))
	draw_colored_polygon(pts, rock)
	for t in tops: # sněhová čepice a v každém čtvrtém štítu sídlo korporace
		var c := Vector2(t.x, t.y)
		var k := t.z * 0.35
		draw_colored_polygon(PackedVector2Array([c, c + Vector2(-k * 0.8, k), c + Vector2(-k * 0.2, k * 0.75), c + Vector2(k * 0.3, k * 1.05), c + Vector2(k * 0.8, k)]), Color(0.72, 0.76, 0.86))
		var seed := floorf(_wx(t.x) / 70.0) + 950.0
		if _h(seed) > 0.75:
			for i in 7:
				draw_rect(Rect2(c + Vector2(-9.0 + _h(seed + i) * 18.0, t.z * 0.45 + _h(seed + i + 9.0) * t.z * 0.35), Vector2(2, 2)), Color(LAMP, 0.8))
			draw_rect(Rect2(c + Vector2(-1, -4), Vector2(3, 3)), CORP_RED)

## Moře mraků pod hřebeny; pod ním prosvítá žlutá záře Parního města.
func _draw_clouds(s: Vector2, horizon: float):
	var cloud := Color(0.55, 0.56, 0.66)
	draw_rect(Rect2(0, horizon + 6.0, s.x, s.y - horizon), cloud.darkened(0.25))
	for i in int(s.x / 60.0) + 2:
		var seed := floorf(_wx(i * 60.0) / 60.0) + 980.0
		var cx := i * 60.0 - fposmod(_wx(0.0), 60.0) + _h(seed) * 30.0
		if _h(seed + 1.0) > 0.6:
			draw_circle(Vector2(cx, horizon + 20.0), 22.0, Color(1.0, 0.8, 0.4, 0.07)) # město pod mraky
		for k in 3:
			draw_circle(Vector2(cx + k * 14.0 - 14.0, horizon + 4.0 - _h(seed + k + 2.0) * 8.0), 10.0 + _h(seed + k) * 8.0, cloud)
	for i in int(s.x * s.y / 2500.0): # sněhové vločky
		var seed := float(i) + floorf(_wx(0.0) / 320.0) * 131.0
		draw_rect(Rect2(_h(seed) * s.x, _h(seed + 0.5) * s.y, 1, 1), Color(1, 1, 1, 0.35))

## Korporátní lanovka po hřebeni: příhradové stožáry, prověšené lano a gondola s nákladem krystalů.
func _draw_cableway(s: Vector2, horizon: float):
	var sil := Color(0.10, 0.10, 0.15)
	var span := 260.0
	var x0 := -fposmod(_wx(0.0), span)
	var base := horizon - 6.0
	for i in int(s.x / span) + 2:
		var a := Vector2(x0 + i * span, base - 62.0)
		var b := a + Vector2(span, 0)
		draw_line(Vector2(a.x - 7, base), a, sil, 2.0)
		draw_line(Vector2(a.x + 7, base), a, sil, 2.0)
		draw_line(a + Vector2(-8, 0), a + Vector2(8, 0), sil, 2.0)
		draw_rect(Rect2(a + Vector2(-1, -4), Vector2(3, 3)), CORP_RED)
		var prev := a
		for k in range(1, 11):
			var t := k / 10.0
			var p := a.lerp(b, t) + Vector2(0, sin(t * PI) * 14.0)
			draw_line(prev, p, Color(sil, 0.9), 1.0)
			prev = p
		var seed := floorf(_wx(a.x) / span) + 990.0
		if _h(seed) > 0.4: # gondola visí na laně
			var t := 0.2 + _h(seed + 1.0) * 0.6
			var g := a.lerp(b, t) + Vector2(0, sin(t * PI) * 14.0)
			draw_line(g, g + Vector2(0, 8), sil, 1.0)
			draw_rect(Rect2(g + Vector2(-7, 8), Vector2(14, 9)), BRASS.darkened(0.55))
			draw_rect(Rect2(g + Vector2(-4, 10), Vector2(8, 3)), Color(BLIGHT, 0.8))


## Slévárna: vzdálená stěna velké šachty. Vše podle světových souřadnic, takže místnosti nad sebou i vedle
## sebe na sebe navazují; žár (barva, jiskry) roste s hloubkou (svět y > 0).
func _heat(world_y: float) -> float:
	return clampf(world_y / 3600.0, 0.0, 1.0)

func _wy(y: float) -> float:
	return global_position.y + y

func _draw_foundry(s: Vector2):
	var cold := Color(0.055, 0.05, 0.065)
	var reactor := style == STYLE_REACTOR
	var hot := Color(0.09, 0.05, 0.17) if reactor else Color(0.19, 0.075, 0.04)
	var y := -fposmod(_wy(0.0), 12.0)
	while y < s.y: # podklad: svislý přechod podle hloubky
		draw_rect(Rect2(0, y, s.x, 12.0), cold.lerp(hot, _heat(_wy(y))))
		y += 12.0
	# Vrstvy horniny ve stěně šachty
	y = -fposmod(_wy(0.0), 46.0)
	while y < s.y + 46.0:
		var band := floorf(_wy(y) / 46.0)
		var x := -fposmod(_wx(0.0), 32.0)
		while x < s.x:
			var off := _h(band * 7.0 + floorf(_wx(x) / 32.0)) * 6.0
			draw_rect(Rect2(x, y + off, 32.0, 3.0 + _h(band + 3.0) * 4.0), Color(0, 0, 0, 0.16))
			x += 32.0
		y += 46.0
	_draw_furnace_tiers(s)
	_draw_shaft_chains(s)
	if not reactor:
		_draw_slag_falls(s)
	for i in int(s.x * s.y / 1800.0): # jiskry a žhavý popel stoupající šachtou
		var seed := float(i) + floorf(_wx(0.0) / 320.0) * 131.0 + floorf(_wy(0.0) / 180.0) * 977.0
		var p := Vector2(_h(seed) * s.x, _h(seed + 0.5) * s.y)
		if _h(seed + 0.7) < 0.35 + _heat(_wy(p.y)) * 0.5:
			draw_rect(Rect2(p, Vector2(1, 1)), Color(0.55, 0.9, 1.0, 0.5) if reactor else Color(1.0, 0.55 + _h(seed + 0.9) * 0.3, 0.2, 0.5))

## Krystalové doly: stěna sloje podle světových souřadnic (místnosti na sebe navazují). Vrstvy horniny,
## výdřeva opuštěných štol s lucernou a žíly krystalů; čím hlouběji, tím víc modrofialové záře.
func _draw_mines(s: Vector2):
	var top := Color(0.05, 0.045, 0.06)
	var deep := Color(0.05, 0.04, 0.11)
	var depth := func(wy: float) -> float: return clampf(wy / 4000.0, 0.0, 1.0)
	var y := -fposmod(_wy(0.0), 12.0)
	while y < s.y:
		draw_rect(Rect2(0, y, s.x, 12.0), top.lerp(deep, depth.call(_wy(y))))
		y += 12.0
	y = -fposmod(_wy(0.0), 38.0)
	while y < s.y + 38.0: # vrstvy horniny
		var band := floorf(_wy(y) / 38.0)
		var x := -fposmod(_wx(0.0), 40.0)
		while x < s.x:
			var off := _h(band * 5.0 + floorf(_wx(x) / 40.0)) * 8.0
			draw_rect(Rect2(x, y + off, 40.0, 2.0 + _h(band + 9.0) * 5.0), Color(0, 0, 0, 0.18))
			x += 40.0
		y += 38.0
	var cell := Vector2(110.0, 90.0)
	var y0 := -fposmod(_wy(0.0), cell.y) - cell.y
	while y0 < s.y + cell.y:
		var x0 := -fposmod(_wx(0.0), cell.x) - cell.x
		while x0 < s.x + cell.x:
			var seed := floorf(_wx(x0) / cell.x) * 17.0 + floorf(_wy(y0) / cell.y) * 59.0 + 2100.0
			var c := Vector2(x0 + _h(seed) * cell.x, y0 + _h(seed + 1.0) * cell.y)
			var kind := _h(seed + 2.0)
			if kind > 0.72: # žíla krystalů: shluk jehel se září
				var col := BLIGHT if _h(seed + 3.0) > 0.4 else RESIST_TEAL
				var glow: float = 0.05 + depth.call(_wy(c.y)) * 0.06
				draw_circle(c, 22.0, Color(col, glow))
				for k in 5:
					var a := -PI / 2.0 + (_h(seed + 4.0 + k) - 0.5) * 2.2
					var len := 6.0 + _h(seed + 10.0 + k) * 12.0
					var base := c + Vector2((k - 2) * 4.0, 4.0)
					draw_colored_polygon(PackedVector2Array([base + Vector2(-2, 0), base + Vector2(2, 0), base + Vector2(cos(a), sin(a)) * len]), Color(col.darkened(0.55), 0.9))
					draw_line(base, base + Vector2(cos(a), sin(a)) * len, Color(col, 0.35), 1.0)
			elif kind < 0.22: # ústí staré štoly s výdřevou a lucernou
				var sil := Color(0.02, 0.018, 0.025)
				var w := 30.0 + _h(seed + 5.0) * 16.0
				draw_rect(Rect2(c.x - w * 0.5, c.y - 22.0, w, 22.0), sil)
				var wood := Color(0.16, 0.11, 0.07)
				draw_rect(Rect2(c.x - w * 0.5 - 2.0, c.y - 24.0, 3.0, 24.0), wood)
				draw_rect(Rect2(c.x + w * 0.5 - 1.0, c.y - 24.0, 3.0, 24.0), wood)
				draw_rect(Rect2(c.x - w * 0.5 - 4.0, c.y - 27.0, w + 8.0, 3.0), wood)
				if _h(seed + 6.0) > 0.4:
					draw_circle(Vector2(c.x, c.y - 18.0), 9.0, Color(LAMP, 0.05))
					draw_rect(Rect2(c.x - 1.0, c.y - 20.0, 2.0, 3.0), Color(LAMP, 0.7))
			x0 += cell.x
		y0 += cell.y
	for i in int(s.x * s.y / 2600.0): # prach a třpyt ve vzduchu
		var seed := float(i) + floorf(_wx(0.0) / 320.0) * 137.0 + floorf(_wy(0.0) / 180.0) * 911.0
		var p := Vector2(_h(seed) * s.x, _h(seed + 0.5) * s.y)
		draw_rect(Rect2(p, Vector2(1, 1)), Color(0.6, 0.7, 1.0, 0.25 + _h(seed + 0.8) * 0.3))

## Patra pecí vytesaná do vzdálené stěny: obrys dílny, klenuté ústí pece se září, komín a pár oken.
func _draw_furnace_tiers(s: Vector2):
	var sil := Color(0.035, 0.03, 0.04)
	var tier := 150.0
	var cell := 120.0
	var y0 := -fposmod(_wy(0.0), tier) - tier
	while y0 < s.y + tier:
		var row := floorf(_wy(y0) / tier)
		var x0 := -fposmod(_wx(0.0), cell) - cell
		# římsa patra přes celou šířku
		draw_rect(Rect2(0, y0 + tier - 10.0, s.x, 4.0), Color(sil, 0.8))
		while x0 < s.x + cell:
			var seed := floorf(_wx(x0) / cell) * 13.0 + row * 71.0 + 1300.0
			if _h(seed) > 0.45:
				var w := 46.0 + _h(seed + 1.0) * 40.0
				var h := 34.0 + _h(seed + 2.0) * 30.0
				var bx := x0 + _h(seed + 3.0) * (cell - w * 0.5)
				var base := y0 + tier - 10.0
				draw_rect(Rect2(bx, base - h, w, h), sil)
				var mouth := Rect2(bx + w * 0.36, base - h * 0.42, w * 0.28, h * 0.42)
				var glow := Color(0.6, 0.35, 1.0) if style == STYLE_REACTOR else Color(1.0, 0.45, 0.12)
				draw_circle(mouth.get_center() + Vector2(0, mouth.size.y * 0.2), mouth.size.x * 0.8, Color(glow, 0.04))
				draw_rect(mouth, Color(glow, 0.22))
				draw_circle(Vector2(mouth.get_center().x, mouth.position.y), mouth.size.x * 0.5, Color(glow, 0.22))
				draw_rect(Rect2(mouth.position.x + 2.0, mouth.end.y - 2.0, mouth.size.x - 4.0, 2.0), Color(1.0, 0.7, 0.35, 0.35))
				var cx := bx + 4.0 + _h(seed + 4.0) * (w - 10.0)
				draw_rect(Rect2(cx, base - h - 26.0, 6.0, 26.0), sil) # komín
				for k in 3:
					draw_circle(Vector2(cx + 3.0 + k * 3.0, base - h - 30.0 - k * 9.0), 4.0 + k * 2.0, Color(0.02, 0.02, 0.03, 0.35 - k * 0.08))
				for k in 3:
					if _h(seed + 5.0 + k) > 0.5:
						draw_rect(Rect2(bx + 4.0 + k * (w - 10.0) / 3.0, base - h + 6.0, 3, 3), Color(LAMP, 0.6))
				if _h(seed + 9.0) > 0.7:
					draw_rect(Rect2(bx + w - 4.0, base - h - 3.0, 3, 3), CORP_RED)
			x0 += cell
		y0 += tier

## Obří řetězy a lana výtahů visící šachtou (podle světové x, takže pokračují přes místnosti nad sebou).
func _draw_shaft_chains(s: Vector2):
	var cell := 200.0
	var x0 := -fposmod(_wx(0.0), cell)
	while x0 < s.x + cell:
		var seed := floorf(_wx(x0) / cell) + 1500.0
		if _h(seed) > 0.4:
			var x := x0 + _h(seed + 1.0) * cell
			var col := Color(0.12, 0.10, 0.10)
			var y := -fposmod(_wy(0.0), 8.0)
			while y < s.y:
				if int(floorf(_wy(y) / 8.0)) % 2 == 0:
					draw_rect(Rect2(x - 2.0, y, 4.0, 7.0), col)
				else:
					draw_rect(Rect2(x - 0.5, y, 1.0, 8.0), col)
				y += 8.0
			if _h(seed + 2.0) > 0.5: # druhé lano se závažím klece
				draw_line(Vector2(x + 14.0, 0), Vector2(x + 14.0, s.y), Color(col, 0.9), 1.0)
				var cy := fposmod(_h(seed + 3.0) * 900.0 - _wy(0.0), 900.0)
				if cy < s.y:
					draw_rect(Rect2(x + 8.0, cy, 12.0, 16.0), BRASS.darkened(0.7))
					draw_rect(Rect2(x + 10.0, cy + 4.0, 8.0, 4.0), Color(LAMP, 0.4))
		x0 += cell

## Proudy strusky stékající po vzdálené stěně, se září kolem.
func _draw_slag_falls(s: Vector2):
	var cell := 420.0
	var x0 := -fposmod(_wx(0.0), cell)
	while x0 < s.x + cell:
		var seed := floorf(_wx(x0) / cell) + 1700.0
		if _h(seed) > 0.55:
			var x := x0 + _h(seed + 1.0) * cell
			var w := 3.0 + _h(seed + 2.0) * 2.0
			draw_rect(Rect2(x - w * 2.0, 0, w * 4.0, s.y), Color(1.0, 0.4, 0.1, 0.025))
			draw_rect(Rect2(x - w * 0.5, 0, w, s.y), Color(0.8, 0.32, 0.08, 0.3))
			var y := -fposmod(_wy(0.0), 14.0)
			while y < s.y:
				draw_rect(Rect2(x - w * 0.3, y, w * 0.6, 4.0), Color(1.0, 0.65, 0.3, 0.3))
				y += 14.0
		x0 += cell
