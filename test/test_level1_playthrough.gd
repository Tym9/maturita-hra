extends Node2D

# Level 1 = 6 velkých Celeste místností (19 buněk 320x180):
#   slevarna 2x1 | sklad 3x2 | sachta 1x3 | komora 2x2 | jadro 1x2 | vstup 2x1
const Level1Scene = preload("res://level1.tscn")
var level_inst = null
var player = null
var cam = null
var test_step = 0
var fails = 0
var checkpoint_before_void = Vector2.ZERO

# Selhání se započítá (a test skončí s kódem 1), ale nezastaví zbytek průchodu.
func _ok(cond: bool, msg: String):
	if not cond:
		fails += 1
		print("[FAIL] ", msg)

func _ready():
	print("=== START TEST_LEVEL1_PLAYTHROUGH ===")
	level_inst = Level1Scene.instantiate()
	add_child(level_inst)

	player = level_inst.get_node("Player")
	assert(player != null, "Player must exist in level1")
	cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Camera2D must exist on Player")

	# Strukturální kontrola: každá skupina buněk tvoří plný obdélník (jinak by kamera ukázala prázdno)
	var groups = {}
	var cells = 0
	for b in level_inst.get_node("Backdrops").get_children():
		cells += 1
		var g = b.room_group
		_ok(g != "", "Každá buňka musí mít room_group: %s" % b.name)
		if not groups.has(g):
			groups[g] = []
		groups[g].append(Vector2i(b.room_x, b.room_y))
	_ok(groups.size() == 6, "Level 1 má mít 6 místností, nalezeno: %d" % groups.size())
	_ok(cells >= 16 and cells <= 22, "Level 1 má mít 16-22 buněk, nalezeno: %d" % cells)
	for g in groups.keys():
		var mn = Vector2i(9999, 9999)
		var mx = Vector2i(-9999, -9999)
		for c in groups[g]:
			mn = Vector2i(min(mn.x, c.x), min(mn.y, c.y))
			mx = Vector2i(max(mx.x, c.x), max(mx.y, c.y))
		var area = (mx.x - mn.x + 1) * (mx.y - mn.y + 1)
		_ok(area == groups[g].size(), "Skupina %s není plný obdélník (%d buněk, plocha %d)" % [g, groups[g].size(), area])
	print("[PASS] %d buněk ve %d místnostech, každá je plný obdélník" % [cells, groups.size()])

	# Obsah levelu zachován
	var crystal_ids = []
	for c in level_inst.get_node("Collectibles").get_children():
		crystal_ids.append(c.crystal_id)
	crystal_ids.sort()
	_ok(crystal_ids == ["crystal_r0", "crystal_r11", "crystal_r20", "crystal_r22", "crystal_r31"], "Přesně 5 krystalů se stejnými ID: %s" % str(crystal_ids))
	_ok(level_inst.get_node("Enemies").get_child_count() == 5, "Přesně 5 nepřátel")
	var packs = 0
	var anomalies = 0
	for m in level_inst.get_node("Mechanics").get_children():
		if m.name.begins_with("HealthPack"):
			packs += 1
		if m.name.begins_with("GravityAnomaly"):
			anomalies += 1
	_ok(packs == 3, "3 lékárničky")
	_ok(anomalies == 2, "2 gravitační anomálie")
	_ok(level_inst.get_node_or_null("Mechanics/CelesteKey_HighBeam") != null and level_inst.get_node_or_null("Mechanics/Gate_KeyBlock") != null, "Klíč a brána")
	var chest_items = level_inst.get_node("Mechanics/StartChest").initial_items
	_ok(chest_items.size() == 2 and "wrench" in chest_items and "health_pack" in chest_items, "StartChest obsahuje hasák a lékárničku")
	var vents = 0
	var spikes = 0
	for h in level_inst.get_node("Hazards").get_children():
		if h is GridSpikes:
			spikes += 1
		else:
			vents += 1
	_ok(vents >= 3 and spikes >= 5, "Parní trysky (%d) a bodáky (%d)" % [vents, spikes])
	_ok(level_inst.get_node_or_null("Platforms/R1_CrumblingBridge") != null, "Drolící se plošina")
	_ok(level_inst.get_node_or_null("NPCs/Otis") != null and level_inst.get_node_or_null("NPCs/EventTrigger_ShaftWarning") != null, "Otis a EventTrigger")
	print("[PASS] Obsah levelu: 5 krystalů, 5 nepřátel, 3 lékárničky, 2 anomálie, klíč + brána, truhla, trysky, bodáky")

