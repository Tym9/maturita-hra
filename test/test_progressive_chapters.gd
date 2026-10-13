extends Node2D

## Automatizovaný integrační test pro postupné odemykání výstroje v sub-etapách.
## Sub-etapa 1: Pouze Hasák (Wrench) od Otise.
## Sub-etapa 2: Hasák + Gravity Coil (Dash) od Rustyho.
## Sub-etapa 3: Hasák + Gravity Coil + Hák (Grapple Hook) od Vesper.

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím integrační test postupného odemykání nástrojů (Celeste Progression)...")
	print("==================================================")
	
	test_subchapter_1_wrench_only()
	test_subchapter_2_wrench_and_coil()
	test_subchapter_3_all_three_tools()
	test_level_npc_and_chest_distribution()
	test_cross_chapter_inventory_persistence()
	test_void_and_safe_checkpoint_protection()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] NĚKTERÉ TESTY PROGRESU SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY POSTUPNÉHO PROGRESU NÁSTROJŮ PROŠLY (100% OK)!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_subchapter_1_wrench_only():
	print("\n--- 1. Sub-etapa 1: Pouze Hasák (Wrench) ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.grid_inventory.clear()
	
	# Hráč začíná bez jakéhokoliv nástroje
	assert_true(player.grid_inventory.items.is_empty(), "Hráč na startu nemá žádné předměty v batohu")
	assert_true(not player.grid_inventory.has_item("wrench"), "Nemá hasák")
	assert_true(not player.grid_inventory.has_item("gravity_coil"), "Nemá Gravity Coil")
	assert_true(not player.grid_inventory.has_item("grapple_hook"), "Nemá hák")
	
	# Pokus o útok bez hasáku
	player.perform_melee_attack()
	assert_true(player.melee_cooldown == 0.0, "Útok hasákem bez itemu zablokován")
	
	# Získání hasáku od Otise
	player.grid_inventory.add_item_auto(ItemData.create("wrench"))
	assert_true(player.grid_inventory.has_item("wrench"), "Hráč získal Hasák od Otise")
	
	# V Sub-etapě 1 funguje hasák
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Útok hasákem úspěšně funguje")
	
	# Ale dash a hák jsou stále zablokovány
	player.is_dashing = false
	player._process_dash_attack()
	assert_true(not player.is_dashing, "Dash je v Sub-etapě 1 nedostupný")
	
	player.fire_hook()
	assert_true(not player.is_grappling, "Hák je v Sub-etapě 1 nedostupný")
	
	player.queue_free()

func test_subchapter_2_wrench_and_coil():
	print("\n--- 2. Sub-etapa 2: Hasák + Gravity Coil ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.grid_inventory.clear()
	
	# Hráč má hasák z 1. etapy a od Rustyho dostane Gravity Coil
	player.grid_inventory.add_item_auto(ItemData.create("wrench"))
	player.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))
	
	assert_true(player.grid_inventory.has_item("wrench"), "Hráč má Hasák")
	assert_true(player.grid_inventory.has_item("gravity_coil"), "Hráč získal Gravity Coil od Rustyho")
	assert_true(not player.grid_inventory.has_item("grapple_hook"), "Hráč stále NEMÁ hák")
	
	# V Sub-etapě 2 funguje jak Hasák, tak Dash
	player.melee_cooldown = 0.0
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Hasák je funkční")
	
	# Test dash útoku s Gravity Coil
	var enemy_scene = preload("res://enemies/patrol_guard.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.position = player.position + Vector2(15, 0)
	add_child(enemy)
	var hp_before = enemy.health
	
	player.is_dashing = true
	player.dash_hit_enemies.clear()
	player._process_dash_attack()
	assert_true(enemy.health < hp_before, "Dash s Gravity Coil úspěšně poškodil nepřítele")
	player.is_dashing = false
	
	# Ale hák stále nelze použít
	player.fire_hook()
	assert_true(not player.is_grappling, "Hák je v Sub-etapě 2 stále nedostupný")
	
	player.queue_free()
	enemy.queue_free()

func test_subchapter_3_all_three_tools():
	print("\n--- 3. Sub-etapa 3: Všechny 3 nástroje (Hasák + Gravity Coil + Hák) ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.grid_inventory.clear()
	
	# Hráč má Hasák, Gravity Coil a od Vesper získá Hák
	player.grid_inventory.add_item_auto(ItemData.create("wrench"))
	player.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))
	player.grid_inventory.add_item_auto(ItemData.create("grapple_hook"))
	
	assert_true(player.grid_inventory.has_item("wrench"), "Nástroj 1: Hasák přítomen")
	assert_true(player.grid_inventory.has_item("gravity_coil"), "Nástroj 2: Gravity Coil přítomna")
	assert_true(player.grid_inventory.has_item("grapple_hook"), "Nástroj 3: Hák přítomen")
	
	# Všechny schopnosti jsou nyní odemčeny
	player.melee_cooldown = 0.0
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Hasák funkční")
	
	# Hák je připraven k míření a výstřelu
	assert_true(player.grid_inventory.has_item("grapple_hook"), "Hák povolen pro zaměřování a výstřel")
	
	player.queue_free()

