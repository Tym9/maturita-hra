extends Node2D

## Plynulé švy místností: místnosti mají 176 px na 180px obrazovku, takže mezi místnostmi různé výšky
## vzniká schod 4-12 px. Hráč ho přejde chůzí (player.STEP_HEIGHT) bez skoku; skutečný schod 16 px dál blokuje.
## Spuštění: godot --headless --path . res://test/test_room_seams.tscn

# [kapitola, start (svět, stojí na podlaze), směr, místnost za švem, rozdíl podlah]
const CASES := [
	["res://levels/c1/chapter1.tscn", Vector2(1240, -61), 1.0, "c1_a06", "+4 px"],
	["res://levels/c2/chapter2.tscn", Vector2(4120, -1893), 1.0, "c2_c02", "+8 px"],
	["res://levels/c3/chapter3.tscn", Vector2(5800, -2733), -1.0, "c3_d01", "+12 px"],
	["res://levels/c2/chapter2.tscn", Vector2(6360, -3137), 1.0, "c2_d05", "dřív 1 dlaždice, teď +4 px"],
]

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

## Drží směr `n` snímků; vrací, zda hráč mezitím nevyskočil (rychlost nahoru > 60 px/s).
func _walk(player, dir: float, n: int) -> bool:
	var action := "move_right" if dir > 0.0 else "move_left"
	var grounded := true
	Input.action_press(action)
	for i in n:
		await get_tree().physics_frame
		grounded = grounded and player.velocity.y > -60.0
	Input.action_release(action)
	return grounded

func _ready():
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	BeatClock.process_mode = Node.PROCESS_MODE_DISABLED # žádné páry ani poryvy během chůze
	for c in CASES:
		var chapter: Chapter = load(c[0]).instantiate()
		add_child(chapter)
		await _frames(2)
		var player = chapter.player
		var start: Room = chapter._room_at(c[1])
		chapter.teleport_to(start.room_id)
		player.global_position = c[1]
		player.spawn_point = c[1]
		await _frames(10)
		var smooth := await _walk(player, c[2], 60)
		await _frames(25) # přechodové zmrazení 0.3 s
		_ok(chapter.current.room_id == c[3] and smooth and not player.is_dying, "%s → %s: šev %s se přejde chůzí bez skoku (je v %s)" % [start.room_id, c[3], c[4], chapter.current.room_id])
		if c == CASES[0]:
			# Kontrola: celá dlaždice (16 px) na rovné podlaze dál blokuje
			var block := StaticBody2D.new()
			var shape := CollisionShape2D.new()
			shape.shape = RectangleShape2D.new()
			shape.shape.size = Vector2(16, 16)
			block.add_child(shape)
			var floor_y: float = player.global_position.y + 9.0
			block.global_position = Vector2(player.global_position.x + 40.0, floor_y - 8.0)
			chapter.add_child(block)
			await _frames(5)
			var x0: float = player.global_position.x
			await _walk(player, 1.0, 40)
			_ok(player.global_position.x < block.global_position.x - 8.0 and player.global_position.x > x0, "schod 16 px chůzí nepřejde (x %.0f, blok %.0f)" % [player.global_position.x, block.global_position.x])
		chapter.queue_free()
		await _frames(2)
	# Checkpoint místnosti cestou uložily hru: vrátit hráčovo skutečné uložení (user:// sdílí test i hra)
	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE).store_string(save_backup)
	print("FAILS: ", fails)
	get_tree().quit(1 if fails else 0)
