extends Node2D

const Level1Scene = preload("res://level1.tscn")
var level_inst = null
var player = null
var cam = null
var test_step = 0

func _ready():
	print("=== START TEST_LEVEL1_PLAYTHROUGH ===")
	level_inst = Level1Scene.instantiate()
	add_child(level_inst)
	
	player = level_inst.get_node("Player")
	assert(player != null, "Player must exist in level1")
	cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Camera2D must exist on Player")
	
	# Ověření počátečního stavu v Místnosti [0, 0]
	assert(cam.current_room == Vector2i(0, 0), "Initial room should be [0, 0]")
	assert(player.spawn_point == player.global_position, "Initial spawn point set")
	print("[PASS] Room [0, 0] initialised successfully")

func _physics_process(delta):
	test_step += 1
	
	# Krok 1: Přechod do Místnosti [1, 0]
	if test_step == 10:
		player.global_position = Vector2(360, 130)
	
	if test_step == 15:
		assert(cam.current_room == Vector2i(1, 0), "Room should update to [1, 0], got: %s" % cam.current_room)
		assert(player.spawn_point.x >= 320, "Spawn point updated to Room [1, 0]")
		print("[PASS] Room [1, 0] transition & checkpoint: OK")
		
		# Krok 2: Přechod doprava do Ventilační věže [2, 0]
		player.global_position = Vector2(680, 120)
	
	if test_step == 20:
		assert(cam.current_room == Vector2i(2, 0), "Room should update to [2, 0], got: %s" % cam.current_room)
		print("[PASS] Room [2, 0] (ventilation tower) transition: OK")
		
		# Krok 3: Sestup do vertikální šachty [1, 1]
		player.global_position = Vector2(400, 220)
	
	if test_step == 25:
		assert(cam.current_room == Vector2i(1, 1), "Room should update to [1, 1], got: %s" % cam.current_room)
		print("[PASS] Room [1, 1] (vertical shaft) transition: OK")
		
		# Krok 4: Přechod do těžebního tunelu [2, 1]
		player.global_position = Vector2(680, 320)
	
	if test_step == 30:
		assert(cam.current_room == Vector2i(2, 1), "Room should update to [2, 1], got: %s" % cam.current_room)
		print("[PASS] Room [2, 1] (mining tunnel) transition: OK")
		
		# Krok 5: Přechod do chladicího kanálu [3, 1]
		player.global_position = Vector2(1000, 280)
	
	if test_step == 35:
		assert(cam.current_room == Vector2i(3, 1), "Room should update to [3, 1], got: %s" % cam.current_room)
		print("[PASS] Room [3, 1] (cooling channel) transition: OK")
		
		# Krok 6: Sestup do přetlakové komory [3, 2]
		player.global_position = Vector2(1050, 440)
	
	if test_step == 40:
		assert(cam.current_room == Vector2i(3, 2), "Room should update to [3, 2], got: %s" % cam.current_room)
		print("[PASS] Room [3, 2] (pressure chamber) transition: OK")
		
		# Krok 7: Přechod doleva do jádra generátoru [2, 2]
		player.global_position = Vector2(760, 420)
	
	if test_step == 45:
		assert(cam.current_room == Vector2i(2, 2), "Room should update to [2, 2], got: %s" % cam.current_room)
		print("[PASS] Room [2, 2] (generator core) transition: OK")
		
		# Krok 8: Sestup na finální etáž [2, 3] ke vstupu do dolů
		player.global_position = Vector2(760, 600)
	
	if test_step == 50:
		assert(cam.current_room == Vector2i(2, 3), "Room should update to [2, 3], got: %s" % cam.current_room)
		print("[PASS] Room [2, 3] (mines entrance finale) transition: OK")
		
		# Krok 9: Dotyk LevelEnd
		var level_end = level_inst.get_node("LevelEnd")
		assert(level_end != null, "LevelEnd must exist")
		assert(level_end.position == Vector2(912, 650), "LevelEnd should be at (912, 650), got: %s" % level_end.position)
		print("[PASS] LevelEnd verified at: %s" % level_end.position)
		print("=== ALL 9 ROOMS IN LEVEL 1 EXPANDED FLOW PASSED (100% OK) ===")
		get_tree().quit(0)
