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
	assert(player.awaiting_room_spawn, "Bez spawn markeru se checkpoint upřesní prvním přistáním")
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
	await Global.room_reset # respawn proběhne po krátkém zatmění
	assert(camera.current_room == Vector2i(1, 1), "Kamera musí po respawnu zůstat v aktuální místnosti [1, 1]")
	print("[PASS] Respawn hráče: probíhá v aktuální místnosti bez vrácení na začátek hry")

	# Velká Celeste místnost 2x1 obrazovky (buňky [5, 0] a [6, 0] se skupinou "velka")
	for x in [5, 6]:
		var b = RoomBackdrop.new()
		b.room_x = x
		b.room_group = "velka"
		add_child(b)
	camera._discover_valid_rooms()
	player.global_position = Vector2(1700, 90)
	camera._process(0.016)
	assert(camera.current_group == "velka", "Hráč musí být ve velké místnosti")
	assert(camera.target_pos == Vector2(1760, 90), "Kamera nesmí vyjet za levý okraj místnosti")
	var big_spawn = player.spawn_point
	player.global_position = Vector2(1990, 90)
	camera._process(0.016)
	assert(camera.current_room == Vector2i(6, 0), "Buňka se musí aktualizovat")
	assert(camera.target_pos == Vector2(1990, 90), "Uvnitř velké místnosti kamera jede za hráčem")
	assert(player.spawn_point == big_spawn, "Přechod buňky uvnitř místnosti nemění checkpoint")
	player.global_position = Vector2(2230, 90)
	camera._process(0.016)
	assert(camera.target_pos == Vector2(2080, 90), "Kamera nesmí vyjet za pravý okraj místnosti")
	print("[PASS] Velká místnost 2x1: kamera sleduje hráče v hranicích místnosti")

	# Spawn marker v nové místnosti určuje checkpoint (vchod), ne bod vstupu
	var b7 = RoomBackdrop.new()
	b7.room_x = 7
	add_child(b7)
	var marker = Marker2D.new()
	marker.position = Vector2(2270, 150)
	marker.add_to_group("spawn_points")
	add_child(marker)
	camera._discover_valid_rooms()
	player.global_position = Vector2(2250, 40)
	camera._process(0.016)
	assert(player.spawn_point == marker.global_position, "Checkpoint musí být na spawn markeru, got: %s" % player.spawn_point)
	assert(not player.awaiting_room_spawn, "Marker checkpoint už se přistáním nemění")
	print("[PASS] Spawn marker: checkpoint u vchodu místnosti")

	# Smrt resetuje místnost: zabitý nepřítel se vrátí na výchozí místo se svým nastavením
	var guard = load("res://enemies/patrol_guard.tscn").instantiate()
	guard.name = "ResetGuard"
	guard.position = Vector2(2400, 100)
	guard.speed = 99.0
	add_child(guard)
	camera.reset_snapshot_taken = false
	camera._snapshot_resettables()
	guard.queue_free()
	await get_tree().process_frame
	player.die()
	await Global.room_reset
	var respawned = get_node_or_null("ResetGuard")
	assert(respawned != null and not is_instance_valid(guard), "Zabitý nepřítel se po smrti hráče vrátí")
	assert(respawned.position.distance_to(Vector2(2400, 100)) < 4.0 and respawned.speed == 99.0, "Nepřítel na výchozím místě s exportovaným nastavením, got: %s" % respawned.position)
	print("[PASS] Reset místnosti: nepřítel obnoven po smrti hráče")

	print("=== VŠECHNY TESTY ROOM GRID KAMERY ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit()
