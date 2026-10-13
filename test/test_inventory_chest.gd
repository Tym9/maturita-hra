extends Node2D

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")

## Automatizovaný integrační test pro mřížkový inventář, truhlu a Gravity Coil dash.

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím integrační testy inventáře, truhly a Gravity Coil...")
	print("==================================================")
	
	test_grid_inventory_logic()
	test_chest_initialization_and_transfer()
	test_player_ability_restrictions()
	test_gravity_coil_dash_damage()
	test_inventory_save_load()
	test_equip_hotbar_slots_and_hook_range()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] NĚKTERÉ TESTY SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY INVENTÁŘE, TRUHLY A GRAVITY COIL PROŠLY!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_grid_inventory_logic():
	print("\n--- 1. Test logiky mřížkového inventáře (GridInventory) ---")
	var inv = GridInventory.new(6, 4)
	
	var wrench = ItemData.create("wrench") # 1x2
	var hook = ItemData.create("grapple_hook") # 2x1
	var coil = ItemData.create("gravity_coil") # 2x2
	
	# Umístění hasáku na (0, 0)
	var placed_wrench = inv.add_item(wrench, 0, 0)
	assert_true(placed_wrench, "Hasák (1x2) úspěšně vložen na (0, 0)")
	
	# Pokus o umístění kolidujícího předmětu na (0, 1)
	var overlap_test = inv.can_place_item(hook, 0, 1)
	assert_true(not overlap_test, "Detekce kolize: nelze položit předmět přes zabrané buňky hasáku (0, 1)")
	
	# Pokus o umístění mimo mřížku
	var out_of_bounds = inv.can_place_item(coil, 5, 3) # 2x2 na (5, 3) by přesahovalo 6x4
	assert_true(not out_of_bounds, "Detekce mezí: nelze položit 2x2 na (5, 3)")
	
	# Úspěšné umístění háku na (1, 0)
	var placed_hook = inv.add_item(hook, 1, 0)
	assert_true(placed_hook, "Hák (2x1) úspěšně položen na (1, 0)")
	
	# Úspěšné umístění Gravity Coil na (3, 0)
	var placed_coil = inv.add_item(coil, 3, 0)
	assert_true(placed_coil, "Gravity Coil (2x2) úspěšně položena na (3, 0)")
	
	assert_true(inv.has_item("wrench"), "has_item('wrench') vrací true")
	assert_true(inv.has_item("grapple_hook"), "has_item('grapple_hook') vrací true")
	assert_true(inv.has_item("gravity_coil"), "has_item('gravity_coil') vrací true")
	assert_true(not inv.has_item("nonexistent"), "has_item('nonexistent') vrací false")

func test_chest_initialization_and_transfer():
	print("\n--- 2. Test inicializace truhly a přesunu do batohu ---")
	var chest_scene = preload("res://mechanics/chest.tscn")
	var chest = chest_scene.instantiate()
	add_child(chest)
	
	assert_true(chest.inventory != null, "Truhla má platnou instanci inventáře")
	assert_true(chest.inventory.items.size() == 5, "Truhla obsahuje 5 výchozích předmětů")
	assert_true(chest.inventory.has_item("wrench"), "Truhla má hasák")
	assert_true(chest.inventory.has_item("grapple_hook"), "Truhla má hák")
	assert_true(chest.inventory.has_item("gravity_coil"), "Truhla má gravity coil")
	assert_true(chest.inventory.has_item("health_pack"), "Truhla má lékárničku")
	assert_true(chest.inventory.has_item("mine_key"), "Truhla má klíč od šachty")
	
	# Simulace přesunu coil z truhly do prázdného batohu hráče
	var player_inv = GridInventory.new(6, 4)
	var coil_item = chest.inventory.get_item_at(chest.inventory.items[2]["x"], chest.inventory.items[2]["y"])
	var coil_data: ItemData = coil_item["data"]
	
	chest.inventory.remove_item(coil_item)
	var transferred = player_inv.add_item_auto(coil_data)
	
	assert_true(transferred, "Gravity Coil byla úspěšně přenesena do hráčova batohu")
	assert_true(player_inv.has_item("gravity_coil"), "Hráčův batoh nyní obsahuje Gravity Coil")
	assert_true(not chest.inventory.has_item("gravity_coil"), "Truhla již Gravity Coil neobsahuje")
	
	chest.queue_free()

