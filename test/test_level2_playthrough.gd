extends Node2D

## Automatizovaný integrační test pro Level 2: Krystalové doly (Celeste / SteamWorld Dig flow).

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím test Level 2: Krystalové doly...")
	print("==================================================")
	
	test_level2_initialization()
	test_level2_components_and_hazards()
	test_level2_camera_flow()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] TESTY LEVELU 2 SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY LEVELU 2 ÚSPĚŠNĚ PROŠLY (100% OK)!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_level2_initialization():
	print("\n--- 1. Inicializace Levelu 2 a sektorů ---")
	var lvl_scene = preload("res://level2.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var player = lvl.get_node_or_null("Player")
	assert_true(player != null, "Hráč je přítomen v Levelu 2")
	assert_true(player.position == Vector2(40, 140), "Hráč začíná v Sektoru [0, 0] na (40, 140)")
	
	var backdrops = lvl.get_node_or_null("Backdrops")
	assert_true(backdrops != null, "Backdrops uzel přítomen")
	assert_true(backdrops.get_node_or_null("Room_0_0") != null, "Sektor 0-0 přítomen")
	assert_true(backdrops.get_node_or_null("Room_1_0") != null, "Sektor 1-0 přítomen")
	assert_true(backdrops.get_node_or_null("Room_1_1") != null, "Sektor 1-1 přítomen")
	assert_true(backdrops.get_node_or_null("Room_2_1") != null, "Sektor 2-1 přítomen")
	assert_true(backdrops.get_node_or_null("Room_2_2") != null, "Sektor 2-2 přítomen")
	assert_true(backdrops.get_node_or_null("Room_3_2") != null, "Sektor 3-2 přítomen")
	
	lvl.queue_free()

func test_level2_components_and_hazards():
	print("\n--- 2. Ověření mechanik a hrozeb v Levelu 2 ---")
	var lvl_scene = preload("res://level2.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var npcs = lvl.get_node_or_null("NPCs")
	assert_true(npcs != null and npcs.get_node_or_null("Rusty") != null, "NPC Rusty přítomen v Levelu 2")
	var mechanics = lvl.get_node_or_null("Mechanics")
	assert_true(mechanics != null, "Mechanics uzel přítomen")
	assert_true(mechanics.get_node_or_null("RustyChest") != null, "RustyChest s Gravity Coilem nalezena")
	var platforms = lvl.get_node_or_null("Platforms")
	assert_true(platforms.get_node_or_null("R10_DashCrumble1") != null, "Dash plošina v propasti nalezena")
	assert_true(mechanics.get_node_or_null("CelesteKey_Corridor") != null, "Celeste létající klíč nalezen")
	assert_true(mechanics.get_node_or_null("Gate_KeyBlock") != null, "Klíčový blok (brána) nalezen")
	assert_true(mechanics.get_node_or_null("GravityAnomaly_Down") != null, "Gravitační anomálie nalezena")
	
	var hazards = lvl.get_node_or_null("Hazards")
	assert_true(hazards != null, "Hazards uzel přítomen")
	assert_true(hazards.get_node_or_null("R11_SteamVent") != null, "Parní tryska v šachtě nalezena")
	assert_true(hazards.get_node_or_null("R32_SteamVent1") != null, "Parní tryska u výtahu nalezena")
	
	var enemies = lvl.get_node_or_null("Enemies")
	assert_true(enemies != null, "Enemies uzel přítomen")
	assert_true(enemies.get_node_or_null("Drone_Chasm") != null, "Dron v propasti nalezen")
	assert_true(enemies.get_node_or_null("Shooter_Tunnel") != null, "Střelec v tunelu nalezen")
	
	var collectibles = lvl.get_node_or_null("Collectibles")
	assert_true(collectibles != null, "Collectibles uzel přítomen")
	assert_true(collectibles.get_child_count() == 3, "Nalezeny 3 sběratelské krystaly")
	
	var level_end = lvl.get_node_or_null("LevelEnd")
	assert_true(level_end != null, "LevelEnd brána nalezena")
	assert_true(level_end.next_level == "res://level3.tscn", "LevelEnd správně odkazuje na Level 3")
	
	lvl.queue_free()

func test_level2_camera_flow():
	print("\n--- 3. Plynulý průchod kamerami dolů a doprava ---")
	var lvl_scene = preload("res://level2.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var player = lvl.get_node("Player")
	var camera = player.camera
	assert_true(camera != null, "Kamera hráče je přítomna")
	
	# Sektor [0, 0]
	player.global_position = Vector2(40, 140)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(0, 0), "Kamera v Sektoru [0, 0]")
	
	# Sektor [1, 0]
	player.global_position = Vector2(350, 120)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(1, 0), "Kamera v Sektoru [1, 0]")
	
	# Sektor [1, 1] (sestup dolů)
	player.global_position = Vector2(450, 260)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(1, 1), "Kamera v Sektoru [1, 1] (sestup do šachty)")
	
	# Sektor [2, 1] (posun doprava)
	player.global_position = Vector2(700, 300)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(2, 1), "Kamera v Sektoru [2, 1] (koridor)")
	
	# Sektor [2, 2] (sestup dolů)
	player.global_position = Vector2(800, 450)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(2, 2), "Kamera v Sektoru [2, 2] (krypta)")
	
	# Sektor [3, 2] (posun k výtahu do reaktoru)
	player.global_position = Vector2(1150, 480)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(3, 2), "Kamera v Sektoru [3, 2] (finále)")
	
	lvl.queue_free()
