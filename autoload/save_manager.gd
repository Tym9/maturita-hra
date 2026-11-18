extends Node

## Autoload správce ukládání hry (SaveManager).
## Ukládá stav hry do JSON souboru (user://save.json).
## Uchovává stav hráče, sebrané krystaly, statistiky i obsah inventáře.

const SAVE_PATH = "user://save.json"
# Trvalý postup napříč restarty (jako záznamy v Celeste): sebrané krystaly a stavy přepínačů.
# Zapisuje se hned při změně, nezávisle na ručním uložení pozice.
const PROGRESS_PATH = "user://progress.json"

var current_save_data: Dictionary = {}
var pending_load: bool = false
var progress: Dictionary = {"crystals": {}, "grand": {}, "flags": {}}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if has_save_file():
		current_save_data = load_game_data()
	if FileAccess.file_exists(PROGRESS_PATH):
		var data = JSON.parse_string(FileAccess.get_file_as_string(PROGRESS_PATH))
		if data is Dictionary:
			for key in progress:
				if data.get(key) is Dictionary:
					progress[key] = data[key]

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(player_node = null, scene_path: String = "", room_id: String = "") -> bool:
	var current_scene_path = scene_path
	var scene := get_tree().current_scene
	if current_scene_path.is_empty() and scene:
		current_scene_path = scene.scene_file_path
	# Ruční uložení v kapitole: místnost, kde hráč je (jako checkpoint)
	if room_id.is_empty() and scene is Chapter and scene.current:
		room_id = scene.current.room_id
	# Obsah truhel scény, aby se po Pokračovat znovu nenaplnily
	var chests := {}
	for c in get_tree().get_nodes_in_group("chests"):
		if scene and scene.is_ancestor_of(c):
			chests[str(scene.get_path_to(c))] = c.inventory.to_save_data()

	var data = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"current_scene": current_scene_path,
		"room_id": room_id, # místnost kapitoly (checkpoint), prázdné u starých levelů
		"stats": {
			"deaths": Global.death_count,
			"kills": Global.kill_count
		},
		"player": {},
		"chests": chests
	}
	
	if not player_node:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_node = players[0]
			
	if player_node:
		data["player"] = {
			"health": player_node.health,
			"max_health": player_node.max_health,
			"crystals": player_node.crystals,
			"collected_crystal_ids": player_node.collected_crystal_ids,
			"active_slot": player_node.active_slot,
			"spawn_point_x": player_node.spawn_point.x,
			"spawn_point_y": player_node.spawn_point.y,
			"inventory": player_node.get_inventory_save_data() if player_node.has_method("get_inventory_save_data") else []
		}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		printerr("Chyba při otevírání save souboru pro zápis: ", SAVE_PATH)
		return false
		
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	current_save_data = data
	print("[SaveManager] Hra úspěšně uložena do: ", SAVE_PATH)
	return true

func load_game_data() -> Dictionary:
	if not has_save_file():
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var content = file.get_as_text()
	file.close()
	var test_json = JSON.new()
	var err = test_json.parse(content)
	if err != OK:
		printerr("[SaveManager] Chyba při čtení JSON: ", test_json.get_error_message())
		return {}
	if test_json.data is Dictionary:
		current_save_data = test_json.data
		return test_json.data
	return {}

func continue_game():
	var data = load_game_data()
	if data.is_empty():
		return
	var target_scene = data.get("current_scene", "res://level1.tscn")
	pending_load = true
	Global.has_persistent_player = false # uložená hra má přednost před stavem přeneseným z minulé kapitoly
	get_tree().change_scene_to_file(target_scene)

func apply_save_to_player(player_node) -> bool:
	if current_save_data.is_empty():
		load_game_data()
	if current_save_data.is_empty() or not current_save_data.has("player"):
		return false
		
	var pdata = current_save_data["player"]
	if pdata.has("health"):
		player_node.health = int(pdata["health"])
	if pdata.has("max_health"):
		player_node.max_health = int(pdata["max_health"])
	if pdata.has("crystals"):
		player_node.crystals = int(pdata["crystals"])
	if pdata.has("collected_crystal_ids"):
		player_node.collected_crystal_ids.clear()
		for id in pdata["collected_crystal_ids"]:
			player_node.collected_crystal_ids.append(str(id))
	if pdata.has("spawn_point_x") and pdata.has("spawn_point_y"):
		player_node.spawn_point = Vector2(float(pdata["spawn_point_x"]), float(pdata["spawn_point_y"]))
		player_node.global_position = player_node.spawn_point
	if pdata.has("inventory") and player_node.has_method("load_inventory_save_data"):
		player_node.load_inventory_save_data(pdata["inventory"])
		
	if current_save_data.has("stats"):
		var stats = current_save_data["stats"]
		if stats.has("deaths"):
			Global.death_count = int(stats["deaths"])
		if stats.has("kills"):
			Global.kill_count = int(stats["kills"])
			
	if player_node.has_method("_init_ui"):
		player_node._init_ui()
	# Až po _ready celé scény (truhly se naplní výchozími předměty, pak je přepíše uložený obsah)
	_restore_chests.call_deferred(current_save_data.get("chests", {}))
		
	pending_load = false
	print("[SaveManager] Uložená data byla úspěšně aplikována na hráče.")
	return true

func _restore_chests(saved: Dictionary):
	var scene := get_tree().current_scene
	for c in get_tree().get_nodes_in_group("chests"):
		var key := str(scene.get_path_to(c)) if scene else ""
		if saved.get(key) is Array:
			c.inventory.load_save_data(saved[key])

func has_crystal(id: String) -> bool:
	return progress.crystals.has(id) or progress.grand.has(id)

func record_crystal(id: String, grand: bool = false):
	progress["grand" if grand else "crystals"][id] = true
	_save_progress()

func get_flag(key: String) -> bool:
	return progress.flags.has(key)

func set_flag(key: String):
	progress.flags[key] = true
	_save_progress()

## Nová hra: smaže sebrané krystaly i otevřené brány.
func reset_progress():
	progress = {"crystals": {}, "grand": {}, "flags": {}}
	_save_progress()

func _save_progress():
	var file = FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if not file:
		printerr("Chyba při zápisu postupu: ", PROGRESS_PATH)
		return
	file.store_string(JSON.stringify(progress))
	file.close()

func delete_save():
	if has_save_file():
		DirAccess.remove_absolute(SAVE_PATH)
	current_save_data = {}