func test_level_npc_and_chest_distribution():
	print("\n--- 4. Distribuce NPC a truhel napříč kapitolami ---")
	# Level 1: Pouze Otis a StartChest (Hasák)
	var lvl1 = preload("res://level1.tscn").instantiate()
	add_child(lvl1)
	var npcs1 = lvl1.get_node_or_null("NPCs")
	var mech1 = lvl1.get_node_or_null("Mechanics")
	assert_true(npcs1 != null and npcs1.get_node_or_null("Otis") != null, "Level 1 obsahuje NPC Otis")
	assert_true(npcs1.get_node_or_null("Rusty") == null, "Level 1 NEOBSAHUJE NPC Rusty")
	assert_true(npcs1.get_node_or_null("Vesper") == null, "Level 1 NEOBSAHUJE NPC Vesper")
	assert_true(mech1.get_node_or_null("StartChest") != null, "Level 1 obsahuje StartChest")
	assert_true(mech1.get_node("StartChest").inventory.has_item("wrench"), "StartChest obsahuje Hasák")
	assert_true(not mech1.get_node("StartChest").inventory.has_item("gravity_coil"), "StartChest NEOBSAHUJE Gravity Coil")
	assert_true(not mech1.get_node("StartChest").inventory.has_item("grapple_hook"), "StartChest NEOBSAHUJE Hák")
	lvl1.queue_free()

	# Level 2: Pouze Rusty a RustyChest (Gravity Coil)
	var lvl2 = preload("res://level2.tscn").instantiate()
	add_child(lvl2)
	var npcs2 = lvl2.get_node_or_null("NPCs")
	var mech2 = lvl2.get_node_or_null("Mechanics")
	assert_true(npcs2 != null and npcs2.get_node_or_null("Rusty") != null, "Level 2 obsahuje NPC Rusty")
	assert_true(npcs2.get_node_or_null("Otis") == null, "Level 2 NEOBSAHUJE NPC Otis")
	assert_true(npcs2.get_node_or_null("Vesper") == null, "Level 2 NEOBSAHUJE NPC Vesper")
	assert_true(mech2.get_node_or_null("RustyChest") != null, "Level 2 obsahuje RustyChest")
	assert_true(mech2.get_node("RustyChest").inventory.has_item("gravity_coil"), "RustyChest obsahuje Gravity Coil")
	assert_true(not mech2.get_node("RustyChest").inventory.has_item("grapple_hook"), "RustyChest NEOBSAHUJE Hák")
	lvl2.queue_free()

	# Level 3: Pouze Vesper a VesperChest (Grapple Hook)
	var lvl3 = preload("res://level3.tscn").instantiate()
	add_child(lvl3)
	var npcs3 = lvl3.get_node_or_null("NPCs")
	var mech3 = lvl3.get_node_or_null("Mechanics")
	assert_true(npcs3 != null and npcs3.get_node_or_null("Vesper") != null, "Level 3 obsahuje NPC Vesper")
	assert_true(npcs3.get_node_or_null("Otis") == null, "Level 3 NEOBSAHUJE NPC Otis")
	assert_true(npcs3.get_node_or_null("Rusty") == null, "Level 3 NEOBSAHUJE NPC Rusty")
	assert_true(mech3.get_node_or_null("VesperChest") != null, "Level 3 obsahuje VesperChest")
	assert_true(mech3.get_node("VesperChest").inventory.has_item("grapple_hook"), "VesperChest obsahuje Přitahovací hák")
	lvl3.queue_free()

func test_cross_chapter_inventory_persistence():
	print("\n--- 5. Perzistence inventáře napříč kapitolami ---")
	Global.reset_all_stats()
	
	# Hráč v Level 1
	var player1 = preload("res://player.tscn").instantiate()
	add_child(player1)
	player1.grid_inventory.clear()
	player1.grid_inventory.add_item_auto(ItemData.create("wrench"))
	Global.save_player_state(player1)
	assert_true(Global.has_persistent_player, "Hráčův stav byl uložen do Global")
	assert_true(Global.persistent_player_inventory.size() == 1, "Perzistentní inventář má 1 předmět")
	player1.queue_free()

	# Hráč v Level 2 (načte stav z Global)
	var player2 = preload("res://player.tscn").instantiate()
	add_child(player2)
	assert_true(player2.grid_inventory.has_item("wrench"), "Hráč v Levelu 2 má zděděný Hasák z Levelu 1")
	assert_true(not player2.grid_inventory.has_item("gravity_coil"), "Hráč v Levelu 2 zatím nemá Gravity Coil")
	# Sebrání Gravity Coil v Levelu 2
	player2.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))
	Global.save_player_state(player2)
	player2.queue_free()

	# Hráč v Level 3 (načte stav z Global)
	var player3 = preload("res://player.tscn").instantiate()
	add_child(player3)
	assert_true(player3.grid_inventory.has_item("wrench"), "Hráč v Levelu 3 má Hasák")
	assert_true(player3.grid_inventory.has_item("gravity_coil"), "Hráč v Levelu 3 má Gravity Coil")
	assert_true(not player3.grid_inventory.has_item("grapple_hook"), "Hráč v Levelu 3 zatím nemá Hák")
	player3.queue_free()

func test_void_and_safe_checkpoint_protection():
	print("\n--- 6. Ochrana před uložením checkpointu ve voidu (mimo mapu) ---")
	var lvl = preload("res://level1.tscn").instantiate()
	add_child(lvl)
	var player = lvl.get_node("Player")
	var cam = player.camera
	var initial_spawn = player.spawn_point
	
	assert_true(cam.is_valid_room(Vector2i(0, 0)), "Pokoj [0, 0] je validní")
	assert_true(not cam.is_valid_room(Vector2i(99, 99)), "Void [99, 99] NENÍ validní")
	
	# Hráč skočí do nevalidní zóny
	player.global_position = Vector2(9999, 9999)
	cam._process(0.016)
	player._physics_process(0.016)
	
	# Checkpoint se nesmí přepsat na void
	assert_true(player.spawn_point == initial_spawn, "Spawn point nebyl přepsán do voidu")
	lvl.queue_free()
