extends Node2D

## Automatizovaný integrační test pro Celeste klíč, klíčový blok a environmentální hrozby.

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím testy CelesteKey, KeyBlock, SteamVent a CrumblingPlatform...")
	print("==================================================")
	
	test_celeste_key_follow_and_death_reset()
	test_key_block_unlock()
	test_steam_vent_cycle()
	test_crumbling_platform_cycle()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] NĚKTERÉ TESTY SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY CELESTE KLÍČE A HROZEB ÚSPĚŠNĚ PROŠLY!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_celeste_key_follow_and_death_reset():
	print("\n--- 1. Test Celeste klíče (následování hráče a návrat při smrti) ---")
	var key_scene = preload("res://mechanics/celeste_key.tscn")
	var key = key_scene.instantiate()
	key.position = Vector2(50, 50)
	add_child(key)
	
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(80, 50)
	add_child(player)
	
	assert_true(key.state == 0, "Klíč začíná ve stavu IDLE (0)")
	assert_true(key.initial_position == Vector2(50, 50), "Klíč si uložil výchozí spawn pozici (50, 50)")
	
	# 1. Hráč sebere klíč
	key.collect(player)
	assert_true(key.state == 1, "Po sebrání je klíč ve stavu FOLLOWING (1)")
	assert_true(key.target_player == player, "Klíč má nastaven cíl na hráče")
	
	# 2. Simulace pohybu klíče za hráčem
	player.position = Vector2(150, 80)
	key._process(0.1)
	assert_true(key.global_position != Vector2(50, 50), "Klíč opustil spawn a následuje hráče")
	
	# 3. Smrt hráče před odemčením brány
	player.die()
	assert_true(key.state == 0, "Po smrti hráče se klíč vrátil do stavu IDLE (0)")
	assert_true(key.target_player == null, "Klíč již nesleduje hráče")
	assert_true(key.global_position == Vector2(50, 50), "Klíč byl okamžitě navrácen na svůj spawn (50, 50)")
	
	key.queue_free()
	player.queue_free()

func test_key_block_unlock():
	print("\n--- 2. Test klíčového bloku (KeyBlock) a odemknutí ---")
	var block_scene = preload("res://mechanics/key_block.tscn")
	var block = block_scene.instantiate()
	block.position = Vector2(200, 100)
	add_child(block)
	
	var key_scene = preload("res://mechanics/celeste_key.tscn")
	var key = key_scene.instantiate()
	key.position = Vector2(180, 100)
	add_child(key)
	
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(190, 100)
	add_child(player)
	
	assert_true(not block.is_unlocked, "KeyBlock je zpočátku zamčený")
	assert_true(not block.collision_shape.disabled, "KeyBlock má aktivní pevnou kolizi")
	
	# Klíč následuje hráče
	key.collect(player)
	assert_true(key.state == 1, "Klíč je připraven u hráče")
	
	# Hráč vstoupí k bloku
	block._check_for_key(player)
	assert_true(block.is_unlocking, "KeyBlock detekoval klíč a zahájil odemykání")
	assert_true(key.state == 2, "Klíč přešel do stavu UNLOCKING (2)")
	
	# Dokončení odemčení
	block._on_key_unlocked()
	assert_true(block.is_unlocked, "KeyBlock je úspěšně odemčen")
	assert_true(block.collision_shape.disabled, "Kolize bloku byla vypnuta (cesta uvolněna)")
	
	block.queue_free()
	player.queue_free()

func test_steam_vent_cycle():
	print("\n--- 3. Test časované parní trysky (SteamVent) ---")
	var vent_scene = preload("res://mechanics/steam_vent.tscn")
	var vent = vent_scene.instantiate()
	vent.idle_time = 0.1
	vent.warn_time = 0.1
	vent.blast_time = 0.1
	add_child(vent)
	
	assert_true(vent.current_state == 0, "Tryska začíná ve stavu IDLE")
	assert_true(vent.collision_shape.disabled, "Během IDLE je kolize páry neaktivní")
	
	# Posun do stavu WARN
	vent._physics_process(0.15)
	assert_true(vent.current_state == 1, "Tryska přešla do stavu WARN (varovné syčení)")
	assert_true(vent.collision_shape.disabled, "Během WARN je kolize páry stále neaktivní")
	
	# Posun do stavu BLAST
	vent._physics_process(0.15)
	assert_true(vent.current_state == 2, "Tryska přešla do stavu BLAST (výtrysk páry)")
	assert_true(not vent.collision_shape.disabled, "Během BLAST je kolize výtrysku aktivní")
	
	# Test poškození hráče párou
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.health = 3
	vent._hit_player(player)
	assert_true(player.health == 2, "Hráč zasažený párou utrpěl 1 poškození (HP: 3 -> 2)")
	assert_true(player.velocity.y != 0.0, "Hráč byl tlakem páry odhozen")
	
	vent.queue_free()
	player.queue_free()

func test_crumbling_platform_cycle():
	print("\n--- 4. Test drolící se plošiny (CrumblingPlatform) ---")
	var plat_scene = preload("res://mechanics/crumbling_platform.tscn")
	var plat = plat_scene.instantiate()
	plat.collapse_delay = 0.1
	plat.respawn_delay = 0.2
	add_child(plat)
	
	assert_true(plat.state == 0, "Plošina začíná ve stavu SOLID (0)")
	assert_true(not plat.collision_shape.disabled, "Plošina má aktivní pevnou kolizi")
	
	# Došlápnutí hráče
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	plat._on_step_zone_entered(player)
	assert_true(plat.state == 1, "Po došlápnutí se plošina začala třást (SHAKING = 1)")
	
	# Vypršení limitu pro kolaps
	plat._physics_process(0.15)
	assert_true(plat.state == 2, "Plošina se zřítila (FALLEN = 2)")
	assert_true(plat.collision_shape.disabled, "Kolize zřícené plošiny byla vypnuta")
	
	# Vypršení obnovovacího času
	plat._physics_process(0.25)
	assert_true(plat.state == 0, "Plošina se automaticky obnovila (SOLID = 0)")
	assert_true(not plat.collision_shape.disabled, "Kolize obnovené plošiny je opět aktivní")
	
	plat.queue_free()
	player.queue_free()
