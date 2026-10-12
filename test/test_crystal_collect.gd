extends Node2D

const Level1Scene = preload("res://level1.tscn")
const CrystalScene = preload("res://mechanics/crystal.tscn")

func _ready():
	print("=== SPUŠTĚNÍ AUTOMATICKÉHO TESTU SBĚRATELSKÝCH KRYSTALŮ ===")
	
	# Test 1: Ověření scény Level 1 a přítomnosti všech 5 krystalů
	var level = Level1Scene.instantiate()
	add_child(level)
	
	var collectibles_node = level.get_node_or_null("Collectibles")
	assert(collectibles_node != null, "Uzel Collectibles musí existovat v level1")
	
	var crystals = collectibles_node.get_children()
	assert(crystals.size() == 5, "Level 1 musí obsahovat přesně 5 sběratelských krystalů, nalezeno: %d" % crystals.size())
	print("[PASS] TEST 1: Level 1 obsahuje všech 5 krystalů")
	
	# Test 2: Hráč má inicializované počítadlo a UI
	var player = level.get_node("Player")
	assert(player != null, "Player musí existovat")
	assert(player.crystals == 0, "Počáteční počet krystalů musí být 0")
	assert(player.crystal_ui != null, "CrystalUI v CanvasLayer musí být nalezen")
	print("[PASS] TEST 2: Hráč i CrystalUI inicializováni (0/5)")
	
	# Test 3: Sebrání krystalu hráčem
	var crystal_0 = crystals[0]
	crystal_0.collect(player)
	assert(player.crystals == 1, "Počet krystalů hráče se musí zvýšit na 1, aktuálně: %d" % player.crystals)
	assert(player.crystal_ui.collected == 1, "CrystalUI musí zobrazovat 1")
	assert(crystal_0.is_collected == true, "Krystal musí být ve stavu is_collected")
	print("[PASS] TEST 3: Sebrání prvního krystalu a aktualizace HUDu na 1/5")
	
	# Test 4: Ochrana proti duplicitnímu sebrání téhož krystalu
	crystal_0.collect(player)
	assert(player.crystals == 1, "Duplicitní sebrání téhož krystalu nesmí zvýšit skóre")
	print("[PASS] TEST 4: Ochrana proti duplikaci krystalů funkční")
	
	# Test 5: Sebrání všech zbývajících krystalů
	for i in range(1, 5):
		crystals[i].collect(player)
	assert(player.crystals == 5, "Po sebrání všech krystalů musí být počet 5/5, aktuálně: %d" % player.crystals)
	print("[PASS] TEST 5: Všech 5 krystalů úspěšně sebráno (5/5)")
	
	print("=== VŠECHNY TESTY SBĚRATELSKÝCH KRYSTALŮ ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit(0)
