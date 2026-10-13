extends Node2D

func _ready():
	print("==================================================")
	print("[TEST] Ověření přenosu inventáře přes LevelEnd...")
	print("==================================================")
	
	Global.reset_all_stats()
	
	var player_scene = load("res://player.tscn")
	var level_end_scene = load("res://level_end.tscn")
	var item_data_script = load("res://mechanics/item_data.gd")
	
	# 1. Hráč v Levelu 1 získá hasák a lékárničku
	var player1 = player_scene.instantiate()
	add_child(player1)
	player1.global_position = Vector2(50, 50)
	
	var wrench = item_data_script.create("wrench")
	var hp = item_data_script.create("health_pack")
	player1.grid_inventory.equip_item(wrench, 0)
	player1.grid_inventory.add_item(hp, 2, 2)
	player1.crystals = 3
	player1.health = 2
	
	assert(player1.grid_inventory.has_item("wrench"), "Hráč 1 musí mít hasák")
	assert(player1.grid_inventory.has_item("health_pack"), "Hráč 1 musí mít lékárničku")
	
	# 2. Vytvoříme LevelEnd portál
	var portal = level_end_scene.instantiate()
	portal.next_level = "res://level2.tscn"
	portal.stage_title = "ETAPA 1: STARÉ DÍLNY"
	portal.max_stage_crystals = 5
	add_child(portal)
	
	# Simulujeme vstup hráče do portálu
	portal._on_body_entered(player1)
	
	# Ověříme, že Global uložil stav hráče
	assert(Global.has_persistent_player, "Global musí mít nastaveno has_persistent_player = true!")
	assert(Global.persistent_player_inventory.size() == 2, "Perzistentní inventář musí mít 2 položky!")
	assert(Global.persistent_player_crystals == 3, "Perzistentní krystaly musí být 3!")
	assert(Global.persistent_player_health == 2, "Perzistentní HP musí být 2!")
	print("  ✓ PASS: LevelEnd úspěšně uložil kompletní stav hráče (inventář, krystaly, HP)")
	
	# 3. Simulujeme načtení hráče v další úrovni (Level 2)
	player1.queue_free()
	portal.queue_free()
	await get_tree().physics_frame
	
	var player2 = player_scene.instantiate()
	add_child(player2)
	# player2._ready() automaticky zavolá Global.load_player_state(self)
	
	assert(player2.grid_inventory.has_item("wrench"), "Hráč 2 v další etapě MUSÍ mít zděděný hasák!")
	assert(player2.grid_inventory.has_item("health_pack"), "Hráč 2 v další etapě MUSÍ mít zděděnou lékárničku!")
	assert(player2.grid_inventory.get_equipped(0) != null, "Hasák musí zůstat vybaven v hotbaru!")
	assert(player2.crystals == 3, "Hráč 2 musí mít zděděné krystaly (3)!")
	assert(player2.health == 2, "Hráč 2 musí mít zachované HP (2)!")
	print("  ✓ PASS: Hráč 2 v další etapě úspěšně převzal celou výbavu a inventář")
	
	player2.queue_free()
	print("==================================================")
	print("[PASS] TEST PŘENOSU INVENTÁŘE PŘES LEVELEND ÚSPĚŠNÝ!")
	print("==================================================")
	get_tree().quit(0)
