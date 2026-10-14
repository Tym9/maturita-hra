@tool
class_name GridPlatform
extends StaticBody2D

## Modulární čtvercová plošina (16x16 px dlaždice)
## Stylizovaná ve vysokém kontrastu podle Celeste a SteamWorld Dig.
## Automaticky spravuje kolizní tvar CollisionShape2D a kreslí mřížku dlaždic.

const THEME_STEAM_BRONZE = 0
const THEME_INDUSTRIAL_SLATE = 1
const THEME_RUST_MINES = 2
const THEME_HIGH_TECH = 3
const THEME_SURFACE_GRASS = 4
const THEME_WOOD_TIMBER = 5
const THEME_STONE_MASONRY = 6

@export var tiles_x: int = 4:
	set(val):
		tiles_x = maxi(1, val)
		_update_collision()
		queue_redraw()

@export var tiles_y: int = 1:
	set(val):
		tiles_y = maxi(1, val)
		_update_collision()
		queue_redraw()

@export var cell_size: int = 16:
	set(val):
		cell_size = maxi(4, val)
		_update_collision()
		queue_redraw()

@export_enum("Steam Bronze", "Industrial Slate", "Rust Mines", "High Tech", "Surface Grass", "Wood Timber", "Stone Masonry") var theme: int = 0:
	set(val):
		theme = val
		_apply_theme()
		queue_redraw()

@export var one_way: bool = false:
	set(val):
		one_way = val
		_update_collision()

@export var has_top_ledge: bool = true:
	set(val):
		has_top_ledge = val
		queue_redraw()

@export var has_bottom_ledge: bool = false:
	set(val):
		has_bottom_ledge = val
		queue_redraw()

@export var has_left_ledge: bool = true:
	set(val):
		has_left_ledge = val
		queue_redraw()

@export var has_right_ledge: bool = true:
	set(val):
		has_right_ledge = val
		queue_redraw()

@export var show_grid_lines: bool = true:
	set(val):
		show_grid_lines = val
		queue_redraw()

var color_top: Color = Color(0.94, 0.74, 0.38, 1.0)       # Jasný měděný/zlatý horní okraj pro skvělou čitelnost
var color_body: Color = Color(0.22, 0.18, 0.22, 1.0)      # Tmavé industriální tělo plošiny
var color_border: Color = Color(0.09, 0.07, 0.11, 1.0)    # Černý obrys mřížky pro oddělení čtverců
var color_inner: Color = Color(0.32, 0.26, 0.30, 1.0)     # Vnitřní panel čtverce
var color_rivet: Color = Color(0.85, 0.62, 0.30, 1.0)     # Nýty a rohové detaily

var col_shape: CollisionShape2D = null

func _ready():
	_apply_theme()
	_update_collision()
	queue_redraw()

func _apply_theme():
	match theme:
		THEME_STEAM_BRONZE:
			color_top = Color(0.95, 0.75, 0.38, 1.0)     # Zlatá / leštěná měď
			color_body = Color(0.24, 0.19, 0.21, 1.0)    # Tmavá steampunk bronz
			color_border = Color(0.09, 0.07, 0.11, 1.0)  # Tmavá kontura
			color_inner = Color(0.34, 0.26, 0.28, 1.0)   # Reliéfní kov
			color_rivet = Color(0.85, 0.62, 0.30, 1.0)   # Mosazný nýt
		THEME_INDUSTRIAL_SLATE:
			color_top = Color(0.48, 0.78, 0.98, 1.0)     # Ocelově modrý okraj
			color_body = Color(0.16, 0.18, 0.24, 1.0)    # Tmavá břidlice
			color_border = Color(0.08, 0.09, 0.13, 1.0)
			color_inner = Color(0.24, 0.27, 0.36, 1.0)
			color_rivet = Color(0.45, 0.72, 0.92, 1.0)
		THEME_RUST_MINES:
			color_top = Color(0.98, 0.54, 0.24, 1.0)     # Zářivá rez / jantar
			color_body = Color(0.28, 0.16, 0.13, 1.0)    # Rezavé železo
			color_border = Color(0.12, 0.07, 0.06, 1.0)
			color_inner = Color(0.38, 0.22, 0.18, 1.0)
			color_rivet = Color(0.88, 0.48, 0.22, 1.0)
		THEME_HIGH_TECH:
			color_top = Color(0.25, 0.95, 0.85, 1.0)     # Neonová cyan
			color_body = Color(0.12, 0.17, 0.20, 1.0)    # Grafit
			color_border = Color(0.06, 0.08, 0.10, 1.0)
			color_inner = Color(0.18, 0.26, 0.30, 1.0)
			color_rivet = Color(0.25, 0.88, 0.80, 1.0)
		THEME_SURFACE_GRASS:
			color_top = Color(0.52, 0.80, 0.34, 1.0)     # Svěží tráva
			color_body = Color(0.27, 0.20, 0.15, 1.0)    # Tmavá hlína
			color_border = Color(0.12, 0.09, 0.07, 1.0)
			color_inner = Color(0.36, 0.27, 0.20, 1.0)
			color_rivet = Color(0.58, 0.52, 0.44, 1.0)   # Kamínky v hlíně
		THEME_WOOD_TIMBER:
			color_top = Color(0.86, 0.62, 0.36, 1.0)     # Světlé dřevo
			color_body = Color(0.30, 0.19, 0.10, 1.0)    # Tmavý trám
			color_border = Color(0.13, 0.08, 0.04, 1.0)
			color_inner = Color(0.44, 0.29, 0.15, 1.0)
			color_rivet = Color(0.88, 0.70, 0.30, 1.0)   # Mosazné hřebíky
		THEME_STONE_MASONRY:
			color_top = Color(0.74, 0.70, 0.64, 1.0)     # Ohlazený kámen
			color_body = Color(0.27, 0.26, 0.29, 1.0)    # Tmavá žula
			color_border = Color(0.11, 0.10, 0.13, 1.0)
			color_inner = Color(0.38, 0.37, 0.40, 1.0)
			color_rivet = Color(0.62, 0.60, 0.58, 1.0)

