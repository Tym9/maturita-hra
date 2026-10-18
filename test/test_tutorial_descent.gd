extends SceneTree

## Fyzický test sestupu na konci tutoriálu do rokle se Základnou odboje (začátek kap. 1): hráč dojde
## po okraji rokle, seskočí do ní a po lešení (zig-zag) sejde až k LevelEnd
## (bez zásahu skriptu do pozice; jen vstupy A/D/W, jako hráč).
## Spuštění: godot --headless --path . -s res://test/test_tutorial_descent.gd

func _init():
	call_deferred("_run")

func _fail(msg: String):
	printerr("  ❌ FAIL: " + msg)
	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("jump")
	quit(1)

func _run():
	print("==================================================")
	print("[TEST] Fyzický sestup do rokle na konci tutoriálu...")
	print("==================================================")
	change_scene_to_file("res://tutorial_level.tscn")
	await process_frame
	await process_frame
	var lvl = current_scene
	var player = lvl.get_node("Player")
	# Začátek: poslední kousek louky před okrajem rokle (buňka [10, 0])
	player.global_position = Vector2(3240, 130)
	player.spawn_point = player.global_position
	var entered_hall := false
	var reached := [false, false, false, false, false]  # L1, L2, L3, L4, podlaha
	var deaths_before: int = root.get_node("Global").death_count
	var jump_frames := 0

	for frame in range(2400):
		await physics_frame
		if current_scene == null or current_scene.name != "TutorialLevel":
			break
		var p = player.global_position
		var floor_now: bool = player.is_on_floor()
		if p.x > 3360.0 and p.y < 180.0:
			entered_hall = true
		# Která plošina je právě pod hráčem (podle výšky stání)
		if floor_now and p.x > 3600.0 and p.y > 240.0 and p.y < 252.0:
			reached[0] = true
		if floor_now and p.y > 305.0 and p.y < 318.0:
			reached[1] = true
		if floor_now and p.y > 369.0 and p.y < 382.0:
			reached[2] = true
		if floor_now and p.y > 433.0 and p.y < 446.0:
			reached[3] = true
		if floor_now and p.y > 495.0:
			reached[4] = true
		# Směr chůze: chodba doprava, L1 doleva, L2 doprava, L3 doleva, L4 a podlaha doleva
		var dir := 1
		if reached[0] and not reached[1]:
			dir = -1
		elif reached[1] and not reached[2]:
			dir = 1
		elif reached[2]:
			dir = -1
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_press("move_right" if dir > 0 else "move_left")
		# Na podlaze před bodáky (příkop x 3280-3328) přeskoč
		if reached[4] and floor_now and p.x < 3380.0 and p.x > 3330.0 and jump_frames == 0:
			Input.action_press("jump")
			jump_frames = 14
		if jump_frames > 0:
			jump_frames -= 1
			if jump_frames == 0:
				Input.action_release("jump")

	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("jump")

	if not entered_hall:
		_fail("Hráč nedošel na okraj rokle")
		return
	print("  ✓ PASS: Hráč došel na okraj rokle")
	if not (reached[0] and reached[1] and reached[2] and reached[3]):
		_fail("Hráč nesešel po všech plošinách lešení: %s" % str(reached))
		return
	print("  ✓ PASS: Hráč sešel po lešení L1 -> L2 -> L3 -> L4")
	if not reached[4]:
		_fail("Hráč nedošel na dno rokle")
		return
	print("  ✓ PASS: Hráč dosáhl dna rokle")
	if current_scene == null or current_scene.name != "StageClearScreen":
		_fail("Hráč nedošel k LevelEnd (scéna: %s)" % (current_scene.name if current_scene else "null"))
		return
	print("  ✓ PASS: Hráč došel k LevelEnd a otevřela se obrazovka statistik")
	if root.get_node("Global").death_count != deaths_before:
		_fail("Hráč během sestupu zemřel")
		return
	print("  ✓ PASS: Sestup proběhl bez smrti")
	print("==================================================")
	print("[PASS] SESTUP DO ROKLE FUNGUJE (100% OK)!")
	print("==================================================")
	quit(0)
