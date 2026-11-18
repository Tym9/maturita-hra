extends Node2D

## Boss Správce reaktoru: pancíř mimo okno, salva + úder pístem, odkryté jádro s limitem zranění,
## fáze 2 s obracením gravitace, návrat na začátek fáze po smrti hráče, porážka.
## Spuštění: godot --headless --path . res://test/test_boss.tscn

var fails: int = 0
var defeated: bool = false

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

## Čeká na stav bosse (nejdéle `limit` snímků); vrací, zda nastal.
func _wait_state(w: ReactorWarden, state: int, limit: int = 1500) -> bool:
	for i in limit:
		if w.state == state:
			return true
		await get_tree().physics_frame
	return false

func _ready():
	var room: Node = load("res://boss_room.tscn").instantiate()
	add_child(room)
	await get_tree().physics_frame
	var player = room.get_node("Player")
	var w: ReactorWarden = room.get_node("c7_boss/Warden")
	w.end_scene = "" # test nemění scénu
	w.defeated.connect(func(): defeated = true)
	player.invulnerable_timer = 1e9 # hráč jen stojí; souboj řídí test

	w.take_hit(2)
	_ok(w.hp == ReactorWarden.MAX_HP, "pancíř: zásah mimo okno nic neubere")

	var saw_volley := false
	for i in 1500:
		saw_volley = saw_volley or (w.state == ReactorWarden.State.VOLLEY and get_tree().get_nodes_in_group("enemy_projectiles").size() > 0)
		if w.state == ReactorWarden.State.EXPOSED:
			break
		await get_tree().physics_frame
	_ok(saw_volley, "útok 1: salva vystřelila střely")
	_ok(w.state == ReactorWarden.State.EXPOSED, "útok 2: po úderu pístem je jádro odkryté")
	_ok(get_tree().get_nodes_in_group("enemy_projectiles").size() >= 2, "úder vyslal rázovou vlnu (2 střely)")
	_ok(absf(w.position.y - (160.0 - ReactorWarden.FOOT)) < 1.0 or absf(w.position.y - (96.0 - ReactorWarden.FOOT)) < 1.0, "píst dosedl na podlahu nebo lávku (y=%.1f)" % w.position.y)
	w.take_hit(2)
	w.take_hit(2)
	_ok(w.hp == 12 and w.state == ReactorWarden.State.RISE, "okno: 4 zranění a boss se zvedá")
	w.take_hit(2)
	_ok(w.hp == 12, "po zavření okna je zase pancéřovaný")

	_ok(await _wait_state(w, ReactorWarden.State.EXPOSED), "druhé okno")
	w.take_hit(2)
	w.take_hit(2)
	_ok(w.phase == 2 and w.hp == ReactorWarden.PHASE2_HP, "půlka životů = fáze 2")

	var flipped := false
	for i in 1500:
		if player.gravity_dir < 0.0:
			flipped = true
			break
		await get_tree().physics_frame
	_ok(flipped and w.grav < 0.0, "fáze 2: gravitace sálu se obrátila")
	_ok(await _wait_state(w, ReactorWarden.State.EXPOSED), "fáze 2: úder ke stropu")
	_ok(absf(w.position.y - (32.0 + ReactorWarden.FOOT)) < 1.0 or absf(w.position.y - (112.0 + ReactorWarden.FOOT)) < 1.0, "píst dosedl na strop nebo spodek lávky (y=%.1f)" % w.position.y)
	w.take_hit(2)

	player.respawn() # smrt hráče
	_ok(w.phase == 2 and w.hp == ReactorWarden.PHASE2_HP and w.grav > 0.0 and player.gravity_dir > 0.0, "po smrti: začátek fáze 2, normální gravitace")
	_ok(get_tree().get_nodes_in_group("enemy_projectiles").all(func(b): return b.is_queued_for_deletion()), "po smrti: střely zmizely")
	player.invulnerable_timer = 1e9

	for n in 2:
		_ok(await _wait_state(w, ReactorWarden.State.EXPOSED, 2500), "fáze 2: okno %d" % (n + 1))
		w.take_hit(2)
		w.take_hit(2)
	_ok(w.state == ReactorWarden.State.DEAD and w.hp == 0, "boss poražen")
	for i in 200:
		await get_tree().physics_frame
	_ok(defeated and player.gravity_dir > 0.0, "signál defeated, gravitace zpět dolů")

	print("[DONE] test_boss: %d selhání" % fails)
	get_tree().quit(1 if fails > 0 else 0)
