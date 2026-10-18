extends Node2D

# Level 2 = 6 velkých Celeste místností (21 buněk 320x180), hlavní novinka je DASH (Gravity Coil):
#   vestibul 2x2 | propast 2x2 | komin 1x2 | geoda 3x2 | chram 1x2 | vytah 3x1
const Level2Scene = preload("res://level2.tscn")
const ItemData = preload("res://mechanics/item_data.gd")
var level_inst = null
var player = null
var cam = null
var test_step = 0
var fails = 0
var checkpoint_before_void = Vector2.ZERO
var dash_frame = 0
var dash_landed = false

# Selhání se započítá (a test skončí s kódem 1), ale nezastaví zbytek průchodu.
func _ok(cond: bool, msg: String):
	if not cond:
		fails += 1
		print("[FAIL] ", msg)

func _ready():
	print("=== START TEST_LEVEL2_PLAYTHROUGH ===")
	level_inst = Level2Scene.instantiate()
	add_child(level_inst)

	player = level_inst.get_node("Player")
	assert(player != null, "Player must exist in level2")
	cam = player.get_node_or_null("Camera2D")
	assert(cam != null, "Camera2D must exist on Player")
	# Gravity Coil by hráč získal z Rustyho truhly; test ho vloží rovnou
	player.grid_inventory.add_item_auto(ItemData.create("gravity_coil"))

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
	_ok(groups.size() == 6, "Level 2 má mít 6 místností, nalezeno: %d" % groups.size())
	_ok(cells >= 16 and cells <= 22, "Level 2 má mít 16-22 buněk, nalezeno: %d" % cells)
	for g in groups.keys():
		var mn = Vector2i(9999, 9999)
		var mx = Vector2i(-9999, -9999)
		for c in groups[g]:
			mn = Vector2i(min(mn.x, c.x), min(mn.y, c.y))
			mx = Vector2i(max(mx.x, c.x), max(mx.y, c.y))
		var area = (mx.x - mn.x + 1) * (mx.y - mn.y + 1)
		_ok(area == groups[g].size(), "Skupina %s není plný obdélník (%d buněk, plocha %d)" % [g, groups[g].size(), area])
	print("[PASS] %d buněk ve %d místnostech, každá je plný obdélník" % [cells, groups.size()])

	# Název místnosti jen na levé horní buňce skupiny
	var titles = 0
	for b in level_inst.get_node("Backdrops").get_children():
		if b.room_title != "":
			titles += 1
	_ok(titles == 6, "Právě 6 názvů místností (jeden na skupinu), nalezeno: %d" % titles)

	# Obsah levelu zachován
	var crystal_ids = []
	for c in level_inst.get_node("Collectibles").get_children():
		crystal_ids.append(c.crystal_id)
	crystal_ids.sort()
	_ok(crystal_ids == ["crystal_m10", "crystal_m21", "crystal_m22"], "Přesně 3 krystaly se stejnými ID: %s" % str(crystal_ids))
	_ok(level_inst.get_node("Enemies").get_child_count() == 5, "Přesně 5 nepřátel")
	for n in ["Drone_Chasm", "PatrolGuard_Shaft", "Shooter_Tunnel", "Drone_Ledge", "Drone_Final"]:
		_ok(level_inst.get_node_or_null("Enemies/" + n) != null, "Nepřítel %s" % n)
	var packs = 0
	var anomalies = 0
	for m in level_inst.get_node("Mechanics").get_children():
		if m.name.begins_with("HealthPack"):
			packs += 1
		if m.name.begins_with("GravityAnomaly"):
			anomalies += 1
	_ok(packs == 3, "3 lékárničky")
	_ok(anomalies == 2, "2 gravitační anomálie")
	_ok(level_inst.get_node_or_null("Mechanics/CelesteKey_Corridor") != null and level_inst.get_node_or_null("Mechanics/Gate_KeyBlock") != null, "Klíč a brána")
	var chest_items = level_inst.get_node("Mechanics/RustyChest").initial_items
	_ok(chest_items.size() == 2 and "gravity_coil" in chest_items and "health_pack" in chest_items, "RustyChest obsahuje Gravity Coil (dash) a lékárničku")
	var vents = 0
	var spikes = 0
	for h in level_inst.get_node("Hazards").get_children():
		if h is GridSpikes:
			spikes += 1
		else:
			vents += 1
	_ok(vents == 4 and spikes >= 5, "Parní trysky (%d) a bodáky (%d)" % [vents, spikes])
	for n in ["R10_DashCrumble1", "R10_DashCrumble2", "R11_CrumblingBridge1", "R11_CrumblingBridge2", "R31_Crumble", "R32_DashCrumble1", "R32_DashCrumble2"]:
		_ok(level_inst.get_node_or_null("Platforms/" + n) != null, "Drolící se plošina %s" % n)
	_ok(level_inst.get_node_or_null("NPCs/Rusty") != null and level_inst.get_node_or_null("NPCs/EventTrigger_MineDepths") != null, "Rusty a EventTrigger")
	_ok(level_inst.get_node("NPCs/EventTrigger_MineDepths").dialogue_pages.size() == 1, "EventTrigger má dialogovou stránku")
	print("[PASS] Obsah levelu: 3 krystaly, 5 nepřátel, 3 lékárničky, 2 anomálie, klíč + brána, truhla s cívkou, trysky, bodáky, drolící plošiny")

