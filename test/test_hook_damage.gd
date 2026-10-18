extends Node2D

func _ready():
	print("==================================================")
	print("[TEST] Ověření poškození hákem proti nepřátelům...")
	print("==================================================")
	
	var player_scene = load("res://player.tscn")
	var drone_scene = load("res://enemies/drone.tscn")
	var guard_scene = load("res://enemies/patrol_guard.tscn")
	var shooter_scene = load("res://enemies/shooter.tscn")
	
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(100, 100)
	
	# Dej hráči hák do inventáře a vybav ho
	var item_data_script = load("res://mechanics/item_data.gd")
	var hook_item = item_data_script.create("grapple_hook")
	player.grid_inventory.equip_item(hook_item, 1)
	player.select_hotbar_slot(1)
	
	# Počkáme 2 fyzikální snímky na inicializaci
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Test 1: Útok hákem na Drona (který má větší HurtArea než tělo)
	var drone = drone_scene.instantiate()
	add_child(drone)
	drone.global_position = Vector2(140, 100) # 40 px vpravo, v dosahu 88 px
	var initial_drone_hp = drone.health
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var aim_info = player.get_hook_aim_info(drone.global_position)
	print("  Dron aim_info.type: ", aim_info.type, ", target: ", aim_info.target.name if aim_info.target else "null")
	assert(aim_info.type == "enemy", "Cíl musí být identifikován jako 'enemy', nikoliv 'world'!")
	assert(aim_info.target == drone, "Target musí být samotný uzel Drone!")
	
	# Vystřelíme hák přímo na drona
	player.fire_hook(drone.global_position)
	print("  Drone HP po zásahu: ", drone.health, " (předtím: ", initial_drone_hp, ")")
	assert(drone.health < initial_drone_hp, "Dron musel utrpět poškození hákem!")
	print("  ✓ PASS: Dron úspěšně detekován a poškozen hákem")
	
	drone.queue_free()
	await get_tree().physics_frame
	
	# Test 2: Útok hákem na PatrolGuard (s HurtArea)
	var guard = guard_scene.instantiate()
	add_child(guard)
	guard.global_position = Vector2(140, 100)
	var initial_guard_hp = guard.health
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var guard_aim = player.get_hook_aim_info(guard.global_position)
	print("  Guard aim_info.type: ", guard_aim.type, ", target: ", guard_aim.target.name if guard_aim.target else "null")
	assert(guard_aim.type == "enemy", "Guard musí být identifikován jako 'enemy'!")
	assert(guard_aim.target == guard, "Target musí být uzel PatrolGuard!")
	
	player.fire_hook(guard.global_position)
	print("  Guard HP po zásahu: ", guard.health, " (předtím: ", initial_guard_hp, ")")
	assert(guard.health < initial_guard_hp, "Stráž musela utrpět poškození hákem!")
	print("  ✓ PASS: Pozemní stráž úspěšně detekována a poškozena hákem")
	
	guard.queue_free()
	await get_tree().physics_frame
	
	# Test 3: Útok hákem na Shootera
	var shooter = shooter_scene.instantiate()
	add_child(shooter)
	shooter.global_position = Vector2(140, 100)
	var initial_shooter_hp = shooter.health
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var shooter_aim = player.get_hook_aim_info(shooter.global_position)
	print("  Shooter aim_info.type: ", shooter_aim.type, ", target: ", shooter_aim.target.name if shooter_aim.target else "null")
	assert(shooter_aim.type == "enemy", "Střelec musí být identifikován jako 'enemy'!")
	assert(shooter_aim.target == shooter, "Target musí být uzel Shooter!")
	
	player.fire_hook(shooter.global_position)
	print("  Shooter HP po zásahu: ", shooter.health, " (předtím: ", initial_shooter_hp, ")")
	assert(shooter.health < initial_shooter_hp, "Střelec musel utrpět poškození hákem!")
	print("  ✓ PASS: Střelec úspěšně detekován a poškozen hákem")
	
	shooter.queue_free()

	# Test 4: Hák se chytá jen kotev - zeď ho zastaví a kotvu za zdí nenabídne
	var wall = StaticBody2D.new()
	var wall_shape = CollisionShape2D.new()
	wall_shape.shape = RectangleShape2D.new()
	wall_shape.shape.size = Vector2(16, 128)
	wall.add_child(wall_shape)
	add_child(wall)
	wall.global_position = player.global_position + Vector2(40, 0)
	var anchor = load("res://mechanics/grapple_point.tscn").instantiate()
	add_child(anchor)
	anchor.global_position = player.global_position + Vector2(70, 0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(player.get_hook_aim_info(wall.global_position).type == "none", "Zeď už není záchytný bod")
	assert(player.get_hook_aim_info(anchor.global_position).type == "none", "Kotva za zdí není cíl")
	wall.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(player.get_hook_aim_info(anchor.global_position).type == "anchor", "Volná kotva je cíl háku")
	print("  ✓ PASS: Hák se chytá jen kotev v přímé viditelnosti")

	player.queue_free()
	
	print("==================================================")
	print("[PASS] TEST POŠKOZENÍ HÁKEM 100% PROŠEL!")
	print("==================================================")
	get_tree().quit(0)
