extends Node2D

# Level 3 = 6 velkých Celeste místností (20 buněk 320x180):
#   hala 2x2 | galerie 2x1 | sachta 1x3 | komora 3x2 | jadro 1x3 | predsin 2x1
const Level3Scene = preload("res://level3.tscn")
var level_inst = null
var player = null
var cam = null
var test_step = 0
var fails = 0
var checkpoint_before_void = Vector2.ZERO

func _ok(cond: bool, msg: String):
	if not cond:
		fails += 1
		print("[FAIL] ", msg)

func _ready():
	print("=== START TEST_LEVEL3_PLAYTHROUGH ===")
	level_inst = Level3Scene.instantiate()
	add_child(level_inst)

	player = level_inst.get_node("Player")
	assert(player != null, "Player must exist in level3")
	cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Camera2D must exist on Player")

	# 1. Strukturální kontrola: každá skupina buněk tvoří plný obdélník
	var groups = {}
	var cells = 0
	for b in level_inst.get_node("Backdrops").get_children():
		cells += 1
		var g = b.room_group
		_ok(g != "", "Každá buňka musí mít room_group: %s" % b.name)
		if not groups.has(g):
			groups[g] = []
		groups[g].append(Vector2i(b.room_x, b.room_y))
	_ok(groups.size() == 6, "Level 3 má mít 6 místností, nalezeno: %d" % groups.size())
	_ok(cells >= 16 and cells <= 22, "Level 3 má mít 16-22 buněk, nalezeno: %d" % cells)
	var expected_sizes = {"hala": 4, "galerie": 2, "sachta": 3, "komora": 6, "jadro": 3, "predsin": 2}
	for g in groups.keys():
		var mn = Vector2i(9999, 9999)
		var mx = Vector2i(-9999, -9999)
		for c in groups[g]:
			mn = Vector2i(min(mn.x, c.x), min(mn.y, c.y))
			mx = Vector2i(max(mx.x, c.x), max(mx.y, c.y))
		var area = (mx.x - mn.x + 1) * (mx.y - mn.y + 1)
		_ok(area == groups[g].size(), "Skupina %s není plný obdélník (%d buněk, plocha %d)" % [g, groups[g].size(), area])
		_ok(expected_sizes.get(g, -1) == groups[g].size(), "Velikost skupiny %s: %d" % [g, groups[g].size()])
	print("[PASS] %d buněk v %d místnostech, každá je plný obdélník" % [cells, groups.size()])

	# 2. Obsah levelu
	var crystal_ids = []
	for c in level_inst.get_node("Collectibles").get_children():
		crystal_ids.append(c.crystal_id)
	crystal_ids.sort()
	_ok(crystal_ids == ["crystal_r10", "crystal_r21", "crystal_r32"], "Přesně 3 krystaly se stejnými ID: %s" % str(crystal_ids))
	_ok(level_inst.get_node("Enemies").get_child_count() == 9, "Přesně 9 nepřátel v reaktoru")

	var mechanics = level_inst.get_node("Mechanics")
	var chests = {
		"VesperChest": ["grapple_hook", "health_pack"],
		"ReactorChest": ["health_pack", "steam_crystal"],
		"BossPrepChest": ["health_pack", "health_pack"],
	}
	for cname in chests.keys():
		var ch = mechanics.get_node_or_null(cname)
		_ok(ch != null and Array(ch.initial_items) == chests[cname], "%s má přesný obsah %s" % [cname, str(chests[cname])])
	var anchors = 0
	var packs = 0
	for m in mechanics.get_children():
		if m.name.begins_with("GrapplePoint"):
			anchors += 1
		if m.name.begins_with("HealthPack"):
			packs += 1
	_ok(anchors == 11, "11 kotev pro hák, nalezeno: %d" % anchors)
	_ok(packs == 3, "3 lékárničky, nalezeno: %d" % packs)
	var vents = 0
	var spikes = 0
	for h in level_inst.get_node("Hazards").get_children():
		if h is GridSpikes:
			spikes += 1
		else:
			vents += 1
	_ok(vents == 8, "8 parních trysek, nalezeno: %d" % vents)
	_ok(spikes >= 5, "Bodáky (%d)" % spikes)
	var crumbles = 0
	for p in level_inst.get_node("Platforms").get_children():
		if p.name.begins_with("Crumble"):
			crumbles += 1
	_ok(crumbles == 4, "4 drolící se plošiny, nalezeno: %d" % crumbles)
	_ok(level_inst.get_node_or_null("NPCs/Vesper") != null, "NPC Vesper přítomna")
	var trig = level_inst.get_node_or_null("NPCs/EventTrigger_ReactorCore")
	_ok(trig != null and trig.dialogue_pages.size() >= 1, "EventTrigger s dialogue_pages")
	var key = mechanics.get_node_or_null("CelesteKey_Accelerator")
	var gate = mechanics.get_node_or_null("Gate_KeyBlock_Reactor")
	_ok(key != null and gate != null, "Klíč a brána")
	_ok(mechanics.get_node_or_null("GravityAnomaly_Up") != null and mechanics.get_node_or_null("GravityAnomaly_Down") != null, "Obě gravitační anomálie")
	print("[PASS] Obsah Levelu 3 (Vesper + hák, 3 truhly, 3 krystaly, 9 nepřátel, 11 kotev, anomálie, klíč + brána): OK")

