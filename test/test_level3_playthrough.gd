extends Node2D

## Automatizovaný integrační test pro Level 3: Předpolí reaktoru (Celeste / SteamWorld Dig flow).

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím test Level 3: Předpolí reaktoru...")
	print("==================================================")
	
	test_level3_initialization()
	test_level3_components_and_hazards()
	test_level3_camera_flow()
	test_level3_mechanics_interaction()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] TESTY LEVELU 3 SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY LEVELU 3 ÚSPĚŠNĚ PROŠLY (100% OK)!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_level3_initialization():
	print("\n--- 1. Inicializace Levelu 3 a high-tech sektorů ---")
	var lvl_scene = preload("res://level3.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var player = lvl.get_node_or_null("Player")
	assert_true(player != null, "Hráč je přítomen v Levelu 3")
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

func test_level3_components_and_hazards():
	print("\n--- 2. Ověření mechanik, hrozeb a nepřátel v Levelu 3 ---")
	var lvl_scene = preload("res://level3.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var mechanics = lvl.get_node_or_null("Mechanics")
	assert_true(mechanics != null, "Mechanics uzel přítomen")
	assert_true(mechanics.get_node_or_null("Chest_R0") != null, "Úvodní truhla se zásobami nalezena")
	assert_true(mechanics.get_node_or_null("BossPrepChest") != null, "Finální truhla před bossem nalezena")
	assert_true(mechanics.get_node_or_null("GrapplePoint_R0") != null, "Kotva pro hák v Sektoru 0-0 nalezena")
	assert_true(mechanics.get_node_or_null("GrapplePoint_Final1") != null, "Finální kotva 1 pro hák nalezena")
	assert_true(mechanics.get_node_or_null("GrapplePoint_Final2") != null, "Finální kotva 2 pro hák nalezena")
	assert_true(mechanics.get_node_or_null("CelesteKey_Accelerator") != null, "Celeste létající klíč v akcelerátoru nalezen")
	assert_true(mechanics.get_node_or_null("Gate_KeyBlock_Reactor") != null, "Klíčový blok (brána jádra) nalezen")
	assert_true(mechanics.get_node_or_null("GravityAnomaly_Up") != null, "Inverzní gravitační anomálie nalezena")
	assert_true(mechanics.get_node_or_null("GravityAnomaly_Down") != null, "Obnovující gravitační anomálie nalezena")
	
	var hazards = lvl.get_node_or_null("Hazards")
	assert_true(hazards != null, "Hazards uzel přítomen")
	assert_true(hazards.get_node_or_null("R0_SteamVent") != null, "Parní tryska v sektoru 0-0 nalezena")
	assert_true(hazards.get_node_or_null("R11_SteamVentUp") != null, "Parní tryska nahoru v šachtě nalezena")
	assert_true(hazards.get_node_or_null("R32_SteamVent1") != null, "Parní tryska 1 před bossem nalezena")
	assert_true(hazards.get_node_or_null("R32_SteamVent2") != null, "Parní tryska 2 před bossem nalezena")
	
	var enemies = lvl.get_node_or_null("Enemies")
	assert_true(enemies != null, "Enemies uzel přítomen")
	assert_true(enemies.get_node_or_null("Drone_R10") != null, "Bezpečnostní dron v sektoru 1-0 nalezen")
	assert_true(enemies.get_node_or_null("Shooter_R11") != null, "Střelec v chladicí šachtě nalezen")
	assert_true(enemies.get_node_or_null("PatrolGuard_R11") != null, "Pozemní strážce v šachtě nalezen")
	assert_true(enemies.get_node_or_null("Drone_R32") != null, "Elitní dron před velínem nalezen")
	
	var collectibles = lvl.get_node_or_null("Collectibles")
	assert_true(collectibles != null, "Collectibles uzel přítomen")
	assert_true(collectibles.get_child_count() == 3, "Nalezeny přesně 3 sběratelské krystaly")
	assert_true(collectibles.get_node_or_null("Crystal_10") != null, "Krystal 1 v sektoru 1-0 nalezen")
	assert_true(collectibles.get_node_or_null("Crystal_21") != null, "Krystal 2 v sektoru 2-1 nalezen")
	assert_true(collectibles.get_node_or_null("Crystal_32") != null, "Krystal 3 v sektoru 3-2 nalezen")
	
	var level_end = lvl.get_node_or_null("LevelEnd")
	assert_true(level_end != null, "LevelEnd brána nalezena")
	assert_true(level_end.next_level == "res://boss_room.tscn", "LevelEnd správně odkazuje na komoru bosse")
	
	lvl.queue_free()

func test_level3_camera_flow():
	print("\n--- 3. Plynulý přechod kamer napříč 6 sektory ---")
	var lvl_scene = preload("res://level3.tscn")
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
	player.global_position = Vector2(360, 140)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(1, 0), "Kamera v Sektoru [1, 0]")
	
	# Sektor [1, 1]
	player.global_position = Vector2(540, 240)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(1, 1), "Kamera v Sektoru [1, 1]")
	
	# Sektor [2, 1]
	player.global_position = Vector2(680, 310)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(2, 1), "Kamera v Sektoru [2, 1]")
	
	# Sektor [2, 2]
	player.global_position = Vector2(870, 410)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(2, 2), "Kamera v Sektoru [2, 2]")
	
	# Sektor [3, 2]
	player.global_position = Vector2(1180, 480)
	camera._process(0.1)
	assert_true(camera.current_room == Vector2i(3, 2), "Kamera v Sektoru [3, 2]")
	
	lvl.queue_free()

func test_level3_mechanics_interaction():
	print("\n--- 4. Interakce: Celeste Klíč, Klíčový blok a Gravitační anomálie ---")
	var lvl_scene = preload("res://level3.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var player = lvl.get_node("Player")
	var key = lvl.get_node("Mechanics/CelesteKey_Accelerator")
	var gate = lvl.get_node("Mechanics/Gate_KeyBlock_Reactor")
	var grav_up = lvl.get_node("Mechanics/GravityAnomaly_Up")
	var grav_down = lvl.get_node("Mechanics/GravityAnomaly_Down")
	
	# Test gravitační anomálie
	assert_true(player.gravity_dir == 1.0, "Hráč má výchozí gravitaci dolů (1.0)")
	grav_up._on_body_entered(player)
	assert_true(player.gravity_dir == -1.0, "Anomálie otočila gravitaci na strop (-1.0)")
	grav_down._on_body_entered(player)
	assert_true(player.gravity_dir == 1.0, "Druhá anomálie vrátila gravitaci na podlahu (1.0)")
	
	# Test sebrání Celeste klíče
	key._on_body_entered(player)
	assert_true(key.state == 1, "Celeste klíč je ve stavu FOLLOWING (následuje hráče)")
	assert_true(key.target_player == player, "Klíč následuje hráče")
	
	# Test odemknutí brány
	gate._on_trigger_body_entered(player)
	gate._on_key_unlocked()
	assert_true(gate.is_unlocked, "Klíčový blok se odemkl a otevřel cestu k jádru")
	
	lvl.queue_free()
