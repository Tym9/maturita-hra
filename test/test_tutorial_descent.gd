extends SceneTree

## Fyzický test sestupu z tutoriálu do dolu: hráč skutečně dojde od povrchu
## přes schody, šachtu a ledges až k LevelEnd (bez zásahu skriptu do pozice).

func _init():
	call_deferred("_run")

func _fail(msg: String):
	printerr("  ❌ FAIL: " + msg)
	Input.action_release("move_right")
	Input.action_release("move_left")
	quit(1)

func _run():
	print("==================================================")
	print("[TEST] Fyzický sestup do dolu na konci tutoriálu...")
	print("==================================================")
	change_scene_to_file("res://tutorial_level.tscn")
	await process_frame
	await process_frame
	var lvl = current_scene
	var player = lvl.get_node("Player")
	player.global_position = Vector2(2280, 130)
	player.spawn_point = player.global_position
	var visited_lower_room := false
	var reached_landing1 := false
	var deaths_before: int = root.get_node("Global").death_count
	
	for frame in range(1500):
		await physics_frame
		if current_scene == null or current_scene.name != "TutorialLevel":
			break
		var p = player.global_position
		if p.y > 185.0:
			visited_lower_room = true
		if p.y > 225.0 and p.y < 245.0 and p.x > 2420.0:
			reached_landing1 = true
		# Nejdřív doprava ze schodů, po přistání na ledge vlevo k východu
		if reached_landing1:
			Input.action_release("move_right")
			Input.action_press("move_left")
		else:
			Input.action_press("move_right")
	
	Input.action_release("move_right")
	Input.action_release("move_left")
	
	if not visited_lower_room:
		_fail("Hráč se nikdy nedostal do spodní místnosti [7, 1]")
		return
	print("  ✓ PASS: Hráč sestoupil schody do místnosti [7, 1]")
	if not reached_landing1:
		_fail("Hráč nepřistál na první plošině v šachtě")
		return
	print("  ✓ PASS: Hráč přistál na první plošině v šachtě")
	if current_scene == null or current_scene.name != "StageClearScreen":
		_fail("Hráč nedošel k LevelEnd (scéna: %s)" % (current_scene.name if current_scene else "null"))
		return
	print("  ✓ PASS: Hráč došel k LevelEnd a otevřela se obrazovka statistik")
	if root.get_node("Global").death_count != deaths_before:
		_fail("Hráč během sestupu zemřel")
		return
	print("  ✓ PASS: Sestup proběhl bez smrti")
	print("==================================================")
	print("[PASS] SESTUP DO DOLU FUNGUJE (100% OK)!")
	print("==================================================")
	quit(0)
