extends Node2D

func _ready():
	print("==================================================")
	print("[TEST] Spouštím test Tutoriálu (Prolog: Na Povrchu)...")
	print("==================================================")
	
	Global.reset_all_stats()
	var tutorial_scene = load("res://tutorial_level.tscn")
	assert(tutorial_scene != null, "Scéna tutorial_level.tscn musí existovat a jít načíst!")
	
	var tut = tutorial_scene.instantiate()
	add_child(tut)
	
	print("\n--- 1. Inicializace Tutoriálu a 8 povrchových sektorů ---")
	var player = tut.get_node_or_null("Player")
	assert(player != null, "Hráč musí být přítomen v tutoriálu")
	print("  ✓ PASS: Hráč je přítomen v tutoriálu")
	assert(player.global_position.x < 320 and player.global_position.y < 180, "Hráč musí začínat v Sektoru [0, 0]")
	print("  ✓ PASS: Hráč začíná v Sektoru [0, 0] na ", player.global_position)
	
	var backdrops = tut.get_node_or_null("Backdrops")
	assert(backdrops != null, "Backdrops uzel musí existovat")
	print("  ✓ PASS: Backdrops uzel přítomen")
	
	for i in range(8):
		var r_name = "Room_%d_0" % i
		var r_node = backdrops.get_node_or_null(r_name)
		assert(r_node != null, "Místnost %s musí existovat v Backdrops!" % r_name)
		print("  ✓ PASS: Sektor %d-0 přítomen (%s)" % [i, r_node.room_title])
		
	print("\n--- 2. Ověření mechanik a objektů na povrchu ---")
	var mechanics = tut.get_node_or_null("Mechanics")
	assert(mechanics != null, "Mechanics uzel musí existovat")
	var chest = mechanics.get_node_or_null("StarterChest")
	assert(chest != null, "Průzkumnická truhla musí existovat v Sektoru 6-0")
	assert(chest.initial_items.has("health_pack"), "Truhla musí obsahovat lékárničku")
	print("  ✓ PASS: StarterChest s lékárničkou nalezena")
	
	var collectibles = tut.get_node_or_null("Collectibles")
	assert(collectibles != null, "Collectibles uzel musí existovat")
	var c1 = collectibles.get_node_or_null("Crystal_Tut1")
	var c2 = collectibles.get_node_or_null("Crystal_Tut2")
	var c3 = collectibles.get_node_or_null("Crystal_Tut3")
	assert(c1 != null and c2 != null and c3 != null, "Všechny 3 krystaly musí být přítomny!")
	print("  ✓ PASS: Všechny 3 sběratelské krystaly nalezeny na povrchu")
	
	var platforms = tut.get_node_or_null("Platforms")
	assert(platforms != null, "Platforms uzel musí existovat")
	var crumble1 = platforms.get_node_or_null("R5_Crumble1")
	var crumble2 = platforms.get_node_or_null("R5_Crumble2")
	var crumble3 = platforms.get_node_or_null("R5_Crumble3")
	assert(crumble1 != null and crumble2 != null and crumble3 != null, "Drolící se bloky mostu musí existovat")
	print("  ✓ PASS: Drolící se dřevěný most v Sektoru 5-0 přítomen")
	
	var level_end = tut.get_node_or_null("LevelEnd")
	assert(level_end != null, "LevelEnd brána musí existovat v Sektoru 7-0")
	assert(level_end.next_level == "res://level1.tscn", "LevelEnd musí vést do Level 1!")
	assert(level_end.stage_index == 0, "Stage index tutoriálu musí být 0")
	assert(level_end.max_stage_crystals == 3, "Max krystaly tutoriálu musí být 3")
	print("  ✓ PASS: LevelEnd správně napojen na Level 1 (res://level1.tscn)")
	
	print("\n--- 3. Plynulý přechod kamery přes 8 místností ---")
	var cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Kamera hráče musí existovat")
	
	# Počkáme na inicializaci kamery
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for i in range(8):
		player.global_position = Vector2(float(i) * 320.0 + 160.0, 100.0)
		cam._process(0.016)
		assert(cam.current_room == Vector2i(i, 0), "Kamera v Sektoru [%d, 0] musí odpovídat!" % i)
		print("  ✓ PASS: Kamera úspěšně zaměřena na Sektor [%d, 0]" % i)
	
	tut.queue_free()
	print("==================================================")
	print("[PASS] VŠECHNY TESTY TUTORIÁLU ÚSPĚŠNĚ PROŠLY (100% OK)!")
	print("==================================================")
	get_tree().quit(0)
