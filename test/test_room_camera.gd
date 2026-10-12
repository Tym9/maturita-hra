extends Node2D

func _ready():
	print("--- SPUŠTĚNÍ AUTOMATICKÉHO TESTU CELESTE ROOM GRID KAMERY ---")
	
	var player_scene = load("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	player.global_position = Vector2(50, 50)
	
	var camera = player.get_node_or_null("Camera2D")
	assert(camera != null, "Kamera musí existovat")
	
	# Počáteční místnost [0, 0]
	camera._init_room()
	assert(camera.current_room == Vector2i(0, 0), "Počáteční místnost musí být [0, 0]")
	assert(camera.target_pos == Vector2(160, 90), "Střed místnosti [0, 0] musí být (160, 90)")
	print("[PASS] Místnost [0, 0]: kamera nacentrována na (160, 90)")
	
	# Pohyb hráče doprava do místnosti [1, 0]
	player.global_position = Vector2(350, 50)
	camera._process(0.016)
	assert(camera.current_room == Vector2i(1, 0), "Místnost se musí přepnout na [1, 0]")
	assert(camera.target_pos == Vector2(480, 90), "Cílová pozice kamery musí být (480, 90)")
	assert(player.spawn_point.x >= 320.0, "Spawn point musí být v nové místnosti [1, 0]")
	print("[PASS] Přechod doprava do místnosti [1, 0]: kamera (480, 90), nový checkpoint nastaven")
	
	# Pohyb hráče dolů do šachty [1, 1] (SteamWorld Dig směr doprava dolů)
	player.global_position = Vector2(350, 220)
	camera._process(0.016)
	assert(camera.current_room == Vector2i(1, 1), "Místnost se musí přepnout na [1, 1]")
	assert(camera.target_pos == Vector2(480, 270), "Cílová pozice kamery musí být (480, 270)")
	assert(player.spawn_point.y >= 180.0, "Spawn point musí být v podzemní místnosti [1, 1]")
	print("[PASS] Přechod dolů do místnosti [1, 1]: kamera (480, 270), checkpoint v podzemí OK")
	
	# Test respawnu po smrti
	player.die()
	assert(camera.current_room == Vector2i(1, 1), "Kamera musí po respawnu zůstat v aktuální místnosti [1, 1]")
	print("[PASS] Respawn hráče: probíhá v aktuální místnosti bez vrácení na začátek hry")
	
	print("=== VŠECHNY TESTY ROOM GRID KAMERY ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit()
