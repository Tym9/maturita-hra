extends Node2D

## Test nepřátel batch E (levels/test_chapter, sekce e): bezpečnostní dron (dohled paprskem,
## zamčení = telegraf, výpad, omráčení po nárazu, návrat), tlaková mina, jeskynní lezec.
## Dopad = odraz + dash, dotyk = zásah, take_hit, room_reset a obrácená gravitace.
## Spuštění: godot --headless --path . res://test/test_enemies.tscn

var fails: int = 0
var player = null

func _ok(cond: bool, msg: String):
	if cond:
		print("[PASS] ", msg)
	else:
		fails += 1
		printerr("[FAIL] ", msg)

func _frames(n: int):
	for i in n:
		await get_tree().physics_frame

func _place(room: Room, local: Vector2, gravity: float = 1.0):
	player.set_gravity_dir(gravity)
	player.global_position = room.global_position + local
	player.velocity = Vector2.ZERO

## Počká, až bude nepřítel ve stavu `st` (max `n` snímků).
func _wait_state(node, st: int, n: int) -> bool:
	for i in n:
		if node.state == st:
			return true
		await get_tree().physics_frame
	return node.state == st

## Počká na smrt hráče (max `n` snímků) a na následný room_reset.
func _wait_death(n: int) -> bool:
	for i in n:
		if player.is_dying:
			break
		await get_tree().physics_frame
	if not player.is_dying:
		return false
	await Global.room_reset
	return true

func _dist_to_rect(p: Vector2, r: Rect2) -> float:
	return p.distance_to(Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y)))