func _expect(room: Vector2i, group: String, label: String):
	cam._process(0.0) # pod zátěží proběhne víc fyzikálních kroků na jeden snímek - kamera musí vidět teleport
	_ok(cam.current_room == room, "%s: room should be %s, got: %s" % [label, room, cam.current_room])
	_ok(cam.current_group == group, "%s: group should be '%s', got: '%s'" % [label, group, cam.current_group])

func _physics_process(delta):
	test_step += 1
	BeatClock.time = 0.0 # parní trysky drží v klidu - test teleportuje hráče kolem nich

	# Krok 0: Start v místnosti "slevarna" (2x1), checkpoint = startovní pozice
	if test_step == 5:
		_expect(Vector2i(0, 0), "slevarna", "Start")
		_ok(cam.target_pos == Vector2(160, 90), "Kamera na začátku velké místnosti 2x1 musí být u levého okraje, got: %s" % cam.target_pos)
		_ok(player.spawn_point.x < 640 and player.spawn_point.y < 180, "Počáteční checkpoint je v první místnosti")
		print("[PASS] Room 'slevarna' [0, 0] initialised, camera at left edge of the 2x1 room")

		# Krok 1: Pohyb uvnitř velké místnosti do druhé buňky - stejná skupina, kamera jede za hráčem
		player.global_position = Vector2(450, 140)

	if test_step == 10:
		_expect(Vector2i(1, 0), "slevarna", "Inside slevarna")
		_ok(abs(cam.target_pos.x - player.global_position.x) < 1.0, "Uvnitř velké místnosti kamera sleduje hráče, cam=%s player=%s" % [cam.target_pos, player.global_position])
		_ok(player.spawn_point.x < 640 and player.spawn_point.y < 180, "Checkpoint zůstává v první místnosti")
		print("[PASS] Cell [1, 0] belongs to the same big room: camera scrolls with the player")

		# Krok 2: Pád dírou do skladu ventilů (3x2) - nová skupina, nový checkpoint
		player.global_position = Vector2(568, 200)

	if test_step == 15:
		_expect(Vector2i(1, 1), "sklad", "Fall into sklad")
		_ok(player.spawn_point.y >= 180.0, "Checkpoint se přesunul do skladu ventilů, got: %s" % player.spawn_point)
		_ok(cam.target_pos.y == 270.0, "Kamera ve skladu ventilů drží horní okraj místnosti, got: %s" % cam.target_pos)
		print("[PASS] Room 'sklad' [1, 1] transition & checkpoint: OK")

		# Krok 3: Dolní patro skladu (buňka [2, 2]) - pořád jedna místnost 3x2
		player.global_position = Vector2(860, 500)

	if test_step == 20:
		_expect(Vector2i(2, 2), "sklad", "Inside sklad")
		_ok(cam.target_pos == Vector2(800, 450), "Kamera v rohu skladu 3x2 musí být přichycena k hranici místnosti, got: %s" % cam.target_pos)
		print("[PASS] Cell [2, 2] is still 'sklad' (3x2): camera clamped to the room corner")

		# Krok 4: Vstup do šachty 1x3 přes bránu
		player.global_position = Vector2(1000, 503)

	if test_step == 25:
		_expect(Vector2i(3, 2), "sachta", "Enter sachta")
		_ok(player.spawn_point.x >= 960.0, "Checkpoint se přesunul do šachty, got: %s" % player.spawn_point)
		_ok(cam.target_pos == Vector2(1120, 450), "Kamera v šachtě je ve středu úzké místnosti, got: %s" % cam.target_pos)
		print("[PASS] Room 'sachta' [3, 2] (vertical shaft 1x3) transition: OK")

		# Krok 5: Horní konec šachty - stejná skupina, o tři obrazovky výš
		player.global_position = Vector2(1200, 151)

	if test_step == 30:
		_expect(Vector2i(3, 0), "sachta", "Top of sachta")
		_ok(cam.target_pos.x == 1120.0 and abs(cam.target_pos.y - player.global_position.y) < 2.0, "Kamera v šachtě jede svisle za hráčem, got: %s" % cam.target_pos)
		print("[PASS] Cell [3, 0] is the top of the same shaft: camera followed 3 screens up")

		# Krok 6: Přechod do přetlakové komory 2x2
		player.global_position = Vector2(1310, 151)

	if test_step == 35:
		_expect(Vector2i(4, 0), "komora", "Enter komora")
		_ok(player.spawn_point.x >= 1280.0, "Checkpoint se přesunul do komory, got: %s" % player.spawn_point)
		print("[PASS] Room 'komora' [4, 0] (2x2) transition: OK")

		# Krok 7: Pravý dolní roh komory (bezpečná podlaha před dveřmi)
		player.global_position = Vector2(1880, 320)

	if test_step == 40:
		_expect(Vector2i(5, 1), "komora", "Inside komora")
		_ok(cam.target_pos == Vector2(1760, 270), "Kamera v rohu komory 2x2 musí být přichycena, got: %s" % cam.target_pos)
		print("[PASS] Cell [5, 1] is still 'komora' (2x2): OK")

		# Krok 8: Jádro generátoru 1x2 (gravitační výtah)
		player.global_position = Vector2(1945, 320)

	if test_step == 45:
		_expect(Vector2i(6, 1), "jadro", "Enter jadro")
		_ok(player.spawn_point.x >= 1920.0, "Checkpoint se přesunul do jádra, got: %s" % player.spawn_point)
		print("[PASS] Room 'jadro' [6, 1] (gravity lift 1x2) transition: OK")

		# Krok 9: Balkón jádra a vstup do závěrečné místnosti
		player.global_position = Vector2(2260, 151)

	if test_step == 50:
		_expect(Vector2i(7, 0), "vstup", "Enter vstup")
		_ok(player.spawn_point.x >= 2240.0, "Checkpoint se přesunul do závěrečné místnosti, got: %s" % player.spawn_point)
		print("[PASS] Room 'vstup' [7, 0] (final 2x1) transition: OK")

		# Krok 10: Pravý konec závěrečné místnosti = druhá buňka stejné skupiny
		player.global_position = Vector2(2750, 140)

	if test_step == 55:
		_expect(Vector2i(8, 0), "vstup", "End of vstup")
		_ok(cam.target_pos.x == 2720.0, "Kamera drží pravý okraj závěrečné místnosti, got: %s" % cam.target_pos)
		print("[PASS] Cell [8, 0] is the second half of the final room: camera clamped to the right edge")
		checkpoint_before_void = player.spawn_point

		# Krok 11: Prázdná buňka [2, 0] nad skladem je smrtící - hráč se vrátí na checkpoint
		player.global_position = Vector2(700, 100)

	if test_step == 78: # smrt = ~0.25 s zatmění před respawnem
		_ok(player.global_position.distance_to(checkpoint_before_void) < 40.0, "Pád do prázdné buňky vrátí hráče na checkpoint %s, got: %s" % [checkpoint_before_void, player.global_position])
		print("[PASS] Falling into a cell without backdrop respawns the player at the checkpoint")

		# Krok 12: LevelEnd
		var level_end = level_inst.get_node("LevelEnd")
		_ok(level_end != null, "LevelEnd must exist")
		_ok(level_end.position == Vector2(2800, 70), "LevelEnd should be at (2800, 70), got: %s" % level_end.position)
		_ok(cam.is_valid_room(Vector2i(int(level_end.position.x / 320.0), 0)), "LevelEnd leží v platné buňce")
		_ok(level_end.next_level == "res://level2.tscn" and level_end.stage_index == 4 and level_end.max_stage_crystals == 5, "LevelEnd properties")
		print("[PASS] LevelEnd verified at: %s" % level_end.position)
		if fails == 0:
			print("=== ALL 6 BIG ROOMS (19 CELLS) IN LEVEL 1 PASSED (100% OK) ===")
			get_tree().quit(0)
		else:
			print("=== LEVEL 1 PLAYTHROUGH FAILED: %d failed checks ===" % fails)
			get_tree().quit(1)
