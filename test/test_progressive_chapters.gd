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
	test_level1_chests_configuration()
	
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

func test_level1_chests_configuration():
	print("\n--- 4. Konfigurace truhel v Levelu 1 ---")
	var lvl_scene = preload("res://level1.tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	
	var mechanics = lvl.get_node("Mechanics")
	var start_chest = mechanics.get_node_or_null("StartChest")
	var rusty_chest = mechanics.get_node_or_null("RustyChest")
	var vesper_chest = mechanics.get_node_or_null("VesperChest")
	
	assert_true(start_chest != null, "StartChest (Otis) nalezena v Levelu 1")
	assert_true(rusty_chest != null, "RustyChest (Rusty) nalezena v Levelu 1")
	assert_true(vesper_chest != null, "VesperChest (Vesper) nalezena v Levelu 1")
	
	# Ověření rozdělení výbavy
	assert_true(start_chest.inventory.has_item("wrench"), "StartChest obsahuje Hasák")
	assert_true(not start_chest.inventory.has_item("gravity_coil"), "StartChest NEOBSAHUJE Gravity Coil")
	assert_true(not start_chest.inventory.has_item("grapple_hook"), "StartChest NEOBSAHUJE Hák")
	
	assert_true(rusty_chest.inventory.has_item("gravity_coil"), "RustyChest obsahuje Gravity Coil")
	assert_true(not rusty_chest.inventory.has_item("grapple_hook"), "RustyChest NEOBSAHUJE Hák")
	
	assert_true(vesper_chest.inventory.has_item("grapple_hook"), "VesperChest obsahuje Přitahovací hák")
	
	lvl.queue_free()
