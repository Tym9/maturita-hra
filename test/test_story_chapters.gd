extends Node2D

## Test příběhových kapitol c1 Základna, c2 Smallville a c3 Parní město (scény z LEVEL_c1–c3.md):
## počet místností, respawny, překryvy, napojení LevelEnd, krystaly, checkpointy, pozadí, dialogy postav.
## Průchodnost řeší tools/level_check.py. Spuštění: godot --headless --path . res://test/test_story_chapters.tscn

const CHAPTERS := [
	{"path": "res://levels/c1/chapter1.tscn", "rooms": 20, "next": "res://levels/c2/chapter2.tscn", "index": 1, "style": RoomDecor.STYLE_OUTPOST, "crystals": 7, "checkpoints": 3},
	{"path": "res://levels/c2/chapter2.tscn", "rooms": 28, "next": "res://levels/c3/chapter3.tscn", "index": 2, "style": RoomDecor.STYLE_VILLAGE, "crystals": 12, "checkpoints": 4},
	{"path": "res://levels/c3/chapter3.tscn", "rooms": 28, "next": "res://level1.tscn", "index": 3, "style": RoomDecor.STYLE_CITY, "crystals": 12, "checkpoints": 4},
]

var fails: int = 0

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

func _ready():
	for spec in CHAPTERS:
		var scene := load(spec.path) as PackedScene
		_ok(scene != null, "%s jde načíst" % spec.path)
		if scene == null:
			continue
		var chapter: Chapter = scene.instantiate()
		add_child(chapter)
		for i in 3:
			await get_tree().physics_frame
		var label: String = spec.path.get_file()
		_ok(chapter.rooms.size() == spec.rooms, "%s: %d místností (má %d)" % [label, spec.rooms, chapter.rooms.size()])
		_ok(chapter.current == chapter.rooms[0], "%s: hráč začíná v první místnosti" % label)
		var ends: Array = []
		var crystals := 0
		var checkpoints := 0
		var bad_rooms: Array[String] = []
		for i in chapter.rooms.size():
			var r: Room = chapter.rooms[i]
			if r.room_id != r.name or r.nearest_respawn(r.bounds().get_center()) == null or not (r.get_node_or_null("Decor") is RoomDecor) or r.get_node("Decor").style != spec.style:
				bad_rooms.append(r.room_id)
			for j in range(i + 1, chapter.rooms.size()):
				if r.bounds().intersection(chapter.rooms[j].bounds()).get_area() > 0.0:
					bad_rooms.append("%s×%s" % [r.room_id, chapter.rooms[j].room_id])
			checkpoints += int(r.checkpoint)
			ends.append_array(r.find_children("*", "Area2D", false, false).filter(func(n): return n.get_script() == preload("res://level_end.gd")))
			crystals += r.get_children().filter(func(n): return n is CollectibleCrystal).size()
			for npc in r.find_children("*", "CharacterBody2D", false, false):
				if "dialogue_pages" in npc and npc.dialogue_pages.is_empty():
					bad_rooms.append("%s/%s bez dialogu" % [r.room_id, npc.name])
		_ok(bad_rooms.is_empty(), "%s: každá místnost má respawn, správné id a pozadí, nic se nepřekrývá, postavy mluví %s" % [label, bad_rooms])
		_ok(ends.size() == 1 and ends[0].next_level == spec.next and ends[0].stage_index == spec.index, "%s: jeden LevelEnd → %s" % [label, spec.next])
		_ok(crystals == spec.crystals, "%s: %d krystalů (má %d)" % [label, spec.crystals, crystals])
		_ok(checkpoints == spec.checkpoints, "%s: %d checkpointy (má %d)" % [label, spec.checkpoints, checkpoints])
		chapter.queue_free()
		await get_tree().process_frame
	print("FAILS: ", fails)
	get_tree().quit(1 if fails else 0)
