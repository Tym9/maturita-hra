extends SceneTree

## Snímky obrazovky pro kontrolu: godot --path . --windowed --resolution 960x540 -s res://tools/shots_cli.gd -- <out_dir> <scene> <cíl>...
## cíl = "x,y" (pozice hráče ve scéně), id místnosti kapitoly, nebo "hint:<id>" (hráč zamrzne pod otvorem s UpExitHint). Vrací user://save.json (příchod do kapitoly ukládá).

var _save_backup := FileAccess.get_file_as_string("user://save.json")

func _finalize():
	if _save_backup.is_empty():
		DirAccess.remove_absolute("user://save.json")
	else:
		FileAccess.open("user://save.json", FileAccess.WRITE).store_string(_save_backup)

func _init():
	_run.call_deferred()

func _run():
	var args := OS.get_cmdline_user_args()
	change_scene_to_file(args[1])
	for i in 10:
		await process_frame
	var player = current_scene.get_node("Player")
	for target in args.slice(2):
		if "," in target:
			player.global_position = Vector2(float(target.get_slice(",", 0)), float(target.get_slice(",", 1)))
			player.spawn_point = player.global_position
			player.camera.reset_to_spawn()
		elif target.begins_with("hint:"):
			var room_id := target.trim_prefix("hint:")
			current_scene.teleport_to(room_id)
			var hint: Node2D = current_scene._find(room_id).find_children("*", "UpExitHint", false, false)[0]
			player.set_physics_process(false)
			player.global_position = hint.global_position + Vector2(hint.width / 2.0, 70.0)
		else:
			current_scene.teleport_to(target)
		player.velocity = Vector2.ZERO
		for i in 60:
			await process_frame
		var img := root.get_texture().get_image()
		img.save_png(args[0].path_join("%s_%s.png" % [args[1].get_file().get_basename(), target.replace(",", "_").replace(":", "_")]))
	quit()
