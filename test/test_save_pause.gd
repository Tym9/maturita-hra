extends Node2D

const PlayerScene = preload("res://player.tscn")

func _ready():
	print("=== SPUŠTĚNÍ AUTOMATICKÉHO TESTU SAVE MANAGERA A PAUZY ===")
	
	# Test 1: Ověření existence SaveManageru
	assert(SaveManager != null, "SaveManager autoload musí existovat")
	print("[PASS] TEST 1: SaveManager autoload načten")
	
	# Test 2: Vytvoření testovacího hráče a uložení
	var player = PlayerScene.instantiate()
	add_child(player)
	
	player.health = 2
	player.crystals = 3
	player.collected_crystal_ids.clear()
	player.collected_crystal_ids.append("crystal_r0")
	player.collected_crystal_ids.append("crystal_r10")
	player.collected_crystal_ids.append("crystal_r11")
	player.spawn_point = Vector2(360, 130)
	Global.death_count = 5
	Global.kill_count = 8
	
	var save_success = SaveManager.save_game(player, "res://level1.tscn")
	assert(save_success == true, "SaveManager.save_game() musí vrátit true")
	assert(SaveManager.has_save_file() == true, "has_save_file() musí hlásit true")
	print("[PASS] TEST 2: Uložení hry do user://save.json proběhlo úspěšně")
	
	# Test 3: Načtení dat ze souboru
	var loaded = SaveManager.load_game_data()
	assert(not loaded.is_empty(), "Načtená data nesmí být prázdná")
	assert(loaded["player"]["health"] == 2, "Uložené zdraví musí být 2")
	assert(loaded["player"]["crystals"] == 3, "Uložené krystaly musí být 3")
	assert(loaded["stats"]["deaths"] == 5, "Statistika smrtí musí být 5")
	assert(loaded["stats"]["kills"] == 8, "Statistika zabití musí být 8")
	print("[PASS] TEST 3: Načtení a parsování dat ze souboru OK")
	
	# Test 4: Aplikace dat na nového hráče
	var fresh_player = PlayerScene.instantiate()
	add_child(fresh_player)
	
	SaveManager.apply_save_to_player(fresh_player)
	assert(fresh_player.health == 2, "Hráč musí mít načtené 2 HP")
	assert(fresh_player.crystals == 3, "Hráč musí mít načtené 3 krystaly")
	assert(fresh_player.collected_crystal_ids.size() == 3, "Hráč musí mít 3 sebrané ID")
	assert(fresh_player.spawn_point == Vector2(360, 130), "Hráč musí mít načtený spawn point (360, 130)")
	print("[PASS] TEST 4: Aplikace uložených dat na nového hráče OK")
	
	# Test 5: Ověření PauseMenu na hráči
	var pause_menu = fresh_player.get_node_or_null("CanvasLayer/PauseMenu")
	assert(pause_menu != null, "PauseMenu musí existovat v CanvasLayer hráče")
	pause_menu.toggle_pause()
	assert(get_tree().paused == true, "get_tree().paused musí být true po otevření pauzy")
	assert(pause_menu.visible == true, "PauseMenu musí být viditelné")
	pause_menu.toggle_pause()
	assert(get_tree().paused == false, "get_tree().paused musí být false po zavření pauzy")
	assert(pause_menu.visible == false, "PauseMenu musí být skryté")
	print("[PASS] TEST 5: PauseMenu funguje (toggling get_tree().paused)")
	
	# Úklid testovacího souboru
	SaveManager.delete_save()
	print("=== VŠECHNY TESTY SAVE/PAUZA ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit(0)
