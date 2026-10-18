extends Node2D

## Test systému místností (levels/test_chapter): kamera, přechod se zmrazením a zachovanou rychlostí,
## aktivace jen sousedů, smrt mimo místnosti + room_reset, checkpoint save, signály a ladicí teleport.
## Spuštění: godot --headless --path . res://test/test_chapter_rooms.tscn

var fails: int = 0
var entered: Array[String] = []
var exited: Array[String] = []

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

func _frames(n: int):
	for i in n:
		await get_tree().physics_frame

func _ready():
	# Test projde checkpointy a zapíše save - skutečný save hráče na konci vrátíme
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	Global.room_entered.connect(func(id): entered.append(id))
	Global.room_exited.connect(func(id): exited.append(id))
	var chapter: Chapter = load("res://levels/test_chapter/test_chapter.tscn").instantiate()
	add_child(chapter)
	await _frames(3)
	var player = chapter.player
	var cam = player.camera
	var a1: Room = chapter._find("tc_a01")
	var a2: Room = chapter._find("tc_a02")
	var a3: Room = chapter._find("tc_a03")

	# 1. Start: statická kamera v 1-obrazovkové místnosti, vzdálené místnosti vypnuté
	_ok(chapter.current == a1 and entered == ["tc_a01"], "Start v tc_a01, room_entered(tc_a01)")
	_ok(cam.global_position == a1.bounds().get_center(), "Kamera stojí ve středu 1-obrazovkové místnosti")
	_ok(a2.process_mode == PROCESS_MODE_INHERIT and a3.process_mode == PROCESS_MODE_DISABLED, "Zpracovává se jen aktuální místnost a sousedé")

	# 2. Přechod doprava: zmrazení, nejbližší RespawnPoint, zachovaná rychlost
	Input.action_press("move_right")
	player.global_position = Vector2(322, 135)
	player.velocity = Vector2(150, 0)
	await _frames(2)
	_ok(get_tree().paused and chapter.current == a2, "Přechod do tc_a02 zmrazí hru")
	_ok(player.spawn_point == a2.get_node("RespawnPoint1").global_position, "Respawn = RespawnPoint nejblíž vstupu")
	_ok(exited == ["tc_a01"] and entered == ["tc_a01", "tc_a02"], "Signály room_exited/room_entered")
	await get_tree().create_timer(0.2).timeout
	_ok(get_tree().paused and player.velocity == Vector2(150, 0), "Během zmrazení se rychlost hráče nemění")
	await get_tree().create_timer(0.2).timeout
	Input.action_release("move_right")
	_ok(not get_tree().paused and player.velocity.x == 150.0 and player.global_position.x > 322.0, "Po ~0.3 s hra pokračuje se zachovanou rychlostí")
	_ok(a1.process_mode == PROCESS_MODE_INHERIT and a3.process_mode == PROCESS_MODE_INHERIT, "Sousedé tc_a02 jsou aktivní")

	# 3. Scrollující místnost: kamera jede za hráčem, ale neopustí hranice
	player.global_position = Vector2(640, 135)
	await get_tree().create_timer(0.5).timeout
	_ok(absf(cam.global_position.x - player.global_position.x) < 2.0 and cam.global_position.y == 90.0, "Kamera sleduje hráče ve 2-obrazovkové místnosti")
	player.global_position = Vector2(900, 135)
	await get_tree().create_timer(0.5).timeout
	_ok(absf(cam.global_position.x - 800.0) < 1.0, "Kamera se zastaví na pravém okraji místnosti (nesahá do sousedů)")

	# 4. Pád do jámy (pod ní žádná místnost) = smrt; room_reset vrátí stráž a nesebraný krystal
	var old_guard = a2.get_node("Guard")
	old_guard.queue_free()
	var crystal = a2.get_node("Crystal")
	player.global_position = Vector2(552, 170)
	player.velocity = Vector2.ZERO
	crystal.start_follow(player)
	for i in 60:
		if player.is_dying:
			break
		await get_tree().physics_frame
	_ok(player.is_dying, "Opuštění místnosti tam, kde žádná nepokračuje, zabije hráče")
	var t0: int = Time.get_ticks_msec()
	await Global.room_reset
	var dt: int = Time.get_ticks_msec() - t0
	_ok(dt < 600 and player.global_position == player.spawn_point, "Respawn do 0.6 s (%d ms) na bodu respawnu" % dt)
	var new_guard = a2.get_node_or_null("Guard")
	_ok(new_guard != null and not is_instance_valid(old_guard), "room_reset obnovil zabitou stráž")
	_ok(crystal.follow_player == null and not crystal.is_collected, "room_reset pustil nesebraný krystal")
	await get_tree().create_timer(0.7).timeout
	_ok(crystal.position.distance_to(crystal.home_position) <= 3.5, "Krystal odplul zpět na své místo (levituje ±3 px)")
	_ok(player.death_fade.color.a == 0.0 and not player.is_dying, "Zatmění po smrti zmizí")

	# 5. Výskok do místnosti nad hráčem: odraz proti gravitaci + checkpoint uloží kapitolu, místnost a respawn
	player.global_position = Vector2(880, -2)
	player.velocity = Vector2(0, -150)
	await _frames(2)
	_ok(chapter.current == a3 and player.velocity.y <= player.JUMP_VELOCITY, "Vstup do tc_a03 zespodu dá odraz nahoru")
	var saved: Dictionary = SaveManager.load_game_data()
	_ok(saved.get("room_id") == "tc_a03" and saved.get("current_scene") == chapter.scene_file_path, "Checkpoint uložil kapitolu a místnost")
	_ok(Vector2(saved.player.spawn_point_x, saved.player.spawn_point_y) == a3.get_node("RespawnPoint1").global_position, "Checkpoint uložil bod respawnu")
	await get_tree().create_timer(0.4).timeout

	# 6. Ladění: F1 hranice, F2 teleport na další místnost, teleport podle id
	var f1 := InputEventKey.new()
	f1.keycode = KEY_F1
	f1.pressed = true
	chapter._unhandled_input(f1)
	_ok(chapter.debug_overlay.visible, "F1 zapne zobrazení hranic a id místností")
	_ok(chapter.teleport_to("tc_a01") and chapter.current == a1 and player.global_position == a1.get_node("RespawnPoint1").global_position, "Teleport na tc_a01 podle id")
	_ok(cam.global_position == a1.bounds().get_center(), "Kamera po teleportu hned v cílové místnosti")
	var f2 := InputEventKey.new()
	f2.keycode = KEY_F2
	f2.pressed = true
	chapter._unhandled_input(f2)
	_ok(chapter.current == a2, "F2 teleportuje na další místnost")

	# 7. Continue po ukončení hry: save z checkpointu postaví hráče do uložené místnosti
	chapter.queue_free()
	await get_tree().process_frame
	SaveManager.pending_load = true
	var resumed: Chapter = load(saved.current_scene).instantiate()
	add_child(resumed)
	await _frames(2)
	_ok(resumed.current.room_id == "tc_a03" and resumed.player.global_position == resumed._find("tc_a03").get_node("RespawnPoint1").global_position, "Continue: hráč začne v uložené checkpoint místnosti")

	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		var f := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		f.store_string(save_backup)
		f.close()
	print("=== TEST MÍSTNOSTÍ KAPITOLY: %s ===" % ("100% OK" if fails == 0 else "%d CHYB" % fails))
	get_tree().quit(1 if fails else 0)
