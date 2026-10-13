extends Node

## Globální správce statistik a stavu etap (Celeste-style per-chapter & total metrics).

# Celkové statistiky napříč celou hrou
var death_count: int = 0:
	set(val):
		if val > death_count and stage_active:
			stage_deaths += (val - death_count)
		death_count = val

var kill_count: int = 0:
	set(val):
		if val > kill_count and stage_active:
			stage_kills += (val - kill_count)
		kill_count = val

var total_time: float = 0.0
var total_crystals: int = 0

# Přenášení stavu hráče a inventáře mezi kapitolami
var persistent_player_inventory: Array = []
var persistent_player_health: int = 3
var persistent_player_max_health: int = 3
var persistent_player_crystals: int = 0
var persistent_collected_crystal_ids: Array = []
var has_persistent_player: bool = false

# Statistika aktuální probíhající etapy
var current_stage_index: int = 1
var current_stage_title: String = "ETAPA 1: STARÉ DÍLNY"
var stage_time: float = 0.0
var stage_deaths: int = 0
var stage_kills: int = 0
var stage_crystals: int = 0
var stage_max_crystals: int = 5
var stage_active: bool = false
var pending_next_scene: String = ""

# Poslední dokončená etapa (data pro zobrazení na obrazovce po dokončení etapy)
var last_stage_result: Dictionary = {}

# Historie všech dokončených etap (pro závěrečnou celkovou tabulku)
var completed_stages: Array[Dictionary] = []

var last_detected_scene_path: String = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	# Automatická detekce načtené úrovně
	var current_scene = get_tree().current_scene
	if current_scene and is_instance_valid(current_scene):
		var path = current_scene.scene_file_path
		if path != last_detected_scene_path and not path.is_empty():
			last_detected_scene_path = path
			_on_scene_changed(path)
	
	if stage_active:
		stage_time += delta
		total_time += delta

func _on_scene_changed(path: String):
	match path:
		"res://level1.tscn":
			start_stage(1, "ETAPA 1: STARÉ DÍLNY", 5)
		"res://level2.tscn":
			start_stage(2, "ETAPA 2: KRYSTALOVÉ DOLY", 3)
		"res://level3.tscn":
			start_stage(3, "ETAPA 3: PŘEDPOLÍ REAKTORU", 3)
		"res://boss_room.tscn":
			stage_active = false
		"res://ui/stage_clear_screen.tscn":
			stage_active = false
		"res://main_menu.tscn":
			stage_active = false

func start_stage(stage_idx: int, title: String = "", max_crystals: int = 5):
	current_stage_index = stage_idx
	current_stage_title = title if not title.is_empty() else ("ETAPA " + str(stage_idx))
	stage_time = 0.0
	stage_deaths = 0
	stage_kills = 0
	stage_crystals = 0
	stage_max_crystals = max_crystals
	stage_active = true

func finish_stage(title: String, max_crystals: int, next_scene: String):
	stage_active = false
	pending_next_scene = next_scene
	var result = {
		"stage_index": current_stage_index,
		"title": title if not title.is_empty() else current_stage_title,
		"time": stage_time,
		"deaths": stage_deaths,
		"kills": stage_kills,
		"crystals": stage_crystals,
		"max_crystals": max_crystals,
		"next_scene": next_scene
	}
	last_stage_result = result
	
	# Uložení do historie pro závěrečnou celkovou tabulku
	var found = false
	for i in range(completed_stages.size()):
		if completed_stages[i]["stage_index"] == current_stage_index:
			completed_stages[i] = result
			found = true
			break
	if not found:
		completed_stages.append(result)
	
	print("[Global] Etapa dokončena: ", result["title"], " | Čas: ", format_time(result["time"]), " | Krystaly: ", result["crystals"], "/", result["max_crystals"], " | Smrti: ", result["deaths"])

func save_player_state(player: CharacterBody2D):
	if not is_instance_valid(player):
		return
	if player.has_method("get_inventory_save_data"):
		persistent_player_inventory = player.get_inventory_save_data()
	persistent_player_health = player.health
	persistent_player_max_health = player.max_health
	persistent_player_crystals = player.crystals
	persistent_collected_crystal_ids = player.collected_crystal_ids.duplicate()
	has_persistent_player = true
	print("[Global] Stav hráče uložen pro přenos do další kapitoly (položek v inventáři: ", persistent_player_inventory.size(), ").")

func load_player_state(player: CharacterBody2D):
	if not has_persistent_player:
		return
	if player.has_method("load_inventory_save_data"):
		player.load_inventory_save_data(persistent_player_inventory)
	player.health = persistent_player_health
	player.max_health = persistent_player_max_health
	player.crystals = persistent_player_crystals
	player.collected_crystal_ids = persistent_collected_crystal_ids.duplicate()
	if player.has_method("_init_ui"):
		player._init_ui()
	print("[Global] Stav hráče úspěšně načten z předchozí kapitoly.")

func on_player_died():
	death_count += 1

func on_enemy_killed():
	kill_count += 1

func on_crystal_collected(amount: int = 1):
	total_crystals += amount
	if stage_active:
		stage_crystals += amount

func format_time(seconds: float) -> String:
	var total_sec = int(floor(seconds))
	var minutes = total_sec / 60
	var sec = total_sec % 60
	var millis = int((seconds - float(total_sec)) * 10.0)
	return "%02d:%02d.%01d" % [minutes, sec, millis]

func reset_all_stats():
	death_count = 0
	kill_count = 0
	total_time = 0.0
	total_crystals = 0
	current_stage_index = 1
	current_stage_title = "ETAPA 1: STARÉ DÍLNY"
	stage_time = 0.0
	stage_deaths = 0
	stage_kills = 0
	stage_crystals = 0
	stage_max_crystals = 5
	stage_active = false
	last_detected_scene_path = ""
	last_stage_result.clear()
	completed_stages.clear()
	persistent_player_inventory.clear()
	persistent_player_health = 3
	persistent_player_max_health = 3
	persistent_player_crystals = 0
	persistent_collected_crystal_ids.clear()
	has_persistent_player = false
