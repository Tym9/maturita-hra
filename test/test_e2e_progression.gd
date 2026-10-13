extends SceneTree

func _init():
	print("==================================================")
	print("[E2E TEST] Spoustim kompletni test pruchodu etap...")
	print("==================================================")
	call_deferred("_start_test")

func _start_test():
	# 1. Spustime tutorial level
	print(">>> 1. Nacteni tutorial_level.tscn")
	change_scene_to_file("res://tutorial_level.tscn")
	await process_frame
	await process_frame
	await process_frame
	
	assert(current_scene != null and current_scene.name == "TutorialLevel", "TutorialLevel musi byt nacten")
	print("  ✓ PASS: Tutorial level nacten (", current_scene.name, ")")
	
	var player = current_scene.get_node_or_null("Player")
	var level_end = current_scene.get_node_or_null("LevelEnd")
	assert(player != null, "Player nenalezen v tutorialu")
	assert(level_end != null, "LevelEnd nenalezen v tutorialu")
	
	# Simulujeme sebrani krystalu v tutorialu
	player.crystals = 2
	player.collected_crystal_ids.append("crystal_tut_1")
	player.collected_crystal_ids.append("crystal_tut_2")
	
	# 2. Hrac projde do LevelEnd portalu
	print(">>> 2. Hrac vstupuje do LevelEnd portalu v tutorialu")
	level_end._on_body_entered(player)
	
	await process_frame
	await process_frame
	await process_frame
	
	# 3. Zkontrolujeme, ze se nacetla StageClearScreen
	assert(current_scene != null and current_scene.name == "StageClearScreen", "Musi se nacist StageClearScreen")
	print("  ✓ PASS: StageClearScreen uspesne zobrazena")
	
	# 4. Hrac stiskne Pokracovat
	print(">>> 3. Hrac potvrzuje dokoncenou etapu (Pokracovat)")
	current_scene._on_continue_pressed()
	
	await process_frame
	await process_frame
	await process_frame
	
	# 5. Zkontrolujeme, ze se nacetl Level 1 bez jakehokoliv padu!
	assert(current_scene != null and current_scene.name == "Level1", "Musi se nacist Level1")
	print("  ✓ PASS: Level 1 uspesne nacten (", current_scene.name, ")!")
	
	var lvl1_player = current_scene.get_node_or_null("Player")
	assert(lvl1_player != null, "Hrac v Levelu 1 musi existovat")
	assert(lvl1_player.crystals == 2, "Hrac musi mit zachovany pocet krystalu (2)")
	assert(lvl1_player.collected_crystal_ids.has("crystal_tut_1"), "Hrac musi mit ID sebranych krystalu")
	print("  ✓ PASS: Hrac v Levelu 1 uspesne prevzal stav z tutoriálu!")
	
	# 6. Nyni otestujeme pruchod z Level 1 do Level 2!
	print(">>> 4. Hrac v Levelu 1 vstupuje do LevelEnd portalu...")
	var lvl1_end = current_scene.get_node_or_null("LevelEnd")
	assert(lvl1_end != null, "LevelEnd v Levelu 1 musi existovat")
	
	# Dejme hraci v Levelu 1 hasak
	var item_data_script = load("res://mechanics/item_data.gd")
	var wrench = item_data_script.create("wrench")
	lvl1_player.grid_inventory.equip_item(wrench, 0)
	
	lvl1_end._on_body_entered(lvl1_player)
	
	await process_frame
	await process_frame
	await process_frame
	
	assert(current_scene != null and current_scene.name == "StageClearScreen", "Musi se nacist StageClearScreen po Levelu 1")
	print("  ✓ PASS: StageClearScreen po Levelu 1 uspesne zobrazena")
	
	current_scene._on_continue_pressed()
	
	await process_frame
	await process_frame
	await process_frame
	
	assert(current_scene != null and current_scene.name == "Level2", "Musi se nacist Level2")
	print("  ✓ PASS: Level 2 uspesne nacten (", current_scene.name, ")!")
	
	var lvl2_player = current_scene.get_node_or_null("Player")
	assert(lvl2_player != null, "Hrac v Levelu 2 musi existovat")
	assert(lvl2_player.grid_inventory.has_item("wrench"), "Hrac v Levelu 2 musi mit hasak!")
	assert(lvl2_player.grid_inventory.get_equipped(0) != null, "Hasak musi zustat vybaven v hotbaru!")
	print("  ✓ PASS: Hrac v Levelu 2 uspesne zdedil hasak ve vyzbroji!")
	
	print("==================================================")
	print("[PASS] KOMPLETNI E2E TEST PRECHODU ETAP 100% USPESNY!")
	print("==================================================")
	quit(0)
