extends Node2D

# Tutoriál (Prolog) = 6 velkých místností (16 buněk 320x180):
#   cesta 3x1 | uboci 3x1 | most 2x1 | skrys 2x1 | vchod 2x1 (okraj rokle) | stola 2x2 (sestup do rokle k Základně, kap. 1)

var fails := 0

# Selhání se započítá (a test skončí s kódem 1), ale nezastaví zbytek průchodu.
func _check(cond: bool, ok_msg: String, fail_msg: String):
	if cond:
		print("  ✓ PASS: ", ok_msg)
	else:
		fails += 1
		print("  ❌ FAIL: ", fail_msg)

func _ready():
	print("==================================================")
	print("[TEST] Spouštím test Tutoriálu (Prolog: Na Povrchu)...")
	print("==================================================")

	Global.reset_all_stats()
	var tutorial_scene = load("res://tutorial_level.tscn")
	assert(tutorial_scene != null, "Scéna tutorial_level.tscn musí existovat a jít načíst!")

	var tut = tutorial_scene.instantiate()
	add_child(tut)

	print("\n--- 1. Inicializace Tutoriálu a velkých místností ---")
	var player = tut.get_node_or_null("Player")
	assert(player != null, "Hráč musí být přítomen v tutoriálu")
	_check(player.global_position.x < 320 and player.global_position.y < 180, "Hráč začíná v Sektoru [0, 0] na %s" % player.global_position, "Hráč musí začínat v Sektoru [0, 0]")

	var backdrops = tut.get_node_or_null("Backdrops")
	assert(backdrops != null, "Backdrops uzel musí existovat")
	var groups = {}
	var styles = {}
	for b in backdrops.get_children():
		_check(b.room_group != "", "Buňka %s má room_group '%s'" % [b.name, b.room_group], "Buňka %s nemá room_group" % b.name)
		if not groups.has(b.room_group):
			groups[b.room_group] = []
		groups[b.room_group].append(Vector2i(b.room_x, b.room_y))
		styles[Vector2i(b.room_x, b.room_y)] = b.style
	var cell_count = backdrops.get_child_count()
	_check(cell_count >= 14 and cell_count <= 20, "Tutoriál má %d buněk (14-20)" % cell_count, "Tutoriál má mít 14-20 buněk, nalezeno %d" % cell_count)
	var expected_groups = {"cesta": 3, "uboci": 3, "most": 2, "skrys": 2, "vchod": 2, "stola": 4}
	_check(groups.size() == expected_groups.size(), "6 místností: %s" % str(groups.keys()), "Očekáváno 6 místností, nalezeno %d" % groups.size())
	for g in expected_groups.keys():
		var cells = groups.get(g, [])
		_check(cells.size() == expected_groups[g], "Místnost '%s' má %d buněk" % [g, cells.size()], "Místnost '%s' má mít %d buněk, má %d" % [g, expected_groups[g], cells.size()])
		var mn = Vector2i(9999, 9999)
		var mx = Vector2i(-9999, -9999)
		for c in cells:
			mn = Vector2i(min(mn.x, c.x), min(mn.y, c.y))
			mx = Vector2i(max(mx.x, c.x), max(mx.y, c.y))
		var area = (mx.x - mn.x + 1) * (mx.y - mn.y + 1)
		_check(area == cells.size(), "Místnost '%s' je plný obdélník" % g, "Místnost '%s' není plný obdélník" % g)
	# Celý prolog je venku (styl Surface); konec nesestupuje do dolu, ale do rokle se Základnou (kap. 1)
	var surface_ok = true
	for c in styles.keys():
		surface_ok = surface_ok and styles[c] == 1
	_check(surface_ok, "Všechny buňky mají styl Surface (žádný důl)", "Všechny buňky musí mít styl 1")
	_check(tut.get_node_or_null("RavineDecor/Descent") is RoomDecor, "Rokle má pozadí tábora odboje (RoomDecor jako kap. 1)", "Chybí RavineDecor/Descent (RoomDecor)")

	print("\n--- 2. Ověření mechanik a objektů ---")
	var mechanics = tut.get_node_or_null("Mechanics")
	assert(mechanics != null, "Mechanics uzel musí existovat")
	var chest = mechanics.get_node_or_null("StarterChest")
	assert(chest != null, "Průzkumnická truhla musí existovat")
	_check(chest.initial_items.has("health_pack") and chest.initial_items.size() == 1, "StarterChest obsahuje jen lékárničku", "Truhla musí obsahovat právě lékárničku")

	var collectibles = tut.get_node_or_null("Collectibles")
	assert(collectibles != null, "Collectibles uzel musí existovat")
	var ids = []
	for c in collectibles.get_children():
		ids.append(c.crystal_id)
	ids.sort()
	_check(ids == ["crystal_tut_1", "crystal_tut_2", "crystal_tut_3"], "Přesně 3 krystaly se stejnými ID: %s" % str(ids), "Krystaly musí mít ID crystal_tut_1..3, nalezeno %s" % str(ids))
	_check(collectibles.get_node_or_null("Crystal_Tut1") != null and collectibles.get_node_or_null("Crystal_Tut2") != null and collectibles.get_node_or_null("Crystal_Tut3") != null, "Uzly Crystal_Tut1..3 existují", "Uzly Crystal_Tut1..3 chybí")

	var platforms = tut.get_node_or_null("Platforms")
	assert(platforms != null, "Platforms uzel musí existovat")
	var crumble_count = 0
	for i in range(1, 6):
		if platforms.get_node_or_null("R5_Crumble%d" % i) != null:
			crumble_count += 1
	_check(crumble_count == 5, "Drolící se most (5 bloků) přítomen", "Drolící se bloky mostu musí existovat (nalezeno %d)" % crumble_count)

	var level_end = tut.get_node_or_null("LevelEnd")
	assert(level_end != null, "LevelEnd brána musí existovat")
	_check(level_end.next_level == "res://levels/c1/chapter1.tscn" and level_end.stage_index == 0 and level_end.max_stage_crystals == 3 and level_end.stage_title == "PROLOG: NA POVRCHU", "LevelEnd správně napojen na kapitolu 1 (res://levels/c1/chapter1.tscn)", "LevelEnd má špatné vlastnosti")

	print("\n--- 3. Cedule: správné ovládání ---")
	var signs = tut.get_node_or_null("TutorialSigns")
	assert(signs != null, "TutorialSigns uzel musí existovat")
	var all_text = ""
	for s in signs.get_children():
		all_text += s.text + "\n"
		_check(s.text.strip_edges() != "", "Cedule %s má text" % s.name, "Cedule %s je prázdná" % s.name)
	_check(not ("MEZERN" in all_text), "Žádná cedule už nezmiňuje MEZERNÍK", "Cedule stále zmiňují MEZERNÍK (skok je na W)")
	var s0 = signs.get_node("Sign_R0").text
	_check("A / D" in s0 and "W" in s0, "Cedule běh/skok: A / D a W", "Sign_R0 musí učit A / D a W")
	_check("[S]" in signs.get_node("Sign_R1").text, "Cedule skrčení: [S]", "Sign_R1 musí učit [S]")
	_check("W" in signs.get_node("Sign_R2").text, "Cedule dvojskoku: W ve vzduchu", "Sign_R2 musí učit W")
	var s3 = signs.get_node("Sign_R3").text
	_check("[Shift]" in s3 and "W / S" in s3 and "Esc" in s3 and "stamin" in s3, "Cedule šplhání: [Shift], W / S, stamina a menu Esc", "Sign_R3 musí zmínit Shift, W / S, staminu a menu Esc")
	_check("W" in signs.get_node("Sign_R4").text and "OD stěny" in signs.get_node("Sign_R4").text, "Cedule wall-jump: W a směr OD stěny", "Sign_R4 musí učit wall-jump")
	var s6 = signs.get_node("Sign_R6").text
	_check("[E]" in s6 and "[I]" in s6 and "[TAB]" in s6, "Cedule truhly: [E], [I] / [TAB]", "Sign_R6 musí zmínit [E], [I] a [TAB]")

	print("\n--- 4. Plynulý přechod kamery přes velké místnosti ---")
	var cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Kamera hráče musí existovat")

	# Počkáme na inicializaci kamery
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(cam.current_group == "cesta" and cam.current_room == Vector2i(0, 0), "Kamera startuje v místnosti 'cesta' [0, 0]", "Kamera musí startovat v 'cesta' [0, 0], je v '%s' %s" % [cam.current_group, cam.current_room])
	_check(cam.target_pos.x == 160.0, "Kamera na začátku široké místnosti drží levý okraj", "Kamera má držet levý okraj, je na %s" % cam.target_pos)

	# [pozice, buňka, skupina]
	var tour = [
		[Vector2(500, 100), Vector2i(1, 0), "cesta"],
		[Vector2(900, 100), Vector2i(2, 0), "cesta"],
		[Vector2(1100, 100), Vector2i(3, 0), "uboci"],
		[Vector2(1500, 100), Vector2i(4, 0), "uboci"],
		[Vector2(1800, 100), Vector2i(5, 0), "uboci"],
		[Vector2(2100, 100), Vector2i(6, 0), "most"],
		[Vector2(2400, 100), Vector2i(7, 0), "most"],
		[Vector2(2700, 100), Vector2i(8, 0), "skrys"],
		[Vector2(3000, 100), Vector2i(9, 0), "skrys"],
		[Vector2(3300, 100), Vector2i(10, 0), "vchod"],
		[Vector2(3600, 100), Vector2i(11, 0), "vchod"],
		[Vector2(3700, 300), Vector2i(11, 1), "stola"],
		[Vector2(3300, 300), Vector2i(10, 1), "stola"],
		[Vector2(3300, 500), Vector2i(10, 2), "stola"],
	]
	for t in tour:
		var prev_group = cam.current_group
		player.global_position = t[0]
		cam._process(0.016)
		_check(cam.current_room == t[1] and cam.current_group == t[2], "Kamera v buňce %s patří do místnosti '%s'" % [t[1], t[2]], "Kamera: buňka %s skupina '%s', očekáváno %s '%s'" % [cam.current_room, cam.current_group, t[1], t[2]])
		if prev_group != t[2]:
			var rect: Rect2 = cam._group_rect(t[2], t[1])
			_check(rect.has_point(player.spawn_point), "Nová místnost '%s': checkpoint %s je uvnitř" % [t[2], player.spawn_point], "Checkpoint %s není uvnitř místnosti '%s' %s" % [player.spawn_point, t[2], rect])
		else:
			_check(abs(cam.target_pos.x - clamp(player.global_position.x, cam._group_rect(t[2], t[1]).position.x + 160.0, cam._group_rect(t[2], t[1]).end.x - 160.0)) < 1.0, "Uvnitř místnosti '%s' kamera jede za hráčem" % t[2], "Kamera nesleduje hráče v místnosti '%s'" % t[2])

	# Pád do prázdné buňky = návrat na checkpoint
	var checkpoint_before = player.spawn_point
	player.global_position = Vector2(200, 400)
	cam._process(0.016)
	await Global.room_reset # respawn po krátkém zatmění
	_check(player.global_position.distance_to(checkpoint_before) < 1.0, "Pád mimo mapu vrátí hráče na checkpoint %s" % checkpoint_before, "Pád mimo mapu nevrátil hráče na checkpoint (je na %s)" % player.global_position)

	print("\n--- 5. Plazení tunelem: puštění S pod stropem hráče nezasekne ---")
	# Skalní brána P2_Stone1: x 1088..1184, spodní hrana y=144, podlaha y=160 (tunel 16 px, hráč stojí 18 px)
	player.global_position = Vector2(1070, 151)
	player.velocity = Vector2.ZERO
	Input.action_press("crouch")
	Input.action_press("move_right")
	for i in 120:
		if player.global_position.x >= 1130:
			break
		await get_tree().physics_frame
	Input.action_release("crouch")
	for i in 20:
		await get_tree().physics_frame
	_check(player.is_crouching, "Pod nízkým stropem zůstane hráč skrčený i bez S", "Hráč se pod stropem postavil (je na %s)" % player.global_position)
	for i in 240:
		if player.global_position.x > 1200:
			break
		await get_tree().physics_frame
	Input.action_release("move_right")
	_check(player.global_position.x > 1200 and not player.is_crouching, "Hráč doplazil tunelem a za ním se sám postavil", "Hráč uvízl v tunelu na %s (skrčený: %s)" % [player.global_position, player.is_crouching])

	tut.queue_free()
	print("==================================================")
	if fails == 0:
		print("[PASS] VŠECHNY TESTY TUTORIÁLU ÚSPĚŠNĚ PROŠLY (100% OK)!")
		print("==================================================")
		get_tree().quit(0)
	else:
		print("[FAIL] TESTY TUTORIÁLU SELHALY: %d chyb" % fails)
		print("==================================================")
		get_tree().quit(1)