func _ready():
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	var chapter: Chapter = load("res://levels/test_chapter/test_chapter.tscn").instantiate()
	add_child(chapter)
	await _frames(3)
	player = chapter.player
	var e1: Room = chapter._find("tc_e01")
	var e2: Room = chapter._find("tc_e02")
	var e3: Room = chapter._find("tc_e03")

	# --- 1. Bezpečnostní dron ---
	chapter.teleport_to("tc_e01")
	var drone = e1.get_node("Drone")
	await _frames(5)
	_ok(drone.state == drone.State.PATROL, "Dron hlídkuje, dokud hráče nevidí")
	drone.sight_range = 400.0
	_place(e1, Vector2(80, 135))
	await _frames(5)
	_ok(drone.state == drone.State.PATROL, "Hráče za pilířem dron nevidí (paprsek)")
	drone.sight_range = 120.0
	_place(e1, Vector2(200, 135))
	_ok(await _wait_state(drone, drone.State.LOCK, 30), "Dron hráče uvidí a zamkne se")
	var lock_pos: Vector2 = drone.global_position
	await _frames(20)
	_ok(drone.state == drone.State.LOCK and drone.global_position.distance_to(lock_pos) < 1.0 and player.health == player.max_health, "Zamčení: dron 0.5 s stojí a míří (telegraf), ještě neútočí")
	await _wait_state(drone, drone.State.CHARGE, 30)
	_place(e1, Vector2(24, 135)) # uhnout - výpad skončí v podlaze
	_ok(await _wait_state(drone, drone.State.STUNNED, 60), "Po nárazu do podlahy je dron omráčený")
	var stun_frames := 0
	while drone.state == drone.State.STUNNED and stun_frames < 120:
		await get_tree().physics_frame
		stun_frames += 1
	_ok(stun_frames >= 50 and stun_frames <= 70, "Omráčení trvá ~1 s (%d snímků)" % stun_frames)
	_ok(await _wait_state(drone, drone.State.PATROL, 300), "Pak se dron vrátí na hlídku")
	player.invulnerable_timer = 0.0
	_place(e1, Vector2(200, 135))
	await _wait_state(drone, drone.State.CHARGE, 60)
	for i in 40:
		if player.health < player.max_health:
			break
		await get_tree().physics_frame
	_ok(player.health < player.max_health, "Výpad dronu hráče zraní")
	_ok(await _wait_state(drone, drone.State.STUNNED, 60), "Dron po výpadu narazí")
	player.can_dash = false
	player.global_position = drone.global_position + Vector2(0, -16)
	player.velocity = Vector2(0, 120)
	await _frames(3)
	_ok(drone.is_dead and player.velocity.y < -200.0 and player.can_dash, "Dopad na omráčený dron: odraz, obnovený dash, dron padá")
	player.die()
	await Global.room_reset
	var drone2 = e1.get_node("Drone")
	_ok(is_instance_valid(drone2) and not drone2.is_dead and drone2.state == drone2.State.PATROL, "room_reset vrátí dron na hlídku")
	player.can_dash = false
	player.set_gravity_dir(-1.0)
	player.global_position = drone2.global_position + Vector2(0, 16)
	player.velocity = Vector2(0, -120)
	await _frames(3)
	_ok(drone2.is_dead and player.velocity.y > 200.0 and player.can_dash, "S obrácenou gravitací jde dron zašlápnout zespodu")
	player.die()
	await Global.room_reset
	var drone3 = e1.get_node("Drone")
	drone3.take_hit(1, Vector2.RIGHT)
	_ok(drone3.is_dead, "take_hit dron sestřelí")

	# --- 2. Tlaková mina ---
	chapter.teleport_to("tc_e02")
	var mine = e2.get_node("Mine1")
	mine.respawn_time = 0.6
	await _frames(3)
	_ok(mine.state == PressureMine.State.IDLE, "Daleko od miny se nic neděje")
	player.can_dash = false
	_place(e2, Vector2(76, 135))
	await _frames(3)
	_ok(mine.state == PressureMine.State.INFLATE, "Hráč u miny: nafukuje se a bliká (telegraf)")
	await _frames(15)
	_ok(mine.state == PressureMine.State.INFLATE, "Ještě 0.25 s nepraskla")
	_ok(await _wait_state(mine, PressureMine.State.GONE, 30), "Po 0.5 s mina praskne")
	_ok(player.velocity.x < -100.0 and player.can_dash, "Výbuch odhodí hráče od miny a obnoví dash (v=%s)" % player.velocity)
	_ok(await _wait_state(mine, PressureMine.State.IDLE, 60), "Mina se po čase znovu složí")
	var mine2 = e2.get_node("Mine2")
	player.can_dash = false
	player.global_position = e2.global_position + Vector2(168, 88)
	player.velocity = Vector2(0, 100)
	await _frames(3)
	_ok(mine2.state == PressureMine.State.GONE and player.velocity.y < -200.0 and player.can_dash, "Dopad na minu ji odpálí a vymrští hráče nahoru")
	_place(e2, Vector2(24, 135))
	var mine3 = e2.get_node("Mine3")
	mine3.take_hit(1, Vector2.RIGHT)
	_ok(mine3.state == PressureMine.State.GONE, "Zásah útokem (take_hit) minu odpálí")
	player.can_dash = false
	player.set_gravity_dir(-1.0)
	player.global_position = e2.global_position + Vector2(104, 136)
	player.velocity = Vector2(0, -100)
	await _frames(3)
	_ok(mine.state == PressureMine.State.GONE and player.velocity.y > 200.0, "S obrácenou gravitací mina vymrští hráče od sebe (dolů)")
	_place(e2, Vector2(24, 135))

	# --- 3. Jeskynní lezec ---
	chapter.teleport_to("tc_e03")
	var crawler = e3.get_node("CrawlerPillar")
	crawler.speed = 90.0
	var pillar := Rect2(e3.global_position + Vector2(96, 80), Vector2(48, 32))
	var seen := {}
	var attached := true
	for i in 240:
		await get_tree().physics_frame
		seen[crawler.up.round()] = true
		var d := _dist_to_rect(crawler.global_position, pillar)
		if d < 2.0 or d > 7.0:
			attached = false
	_ok(seen.size() == 4, "Lezec obleze pilíř dokola (vršek, stěna, spodek, stěna)")
	_ok(attached, "Lezec se celou dobu drží povrchu")
	var ceiling = e3.get_node("CrawlerCeiling")
	ceiling.speed = 0.0
	player.invulnerable_timer = 0.0
	player.global_position = ceiling.global_position + Vector2(0, 10)
	player.velocity = Vector2(0, -50)
	await _frames(2)
	_ok(player.health < player.max_health and ceiling.state == CaveCrawler.State.CRAWL, "Lezce na stropě nejde zespodu zašlápnout - zraní")
	player.invulnerable_timer = 0.0
	player.can_dash = false
	player.set_gravity_dir(-1.0)
	player.global_position = ceiling.global_position + Vector2(0, 10)
	player.velocity = Vector2(0, -120)
	await _frames(2)
	_ok(ceiling.state == CaveCrawler.State.DEAD and player.velocity.y > 200.0 and player.can_dash, "S obrácenou gravitací hráč stropního lezce zašlápne")
	_place(e3, Vector2(24, 135))
	for i in 240:
		if crawler.up == Vector2.UP:
			break
		await get_tree().physics_frame
	crawler.speed = 0.0
	player.can_dash = false
	player.global_position = crawler.global_position + Vector2(0, -12)
	player.velocity = Vector2(0, 120)
	await _frames(2)
	_ok(crawler.state == CaveCrawler.State.DEAD and player.velocity.y < -200.0, "Lezce nahoře jde zašlápnout")
	player.die()
	await Global.room_reset
	var crawler2 = e3.get_node("CrawlerPillar")
	_ok(crawler2.state == CaveCrawler.State.CRAWL and e3.get_node("CrawlerCeiling").state == CaveCrawler.State.CRAWL, "room_reset lezce obnoví")
	crawler2.take_hit(1, Vector2.RIGHT)
	_ok(crawler2.state == CaveCrawler.State.DEAD, "take_hit lezce zabije")

	# --- 4. Anomální ozvěna ---
	chapter.teleport_to("tc_e04")
	var e4: Room = chapter._find("tc_e04")
	var echo = e4.get_node("Echo")
	await _frames(3)
	_ok(echo.state == AnomalyEcho.State.WAITING and echo.armed, "Ozvěna čeká, dokud je hráč ve startovní oblasti")
	var positions: Array[Vector2] = []
	var telegraph_seen := false
	for i in 150:
		var pos := e4.global_position + Vector2(80.0 + i * 1.5, 135.0)
		player.global_position = pos
		player.velocity = Vector2.ZERO
		positions.append(pos)
		await get_tree().physics_frame
		if i == 30:
			_ok(echo.state == AnomalyEcho.State.RECORDING and echo.alpha == 0.0, "0.5 s po odchodu ze startu ozvěna ještě není vidět")
		if i == 75:
			telegraph_seen = echo.state == AnomalyEcho.State.RECORDING and echo.alpha > 0.0 and echo.alpha < 1.0
	_ok(telegraph_seen, "Posledních 0.5 s před startem se stín zhmotňuje (telegraf)")
	_ok(echo.state == AnomalyEcho.State.CHASING and echo.shadow_pos.distance_to(positions[59]) < 0.01, "Ozvěna přesně opakuje cestu hráče o 1.5 s (90 snímků) později")
	_ok(await _wait_death(150), "Kdo zastaví, toho ozvěna dožene a zabije")
	var echo2 = e4.get_node("Echo")
	_ok(echo2 != echo and echo2.state == AnomalyEcho.State.WAITING, "room_reset vrátí ozvěnu do čekání")
	await _frames(3)
	for i in 100:
		player.set_gravity_dir(-1.0)
		player.global_position = e4.global_position + Vector2(80.0 + i * 1.5, 30.0)
		player.velocity = Vector2.ZERO
		await get_tree().physics_frame
	_ok(echo2.state == AnomalyEcho.State.CHASING and echo2.shadow_flip.x < 0.0, "Ozvěna opakuje i pohyb s obrácenou gravitací")
	_ok(await _wait_death(150), "...a zabije i hráče na stropě")
	var echo3 = e4.get_node("Echo")
	echo3.take_hit(5, Vector2.RIGHT)
	_ok(echo3.state == AnomalyEcho.State.WAITING, "Útoky ozvěnou projdou (take_hit nic nedělá)")
	await _frames(3)
	for i in 100:
		player.global_position = e4.global_position + Vector2(80.0 + i * 6.0, 135.0)
		player.velocity = Vector2.ZERO
		await get_tree().physics_frame
	_ok(await _wait_state(echo3, AnomalyEcho.State.DONE, 150), "Když cesta opustí místnost, ozvěna se rozplyne")

	# --- 5. Mechanická stráž ---
	chapter.teleport_to("tc_e05")
	var e5: Room = chapter._find("tc_e05")
	player.die() # čistá místnost: nepřátelé ze sousední místnosti mohli hráče mezitím zranit
	await Global.room_reset
	var guard = e5.get_node("Guard")
	_place(e5, Vector2(232, 55)) # na římse, mimo dosah stráže
	_ok(await _wait_state(guard, guard.State.TURN, 300), "Stráž dojde ke zdi")
	var turn_frames := 0
	while guard.state == guard.State.TURN and turn_frames < 60:
		await get_tree().physics_frame
		turn_frames += 1
	_ok(turn_frames >= 20 and turn_frames <= 28 and guard.direction == 1, "Před otočkou ~0.4 s natahuje klíček (telegraf, %d snímků), pak se otočí" % turn_frames)
	player.can_dash = false
	player.global_position = guard.global_position + Vector2(0, -10)
	player.velocity = Vector2(0, 120)
	await _frames(2)
	_ok(guard.is_dead and player.velocity.y < -200.0 and player.can_dash, "Dopad na stráž: odraz a obnovený dash")
	player.die()
	await Global.room_reset
	var guard2 = e5.get_node("Guard")
	player.invulnerable_timer = 0.0
	player.global_position = guard2.global_position + Vector2(10, 0)
	player.velocity = Vector2.ZERO
	await _frames(2)
	_ok(player.health < player.max_health, "Boční dotyk se stráží zraní")
	guard2.take_hit(1, Vector2.RIGHT)
	_ok(guard2.health == guard2.max_health - 1, "take_hit stráži ubere život")

	# --- 6. Parní střelec ---
	chapter.teleport_to("tc_e06")
	var e6: Room = chapter._find("tc_e06")
	player.die()
	await Global.room_reset
	var turret = e6.get_node("Turret")
	await _frames(20)
	_place(e6, Vector2(200, 135))
	await _frames(5)
	_ok(turret.current_state == turret.State.PATROL, "Za plošinou střelec hráče nevidí (nestřílí skrz zdi)")
	for i in 24:
		_place(e6, Vector2(120, 80))
		await get_tree().physics_frame
	_ok(turret.current_state == turret.State.AIMING and get_tree().get_nodes_in_group("enemy_projectiles").is_empty(), "Střelec míří laserem (telegraf) a ještě nestřílí")
	var bullet = null
	for i in 40:
		_place(e6, Vector2(120, 80))
		await get_tree().physics_frame
		var shots := get_tree().get_nodes_in_group("enemy_projectiles")
		if not shots.is_empty():
			bullet = shots[0]
			break
	_ok(bullet != null, "Pak vystřelí pomalý projektil")
	player.can_dash = false
	if bullet:
		bullet.take_hit(1, Vector2.RIGHT)
	_ok(player.can_dash, "Seknutí projektilu obnoví dash")
	player.can_dash = false
	player.global_position = turret.global_position + Vector2(0, -11)
	player.velocity = Vector2(0, 120)
	await _frames(2)
	_ok(turret.is_dead and player.velocity.y < -200.0 and player.can_dash, "Dopad na střelce: odraz a obnovený dash")
	player.die()
	await Global.room_reset
	var turret2 = e6.get_node("Turret")
	turret2.take_hit(1, Vector2.RIGHT)
	_ok(turret2.health == turret2.max_health - 1, "take_hit střelci ubere život")

	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		var f := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		f.store_string(save_backup)
		f.close()
	print("=== TEST NEPŘÁTEL BATCH E: %s ===" % ("100% OK" if fails == 0 else "%d CHYB" % fails))
	get_tree().quit(1 if fails else 0)