func test_player_ability_restrictions():
	print("\n--- 3. Test restrikcí schopností hráče podle obsahu inventáře ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.grid_inventory.clear()
	
	# Test útoku hasákem bez hasáku
	assert_true(not player.grid_inventory.has_item("wrench"), "Hráč zpočátku NEMÁ hasák")
	player.perform_melee_attack()
	assert_true(player.melee_cooldown == 0.0, "Útok hasákem zablokován, cooldown nenastaven")
	
	# Vložení hasáku
	player.grid_inventory.add_item_auto(ItemData.create("wrench"))
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Po vložení hasáku útok úspěšně proběhl (cooldown aktivní)")
	
	# Test háku bez háku
	assert_true(not player.grid_inventory.has_item("grapple_hook"), "Hráč NEMÁ hák v batohu")
	player.fire_hook()
	assert_true(not player.is_grappling, "Vystřelení háku zablokováno")
	
	player.queue_free()

func test_gravity_coil_dash_damage():
	print("\n--- 4. Test Gravity Coil dashe a poškození nepřítele ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(100, 100)
	add_child(player)
	player.grid_inventory.clear()
	
	# Vytvoření testovacího nepřítele
	var enemy_scene = preload("res://enemies/patrol_guard.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(115, 100) # v dosahu dashe
	add_child(enemy)
	var initial_hp = enemy.health
	
	# Bez Gravity Coil dash neudělá nic
	player.is_dashing = true
	player._process_dash_attack()
	assert_true(enemy.health == initial_hp, "Bez aktivního dashe s cívkou nepřítel nezraněn")
	player.is_dashing = false
	
	# Vložení Gravity Coil a provedení dash útoku
	player.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))
	player.is_dashing = true
	player.dash_hit_enemies.clear()
	player._process_dash_attack()
	
	assert_true(enemy.health < initial_hp, "Při dashi s Gravity Coil nepřítel utrpěl poškození (HP: %d -> %d)" % [initial_hp, enemy.health])
	assert_true(enemy in player.dash_hit_enemies, "Nepřítel byl zařazen do dash_hit_enemies")
	
	player.queue_free()
	enemy.queue_free()

func test_inventory_save_load():
	print("\n--- 5. Test uložení a načtení inventáře přes SaveManager ---")
	var player_scene = preload("res://player.tscn")
	var player1 = player_scene.instantiate()
	add_child(player1)
	player1.grid_inventory.clear()
	player1.grid_inventory.add_item_auto(ItemData.create("wrench"))
	player1.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))
	player1.health = 2
	
	var save_data = player1.get_inventory_save_data()
	assert_true(save_data.size() == 2, "Inventář exportoval 2 položky pro uložení")
	
	var ok = SaveManager.save_game(player1, "res://level1.tscn")
	assert_true(ok, "SaveManager.save_game proběhl úspěšně")
	
	var player2 = player_scene.instantiate()
	add_child(player2)
	player2.grid_inventory.clear()
	SaveManager.apply_save_to_player(player2)
	
	assert_true(player2.grid_inventory.has_item("wrench"), "Načtený hráč má hasák v inventáři")
	assert_true(player2.grid_inventory.has_item("gravity_coil"), "Načtený hráč má Gravity Coil v inventáři")
	assert_true(player2.health == 2, "Načtený hráč má správný počet HP (2)")
	
	player1.queue_free()
	player2.queue_free()

func test_equip_hotbar_slots_and_hook_range():
	print("\n--- 6. Test Equip Slotů (Hotbar ve výzbroji) a dosahu háku ---")
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.grid_inventory.clear()
	
	# Test 6A: Zkrácení dosahu háku na 1/3 (88.0 px)
	assert_true(player.GRAPPLE_RANGE == 88.0, "Dosah háku (GRAPPLE_RANGE) je zkrácen na 88.0 px (1/3 z původních 260)")
	
	# Test 6B: Vybavení zbraní do Equip slotů v GridInventory
	var wrench = ItemData.create("wrench")
	var hook = ItemData.create("grapple_hook")
	var coil = ItemData.create("gravity_coil")
	
	player.grid_inventory.equip_item(wrench, 0)
	player.grid_inventory.equip_item(hook, 1)
	player.grid_inventory.equip_item(coil, 2)
	
	assert_true(player.grid_inventory.is_equipped("wrench"), "Hasák je vybaven v Hotbaru (Slot 1)")
	assert_true(player.grid_inventory.is_equipped("grapple_hook"), "Hák je vybaven v Hotbaru (Slot 2)")
	assert_true(player.grid_inventory.is_equipped("gravity_coil"), "Gravity Coil je vybavena v Hotbaru (Slot 3)")
	assert_true(player.grid_inventory.has_item("wrench"), "has_item('wrench') vrací true i pro vybavené sloty")
	
	# Test 6C: Útok funguje s vybaveným hasákem
	player.melee_cooldown = 0.0
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Útok hasákem úspěšně proběhl")
	
	# Test 6D: Sundání hasáku z equip slotu
	var unequipped = player.grid_inventory.unequip_item(0)
	assert_true(unequipped != null and unequipped.id == "wrench", "Hasák byl úspěšně sundán z equip slotu")
	assert_true(not player.grid_inventory.is_equipped("wrench"), "Hasák již NENÍ vybaven")
	
	# Útok se sundaným hasákem musí být zablokován
	player.melee_cooldown = 0.0
	player.perform_melee_attack()
	assert_true(player.melee_cooldown == 0.0, "Útok se sundaným hasákem je zablokován (vyžaduje equip v hotbaru)")
	
	# Test 6E: Opětovné nasazení hasáku
	player.grid_inventory.equip_item(unequipped, 0)
	assert_true(player.grid_inventory.is_equipped("wrench"), "Hasák je znovu vybaven v Hotbaru")
	player.perform_melee_attack()
	assert_true(player.melee_cooldown > 0.0, "Po opětovném nasazení hasák znovu funguje")
	
	# Test 6F: Ověření přítomnosti komponenty EquipHotbarView v BackpackWindow
	assert_true(player.backpack_window != null, "BackpackWindow přítomno")
	assert_true(player.backpack_window.equip_view != null, "EquipHotbarView nalezeno v BackpackWindow")
	
	player.queue_free()
