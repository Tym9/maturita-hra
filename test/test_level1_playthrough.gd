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
	
	# Krok 1: Teleportujeme hráče do Místnosti [1, 0] (překročení X=320)
	if test_step == 10:
		player.global_position = Vector2(360, 130)
	
	if test_step == 15:
		assert(cam.current_room == Vector2i(1, 0), "Room should update to [1, 0], got: %s" % cam.current_room)
		assert(player.spawn_point.x >= 320, "Spawn point updated to Room [1, 0]")
		print("[PASS] Room [1, 0] transition & checkpoint: OK")
		
		# Krok 2: Přechod dolů do vertikální šachty Místnosti [1, 1] (překročení Y=180)
		player.global_position = Vector2(400, 220)
	
	if test_step == 20:
		assert(cam.current_room == Vector2i(1, 1), "Room should update to [1, 1], got: %s" % cam.current_room)
		assert(player.spawn_point.y >= 180, "Spawn point updated to Room [1, 1]")
		print("[PASS] Room [1, 1] (downward shaft) transition: OK")
		
		# Krok 3: Přechod doprava do Místnosti [2, 1] (překročení X=640)
		player.global_position = Vector2(680, 320)
	
	if test_step == 25:
		assert(cam.current_room == Vector2i(2, 1), "Room should update to [2, 1], got: %s" % cam.current_room)
		print("[PASS] Room [2, 1] (tunnel with shooter) transition: OK")
		
		# Krok 4: Přechod dolů do Místnosti [2, 2] (překročení Y=360)
		player.global_position = Vector2(700, 400)
	
	if test_step == 30:
		assert(cam.current_room == Vector2i(2, 2), "Room should update to [2, 2], got: %s" % cam.current_room)
		print("[PASS] Room [2, 2] (reactor core finale) transition: OK")
		
		# Krok 5: Dotyk LevelEnd
		var level_end = level_inst.get_node("LevelEnd")
		assert(level_end != null, "LevelEnd must exist")
		print("[PASS] LevelEnd verified at: %s" % level_end.position)
		print("=== ALL LEVEL 1 DOWNWARD FLOW TESTS PASSED (100% OK) ===")
		get_tree().quit(0)
