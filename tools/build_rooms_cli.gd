extends SceneTree

## Headless přestavba vybraných místností z ASCII: godot --headless --path . -s res://tools/build_rooms_cli.gd -- <LEVEL_cN.md> <out_dir> <room_id>...
## (out_dir = res://levels/cN/ přepíše scény; ruční úpravy v nich se ztratí)

func _init():
	_run.call_deferred()

func _run():
	await process_frame # autoloady (SaveManager, DialogueManager) musí existovat dřív, než se builder zkompiluje
	var args := OS.get_cmdline_user_args()
	var builder = load("res://tools/ascii_room_builder.gd")
	var doc: Dictionary = builder.parse_doc(FileAccess.get_file_as_string("res://" + args[0]))
	for id in args.slice(2):
		print(id, ": ", builder.build_room(id, doc.rooms[id], args[1].path_join(id + ".tscn"), true))
	quit()
