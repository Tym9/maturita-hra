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
	test_escape_closes_chest_first()
	
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
	
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	var ok = SaveManager.save_game(player1, "res://level1.tscn")
	assert_true(ok, "SaveManager.save_game proběhl úspěšně")
	
	var player2 = player_scene.instantiate()
	add_child(player2)
	player2.grid_inventory.clear()
	SaveManager.apply_save_to_player(player2)
	
	assert_true(player2.grid_inventory.has_item("wrench"), "Načtený hráč má hasák v inventáři")
	assert_true(player2.grid_inventory.has_item("gravity_coil"), "Načtený hráč má Gravity Coil v inventáři")
	assert_true(player2.health == 2, "Načtený hráč má správný počet HP (2)")
	# Vrátit hráčovo skutečné uložení (user:// sdílí test i hra)
	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE).store_string(save_backup)
		SaveManager.load_game_data()
	
	player1.queue_free()
	player2.queue_free()

func test_escape_closes_chest_first():
	print("
--- 7. Esc zavře otevřenou truhlu dřív, než otevře pauzu ---")
	var chest = preload("res://mechanics/chest.tscn").instantiate()
	add_child(chest)
	var player = preload("res://player.tscn").instantiate()
	add_child(player) # hráč je ve scéně až za truhlou jako v levelech (Esc dostane první pauza)
	chest.player_in_range = player
	chest.open_chest()
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	get_viewport().push_input(esc)
	assert_true(not chest.is_window_active and not chest.chest_window.visible, "Esc zavřel truhlu")
	assert_true(not get_tree().paused, "Esc s otevřenou truhlou neotevřel pauzu")
	get_viewport().push_input(esc)
	assert_true(get_tree().paused, "Další Esc otevře pauzu")
	get_tree().paused = false
	chest.queue_free()
	player.queue_free()

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
	
	# Dva sloty, do každého jde kterýkoli nástroj; třetí nástroj se nevejde, dokud jeden nevyměníš
	player.grid_inventory.clear()
	player.grid_inventory.equip_item(hook, 0)
	player.grid_inventory.equip_item(wrench, 1)
	assert_true(player.grid_inventory.slot_of("grapple_hook") == 0 and player.grid_inventory.slot_of("wrench") == 1, "Hák jde do slotu 1 a hasák do slotu 2 (sloty nejsou vázané na druh nástroje)")
	assert_true(not player.grid_inventory.equip_item(coil), "Třetí nástroj se bez volného slotu nevybaví")
	player.grid_inventory.add_item_auto(coil)
	assert_true(player.grid_inventory.has_item("gravity_coil") and not player.grid_inventory.is_equipped("gravity_coil"), "Cívka zůstane v batohu")
	player.can_dash = true
	player.dash_cooldown = 0.0
	player.perform_dash()
	assert_true(not player.is_dashing, "Cívka v batohu nefunguje (naráz jen dva nástroje)")
	assert_true(not player.grid_inventory.equip_item(ItemData.create("health_pack"), 0) and player.grid_inventory.slot_of("grapple_hook") == 0, "Lékárnička do slotu nepatří")
	player.grid_inventory.equip_item(wrench, 0)
	player.grid_inventory.equip_item(hook, 1)
	player.select_hotbar_slot(0)

	# Lékárnička z batohu [Q]
	player.grid_inventory.add_item_auto(ItemData.create("health_pack"))
	player.health = player.max_health
	assert_true(not player.use_health_pack() and player.grid_inventory.has_item("health_pack"), "Při plném zdraví se lékárnička nespotřebuje")
	player.health = 1
	assert_true(player.use_health_pack() and player.health == 2 and not player.grid_inventory.has_item("health_pack"), "Lékárnička z batohu [Q] doplní srdíčko a spotřebuje se")
	player.health = player.max_health

	# Staré uložení se třemi sloty: třetí nástroj se neztratí, skončí v batohu
	var old_inv := GridInventory.new(6, 4, true)
	old_inv.load_save_data([{"id": "wrench", "x": -1, "y": -1, "equipped_slot": 0}, {"id": "grapple_hook", "x": -1, "y": -1, "equipped_slot": 1}, {"id": "gravity_coil", "x": -1, "y": -1, "equipped_slot": 2}])
	assert_true(old_inv.is_equipped("wrench") and old_inv.is_equipped("grapple_hook") and old_inv.has_item("gravity_coil") and not old_inv.is_equipped("gravity_coil"), "Staré uložení: nástroj ze 3. slotu je v batohu")

	assert_true(player.grid_inventory.is_equipped("wrench"), "Hasák je vybaven v Hotbaru (Slot 1)")
	assert_true(player.grid_inventory.is_equipped("grapple_hook"), "Hák je vybaven v Hotbaru (Slot 2)")
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

	# Test 6G: Tab otevře a zavře batoh kdekoli; s otevřeným batohem se neútočí
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	player._unhandled_input(tab)
	assert_true(player.backpack_window.visible, "Tab otevře batoh")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	player.melee_cooldown = 0.0
	player._unhandled_input(click)
	assert_true(player.melee_cooldown == 0.0, "S otevřeným batohem klik neútočí")
	player._unhandled_input(tab)
	assert_true(not player.backpack_window.visible, "Tab batoh zase zavře")
	
	player.queue_free()