func _expect(room: Vector2i, group: String, label: String):
	cam._process(0.0) # pod zátěží proběhne víc fyzikálních kroků na jeden snímek - kamera musí vidět teleport
	_ok(cam.current_room == room, "%s: room should be %s, got: %s" % [label, room, cam.current_room])
	_ok(cam.current_group == group, "%s: group should be '%s', got: '%s'" % [label, group, cam.current_group])

func _physics_process(delta):
	test_step += 1
	BeatClock.time = 0.0 # parní trysky drží v klidu - test teleportuje hráče kolem nich

	# Krok 0: Start v místnosti "vestibul" (2x2), checkpoint = startovní pozice
	if test_step == 5:
		_expect(Vector2i(0, 0), "vestibul", "Start")
		_ok(cam.target_pos.x == 160.0, "Kamera na začátku velké místnosti 2x2 musí být u levého okraje, got: %s" % cam.target_pos)
		_ok(player.spawn_point.x < 640 and player.spawn_point.y < 180, "Počáteční checkpoint je v první místnosti")
		print("[PASS] Room 'vestibul' [0, 0] initialised, camera at the left edge of the 2x2 room")

		# Krok 1: pravá polovina místnosti (za propastí pro dash) - stejná skupina, kamera jede za hráčem
		player.global_position = Vector2(450, 140)

	if test_step == 10:
		_expect(Vector2i(1, 0), "vestibul", "Inside vestibul")
		_ok(abs(cam.target_pos.x - player.global_position.x) < 1.0, "Uvnitř velké místnosti kamera sleduje hráče, cam=%s player=%s" % [cam.target_pos, player.global_position])
		print("[PASS] Cell [1, 0] belongs to the same big room: camera scrolls with the player")

		# Krok 2: dno jámy pod propastí - o patro níž, pořád jedna místnost
		player.global_position = Vector2(300, 290)

	if test_step == 15:
		_expect(Vector2i(0, 1), "vestibul", "Pit of vestibul")
		_ok(cam.target_pos.y == 270.0, "Kamera u dna jámy drží spodní okraj místnosti 2x2, got: %s" % cam.target_pos)
		_ok(player.spawn_point.y < 200.0 or player.spawn_point.y > 290.0, "Checkpoint zůstává v místnosti vestibul")
		print("[PASS] Cell [0, 1] is the pit of the same room: camera followed one screen down")

		# Krok 3: vstup do Krystalové propasti (2x2) dveřmi vpravo nahoře
		player.global_position = Vector2(700, 140)

	if test_step == 20:
		_expect(Vector2i(2, 0), "propast", "Enter propast")
		_ok(player.spawn_point.x >= 640.0, "Checkpoint se přesunul do propasti, got: %s" % player.spawn_point)
		print("[PASS] Room 'propast' [2, 0] (2x2) transition: OK")

		# Krok 4: dolní pravý roh propasti (podlaha před dveřmi do šachty)
		player.global_position = Vector2(1200, 300)

	if test_step == 25:
		_expect(Vector2i(3, 1), "propast", "Inside propast")
		_ok(cam.target_pos == Vector2(1120, 270), "Kamera v rohu propasti 2x2 musí být přichycena, got: %s" % cam.target_pos)
		print("[PASS] Cell [3, 1] is still 'propast' (2x2): camera clamped to the room corner")

		# Krok 5: úzká šachta 1x2
		player.global_position = Vector2(1400, 300)

	if test_step == 30:
		_expect(Vector2i(4, 1), "komin", "Enter komin")
		_ok(player.spawn_point.x >= 1280.0, "Checkpoint se přesunul do šachty, got: %s" % player.spawn_point)
		_ok(cam.target_pos == Vector2(1440, 270), "Kamera v šachtě je ve středu úzké místnosti, got: %s" % cam.target_pos)
		print("[PASS] Room 'komin' [4, 1] (shaft 1x2) transition: OK")

		# Krok 6: horní ostrůvek šachty (po dashi) - stejná skupina, o patro výš
		player.global_position = Vector2(1560, 119)

	if test_step == 35:
		_expect(Vector2i(4, 0), "komin", "Top of komin")
		_ok(cam.target_pos.x == 1440.0 and abs(cam.target_pos.y - player.global_position.y) < 2.0, "Kamera v šachtě jede svisle za hráčem, got: %s" % cam.target_pos)
		print("[PASS] Cell [4, 0] is the top of the same shaft: camera followed up")

		# Krok 7: vstup do Safírové geody 3x2
		player.global_position = Vector2(1630, 119)

	if test_step == 40:
		_expect(Vector2i(5, 0), "geoda", "Enter geoda")
		_ok(player.spawn_point.x >= 1600.0, "Checkpoint se přesunul do geody, got: %s" % player.spawn_point)
		print("[PASS] Room 'geoda' [5, 0] (3x2) transition: OK")

		# Krok 8: pravý dolní roh geody (podlaha před branou)
		player.global_position = Vector2(2520, 300)

	if test_step == 45:
		_expect(Vector2i(7, 1), "geoda", "Inside geoda")
		_ok(cam.target_pos == Vector2(2400, 270), "Kamera v rohu geody 3x2 musí být přichycena, got: %s" % cam.target_pos)
		print("[PASS] Cell [7, 1] is still 'geoda' (3x2): OK")

		# Krok 9: gravitační výtah 1x2
		player.global_position = Vector2(2570, 300)

	if test_step == 50:
		_expect(Vector2i(8, 1), "chram", "Enter chram")
		_ok(player.spawn_point.x >= 2560.0, "Checkpoint se přesunul do výtahu, got: %s" % player.spawn_point)
		_ok(cam.target_pos == Vector2(2720, 270), "Kamera ve výtahu 1x2, got: %s" % cam.target_pos)
		print("[PASS] Room 'chram' [8, 1] (gravity lift 1x2) transition: OK")

		# Krok 10: závěrečná místnost reaktoru 3x1
		player.global_position = Vector2(2950, 140)

	if test_step == 55:
		_expect(Vector2i(9, 0), "vytah", "Enter vytah")
		_ok(player.spawn_point.x >= 2880.0, "Checkpoint se přesunul do závěrečné místnosti, got: %s" % player.spawn_point)
		print("[PASS] Room 'vytah' [9, 0] (final 3x1) transition: OK")

		# Krok 11: pravý konec závěrečné místnosti = třetí buňka stejné skupiny
		player.global_position = Vector2(3760, 140)

	if test_step == 60:
		_expect(Vector2i(11, 0), "vytah", "End of vytah")
		_ok(cam.target_pos.x == 3680.0, "Kamera drží pravý okraj závěrečné místnosti, got: %s" % cam.target_pos)
		print("[PASS] Cell [11, 0] is the last third of the final room: camera clamped to the right edge")
		checkpoint_before_void = player.spawn_point

		# Krok 12: Prázdná buňka [9, 1] pod reaktorem je smrtící - hráč se vrátí na checkpoint
		player.global_position = Vector2(3000, 300)

	if test_step == 83: # smrt = ~0.25 s zatmění před respawnem
		_ok(player.global_position.distance_to(checkpoint_before_void) < 40.0, "Pád do prázdné buňky vrátí hráče na checkpoint %s, got: %s" % [checkpoint_before_void, player.global_position])
		print("[PASS] Falling into a cell without backdrop respawns the player at the checkpoint")

		# Krok 13: LevelEnd
		var level_end = level_inst.get_node("LevelEnd")
		_ok(level_end != null, "LevelEnd must exist")
		_ok(level_end.position == Vector2(3806, 70), "LevelEnd should be at (3806, 70), got: %s" % level_end.position)
		_ok(cam.is_valid_room(Vector2i(int(level_end.position.x / 320.0), 0)), "LevelEnd leží v platné buňce")
		_ok(level_end.next_level == "res://level3.tscn" and level_end.stage_index == 5 and level_end.max_stage_crystals == 3 and level_end.stage_title == "KAPITOLA 5: KRYSTALOVÉ DOLY", "LevelEnd properties")
		print("[PASS] LevelEnd verified at: %s" % level_end.position)

		# Krok 14: důkaz dashe v enginu - 14 dlaždic široká propast ve vestibulu (skok + dvojskok + dash)
		_start_dash_proof()

	if test_step > 83:
		_run_dash_proof()

