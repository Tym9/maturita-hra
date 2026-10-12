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
			# Pozastavíme časování etapy při vstupu do předsíně bosse
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
