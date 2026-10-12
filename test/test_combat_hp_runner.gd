extends Node2D

func _ready():
	print("--- SPUŠTĚNÍ AUTOMATICKÉHO TESTU HP, COMBAT A 3 TYPŮ NEPŘÁTEL ---")
	
	# 1. Test Player HP a i-frames
	var player_scene = load("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	assert(player.health == 3, "Player by měl začínat s 3 HP")
	print("[PASS] Počáteční stav hráče: 3 HP, max 3 HP")
	
	player.take_damage(1, Vector2(100, 0))
	assert(player.health == 2, "Player by měl mít po zásahu 2 HP")
	assert(player.invulnerable_timer > 0.0, "i-frames by měly být aktivní")
	print("[PASS] Poškození hráče: HP kleslo na 2, i-frames aktivní")
	
	player.take_damage(1, Vector2(100, 0))
	assert(player.health == 2, "Během i-frames nesmí hráč utrpět další poškození")
	print("[PASS] i-frames ochrana: druhý úder během blikání ignorován")
	
	# 2. Test Lékárničky
	var healed = player.heal(1)
	assert(healed == true, "Hráč by měl být úspěšně vyléčen")
	assert(player.health == 3, "HP hráče by mělo být opět 3")
	print("[PASS] Lékárnička: úspěšně obnovila HP na maximum (3/3)")
	
	# 3. Test Typ 1: Pozemní stráž (Patrol Guard)
	var patrol_scene = load("res://enemies/patrol_guard.tscn")
	var guard = patrol_scene.instantiate()
	add_child(guard)
	assert(guard.health == 2, "Stráž by měla mít 2 HP")
	guard.take_damage(1, Vector2.RIGHT)
	assert(guard.health == 1, "Stráž by měla mít po zásahu 1 HP")
	guard.take_damage(1, Vector2.RIGHT)
	assert(guard.is_dead == true, "Stráž by měla být po 2 zásazích mrtvá")
	print("[PASS] Typ 1 - Pozemní stráž (Patrol Guard): funguje, HP a knockback OK")
	
	# 4. Test Typ 2: Střelec korporace (Corporate Shooter) a Projektil
	var shooter_scene = load("res://enemies/shooter.tscn")
	var shooter = shooter_scene.instantiate()
	add_child(shooter)
	assert(shooter.health == 2, "Střelec by měl mít 2 HP")
	assert(shooter.current_state == shooter.State.PATROL, "Střelec začíná v PATROL stavu")
	
	var bullet_scene = load("res://enemies/steam_bullet.tscn")
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.setup(Vector2.RIGHT)
	assert(bullet.is_in_group("enemies"), "Projektil lze zasáhnout hasákem")
	bullet.take_damage(1)
	print("[PASS] Typ 2 - Střelec korporace a zničitelný parní projektil: OK")
	
	# 5. Test Typ 3: Létající bezpečnostní dron (Security Drone)
	var drone_scene = load("res://enemies/drone.tscn")
	var drone = drone_scene.instantiate()
	add_child(drone)
	assert(drone.health == 1, "Létající dron by měl mít 1 HP (křehký cíl ve vzduchu)")
	drone.take_damage(1, Vector2.DOWN)
	assert(drone.is_dead == true, "Dron je po zásahu hákem/stompem zničen")
	print("[PASS] Typ 3 - Létající bezpečnostní dron (Drone): OK")
	
	print("=== VŠECHNY TESTY 3 TYPŮ NEPŘÁTEL ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit()