func _expect(room: Vector2i, group: String, label: String):
	cam._process(0.0) # pod zátěží proběhne víc fyzikálních kroků na jeden snímek - kamera musí vidět teleport
	_ok(cam.current_room == room, "%s: room should be %s, got: %s" % [label, room, cam.current_room])
	_ok(cam.current_group == group, "%s: group should be '%s', got: '%s'" % [label, group, cam.current_group])

func _physics_process(_delta):
	test_step += 1
	BeatClock.time = 0.0 # parní trysky drží v klidu - test teleportuje hráče kolem nich

	# Start v hale 2x2 (hák, propast)
	if test_step == 5:
		_expect(Vector2i(0, 0), "hala", "Start")
		_ok(cam.target_pos.x == 160.0, "Kamera na začátku haly drží levý okraj, got: %s" % cam.target_pos)
		_ok(player.spawn_point.x < 640 and player.spawn_point.y < 180, "Počáteční checkpoint je v první místnosti")
		print("[PASS] Room 'hala' [0, 0] initialised")
		player.global_position = Vector2(450, 300)

	# Dno propasti = spodní patro téže velké místnosti
	if test_step == 10:
		_expect(Vector2i(1, 1), "hala", "Pit floor of hala")
		_ok(abs(cam.target_pos.x - 450.0) < 15.0 and cam.target_pos.y == 270.0, "Kamera na dně propasti sleduje hráče a drží spodní okraj, got: %s" % cam.target_pos)
		_ok(player.spawn_point.y < 180.0, "Checkpoint zůstává v hale")
		print("[PASS] Cell [1, 1] belongs to 'hala' (2x2): camera scrolls inside the pit")
		player.global_position = Vector2(700, 135)

	# Parní galerie 2x1
	if test_step == 15:
		_expect(Vector2i(2, 0), "galerie", "Enter galerie")
		_ok(player.spawn_point.x >= 640.0, "Checkpoint se přesunul do galerie, got: %s" % player.spawn_point)
		print("[PASS] Room 'galerie' [2, 0] transition: OK")
		player.global_position = Vector2(1200, 135)

	if test_step == 20:
		_expect(Vector2i(3, 0), "galerie", "Inside galerie")
		_ok(cam.target_pos == Vector2(1120, 90), "Kamera drží pravý okraj galerie, got: %s" % cam.target_pos)
		print("[PASS] Cell [3, 0] same big room: OK")
		player.global_position = Vector2(1340, 135)

	# Chladicí šachta 1x3
	if test_step == 25:
		_expect(Vector2i(4, 0), "sachta", "Enter sachta")
		_ok(player.spawn_point.x >= 1280.0, "Checkpoint v šachtě, got: %s" % player.spawn_point)
		_ok(cam.target_pos.x == 1440.0, "Kamera v šachtě je vycentrovaná, got: %s" % cam.target_pos)
		print("[PASS] Room 'sachta' [4, 0] (vertical shaft 1x3) transition: OK")
		player.global_position = Vector2(1400, 480)

	if test_step == 30:
		_expect(Vector2i(4, 2), "sachta", "Bottom of sachta")
		_ok(cam.target_pos == Vector2(1440, 450), "Kamera na dně šachty, got: %s" % cam.target_pos)
		print("[PASS] Cell [4, 2] bottom of the same shaft: camera followed 3 screens down")
		player.global_position = Vector2(1700, 487)

	# Gravitační komora 3x2
	if test_step == 35:
		_expect(Vector2i(5, 2), "komora", "Enter komora")
		_ok(player.spawn_point.x >= 1600.0, "Checkpoint v komoře, got: %s" % player.spawn_point)
		_ok(cam.target_pos == Vector2(1760, 450), "Kamera v rohu komory 3x2, got: %s" % cam.target_pos)
		print("[PASS] Room 'komora' [5, 2] (3x2) transition: OK")
		player.global_position = Vector2(2300, 300)

	if test_step == 40:
		_expect(Vector2i(7, 1), "komora", "Inside komora")
		_ok(abs(cam.target_pos.x - 2300.0) < 15.0, "Kamera jede za hráčem komorou, got: %s" % cam.target_pos)
		print("[PASS] Cell [7, 1] still 'komora': OK")
		player.global_position = Vector2(2700, 487)

	# Jádro 1x3
	if test_step == 45:
		_expect(Vector2i(8, 2), "jadro", "Enter jadro")
		_ok(player.spawn_point.x >= 2560.0, "Checkpoint v jádru, got: %s" % player.spawn_point)
		_ok(cam.target_pos == Vector2(2720, 450), "Kamera v jádru, got: %s" % cam.target_pos)
		print("[PASS] Room 'jadro' [8, 2] (shaft 1x3) transition: OK")
		player.global_position = Vector2(2780, 135)

	if test_step == 50:
		_expect(Vector2i(8, 0), "jadro", "Top of jadro")
		_ok(cam.target_pos.x == 2720.0, "Kamera na vrcholu jádra, got: %s" % cam.target_pos)
		print("[PASS] Cell [8, 0] top of the same shaft: OK")
		player.global_position = Vector2(3000, 135)

	# Předsíň 2x1
	if test_step == 55:
		_expect(Vector2i(9, 0), "predsin", "Enter predsin")
		_ok(player.spawn_point.x >= 2880.0, "Checkpoint v předsíni, got: %s" % player.spawn_point)
		print("[PASS] Room 'predsin' [9, 0] transition: OK")
		player.global_position = Vector2(3480, 135)

	if test_step == 60:
		_expect(Vector2i(10, 0), "predsin", "End of predsin")
		_ok(cam.target_pos.x == 3360.0, "Kamera drží pravý okraj předsíně, got: %s" % cam.target_pos)
		print("[PASS] Cell [10, 0] second half of the final room: camera clamped to the right edge")
		checkpoint_before_void = player.spawn_point
		player.global_position = Vector2(1000, 300) # prázdná buňka [3, 1]

	if test_step == 83: # smrt = ~0.25 s zatmění před respawnem
		_ok(player.global_position.distance_to(checkpoint_before_void) < 40.0, "Pád do prázdné buňky vrátí hráče na checkpoint %s, got: %s" % [checkpoint_before_void, player.global_position])
		print("[PASS] Falling into a cell without backdrop respawns the player at the checkpoint")

		var mechanics = level_inst.get_node("Mechanics")
		var key = mechanics.get_node("CelesteKey_Accelerator")
		var gate = mechanics.get_node("Gate_KeyBlock_Reactor")
		var grav_up = mechanics.get_node("GravityAnomaly_Up")
		var grav_down = mechanics.get_node("GravityAnomaly_Down")
		_ok(player.gravity_dir == 1.0, "Výchozí gravitace dolů (1.0)")
		grav_up._on_body_entered(player)
		_ok(player.gravity_dir == -1.0, "První anomálie otočila gravitaci na strop (-1.0)")
		grav_down._on_body_entered(player)
		_ok(player.gravity_dir == 1.0, "Druhá anomálie vrátila gravitaci na podlahu (1.0)")
		key._on_body_entered(player)
		_ok(key.state == 1 and key.target_player == player, "CelesteKey následuje hráče")
		gate._on_key_unlocked()
		_ok(gate.is_unlocked, "Brána se odemkla")
		print("[PASS] Interakce anomálií, klíče a brány: OK")

		var level_end = level_inst.get_node("LevelEnd")
		_ok(level_end != null, "LevelEnd must exist")
		_ok(level_end.position == Vector2(3440, 110), "LevelEnd at (3440, 110), got: %s" % level_end.position)
		_ok(cam.is_valid_room(Vector2i(int(level_end.position.x / 320.0), int(level_end.position.y / 180.0))), "LevelEnd leží v platné buňce")
		_ok(level_end.next_level == "res://boss_room.tscn" and level_end.stage_index == 6 and level_end.max_stage_crystals == 3, "LevelEnd properties")
		print("[PASS] LevelEnd verified at: %s -> res://boss_room.tscn" % level_end.position)
		if fails == 0:
			print("=== ALL 6 BIG CELESTE ROOMS (20 CELLS) IN LEVEL 3 PASSED (100% OK) ===")
			get_tree().quit(0)
		else:
			print("=== LEVEL 3 PLAYTHROUGH FAILED: %d failed checks ===" % fails)
			get_tree().quit(1)
