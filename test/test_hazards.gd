extends Node2D

## Test hazardů sekce b testovací kapitoly: pístový drtič, pila na kolejnici, tesla oblouk, padající
## kámen. Fáze se nastavují přes BeatClock.time; ověřuje telegraf, zabití, synchronizaci, reset,
## menší hitbox a obrácenou gravitaci.
## Spuštění: godot --headless --path . res://test/test_hazards.tscn

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

## Nastaví hodiny tak, aby měl hazard fázi `p`.
func _set_phase(hazard, p: float):
	BeatClock.time = p - hazard.offset

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

func _place(room: Room, local: Vector2, gravity: float = 1.0):
	player.set_gravity_dir(gravity)
	player.global_position = room.global_position + local
	player.velocity = Vector2.ZERO

func _ready():
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	var chapter: Chapter = load("res://levels/test_chapter/test_chapter.tscn").instantiate()
	add_child(chapter)
	await _frames(3)
	player = chapter.player
	var b1: Room = chapter._find("tc_b01")
	var b2: Room = chapter._find("tc_b02")
	var b3: Room = chapter._find("tc_b03")
	var b4: Room = chapter._find("tc_b04")

	# --- 1. Pístový drtič ---
	chapter.teleport_to("tc_b01")
	var crusher = b1.get_node("Crusher1")
	var crusher2 = b1.get_node("Crusher2")
	_set_phase(crusher, 1.8) # klid
	_place(b1, Vector2(96, 135))
	await _frames(3)
	_ok(not crusher.dangerous and not crusher.warning and not player.is_dying, "Drtič v klidu je bezpečný")
	_set_phase(crusher, 0.1)
	await _frames(2)
	_ok(crusher.warning and not crusher.dangerous and not player.is_dying, "Drtič 0.4 s předem varuje (třes, kontrolka) a ještě nezabíjí")
	_ok(await _wait_death(40), "Úder drtiče zabije hráče pod ním")
	_ok(BeatClock.time < 0.2, "room_reset vrátil sdílené hodiny na nulu")
	# Regrese: Crusher2 (posun 0.66) je hned po resetu hodin nebezpečný - respawnutý hráč nesmí znovu umřít
	_place(b1, Vector2(160, 135))
	_ok(await _wait_death(80), "Druhý drtič zabije hráče pod sebou")
	await _frames(10)
	_ok(not player.is_dying, "Po respawnu hráče nezabije drtič podle jeho staré pozice")
	crusher2.offset = crusher.offset
	await _frames(2)
	_ok(crusher.extension == crusher2.extension, "Drtiče se stejným posunem jdou synchronně (sdílené hodiny)")
	crusher2.offset = 0.66
	_ok(crusher.kill_col.shape.size.x == crusher.width * 16.0 - 6.0, "Hitbox drtiče je o 3 px z každé strany menší než grafika")
	_set_phase(crusher, 1.8)
	_place(b1, Vector2(96, 100), -1.0)
	await _frames(20)
	_ok(player.is_on_floor() and not player.is_dying, "Hráč s obrácenou gravitací stojí pod tělesem drtiče")
	_set_phase(crusher, 0.3)
	_ok(await _wait_death(40), "Drtič zabíjí i při obrácené gravitaci")

	# --- 2. Pila na kolejnici ---
	chapter.teleport_to("tc_b02")
	var saw = b2.get_node("SawLow")
	_set_phase(saw, 0.4) # polovina cesty tam (cesta 0.8 s)
	await _frames(2) # await se probudí před _physics_process snímku - až druhý snímek má novou fázi
	_ok(absf(saw.blade.position.x - 64.0) < 8.0 and not saw.revving, "Pila jede po kolejnici podle hodin (x=%.1f)" % saw.blade.position.x)
	_set_phase(saw, 0.9)
	await _frames(2)
	_ok(saw.revving and saw.blade.position.x == 128.0, "Na konci kolejnice pila 0.4 s stojí a roztáčí se (telegraf)")
	_place(b2, Vector2(48 + 128, 134))
	_ok(await _wait_death(10), "Dotyk pily zabije")
	var vertical = b2.get_node("SawVertical")
	_set_phase(vertical, 1.0)
	await _frames(2)
	_place(b2, vertical.position + vertical.blade.position, -1.0)
	_ok(await _wait_death(10), "Pila zabíjí i při obrácené gravitaci")
	var square := CogSaw.new()
	square.rail = PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)])
	square.loop = true
	_ok(square.point_at(0.5) == Vector2(10, 10) and square.point_at(0.875) == Vector2(0, 5), "Pila v režimu loop objíždí kolejnici dokola")
	square.free()
	_ok(saw.blade.get_child(0).shape.radius == saw.radius - 3.0, "Hitbox pily je o 3 px menší než grafika")

	# --- 3. Tesla oblouk ---
	chapter.teleport_to("tc_b03")
	var arc = b3.get_node("Tesla1")
	var arc2 = b3.get_node("Tesla2")
	_set_phase(arc, 1.6) # vypnuto
	_place(b3, Vector2(112, 135))
	await _frames(3)
	_ok(not arc.dangerous and not player.is_dying, "Vypnutý oblouk je bezpečný")
	_place(b3, Vector2(24, 135)) # mimo výboje
	_set_phase(arc, 0.8)
	await _frames(2)
	_ok(arc.dangerous != arc2.dangerous, "Oblouky v místnosti se střídají (sdílené hodiny)")
	_set_phase(arc, 1.6)
	await _frames(2)
	_set_phase(arc, 0.1)
	_place(b3, Vector2(112, 135))
	await _frames(2)
	_ok(arc.warning and not arc.dangerous and not player.is_dying, "Cívky 0.4 s předem jiskří a ještě nezabíjí (fáze %.2f, varuje %s, zabíjí %s, umírá %s)" % [BeatClock.phase(arc.period, arc.offset), arc.warning, arc.dangerous, player.is_dying])
	_ok(await _wait_death(40), "Zapnutý výboj zabije")
	_set_phase(arc, 1.6)
	_place(b3, Vector2(112, 30), -1.0)
	await _frames(10)
	_set_phase(arc, 0.3)
	_ok(await _wait_death(30), "Výboj zabíjí i hráče chodícího po stropě")
	_ok(arc.kill_area.get_child(0).shape.size.y == 4.0, "Hitbox výboje (4 px) je užší než kreslený výboj")

	# --- 4. Padající kámen ---
	chapter.teleport_to("tc_b04")
	var rock = b4.get_node("Rock1")
	_place(b4, Vector2(50, 135))
	await _frames(5)
	_ok(rock.state == FallingRock.State.IDLE, "Mimo sloupec pod kamenem se nic neděje")
	_place(b4, Vector2(88, 135))
	await _frames(3)
	_ok(rock.state == FallingRock.State.SHAKING and not player.is_dying, "Hráč pod kamenem: 0.4 s třesení a prach (telegraf)")
	_ok(await _wait_death(90), "Padající kámen zabije hráče pod sebou")
	var rebuilt = b4.get_node_or_null("Rock1")
	_ok(rebuilt != null and rebuilt != rock and rebuilt.state == FallingRock.State.IDLE, "room_reset vrátil kámen do stropu")
	var rock2 = b4.get_node("Rock2")
	_place(b4, Vector2(136, 135))
	for i in 40:
		if rock2.state == FallingRock.State.FALLING:
			break
		await get_tree().physics_frame
	_place(b4, Vector2(24, 135))
	for i in 90:
		if rock2.state == FallingRock.State.GONE:
			break
		await get_tree().physics_frame
	_ok(rock2.state == FallingRock.State.GONE and not player.is_dying, "Kámen se o podlahu rozbije")
	var rock3 = b4.get_node("Rock3")
	_place(b4, Vector2(184, 100), -1.0)
	await _frames(3)
	_ok(rock3.state == FallingRock.State.SHAKING, "Kámen spustí i hráč s obrácenou gravitací")

	# --- 5. Roztavená struska (stoupající) ---
	chapter.teleport_to("tc_b05")
	var b5: Room = chapter._find("tc_b05")
	var slag = b5.get_node("Slag")
	await _frames(2)
	_ok(slag.kill_col.shape.size.x == slag.size.x - 6.0, "Hitbox strusky je o 3 px z každé strany užší než grafika")
	for i in 120:
		if slag.warning:
			break
		await get_tree().physics_frame
	_ok(slag.warning and slag.risen == 0.0, "Struska 0.4 s před stoupáním víc bublá (telegraf), ještě nestoupá")
	for i in 60:
		if slag.risen > 0.0:
			break
		await get_tree().physics_frame
	_ok(slag.risen > 0.0, "Po zpoždění hladina strusky stoupá")
	_place(b5, Vector2(160, 172))
	_ok(await _wait_death(10), "Dotyk strusky zabije")
	_ok(slag.risen == 0.0 and slag.timer < 0.1, "room_reset vrátil hladinu strusky dolů")
	_place(b5, Vector2(160, 172), -1.0)
	_ok(await _wait_death(10), "Struska zabíjí i při obrácené gravitaci")

	# --- 6. Nestabilní krystalové bodce ---
	chapter.teleport_to("tc_b06")
	var b6: Room = chapter._find("tc_b06")
	var cspikes = b6.get_node("Spikes1")
	_place(b6, Vector2(40, 135))
	await _frames(5)
	_ok(cspikes.state == CrystalSpikes.State.IDLE, "Daleko od bodců se nic neděje")
	_place(b6, Vector2(96, 135))
	await _frames(3)
	_ok(cspikes.state == CrystalSpikes.State.WARN and not player.is_dying, "Hráč u bodců: prasklina 0.4 s žhne (telegraf), ještě nezabíjí")
	_ok(await _wait_death(40), "Vyražené bodce zabijí")
	var rebuilt_spikes = b6.get_node("Spikes1")
	_ok(rebuilt_spikes != cspikes and rebuilt_spikes.state == CrystalSpikes.State.IDLE, "room_reset vrátil bodce do země")
	_place(b6, Vector2(70, 135)) # vylákat: v pásu spouště, ale vedle bodců
	for i in 60:
		if rebuilt_spikes.state == CrystalSpikes.State.OUT:
			break
		await get_tree().physics_frame
	await _frames(10)
	_ok(rebuilt_spikes.extension == 1.0 and not player.is_dying, "Vylákané bodce hráče vedle nezasáhnou")
	_ok(rebuilt_spikes.kill_col.shape.size.x == 2 * 16.0 - 6.0, "Hitbox bodců je o 3 px z každé strany užší")
	for i in 200:
		if rebuilt_spikes.state == CrystalSpikes.State.COOLDOWN:
			break
		await get_tree().physics_frame
	_place(b6, Vector2(96, 135))
	await _frames(10)
	_ok(rebuilt_spikes.state == CrystalSpikes.State.COOLDOWN and not player.is_dying, "Po zatažení je chvíle na průchod")
	_place(b6, Vector2(24, 135))
	_place(b6, Vector2(256, 30), -1.0)
	await _frames(3)
	_ok(b6.get_node("Spikes3").state == CrystalSpikes.State.WARN, "Stropní bodce spustí hráč s obrácenou gravitací")
	_ok(await _wait_death(40), "Stropní bodce zabijí hráče na stropě")

	# --- 7. Parní tryska na sdílených hodinách ---
	chapter.teleport_to("tc_b07")
	var b7: Room = chapter._find("tc_b07")
	var vent1 = b7.get_node("Vent1")
	var vent2 = b7.get_node("Vent2")
	_set_phase(vent1, 0.5)
	_place(b7, Vector2(96, 135))
	await _frames(3)
	_ok(vent1.current_state == vent1.State.IDLE and player.health == player.max_health, "Tryska v klidu nepálí")
	_set_phase(vent1, 1.5)
	await _frames(2)
	_ok(vent1.current_state == vent1.State.WARN and player.health == player.max_health, "Tryska před výtryskem syčí (telegraf podle hodin)")
	_set_phase(vent1, 2.0)
	await _frames(3)
	_ok(vent1.current_state == vent1.State.BLAST and player.health == player.max_health - 1, "Výtrysk páry ubere 1 HP")
	vent2.offset = vent1.offset
	await _frames(2)
	_ok(vent1.current_state == vent2.current_state, "Trysky se stejným posunem jdou synchronně (sdílené hodiny)")
	vent2.offset = 0.9
	var side_vent = load("res://mechanics/steam_vent.tscn").instantiate()
	side_vent.blast_direction = Vector2.RIGHT
	b7.add_child(side_vent)
	_ok(side_vent.collision_shape.position == Vector2(32, 0) and side_vent.collision_shape.shape.size == Vector2(10, 61), "Oblast páry odpovídá směru a délce výtrysku")
	side_vent.free()
	player.die()
	await Global.room_reset
	await _frames(2)
	_ok(vent1.current_state == vent1.State.IDLE, "Po room_reset začínají trysky znovu od klidu")

	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		var f := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		f.store_string(save_backup)
		f.close()
	print("=== TEST HAZARDŮ: %s ===" % ("100% OK" if fails == 0 else "%d CHYB" % fails))
	get_tree().quit(1 if fails else 0)