# Scénář zaznamenaný přes bota (skok + dash) z kraje startovní římsy na druhou stranu propasti.
# Klíč: [snímek, akce, stisknuto]
const DASH_EVENTS = [[0, "move_right", true], [0, "jump", true], [21, "jump", false], [21, "dash", true], [23, "dash", false]]

func _start_dash_proof():
	dash_frame = 0
	dash_landed = false
	for a in ["move_left", "move_right", "jump", "crouch", "grab", "dash"]:
		Input.action_release(a)
	player.global_position = Vector2(226, 151)
	player.velocity = Vector2(150, 0)
	player.spawn_point = Vector2(226, 151)
	player.stamina = player.stamina_max
	player.air_jumps_left = 1
	player.can_dash = true

func _run_dash_proof():
	if dash_frame < 0:
		return
	for ev in DASH_EVENTS:
		if ev[0] == dash_frame:
			if ev[2]:
				Input.action_press(ev[1])
			else:
				Input.action_release(ev[1])
	dash_frame += 1
	if dash_frame > 20 and player.is_on_floor() and player.global_position.y < 170.0 and player.global_position.x > 420.0:
		dash_landed = true
	if dash_landed or dash_frame > 150:
		for a in ["move_left", "move_right", "jump", "dash"]:
			Input.action_release(a)
		_ok(dash_landed, "Dash přenese hráče přes 12 dlaždic širokou propast na druhou římsu, pozice: %s" % player.global_position)
		print("[PASS] Dash crosses the 12-tile gap of the vestibul (real engine): landed at %s" % player.global_position)
		dash_frame = -1
		if fails == 0:
			print("=== ALL 6 BIG ROOMS (21 CELLS) IN LEVEL 2 PASSED (100% OK) ===")
			get_tree().quit(0)
		else:
			print("=== LEVEL 2 PLAYTHROUGH FAILED: %d failed checks ===" % fails)
			get_tree().quit(1)
