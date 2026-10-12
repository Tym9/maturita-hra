extends Node2D

## Automatizovaný test pro souhrnné statistiky po etapách a celkový přehled.

var failed: bool = false

func _ready():
	print("==================================================")
	print("[TEST] Spouštím test statistik etap a StageClearScreen...")
	print("==================================================")
	
	test_global_stage_stats_tracking()
	test_stage_clear_screen_instantiation()
	test_grand_summary_screen_instantiation()
	test_level_end_integration()
	
	print("==================================================")
	if failed:
		printerr("[FAIL] TESTY STATISTIK ETAP SELHALY!")
		get_tree().quit(1)
	else:
		print("[PASS] VŠECHNY TESTY STATISTIK ETAP ÚSPĚŠNĚ PROŠLY (100% OK)!")
		get_tree().quit(0)

func assert_true(condition: bool, msg: String):
	if not condition:
		printerr("  ❌ FAIL: " + msg)
		failed = true
	else:
		print("  ✓ PASS: " + msg)

func test_global_stage_stats_tracking():
	print("\n--- 1. Test správy statistik v Global ---")
	Global.reset_all_stats()
	assert_true(Global.death_count == 0, "Výchozí death_count je 0")
	assert_true(Global.kill_count == 0, "Výchozí kill_count je 0")
	assert_true(Global.stage_active == false, "Výchozí stage_active je false")
	
	# Spuštění etapy 1
	Global.start_stage(1, "ETAPA 1: STARÉ DÍLNY", 5)
	assert_true(Global.stage_active == true, "Etapa 1 je aktivní")
	assert_true(Global.current_stage_index == 1, "Index etapy je 1")
	assert_true(Global.stage_max_crystals == 5, "Maximální krystaly etapy 1 = 5")
	
	# Simulace událostí během etapy
	Global._process(2.5) # simulace uplynutí 2.5s
	assert_true(Global.stage_time >= 2.0, "Čas etapy se inkrementuje")
	assert_true(Global.total_time >= 2.0, "Celkový čas se inkrementuje")
	
	Global.death_count += 2
	assert_true(Global.stage_deaths == 2, "Zaznamenána 2 úmrtí v etapě")
	
	Global.kill_count += 3
	assert_true(Global.stage_kills == 3, "Zaznamenáni 3 zabití nepřátelé v etapě")
	
	Global.on_crystal_collected(4)
	assert_true(Global.stage_crystals == 4, "Zaznamenány 4 sebrané krystaly v etapě")
	assert_true(Global.total_crystals == 4, "Celkové krystaly = 4")
	
	# Dokončení etapy 1
	Global.finish_stage("ETAPA 1: STARÉ DÍLNY", 5, "res://level2.tscn")
	assert_true(Global.stage_active == false, "Etapa 1 již není aktivní")
	assert_true(Global.pending_next_scene == "res://level2.tscn", "pending_next_scene je level2.tscn")
	assert_true(Global.completed_stages.size() == 1, "V historii je 1 dokončená etapa")
	assert_true(Global.last_stage_result["crystals"] == 4, "Výsledek etapy 1 obsahuje 4 krystaly")
	assert_true(Global.last_stage_result["deaths"] == 2, "Výsledek etapy 1 obsahuje 2 úmrtí")
	assert_true(Global.last_stage_result["kills"] == 3, "Výsledek etapy 1 obsahuje 3 zabití")
	
	# Test formátování času
	var formatted = Global.format_time(125.4)
	assert_true(formatted == "02:05.4", "Formátování času 125.4s -> 02:05.4 (vrátilo: " + formatted + ")")

