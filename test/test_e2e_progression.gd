extends SceneTree

# Hra i testy sdílí user://save.json: příchod do kapitoly ukládá, po testu vrátit hráčovo uložení
var _save_backup := FileAccess.get_file_as_string("user://save.json")

func _finalize():
	if _save_backup.is_empty():
		DirAccess.remove_absolute("user://save.json")
	else:
		FileAccess.open("user://save.json", FileAccess.WRITE).store_string(_save_backup)

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
	
	# 5. Pribehove kapitoly 1 (Zakladna), 2 (Smallville), 3 (Parni mesto), 4 (Severni stena), 5 (Slevarna), 6 (Doly) a 7 (Komplex):
	# LevelEnd v posledni mistnosti, stav hrace se prenasi
	for chapter_name in ["Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7"]:
		assert(current_scene != null and current_scene.name == chapter_name, "Musi se nacist " + chapter_name)
		var ch_player = current_scene.get_node_or_null("Player")
		assert(ch_player != null and ch_player.crystals == 2, chapter_name + ": hrac s krystaly z tutorialu")
		assert(ch_player.collected_crystal_ids.has("crystal_tut_1"), chapter_name + ": hrac ma ID sebranych krystalu")
		var ch_end = current_scene.find_child("LevelEnd", true, false)
		assert(ch_end != null, chapter_name + ": LevelEnd musi existovat")
		print("  ✓ PASS: ", chapter_name, " nactena, hrac prevzal stav")
		if chapter_name == "Chapter5": # hasak ve vyzbroji se musi prenest dal az k bossovi
			var wrench = load("res://mechanics/item_data.gd").create("wrench")
			ch_player.grid_inventory.equip_item(wrench, 0)
		ch_end._on_body_entered(ch_player)
		await process_frame
		await process_frame
		await process_frame
		assert(current_scene != null and current_scene.name == "StageClearScreen", "StageClearScreen po " + chapter_name)
		current_scene._on_continue_pressed()
		await process_frame
		await process_frame
		await process_frame

	assert(current_scene != null and current_scene.name == "BossRoom", "Po kapitole 7 se musi nacist BossRoom")
	var boss_player = current_scene.get_node_or_null("Player")
	assert(boss_player != null, "Hrac v BossRoom musi existovat")
	assert(boss_player.grid_inventory.has_item("wrench"), "Hrac v BossRoom musi mit hasak!")
	assert(boss_player.grid_inventory.get_equipped(0) != null, "Hasak musi zustat vybaven v hotbaru!")
	print("  ✓ PASS: BossRoom nacten, hrac zdedil hasak ve vyzbroji!")
	
	print("==================================================")
	print("[PASS] KOMPLETNI E2E TEST PRECHODU ETAP (TUTORIAL -> K1 -> ... -> K7 -> BOSS) 100% USPESNY!")
	print("==================================================")
	quit(0)
