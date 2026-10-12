class_name ItemData
extends RefCounted

## Definice předmětu pro mřížkový inventář (velikost width x height v buňkách).

var id: String = ""
var name: String = ""
var description: String = ""
var width: int = 1
var height: int = 1
var color_main: Color = Color(0.6, 0.6, 0.7, 1.0)
var color_accent: Color = Color(1.0, 1.0, 1.0, 1.0)
var icon_symbol: String = "■"

func _init(p_id: String, p_name: String, p_w: int, p_h: int, p_col: Color, p_desc: String = "", p_symbol: String = "■"):
	id = p_id
	name = p_name
	width = p_w
	height = p_h
	color_main = p_col
	color_accent = p_col.lightened(0.35)
	description = p_desc
	icon_symbol = p_symbol

static func create(item_id: String) -> RefCounted:
	match item_id:
		"wrench":
			return new("wrench", "Hasák", 1, 2, Color(0.85, 0.55, 0.25), "Hasák [LMB]: útok na blízko (2 poškození).", "🔧")
		"grapple_hook":
			return new("grapple_hook", "Přitahovací hák", 2, 1, Color(0.92, 0.75, 0.32), "Hák [RMB]: přitáhne ke stěnám a kotvám.", "🪝")
		"gravity_coil":
			return new("gravity_coil", "Gravitační cívka", 2, 2, Color(0.65, 0.35, 0.95), "Gravity Coil [Mezerník]: bleskový výpad (Dash), který prorazí nepřátele (2 poškození).", "⚡")
		"health_pack":
			return new("health_pack", "Lékárnička", 1, 1, Color(0.25, 0.85, 0.45), "Opravná sada: doplní 1 ztracené srdíčko.", "✚")
		"mine_key":
			return new("mine_key", "Klíč od šachty", 1, 2, Color(1.0, 0.85, 0.35), "Mosazný klíč: otevírá bezpečnostní zábrany.", "🗝")
		"steam_crystal":
			return new("steam_crystal", "Éterický krystal", 1, 1, Color(0.25, 0.92, 1.0), "Zářící krystal z hlubin reaktoru.", "💎")
		_:
			return new(item_id, item_id.capitalize(), 1, 1, Color(0.5, 0.5, 0.5), "Neznámý předmět.", "?")