func test_stage_clear_screen_instantiation():
	print("\n--- 2. Test zobrazení StageClearScreen ---")
	var scene = preload("res://ui/stage_clear_screen.tscn")
	var screen = scene.instantiate()
	add_child(screen)
	
	var subtitle = screen.get_node("CenterContainer/Panel/Margin/VBox/SubtitleLabel")
	var time_val = screen.get_node("CenterContainer/Panel/Margin/VBox/StatsGrid/TimeValue")
	var cryst_val = screen.get_node("CenterContainer/Panel/Margin/VBox/StatsGrid/CrystalsValue")
	var deaths_val = screen.get_node("CenterContainer/Panel/Margin/VBox/StatsGrid/DeathsValue")
	var kills_val = screen.get_node("CenterContainer/Panel/Margin/VBox/StatsGrid/KillsValue")
	var btn = screen.get_node("CenterContainer/Panel/Margin/VBox/BtnContinue")
	
	assert_true(subtitle.text == "ETAPA 1: STARÉ DÍLNY", "Subtitle zobrazuje název dokončené etapy")
	assert_true(cryst_val.text == "4 / 5", "Zobrazeny krystaly 4 / 5")
	assert_true(deaths_val.text == "2", "Zobrazena 2 úmrtí")
	assert_true(kills_val.text == "3", "Zobrazena 3 zabití")
	assert_true(btn != null, "Tlačítko Pokračovat je přítomno")
	
	screen.queue_free()

func test_grand_summary_screen_instantiation():
	print("\n--- 3. Test zobrazení GrandSummaryScreen ---")
	var scene = preload("res://ui/grand_summary_screen.tscn")
	var screen = scene.instantiate()
	add_child(screen)
	
	var time_val = screen.get_node("CenterContainer/Panel/Margin/VBox/TotalStats/TimeVal")
	var cryst_val = screen.get_node("CenterContainer/Panel/Margin/VBox/TotalStats/CrystalsVal")
	var deaths_val = screen.get_node("CenterContainer/Panel/Margin/VBox/TotalStats/DeathsVal")
	var btn_menu = screen.get_node("CenterContainer/Panel/Margin/VBox/BtnMainMenu")
	
	assert_true(time_val != null, "Celkový čas nalezen")
	assert_true(cryst_val.text == "4 / 11 💎", "Celkové krystaly: 4 / 11 💎")
	assert_true(deaths_val.text == "2 💀", "Celková úmrtí: 2 💀")
	assert_true(btn_menu != null, "Tlačítko Hlavní menu přítomno")
	
	screen.queue_free()

func test_level_end_integration():
	print("\n--- 4. Test konfigurace LevelEnd v etapách ---")
	var l1 = preload("res://level1.tscn").instantiate()
	var le1 = l1.get_node("LevelEnd")
	assert_true(le1.stage_index == 1, "LevelEnd v Levelu 1 má stage_index = 1")
	assert_true(le1.max_stage_crystals == 5, "LevelEnd v Levelu 1 má max_stage_crystals = 5")
	assert_true(le1.next_level == "res://level2.tscn", "LevelEnd v Levelu 1 odkazuje na level2.tscn")
	l1.queue_free()
	
	var l2 = preload("res://level2.tscn").instantiate()
	var le2 = l2.get_node("LevelEnd")
	assert_true(le2.stage_index == 2, "LevelEnd v Levelu 2 má stage_index = 2")
	assert_true(le2.max_stage_crystals == 3, "LevelEnd v Levelu 2 má max_stage_crystals = 3")
	assert_true(le2.next_level == "res://level3.tscn", "LevelEnd v Levelu 2 odkazuje na level3.tscn")
	l2.queue_free()
	
	var l3 = preload("res://level3.tscn").instantiate()
	var le3 = l3.get_node("LevelEnd")
	assert_true(le3.stage_index == 3, "LevelEnd v Levelu 3 má stage_index = 3")
	assert_true(le3.max_stage_crystals == 3, "LevelEnd v Levelu 3 má max_stage_crystals = 3")
	assert_true(le3.next_level == "res://boss_room.tscn", "LevelEnd v Levelu 3 odkazuje na boss_room.tscn")
	l3.queue_free()
