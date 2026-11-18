extends SceneTree

## Jednotné ukládání ve všech kapitolách (prolog, c1–c7, staré level1–3): příchod do kapitoly a checkpoint uloží hru,
## Pokračovat vrátí místo, batoh i obsah truhel, i když hráč přišel z předchozí kapitoly (přenášený stav).
## Batoh se sám neplní: startovní předměty kapitoly leží v truhle. Zálohuje a vrací user://save.json a progress.json.
## Spuštění: godot --headless --path . -s res://test/test_save_continue.gd

const SCENES := ["res://tutorial_level.tscn", "res://levels/c1/chapter1.tscn", "res://levels/c3/chapter3.tscn",
	"res://levels/c5/chapter5.tscn", "res://levels/c6/chapter6.tscn", "res://levels/c7/chapter7.tscn", "res://level1.tscn", "res://level2.tscn", "res://level3.tscn"]

var fails := 0
var Global: Node
var SaveManager: Node

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""

func _restore(path: String, content: String):
	if content.is_empty():
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		return
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(content)

func _frames(n: int):
	for i in n:
		await physics_frame

func _load(path: String):
	for i in 120:
		await process_frame
		if current_scene and current_scene.scene_file_path == path:
			break
	await _frames(4)

func _ids(inv) -> Array:
	return inv.to_save_data().map(func(e): return e.id)

func _init():
	call_deferred("_run")

func _run():
	Global = root.get_node("Global")
	SaveManager = root.get_node("SaveManager")
	var save_backup := _read(SaveManager.SAVE_PATH)
	var progress_backup := _read(SaveManager.PROGRESS_PATH)
	for path in SCENES:
		await _check(path)
	_restore(SaveManager.SAVE_PATH, save_backup)
	_restore(SaveManager.PROGRESS_PATH, progress_backup)
	print("FAILS: ", fails)
	quit(1 if fails else 0)

func _check(path: String):
	var label: String = path.get_file()
	# Hráč přišel z předchozí kapitoly s prázdným batohem (LevelEnd nastaví přenášený stav)
	Global.has_persistent_player = true
	Global.persistent_player_inventory = []
	change_scene_to_file(path)
	await _load(path)
	var player = current_scene.get_node("Player")
	_ok(_ids(player.grid_inventory).is_empty(), "%s: batoh se při vstupu sám nenaplní %s" % [label, _ids(player.grid_inventory)])
	_ok(SaveManager.load_game_data().get("current_scene") == path, "%s: příchod do kapitoly uloží hru" % label)
	var is_chapter: bool = current_scene.get("rooms") != null # kořen Chapter (třídy autoloadů tu nejsou známé)
	var chests: Array = root.get_tree().get_nodes_in_group("chests").filter(func(c): return current_scene.is_ancestor_of(c))
	if is_chapter and not current_scene.start_items.is_empty():
		var supply = current_scene.find_child("SupplyChest", true, false)
		_ok(supply != null and _ids(supply.inventory) == Array(current_scene.start_items), "%s: startovní předměty leží v truhle u startu" % label)

	if is_chapter: # ruční uložení uprostřed kapitoly
		current_scene.teleport_to(current_scene.rooms[3].room_id)
		await _frames(2)

	# Checkpoint u starých levelů: přechod do jiné místnosti uloží po prvním bezpečném přistání
	if not is_chapter:
		var cam = player.camera
		var other: Vector2i = cam.valid_rooms.filter(func(r): return cam._group_of(r) != cam.current_group)[0]
		var target := Vector2(other) * Vector2(cam.ROOM_WIDTH, cam.ROOM_HEIGHT) + Vector2(100, 60)
		player.global_position = target
		cam._transition_to_room(other)
		player.spawn_point = target # jako první bezpečné přistání
		player.awaiting_room_spawn = false
		await process_frame
		await process_frame
		var d: Dictionary = SaveManager.load_game_data()
		_ok(Vector2(d.player.spawn_point_x, d.player.spawn_point_y) == player.spawn_point, "%s: vstup do další místnosti uloží checkpoint" % label)

	# Hráč si vezme vše z truhel, ručně uloží v pauze, odejde do menu a dá Pokračovat
	player.grid_inventory.clear()
	player.grid_inventory.add_item_auto(ItemData.create("mine_key"))
	for c in chests:
		c.inventory.clear()
	var spawn: Vector2 = player.spawn_point
	player.get_node("CanvasLayer/PauseMenu")._on_save_pressed()
	change_scene_to_file("res://main_menu.tscn")
	await _load("res://main_menu.tscn")
	current_scene._on_continue_pressed()
	await _load(path)
	_ok(current_scene.scene_file_path == path, "%s: Pokračovat načte stejnou scénu (%s)" % [label, current_scene.scene_file_path])
	var p2 = current_scene.get_node("Player")
	_ok(p2.global_position.distance_to(spawn) < 24.0, "%s: Pokračovat vrátí hráče na uložené místo %s (je %s)" % [label, spawn, p2.global_position])
	_ok(_ids(p2.grid_inventory) == ["mine_key"], "%s: batoh z uložené hry %s" % [label, _ids(p2.grid_inventory)])
	var refilled: Array = root.get_tree().get_nodes_in_group("chests").filter(func(c): return current_scene.is_ancestor_of(c) and not c.inventory.items.is_empty())
	_ok(refilled.is_empty(), "%s: vybrané truhly zůstanou po Pokračovat prázdné (%d plných)" % [label, refilled.size()])