func _update_collision():
	col_shape = get_node_or_null("CollisionShape2D")
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		add_child(col_shape)
		if Engine.is_editor_hint() and is_inside_tree() and get_tree():
			col_shape.owner = get_tree().edited_scene_root
	
	var total_w = float(tiles_x * cell_size)
	var total_h = float(tiles_y * cell_size)
	
	var rect_shape = col_shape.shape as RectangleShape2D
	if not rect_shape:
		rect_shape = RectangleShape2D.new()
		col_shape.shape = rect_shape
	
	rect_shape.size = Vector2(total_w, total_h)
	# Plošina má počátek (0, 0) v levém horním rohu
	col_shape.position = Vector2(total_w * 0.5, total_h * 0.5)
	col_shape.one_way_collision = one_way

func _draw():
	var total_w = tiles_x * cell_size
	var total_h = tiles_y * cell_size
	
	for y in range(tiles_y):
		for x in range(tiles_x):
			var rx = float(x * cell_size)
			var ry = float(y * cell_size)
			var rect = Rect2(rx, ry, cell_size, cell_size)
			
			# 1. Základní výplň těla dlaždice
			draw_rect(rect, color_body)
			
			# 2. Vnitřní reliéfní panel (inlay)
			if cell_size >= 12:
				var inner_rect = Rect2(rx + 2.0, ry + 2.0, cell_size - 4.0, cell_size - 4.0)
				draw_rect(inner_rect, color_inner, false, 1.0)
				
				# Nýty v rozích každého 16x16 čtverce
				draw_rect(Rect2(rx + 3.0, ry + 3.0, 1.0, 1.0), color_rivet)
				draw_rect(Rect2(rx + cell_size - 4.0, ry + 3.0, 1.0, 1.0), color_rivet)
				draw_rect(Rect2(rx + 3.0, ry + cell_size - 4.0, 1.0, 1.0), color_border)
				draw_rect(Rect2(rx + cell_size - 4.0, ry + cell_size - 4.0, 1.0, 1.0), color_border)
			
			# 3. Horní pochozí hrana (vysoký kontrast jako Celeste)
			if y == 0 and has_top_ledge:
				draw_rect(Rect2(rx, ry, cell_size, 2.0), color_top)
				draw_line(Vector2(rx, ry + 2.0), Vector2(rx + cell_size, ry + 2.0), color_rivet, 1.0)
			
			# 4. Spodní hrana
			if y == tiles_y - 1 and has_bottom_ledge:
				draw_line(Vector2(rx, ry + cell_size - 1.0), Vector2(rx + cell_size, ry + cell_size - 1.0), color_border, 1.0)
			
			# 5. Levá lezecká stěna
			if x == 0 and has_left_ledge:
				draw_rect(Rect2(rx, ry, 1.0, cell_size), color_top * 0.75)
			
			# 6. Pravá lezecká stěna
			if x == tiles_x - 1 and has_right_ledge:
				draw_rect(Rect2(rx + cell_size - 1.0, ry, 1.0, cell_size), color_top * 0.75)
			
			# 7. Oddělovací mřížka čtverců
			if show_grid_lines:
				draw_rect(rect, color_border, false, 1.0)
			
			# 8. Tematické detaily (tráva, dřevěná vlákna, kamenné zdivo)
			_draw_theme_details(rx, ry, x, y)

func _draw_theme_details(rx: float, ry: float, tx: int, ty: int):
	var cs = float(cell_size)
	match theme:
		THEME_SURFACE_GRASS:
			# Stébla trávy vyrůstající z horní hrany
			if ty == 0 and has_top_ledge:
				for k in range(4):
					var bx = rx + 2.0 + float(k) * 4.0
					var blade_h = 2.0 + float((tx * 3 + k * 5) % 3)
					var lean = float((tx + k) % 3 - 1) * 0.8
					draw_line(Vector2(bx, ry + 1.0), Vector2(bx + lean, ry - blade_h), color_top, 1.0)
			# Kamínky a kořínky v hlíně
			elif (tx * 7 + ty * 13) % 5 == 0:
				draw_rect(Rect2(rx + 6.0, ry + 8.0, 3.0, 2.0), color_rivet)
		THEME_WOOD_TIMBER:
			# Letokruhy a vlákna dřeva
			draw_line(Vector2(rx + 2.0, ry + cs * 0.5), Vector2(rx + cs - 2.0, ry + cs * 0.5), color_border, 1.0)
			draw_line(Vector2(rx + 4.0, ry + cs * 0.5 + 3.0), Vector2(rx + cs * 0.6, ry + cs * 0.5 + 3.0), color_inner, 1.0)
		THEME_STONE_MASONRY:
			# Malta mezi cihlami (střídavě posunutá)
			draw_line(Vector2(rx, ry + cs * 0.5), Vector2(rx + cs, ry + cs * 0.5), color_border, 1.0)
			var vx = rx + (cs * 0.5 if (tx + ty) % 2 == 0 else 0.0)
			draw_line(Vector2(vx, ry), Vector2(vx, ry + cs * 0.5), color_border, 1.0)
			var vx2 = rx + (0.0 if (tx + ty) % 2 == 0 else cs * 0.5)
			draw_line(Vector2(vx2, ry + cs * 0.5), Vector2(vx2, ry + cs), color_border, 1.0)
