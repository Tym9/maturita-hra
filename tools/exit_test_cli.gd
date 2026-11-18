extends SceneTree
var _save_backup := FileAccess.get_file_as_string("user://save.json")
var deaths := 0
func _finalize():
	if not _save_backup.is_empty():
		FileAccess.open("user://save.json", FileAccess.WRITE).store_string(_save_backup)
func _init():
	_run.call_deferred()
func wait(t: float):
	var n := int(t * 60)
	for i in n:
		await physics_frame
func _run():
	var args := OS.get_cmdline_user_args()
	change_scene_to_file(args[0])
	for i in 10:
		await process_frame
	var ch = current_scene
	var player = ch.get_node("Player")
	player.player_died.connect(func(): deaths += 1)
	for spec in args.slice(1):
		var p := spec.split(":")
		var ab := p[0].split(">")
		if p.size() < 5:
			print("SKIP ", spec); continue
		if root.get_node("DialogueManager").is_active: root.get_node("DialogueManager").close_dialogue()
		ch.teleport_to(ab[0])
		await wait(0.3)
		deaths = 0
		player.health = 3
		player.global_position = Vector2(float(p[2]), float(p[3]))
		player.velocity = Vector2.ZERO
		if p[1] == "R":
			Input.action_press("move_right")
		var t := 0.0
		while t < 3.0 and ch.current.room_id != ab[1] and deaths == 0:
			if root.get_node("DialogueManager").is_active: root.get_node("DialogueManager").close_dialogue()
			await wait(0.1); t += 0.1
		Input.action_release("move_right")
		var entered: bool = ch.current.room_id == ab[1]
		await wait(2.5)
		print("%s %s  entered=%s deaths=%d hp=%d floor=%s room_now=%s pos=%s spawn=%s" % ["OK  " if entered and deaths == 0 and player.is_on_floor() else "FAIL", spec, entered, deaths, player.health, player.is_on_floor(), ch.current.room_id, player.global_position.round(), player.spawn_point.round()])
	quit()
