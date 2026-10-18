extends Node2D

## Test prvků batch B (levels/test_chapter, sekce c): pružiny, krystal dashe, důlní vozík,
## pohyblivé a křehké kotvy. Ověřuje přenos hybnosti (lift do 0.1 s), API hráče, room_reset
## a obrácenou gravitaci.
## Spuštění: godot --headless --path . res://test/test_elements.tscn

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

## Dash doprava z místa (bez vstupu míří dash ve směru pohledu).
func _dash_right(room: Room, local: Vector2, gravity: float = 1.0):
	_place(room, local, gravity)
	player.sprite.flip_h = false
	player.can_dash = true
	player.dash_cooldown = 0.0
	await _frames(1)
	player.perform_dash()

## Skok jako ze vstupu (stisk se zpracuje v nejbližším fyzikálním snímku hráče).
func _jump():
	Input.action_press("jump")
	await _frames(2)
	Input.action_release("jump")

func _ready():
	var save_backup: String = FileAccess.get_file_as_string(SaveManager.SAVE_PATH) if SaveManager.has_save_file() else ""
	var chapter: Chapter = load("res://levels/test_chapter/test_chapter.tscn").instantiate()
	add_child(chapter)
	await _frames(3)
	player = chapter.player
	var c1: Room = chapter._find("tc_c01")
	var c2: Room = chapter._find("tc_c02")
	var c3: Room = chapter._find("tc_c03")
	var c4: Room = chapter._find("tc_c04")
	_ok(player.grid_inventory.has_item("gravity_coil") and player.grid_inventory.has_item("grapple_hook"), "Kapitola dala hráči startovní předměty (start_items)")

	# --- 1. Tlaková pružina ---
	chapter.teleport_to("tc_c01")
	player.can_dash = false
	_place(c1, Vector2(40, 130))
	await _frames(3)
	_ok(player.velocity.y < -400.0 and player.can_dash, "Pružina vymrští nahoru a obnoví dash (vy=%.0f)" % player.velocity.y)
	_ok(not player.can_jump_cut, "Puštění skoku výstřel z pružiny nezkrátí")
	_place(c1, Vector2(152, 130))
	await _frames(3)
	var vx: float = player.velocity.x
	await _frames(6)
	_ok(vx > 250.0 and absf(player.velocity.x - vx) < 1.0, "Šikmá pružina: vodorovná rychlost (%.0f) drží i bez vstupu" % vx)
	var ceiling_spring = load("res://mechanics/pressure_spring.tscn").instantiate()
	ceiling_spring.direction = Vector2.DOWN
	ceiling_spring.position = Vector2(232, 16)
	c1.add_child(ceiling_spring)
	_place(c1, Vector2(232, 40), -1.0)
	for i in 30:
		if player.velocity.y > 300.0:
			break
		await get_tree().physics_frame
	_ok(player.velocity.y > 300.0, "Stropní pružina vymrští hráče s obrácenou gravitací dolů")
	ceiling_spring.queue_free()

	# --- 2. Krystal dashe ---
	chapter.teleport_to("tc_c02")
	var shard = c2.get_node("Shard1")
	player.can_dash = true
	_place(c2, Vector2(120, 104))
	await _frames(2)
	_ok(not shard.used, "Hráč, který dash má, krystal nespotřebuje")
	player.can_dash = false
	_place(c2, Vector2(120, 104))
	await _frames(2)
	_ok(shard.used and player.can_dash, "Krystal obnoví dash a pohasne")
	await get_tree().create_timer(2.6).timeout
	_ok(not shard.used, "Krystal po 2.5 s doroste")
	player.can_dash = false
	_place(c2, Vector2(120, 104))
	await _frames(2)
	player.die()
	await Global.room_reset
	_ok(not shard.used, "room_reset krystal obnoví hned")

	# --- 3. Důlní vozík ---
	chapter.teleport_to("tc_c03")
	var cart = c3.get_node("Cart")
	_place(c3, Vector2(88, 135))
	await _frames(3)
	_ok(cart.state != MineCart.State.IDLE, "Hráč na vozíku ho spustí (rachot)")
	for i in 60:
		if cart.state == MineCart.State.RUN and cart.speed > 200.0:
			break
		await get_tree().physics_frame
	_ok(player.is_on_floor() and player.global_position.x > c3.global_position.x + 98.0 and player.lift_velocity.x > 150.0, "Vozík veze hráče a hlásí mu svou rychlost")
	await _jump()
	_ok(player.velocity.x > 200.0, "Skok z jedoucího vozíku přičte jeho rychlost (vx=%.0f, chůze max 150)" % player.velocity.x)
	player.die()
	await Global.room_reset
	cart = c3.get_node("Cart")
	_ok(cart.state == MineCart.State.IDLE and cart.travelled == 0.0, "room_reset vrátil vozík na začátek")
	_place(c3, Vector2(88, 135))
	for i in 150:
		if cart.state == MineCart.State.IMPACT:
			break
		await get_tree().physics_frame
	await _frames(2)
	_ok(player.velocity.x > 100.0 and player.velocity.y < 0.0, "Náraz na konci vymrští hráče, který jen stojí (v=%s)" % player.velocity)
	await _frames(45)
	_ok(player.is_on_floor() and player.global_position.x > c3.global_position.x + 272.0, "Vymrštění dopraví hráče na protější římsu")

	# Lift: skok do 0.1 s po opuštění pohyblivé věci přičte její rychlost, později už ne
	_place(c3, Vector2(24, 135))
	await _frames(5)
	player.set_lift_velocity(Vector2(300, 0))
	await _frames(12) # 0.2 s
	await _jump()
	_ok(player.velocity.x < 100.0, "Skok 0.2 s po opuštění vozíku už rychlost nepřičte")
	await _frames(40)
	_place(c3, Vector2(24, 135))
	await _frames(5)
	player.set_lift_velocity(Vector2(300, 0))
	await _frames(2)
	await _jump()
	_ok(player.velocity.x > 250.0, "Skok do 0.1 s po opuštění vozíku přičte jeho rychlost")

	# --- 4. Kotvy pro hák ---
	chapter.teleport_to("tc_c04")
	var moving = c4.get_node("AnchorMoving")
	var fragile = c4.get_node("AnchorBreakable")
	BeatClock.time = 0.0
	_place(c4, Vector2(50, 110))
	await _frames(1)
	player.fire_hook(moving.global_position)
	_ok(player.is_grappling and player.grapple_anchor == moving, "Hák se zachytí pohyblivé kotvy")
	await _frames(4)
	_ok(not player.is_grappling or player.grapple_point_pos == moving.global_position, "Hák sleduje pohyblivou kotvu")
	_ok(player.lift_timer > 0.0, "Pohyblivá kotva hlásí hráči rychlost pro odskok z háku")
	fragile.break_delay = 0.05
	_place(c4, Vector2(110, 110))
	await _frames(1)
	player.fire_hook(fragile.global_position)
	_ok(player.is_grappling, "Hák se zachytí křehké kotvy")
	await _frames(6)
	_ok(not player.is_grappling and not fragile.visible and not fragile.is_in_group("grapple_points"), "Křehká kotva praskne a hák pustí")
	_ok(player.get_hook_aim_info(fragile.global_position).type != "anchor", "Ulomenou kotvu hák nenajde")
	player.die()
	await Global.room_reset
	_ok(fragile.visible and fragile.is_in_group("grapple_points"), "room_reset kotvu obnoví")
	BeatClock.time = 0.0
	_place(c4, Vector2(50, 110), -1.0)
	await _frames(1)
	player.fire_hook(moving.global_position)
	_ok(player.is_grappling and player.grapple_anchor == moving, "Hák a kotvy fungují i s obrácenou gravitací")

	# --- 5. Tlumicí pole ---
	chapter.teleport_to("tc_d01")
	var d1: Room = chapter._find("tc_d01")
	_place(d1, Vector2(160, 100))
	await _frames(2)
	_ok(player._ability_blocked(&"dash") and player._ability_blocked(&"grapple") and not player._ability_blocked(&"double_jump"), "Pole potlačí dash a hák, dvojskok nechá")
	player.can_dash = true
	player.dash_cooldown = 0.0
	player.perform_dash()
	player.fire_hook(d1.get_node("BlockedAnchor").global_position)
	_ok(not player.is_dashing and not player.is_grappling, "V poli nejde dash ani hák")
	_place(d1, Vector2(24, 135))
	await _frames(2)
	player.perform_dash()
	_ok(not player._ability_blocked(&"dash") and player.is_dashing, "Mimo pole dash zase funguje")
	await _frames(15)
	_place(d1, Vector2(160, 100))
	await _frames(2)
	player.die()
	await Global.room_reset
	await _frames(2)
	_ok(not player._ability_blocked(&"dash"), "Smrt v poli schopnosti uvolní")

	# --- 6. Anomální zeď ---
	chapter.teleport_to("tc_d02")
	var d2: Room = chapter._find("tc_d02")
	_place(d2, Vector2(110, 135))
	Input.action_press("move_right")
	await _frames(30)
	Input.action_release("move_right")
	_ok(player.global_position.x < d2.global_position.x + 128.0, "Bez dashe je anomální zeď pevná")
	await _dash_right(d2, Vector2(100, 135))
	var glided := false
	for i in 60:
		glided = glided or player.is_gliding
		if glided and not player.is_gliding:
			break
		await get_tree().physics_frame
	_ok(glided and not player.is_gliding and player.global_position.x > d2.global_position.x + 192.0 and player.can_dash and not player.is_dying, "Dash do zdi: průlet skrz, na druhé straně dash zpět")
	var blocker := StaticBody2D.new()
	var blocker_col := CollisionShape2D.new()
	blocker_col.shape = RectangleShape2D.new()
	blocker_col.shape.size = Vector2(16, 128)
	blocker_col.position = Vector2(8, 64)
	blocker.add_child(blocker_col)
	blocker.position = Vector2(192, 16)
	d2.add_child(blocker)
	await _dash_right(d2, Vector2(100, 135))
	_ok(await _wait_death(60), "Zablokovaný výstup z anomální zdi zabije")
	blocker.free()
	_place(d2, Vector2(100, 40), -1.0)
	await _frames(15)
	await _dash_right(d2, Vector2(100, player.global_position.y - d2.global_position.y), -1.0)
	glided = false
	for i in 60:
		glided = glided or player.is_gliding
		if glided and not player.is_gliding:
			break
		await get_tree().physics_frame
	_ok(glided and player.global_position.x > d2.global_position.x + 192.0, "Průlet funguje i s obrácenou gravitací")

	# --- 7. Vrtatelná skála ---
	chapter.teleport_to("tc_d03")
	var d3: Room = chapter._find("tc_d03")
	var rock = d3.get_node("DrillRock")
	for item in player.grid_inventory.items:
		if item["data"].id == "drill":
			player.grid_inventory.remove_item(item)
			break
	await _dash_right(d3, Vector2(110, 135))
	await _frames(25)
	_ok(not rock.broken and player.global_position.x < d3.global_position.x + 144.0, "Bez vrtáku je skála pevná")
	player.grid_inventory.add_item_auto(load("res://mechanics/item_data.gd").create("drill"))
	await _dash_right(d3, Vector2(110, 135))
	await _frames(25)
	_ok(rock.broken and player.global_position.x > d3.global_position.x + 160.0, "Dash s vrtákem skálu prorazí a hráč letí dál")
	player.die()
	await Global.room_reset
	var rebuilt_rock = d3.get_node("DrillRock")
	_ok(rebuilt_rock != rock and not rebuilt_rock.broken, "room_reset skálu vrátí")

	# --- 8. Pás dopravníku ---
	chapter.teleport_to("tc_d04")
	var d4: Room = chapter._find("tc_d04")
	_place(d4, Vector2(120, 103))
	await _frames(5)
	var belt_x0: float = player.global_position.x
	await _frames(20)
	_ok(player.is_on_floor() and player.global_position.x - belt_x0 > 20.0 and player.lift_velocity == Vector2(90, 0), "Pás veze hráče a hlásí mu rychlost")
	await _jump()
	_ok(player.velocity.x >= 80.0, "Seskok z pásu přičte jeho rychlost (vx=%.0f)" % player.velocity.x)

	# --- 9. Měchy (vítr) ---
	chapter.teleport_to("tc_d05")
	var d5: Room = chapter._find("tc_d05")
	var gust = d5.get_node("GustLeft")
	_place(d5, Vector2(150, 60))
	await _frames(2)
	var wind_x0: float = player.global_position.x
	await _frames(10)
	_ok(player.global_position.x - wind_x0 > 10.0 and absf(player.velocity.x) < 1.0, "Vítr hráče posouvá, jeho rychlost nemění")
	_place(d5, Vector2(24, 135))
	BeatClock.time = 0.1 - gust.offset
	await _frames(2)
	_ok(gust.warning and not gust.blowing, "Nárazový měch se 0.4 s předem nafukuje (telegraf)")
	BeatClock.time = 0.6 - gust.offset
	await _frames(2)
	_ok(gust.blowing and not gust.warning, "Pak fouká")

	# --- 10. Rytmické bloky ---
	chapter.teleport_to("tc_d06")
	var d6: Room = chapter._find("tc_d06")
	var a1 = d6.get_node("Rhythm1")
	var b1 = d6.get_node("Rhythm2")
	BeatClock.time = 0.2
	await _frames(2)
	_ok(a1.solid and not b1.solid, "V první půlce cyklu je pevná sada A")
	BeatClock.time = 1.2
	await _frames(2)
	_ok(not a1.solid and b1.solid, "Ve druhé půlce sada B")
	BeatClock.time = 0.7
	await _frames(2)
	_ok(a1.warning and b1.warning, "0.4 s před přepnutím bloky blikají")
	BeatClock.time = 1.5
	await _frames(2)
	_place(d6, a1.position + Vector2(16, 8))
	BeatClock.time = 0.1
	await _frames(2)
	_ok(not a1.solid, "Blok nezpevní, dokud v něm hráč je")
	_place(d6, Vector2(24, 135))
	await _frames(2)
	_ok(a1.solid, "Po odchodu hráče blok zpevní")

	if save_backup.is_empty():
		SaveManager.delete_save()
	else:
		var f := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		f.store_string(save_backup)
		f.close()
	print("=== TEST PRVKŮ BATCH B: %s ===" % ("100% OK" if fails == 0 else "%d CHYB" % fails))
	get_tree().quit(1 if fails else 0)
