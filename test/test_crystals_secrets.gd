extends Node2D

## Test krystalů a tajných cest (levels/test_chapter): id z místnosti, fronta, započítání po 0.15 s
## na bezpečné zemi (ne na drolící se plošině), počítadlo, duch, GRAND, WINGED, HIDDEN, trvalé záznamy,
## menu pauzy, batoh, falešná zeď a přepínač s bránou (stav přežije restart).
## Spuštění: godot --headless --path . res://test/test_crystals_secrets.tscn

const CrystalScene = preload("res://mechanics/crystal.tscn")

var fails: int = 0

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

func _frames(n: int):
	for i in n:
		await get_tree().physics_frame

func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""

func _restore(path: String, content: String):
	if content.is_empty():
		DirAccess.remove_absolute(path)
	else:
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_string(content)
		f.close()

func _ready():
	# Test zapisuje trvalý postup i save - hráčovy soubory na konci vrátíme
	var progress_backup := _read(SaveManager.PROGRESS_PATH)
	var save_backup := _read(SaveManager.SAVE_PATH)
	SaveManager.progress = {"crystals": {}, "grand": {}, "flags": {}}
	var chapter: Chapter = load("res://levels/test_chapter/test_chapter.tscn").instantiate()
	add_child(chapter)
	await _frames(3)
	var player = chapter.player
	var a1: Room = chapter._find("tc_a01")
	var a2: Room = chapter._find("tc_a02")
	var a3: Room = chapter._find("tc_a03")
	var normal = a2.get_node("Crystal")
	var grand = a1.get_node("GrandCrystal")
	var winged = a3.get_node("WingedCrystal")

	# 1. Id = room_id + pořadí v místnosti
	_ok(normal.id == "tc_a02_0" and grand.id == "tc_a01_0" and winged.id == "tc_a03_0", "Id krystalu = room_id + pořadí (%s, %s, %s)" % [normal.id, grand.id, winged.id])

	# 2. Fronta: dva krystaly letí za sebou
	chapter.teleport_to("tc_a02")
	var extra = CrystalScene.instantiate()
	extra.position = Vector2(100, 60)
	a2.add_child(extra)
	await _frames(1)
	_ok(extra.id == "tc_a02_1", "Druhý krystal v místnosti dostane index 1")
	player.global_position = Vector2(552, 40) # nad jámou, ve vzduchu
	player.velocity = Vector2.ZERO
	normal.start_follow(player)
	extra.start_follow(player)
	await _frames(30) # fronta se ustálí
	_ok(player.crystal_trail == [normal, extra] and not normal.is_collected, "Krystaly čekají ve frontě za hráčem")
	_ok(extra.global_position.distance_to(normal.global_position) < extra.global_position.distance_to(player.global_position), "Druhý krystal letí za prvním")

	# 3. Drolící se plošina není bezpečná zem
	player.global_position = Vector2(560, 113)
	player.velocity = Vector2.ZERO
	await _frames(12)
	_ok(player.is_on_floor() and not normal.is_collected, "Na drolící se plošině se krystal nezapočítá")

	# 4. Pevná zem: započítá se až po ~0.15 s, zapíše se trvale a vyjede počítadlo
	player.global_position = Vector2(400, 135)
	player.velocity = Vector2.ZERO
	var frames := 0
	while not normal.is_collected and frames < 60:
		await get_tree().physics_frame
		frames += 1
	_ok(normal.is_collected and extra.is_collected and frames >= 8, "Započítání po stání na pevné zemi (%d snímků)" % frames)
	_ok(player.crystals == 2 and player.crystal_trail.is_empty(), "Počítadlo 2, fronta prázdná")
	var saved = JSON.parse_string(_read(SaveManager.PROGRESS_PATH))
	_ok(saved is Dictionary and saved.crystals.has("tc_a02_0") and saved.crystals.has("tc_a02_1"), "Sebraná id uložena v user://progress.json")
	await get_tree().create_timer(0.35).timeout
	_ok(absf(player.crystal_ui.position.x - player.crystal_ui.shown_x) < 1.0, "Počítadlo krystalů vyjelo na obrazovku")

	# 5. Duch: už sebraný krystal jde sebrat, ale nezapočítá se znovu
	var ghost = CrystalScene.instantiate()
	ghost.crystal_id = "tc_a02_0"
	a2.add_child(ghost)
	await _frames(1)
	_ok(ghost.ghost and is_equal_approx(ghost.modulate.a, ghost.GHOST_ALPHA), "Sebraný krystal se ukáže jako průhledný duch")
	ghost.collect(player)
	_ok(ghost.is_collected and player.crystals == 2, "Duch se sebere, ale nezapočítá")
	ghost.free()

	# 6. Menu pauzy a batoh: krystaly kapitoly sebrané/celkem
	var pause = player.get_node("CanvasLayer/PauseMenu")
	pause.toggle_pause()
	_ok(pause.crystals_label.text == "Krystaly: 2/3   Velký: 0/1", "Menu pauzy: '%s'" % pause.crystals_label.text)
	pause.toggle_pause()
	player.backpack_window.open_backpack()
	_ok("Gravitační krystal: 2   Velké: 0" in player.backpack_window.info_label.text, "Batoh ukazuje krystaly jako typ předmětu")
	player.backpack_window.close_backpack()

	# 7. GRAND se počítá zvlášť
	chapter.teleport_to("tc_a01")
	grand.collect(player)
	_ok(player.crystals == 2 and SaveManager.progress.grand.has("tc_a01_0"), "Velký krystal se počítá zvlášť")

	# 8. Falešná zeď: hráč projde dovnitř, zeď zprůhlední; venku zase plná
	var fake: FakeWall = a1.get_node("FakeWall")
	player.global_position = Vector2(40, 87)
	player.velocity = Vector2.ZERO
	await _frames(20)
	_ok(not fake.collision_enabled and player.global_position.distance_to(Vector2(40, 87)) < 2.0, "Hráč stojí uvnitř falešné zdi")
	_ok(fake.modulate.a < 0.5, "Falešná zeď zprůhlední, když je hráč uvnitř")
	player.global_position = Vector2(120, 135)
	await _frames(20)
	_ok(fake.modulate.a == 1.0, "Po odchodu je zeď zase plná")

	# 9. WINGED: dash mimo jeho místnost nevadí, v místnosti uletí; room_reset ho vrátí
	player.is_dashing = true
	await _frames(2)
	_ok(not winged.flown, "Dash v jiné místnosti okřídlený krystal nevyplaší")
	chapter.teleport_to("tc_a03")
	player.is_dashing = true
	await _frames(2)
	_ok(winged.flown, "Dash v místnosti okřídlený krystal vyplaší")
	player.die()
	await Global.room_reset
	_ok(not winged.flown and winged.position.distance_to(winged.home_position) <= 3.5 and winged.modulate.a == 1.0, "room_reset vrátí okřídlený krystal")

	# 10. Přepínač + brána + HIDDEN krystal; stav přepínače přežije restart
	var sw := GateSwitch.new()
	sw.name = "TestSwitch"
	sw.position = Vector2(150, 140)
	sw.gates = [NodePath("../TestGate")]
	var gate := Gate.new()
	gate.name = "TestGate"
	gate.position = Vector2(240, 96)
	a3.add_child(gate)
	a3.add_child(sw)
	var hidden = CrystalScene.instantiate()
	hidden.variant = hidden.Variant.HIDDEN
	hidden.reveal_source = NodePath("../TestSwitch")
	hidden.position = Vector2(150, 100)
	a3.add_child(hidden)
	await _frames(1)
	_ok(not hidden.visible and not hidden.monitoring and not gate.col.disabled, "HIDDEN krystal skrytý, brána zavřená")
	sw._on_body_entered(player)
	await _frames(2)
	_ok(gate.col.disabled and hidden.visible and SaveManager.get_flag("tc_a03/TestSwitch"), "Přepínač otevřel bránu, zjevil krystal a uložil stav")
	sw.free()
	gate.free()
	var sw2 := GateSwitch.new()
	sw2.name = "TestSwitch"
	sw2.gates = [NodePath("../TestGate")]
	var gate2 := Gate.new()
	gate2.name = "TestGate"
	a3.add_child(gate2)
	a3.add_child(sw2)
	await _frames(2)
	_ok(sw2.is_on and gate2.col.disabled and not gate2.visible, "Po restartu je brána z uloženého stavu rovnou otevřená")
	saved = JSON.parse_string(_read(SaveManager.PROGRESS_PATH))
	_ok(saved.grand.has("tc_a01_0") and saved.flags.has("tc_a03/TestSwitch"), "Velký krystal i přepínač uloženy v user://progress.json")

	_restore(SaveManager.PROGRESS_PATH, progress_backup)
	_restore(SaveManager.SAVE_PATH, save_backup)
	print("=== TEST KRYSTALŮ A TAJNÝCH CEST: %s ===" % ("100% OK" if fails == 0 else "%d CHYB" % fails))
	get_tree().quit(1 if fails else 0)
