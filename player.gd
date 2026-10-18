extends CharacterBody2D

signal player_died

const SPEED = 150.0
const ACCELERATION = 800.0
const FRICTION = 1000.0
const JUMP_VELOCITY = -300.0
const JUMP_CUT_MULTIPLIER = 0.5

const WALL_JUMP_VELOCITY = Vector2(200.0, -250.0)
const WALL_SLIDE_SPEED = 50.0
const CLIMB_SPEED = 60.0

const DASH_SPEED = 400.0
const DASH_DURATION = 0.2

# Dvojskok: kolik skoků navíc má hráč ve vzduchu
const MAX_AIR_JUMPS = 1

# Přitahovací hák (grappling hook) - vyvážený dosah (1/3 původního)
const GRAPPLE_RANGE = 88.0
const GRAPPLE_PULL_SPEED = 380.0
const GRAPPLE_ARRIVE_DISTANCE = 16.0
const GRAPPLE_MAX_TIME = 1.6

@export var double_jump_enabled: bool = true
@export var grapple_enabled: bool = true
@export var hook_damage: int = 2
@export var max_health: int = 3

var health: int = 3
var invulnerable_timer: float = 0.0
const INVULNERABILITY_TIME: float = 1.0

const MELEE_SLASH_SCENE = preload("res://mechanics/melee_slash.tscn")
const MELEE_COOLDOWN_TIME: float = 0.28
const MELEE_RANGE: float = 40.0
const MELEE_DAMAGE: int = 2

# Aktivní předmět v hotbaru: 0 = Hasák (LMB útok), 1 = Hák (LMB hák), 2 = Prázdný
var active_slot: int = 0
var is_hook_equipped: bool = false
var is_grappling: bool = false
var grapple_point_pos: Vector2 = Vector2.ZERO
var grapple_timer: float = 0.0
var melee_cooldown: float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 1.0 = gravitace dolů (normál), -1.0 = gravitace nahoru (gravitační anomálie)
var gravity_dir: float = 1.0

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var can_dash = true
var dash_hit_enemies: Array = []
const DASH_DAMAGE: int = 2

var coyote_timer = 0.0
const COYOTE_TIME = 0.1

var air_jumps_left = MAX_AIR_JUMPS
var is_crouching = false

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var original_shape_extents = Vector2(14, 18)
@onready var death_label = $CanvasLayer/DeathLabel
@onready var kill_label = $CanvasLayer/KillLabel
@onready var stamina_bar = $StaminaBar
@onready var stamina_fill = $StaminaBar/Fill
@onready var grapple_line = get_node_or_null("GrappleLine")
@onready var inventory_ui = get_node_or_null("CanvasLayer/InventoryUI")
@onready var hearts_ui = get_node_or_null("CanvasLayer/HeartsUI")
@onready var crystal_ui = get_node_or_null("CanvasLayer/CrystalUI")
@onready var reticle = get_node_or_null("HookReticle")
@onready var camera = get_node_or_null("Camera2D")
@onready var backpack_window = get_node_or_null("CanvasLayer/BackpackWindow")

var spawn_point = Vector2.ZERO
# Po vstupu do místnosti bez spawn markeru se checkpoint upřesní při prvním bezpečném přistání
var awaiting_room_spawn: bool = false
# Smrt: záblesk + zatmění, respawn ve chvíli plné tmy (~0.25 s), obraz zpět za ~0.5 s
const DEATH_FADE_TIME: float = 0.25
var is_dying: bool = false
var death_fade := ColorRect.new()
var stamina_max: float = 8.0
var stamina: float = 8.0

var crystals: int = 0
var max_crystals: int = 5
# Krystaly, které za hráčem letí a čekají na započítání (fronta, viz mechanics/crystal.gd)
var crystal_trail: Array = []
# Jak dlouho hráč nepřetržitě stojí na pevné bezpečné zemi (krystal se započítá po 0.15 s)
var safe_ground_time: float = 0.0
# Unášení prvky prostředí (pružiny, vozíky, pohyblivé kotvy) - viz API pro prvky níže
const LIFT_GRACE: float = 0.1 # skok do 0.1 s po opuštění pohyblivé věci přičte její rychlost
const LIFT_LOCK: float = 0.15 # tak dlouho vstup neubírá unášenou vodorovnou rychlost
var lift_velocity: Vector2 = Vector2.ZERO
var lift_timer: float = 0.0
var momentum_lock: float = 0.0
var can_jump_cut: bool = true
var grapple_anchor: Node2D = null
# Tlumicí pole: zdroj -> potlačené schopnosti (&"dash", &"grapple", &"double_jump", &"climb")
var ability_blocks: Dictionary = {}
# Anomální zeď: průlet rovně skrz těleso `glide_through`
var is_gliding: bool = false
var glide_velocity: Vector2 = Vector2.ZERO
var glide_through: PhysicsBody2D = null
# Vítr (měchy) v aktuálním fyzikálním snímku
var wind: Vector2 = Vector2.ZERO
var wind_frame: int = -1
var collected_crystal_ids: Array[String] = []
var is_talking: bool = false

const GridInventory = preload("res://mechanics/grid_inventory.gd")
const ItemData = preload("res://mechanics/item_data.gd")
var grid_inventory = GridInventory.new(6, 4, true)

func _ready():
	add_to_group("player")
	grid_inventory.has_equip_slots = true
	spawn_point = global_position
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape = collision_shape.shape.duplicate()
		original_shape_extents = collision_shape.shape.size
	if get_parent() and get_parent().has_meta("use_legacy_grass"):
		call_deferred("_texture_platforms")
	call_deferred("_init_ui")
	if Global and Global.has_persistent_player:
		Global.load_player_state(self)
	elif SaveManager and SaveManager.pending_load:
		SaveManager.apply_save_to_player(self)
	if backpack_window and backpack_window.has_method("setup"):
		backpack_window.setup(grid_inventory)
	# Nosnou rychlost plošiny přidává jen skok (lift, viz set_lift_velocity), jako v Celeste
	platform_on_leave = PLATFORM_ON_LEAVE_DO_NOTHING
	death_fade.color = Color(0, 0, 0, 0)
	death_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	death_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	if has_node("CanvasLayer"):
		$CanvasLayer.add_child(death_fade)

func _init_ui():
	var crystal_stats := CollectibleCrystal.scene_stats(get_tree()) if is_inside_tree() else {"total": 0}
	if crystal_stats.total > 0:
		max_crystals = crystal_stats.total # počet běžných krystalů v této kapitole
	if inventory_ui and inventory_ui.has_method("update_ui"):
		inventory_ui.update_ui()
	if hearts_ui and hearts_ui.has_method("set_hearts"):
		hearts_ui.set_hearts(health, max_health)
	if crystal_ui and crystal_ui.has_method("set_crystals"):
		crystal_ui.set_crystals(crystals, max_crystals)

func _unhandled_input(event):
	if is_talking or is_dying:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cycle_hotbar(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cycle_hotbar(1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if active_slot == 0:
				perform_melee_attack()
			elif active_slot == 1:
				fire_hook()
			elif active_slot == 2:
				perform_dash()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Pravé tlačítko myši vždy vystřelí přitahovací hák
			fire_hook()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			select_hotbar_slot(0)
		elif event.keycode == KEY_2:
			select_hotbar_slot(1)
		elif event.keycode == KEY_3:
			select_hotbar_slot(2)
		elif event.keycode == KEY_F:
			perform_melee_attack()
		elif event.keycode in [KEY_I, KEY_TAB]:
			if backpack_window:
				backpack_window.toggle_backpack()
				get_viewport().set_input_as_handled()

func cycle_hotbar(delta_idx: int):
	# Přepínání mezi dostupnými předměty: 0 (Hasák), 1 (Hák), 2 (Cívka)
	var next_slot = (active_slot + delta_idx) % 3
	if next_slot < 0:
		next_slot += 3
	select_hotbar_slot(next_slot)

func select_hotbar_slot(idx: int):
	if idx < 0 or idx > 2:
		return
	active_slot = idx
	is_hook_equipped = (active_slot == 1)
	if not is_hook_equipped and is_grappling:
		_end_grapple(false)
	if is_instance_valid(inventory_ui) and inventory_ui.has_method("update_ui"):
		inventory_ui.update_ui()

func is_item_ready(item_id: String, default_slot: int = -1) -> bool:
	if not grid_inventory:
		return false
	if grid_inventory.is_equipped(item_id):
		return true
	# Pokud hráč item vlastní v batohu a hotbar slot je volný, automaticky se nasadí
	if grid_inventory.has_item(item_id):
		var target_slot = default_slot if default_slot >= 0 else grid_inventory.get_default_slot_for(item_id)
		if target_slot >= 0 and grid_inventory.get_equipped(target_slot) == null:
			for item in grid_inventory.items:
				if item["data"].id == item_id:
					grid_inventory.equip_item(item["data"], target_slot)
					grid_inventory.remove_item(item)
					if is_instance_valid(inventory_ui) and inventory_ui.has_method("update_ui"):
						inventory_ui.update_ui()
					return true
	return false

func toggle_hook_equip():
	if active_slot == 1:
		select_hotbar_slot(0)
	else:
		select_hotbar_slot(1)

func set_hook_equipped(value: bool):
	if value:
		select_hotbar_slot(1)
	else:
		select_hotbar_slot(0)

func perform_melee_attack():
	if not grid_inventory.has_item("wrench"):
		_show_missing_item_popup("Chybí Hasák!")
		return
	if not is_item_ready("wrench", 0):
		_show_missing_item_popup("Hasák není vybaven v Hotbaru [1]!")
		return
	if melee_cooldown > 0:
		return
	melee_cooldown = MELEE_COOLDOWN_TIME
	
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var aim_dir = to_mouse.normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT if (sprite and sprite.flip_h) else Vector2.RIGHT
		
	if sprite:
		sprite.flip_h = (to_mouse.x < 0)
		
	# Instancovat vizuální efekt švihu hasákem
	var slash = MELEE_SLASH_SCENE.instantiate()
	slash.position = global_position + aim_dir * 8.0
	slash.setup(aim_dir)
	var p = get_parent()
	if p:
		p.add_child(slash)
	else:
		add_child(slash)
		
	# Detekce a poškození nepřátel v dosahu a úhlu
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var to_enemy = enemy.global_position - global_position
		var dist = to_enemy.length()
		if dist <= MELEE_RANGE + 8.0:
			var dot = aim_dir.dot(to_enemy.normalized())
			if dot > 0.15 or dist <= 22.0:
				var kb_dir = (enemy.global_position - global_position).normalized()
				if kb_dir == Vector2.ZERO:
					kb_dir = aim_dir
				if not _hit_enemy(enemy, MELEE_DAMAGE, kb_dir) and enemy is CharacterBody2D:
					enemy.velocity = kb_dir * 180.0 + Vector2(0, -90.0)

## Vstát jde jen tam, kde se vejde plná výška hráče (jinak by uvízl v nízkém tunelu).
func _has_headroom() -> bool:
	var standing = RectangleShape2D.new()
	standing.size = original_shape_extents - Vector2(2, 2) # 1 px rezerva, aby se nepočítala podlaha a stěny, o které se hráč opírá
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = standing
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _physics_process(delta):
	if is_dying:
		return
	if is_talking:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		if not is_on_floor():
			velocity.y += gravity * delta * gravity_dir
		move_and_slide()
		if sprite and sprite is AnimatedSprite2D and sprite.animation != "idle":
			sprite.play("idle")
		return

	if is_gliding:
		velocity = glide_velocity # anomální zeď: rovný let bez gravitace a ovládání
		move_and_slide()
		return

	# Pokud probíhá přitahování hákem, řešíme jeho fyziku přednostně
	if is_grappling:
		_process_grapple(delta)
		return

	if is_dashing:
		dash_timer -= delta
		_process_dash_attack()
		if dash_timer <= 0:
			is_dashing = false
			velocity.y = 0
			if sprite and invulnerable_timer <= 0:
				sprite.modulate = Color.WHITE
		else:
			move_and_slide()
			return

	if dash_cooldown > 0:
		dash_cooldown -= delta

	if lift_timer > 0.0:
		lift_timer -= delta

	if melee_cooldown > 0:
		melee_cooldown -= delta

	if invulnerable_timer > 0:
		invulnerable_timer -= delta
		if sprite:
			sprite.modulate.a = 0.35 if fmod(invulnerable_timer, 0.16) > 0.08 else 0.95
		if invulnerable_timer <= 0 and sprite:
			sprite.modulate = Color.WHITE

	# Kontrola vstupu pro hák přes Input map (pokud už nebyl zachycen v _unhandled_input)
	if Input.is_action_just_pressed("grapple"):
		fire_hook()
		if is_grappling:
			_process_grapple(delta)
			return

	# Základní směr pohybu A / D
	var direction = Input.get_axis("move_left", "move_right")

	# Gravitace a lezení po stěnách se staminou
	var on_wall = is_on_wall() and not is_on_floor()
	var wall_normal = get_wall_normal()
	# Držení zdi podle nastavení: tlačítko Grab (Shift, jako Celeste) nebo automaticky při dotyku
	var pressing_away = on_wall and direction == sign(wall_normal.x)
	# Auto režim chytá až když hráč nestoupá rychleji než lezení, aby skok podél zdi nezastavil
	var grabbing = on_wall and stamina > 0 and not pressing_away and not _ability_blocked(&"climb") and (
		Input.is_action_pressed("grab") if Global.grab_mode == Global.GRAB_BUTTON
		else velocity.y * gravity_dir >= -CLIMB_SPEED)

	if on_wall:
		if grabbing:
			# Celeste lezení a držení se na zdi
			if Input.is_action_pressed("jump"):
				velocity.y = -CLIMB_SPEED
			elif Input.is_action_pressed("crouch"):
				velocity.y = CLIMB_SPEED
			else:
				velocity.y = 0.0
			
			stamina -= delta
			if stamina < 0:
				stamina = 0.0
			if stamina_bar:
				stamina_bar.visible = true
				var ratio = clamp(stamina / stamina_max, 0.0, 1.0)
				stamina_fill.size.x = 30.0 * ratio
				stamina_fill.color = Color(1.0 - ratio, ratio, 0.0)
		else:
			if stamina <= 0:
				velocity.y += gravity * gravity_dir * delta
			else:
				var slid_velocity = velocity.y + gravity * gravity_dir * delta
				if gravity_dir > 0:
					velocity.y = min(slid_velocity, WALL_SLIDE_SPEED)
				else:
					velocity.y = max(slid_velocity, -WALL_SLIDE_SPEED)
			
			if stamina_bar:
				stamina_bar.visible = false
		coyote_timer -= delta
	elif not is_on_floor():
		velocity.y += gravity * gravity_dir * delta
		coyote_timer -= delta
		if stamina_bar:
			stamina_bar.visible = false
	else:
		coyote_timer = COYOTE_TIME
		can_dash = true
		if velocity.y * gravity_dir >= 0.0: # vymrštění ze země (pružina, vozík) unášení neruší
			momentum_lock = 0.0
		air_jumps_left = MAX_AIR_JUMPS
		stamina = stamina_max
		if stamina_bar:
			stamina_bar.visible = false

	# Skrčení
	if Input.is_action_pressed("crouch") and is_on_floor():
		is_crouching = true
		if collision_shape and collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size.y = original_shape_extents.y / 2
			collision_shape.position.y = original_shape_extents.y / 4 * gravity_dir
	elif is_crouching and _has_headroom():
		is_crouching = false
		if collision_shape and collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size.y = original_shape_extents.y
			collision_shape.position.y = 0

	# Horizontální pohyb
	var current_speed = SPEED
	if is_crouching:
		current_speed = SPEED * 0.4
		
	if momentum_lock > 0.0:
		momentum_lock -= delta # unášená rychlost (pružina, vozík) - vstup ani tření ji hned neuberou
	elif direction:
		velocity.x = move_toward(velocity.x, direction * current_speed, ACCELERATION * delta)
		sprite.flip_h = direction < 0
	elif grabbing:
		velocity.x = -wall_normal.x * 10.0 # lehký tlak do zdi, jinak by is_on_wall() zhaslo
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Skok a dvojskok
	if Input.is_action_just_pressed("jump"):
		var jumped := true
		if coyote_timer > 0 and not is_crouching:
			velocity.y = JUMP_VELOCITY * gravity_dir
			coyote_timer = 0
		elif (is_on_wall() and not is_on_floor()) and stamina > 0:
			stamina -= 0.3
			if stamina < 0:
				stamina = 0
			var wall_normal_jump = get_wall_normal()
			
			if direction == -sign(wall_normal_jump.x) or (grabbing and not direction):
				velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
				velocity.x = -wall_normal_jump.x * SPEED
			else:
				velocity.x = wall_normal_jump.x * WALL_JUMP_VELOCITY.x
				velocity.y = WALL_JUMP_VELOCITY.y * gravity_dir
				
			sprite.flip_h = wall_normal_jump.x < 0
			air_jumps_left = MAX_AIR_JUMPS
		elif double_jump_enabled and air_jumps_left > 0 and not is_on_floor() and not _ability_blocked(&"double_jump"):
			velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
			air_jumps_left -= 1
			if sprite is AnimatedSprite2D:
				sprite.stop()
				sprite.play("jump")
		else:
			jumped = false
		if jumped:
			can_jump_cut = true
			_apply_lift()

	# Jump Cut (ne po vymrštění pružinou / vozíkem)
	if can_jump_cut and Input.is_action_just_released("jump") and velocity.y * gravity_dir < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Dash (Gravity Coil jako zbraň a pohon)
	if Input.is_action_just_pressed("dash"):
		perform_dash()

	# Aktualizace animací
	if sprite is AnimatedSprite2D:
		if grabbing:
			sprite.play("climb")
			if abs(velocity.y) < 1.0:
				sprite.pause()
			else:
				sprite.play()
		elif not is_on_floor():
			sprite.play("jump")
		else:
			if abs(velocity.x) > 1.0:
				sprite.play("walk")
			else:
				sprite.play("idle")

	move_and_slide()
	if wind_frame == Engine.get_physics_frames() and wind != Vector2.ZERO:
		move_and_collide(wind * delta) # vítr hráče posune, rychlost ani ovládání nemění
	
	if death_label:
		death_label.text = "Smrti: " + str(Global.death_count)
	if kill_label:
		kill_label.text = "Zabití: " + str(Global.kill_count)
	
	# Checkpoint = vchod do místnosti (Celeste); bez markeru první bezpečné přistání po vstupu
	var on_safe_floor := is_on_safe_floor()
	safe_ground_time = safe_ground_time + delta if on_safe_floor else 0.0
	if awaiting_room_spawn and on_safe_floor:
		var rx = int(floor(global_position.x / 320.0))
		var ry = int(floor(global_position.y / 180.0))
		if not camera or camera.valid_rooms.is_empty() or camera.valid_rooms.has(Vector2i(rx, ry)):
			spawn_point = global_position
			awaiting_room_spawn = false
	
	# Okamžitá detekce vypadnutí z mapy
	if camera and not camera.valid_rooms.is_empty():
		var rx = int(floor(global_position.x / 320.0))
		var ry = int(floor(global_position.y / 180.0))
		if not camera.valid_rooms.has(Vector2i(rx, ry)):
			die()
	elif not (camera and camera.chapter) and (global_position.y > 600 or global_position.y < -400):
		die()

## Stojí na pevné geometrii levelu (GridPlatform) - ne na drolící se plošině, bráně ani pohyblivém bloku.
func is_on_safe_floor() -> bool:
	if not is_on_floor() or is_dashing or is_grappling:
		return false
	# Testovací posun o 2 px "dolů" (bez pohybu) vrátí podlahu i když hráč stojí na místě
	var col: KinematicCollision2D = move_and_collide(-up_direction * 2.0, true)
	return col != null and (col.get_collider() is GridPlatform or col.get_collider() is TileMapLayer)

# --- API pro prvky prostředí (pružiny, krystaly dashe, vozíky, kotvy) ---

## Obnoví dash (a staminu). Vrací false, když hráč dash už má - krystal se pak nespotřebuje.
func refill_dash() -> bool:
	if can_dash:
		return false
	can_dash = true
	dash_cooldown = 0.0
	stamina = stamina_max
	return true

## Vymrští hráče rychlostí `v` (pružina, náraz vozíku). Ruší dash i hák a vrací dvojskok;
## `lock_time` = jak dlouho vstup neubírá vodorovnou rychlost. Puštění skoku výskok nezkrátí.
func launch(v: Vector2, lock_time: float = 0.0):
	_end_grapple(false)
	is_dashing = false
	velocity = v
	momentum_lock = lock_time
	can_jump_cut = false
	coyote_timer = 0.0
	lift_timer = 0.0
	air_jumps_left = MAX_AIR_JUMPS
	stamina = stamina_max

## Pohyblivá věc, na které hráč stojí nebo visí, hlásí každý snímek svou rychlost.
## Skok do LIFT_GRACE po opuštění (nebo zastavení) ji přičte (lift boost z Celeste).
func set_lift_velocity(v: Vector2):
	lift_velocity = v
	lift_timer = LIFT_GRACE

## Pustí hák (např. když se kotva ulomí); hráč si nechá polovinu rychlosti.
func release_grapple():
	_end_grapple(true)

## Tlumicí pole: `source` potlačí schopnosti (&"dash", &"grapple", &"double_jump", &"climb"); prázdné pole je uvolní.
func set_abilities_blocked(source: Object, abilities: Array):
	if abilities.is_empty():
		ability_blocks.erase(source)
	else:
		ability_blocks[source] = abilities

func _ability_blocked(ability: StringName) -> bool:
	for list in ability_blocks.values():
		if ability in list:
			return true
	return false

## Anomální zeď: hráč letí rychlostí `v` rovně skrz těleso `through` (bez gravitace a ovládání).
func start_glide(v: Vector2, through: PhysicsBody2D):
	_end_grapple(false)
	is_dashing = false
	is_gliding = true
	glide_velocity = v
	glide_through = through
	add_collision_exception_with(through)

## Konec průletu: vrátí dash i dvojskok, rychlost si nechá a vstup ji chvíli neubere.
func end_glide():
	if not is_gliding:
		return
	is_gliding = false
	if is_instance_valid(glide_through):
		remove_collision_exception_with(glide_through)
	glide_through = null
	velocity = glide_velocity
	momentum_lock = LIFT_LOCK
	can_dash = true
	air_jumps_left = MAX_AIR_JUMPS

## Vítr (měchy): v tomto snímku hráče posune o v * delta; rychlost a ovládání nemění.
func apply_wind(v: Vector2):
	if wind_frame != Engine.get_physics_frames():
		wind = Vector2.ZERO
		wind_frame = Engine.get_physics_frames()
	wind += v

## Zásah nepřítele útokem hráče (hasák, dash, hák): nové typy mají take_hit, starší take_damage.
func _hit_enemy(enemy: Node, damage: int, dir: Vector2) -> bool:
	if enemy.has_method("take_hit"):
		enemy.take_hit(damage, dir)
	elif enemy.has_method("take_damage"):
		enemy.take_damage(damage, dir)
	else:
		return false
	return true

func _apply_lift():
	if lift_timer <= 0.0:
		return
	velocity.x += lift_velocity.x
	if lift_velocity.y * gravity_dir < 0.0: # jen složka proti gravitaci
		velocity.y += lift_velocity.y
	momentum_lock = LIFT_LOCK
	lift_timer = 0.0

func perform_dash():
	if _ability_blocked(&"dash"):
		_show_missing_item_popup("Dash potlačen polem!")
		return
	if not grid_inventory.has_item("gravity_coil"):
		_show_missing_item_popup("Chybí Gravity Coil!")
		return
	if not is_item_ready("gravity_coil", 2):
		_show_missing_item_popup("Gravity Coil není vybavena v Hotbaru [3]!")
		return
	if can_dash and dash_cooldown <= 0 and not is_crouching:
		is_dashing = true
		momentum_lock = 0.0
		can_dash = false
		dash_timer = DASH_DURATION
		dash_cooldown = 0.4
		dash_hit_enemies.clear()
		
		if sprite:
			sprite.modulate = Color(1.8, 0.6, 2.5, 0.95)
		
		var dash_dir_x = Input.get_axis("move_left", "move_right")
		var dash_dir_y = Input.get_axis("jump", "crouch")
		var dash_vec = Vector2(dash_dir_x, dash_dir_y)
		
		if dash_vec == Vector2.ZERO:
			dash_vec = Vector2(-1.0 if (sprite and sprite.flip_h) else 1.0, 0.0)
		else:
			dash_vec = dash_vec.normalized()
			
		velocity = dash_vec * DASH_SPEED

func die():
	if is_dying:
		return
	is_dying = true
	Global.death_count += 1
	player_died.emit()
	get_tree().call_group("celeste_keys", "on_player_died")
	_end_grapple(false)
	velocity = Vector2.ZERO
	var tw = create_tween()
	if sprite:
		tw.tween_property(sprite, "modulate", Color(3.0, 0.5, 0.3, 0.0), DEATH_FADE_TIME)
	tw.parallel().tween_property(death_fade, "color:a", 1.0, DEATH_FADE_TIME)
	tw.tween_callback(respawn)
	tw.tween_property(death_fade, "color:a", 0.0, DEATH_FADE_TIME)

## Návrat na checkpoint po smrti; nakonec globální room_reset (nepřátelé, plošiny, krystaly).
func respawn():
	end_glide()
	ability_blocks.clear()
	set_gravity_dir(1.0)
	global_position = spawn_point
	velocity = Vector2.ZERO
	momentum_lock = 0.0
	lift_timer = 0.0
	can_jump_cut = true
	stamina = stamina_max
	air_jumps_left = MAX_AIR_JUMPS
	melee_cooldown = 0.0
	health = max_health
	invulnerable_timer = 0.0
	if sprite:
		sprite.modulate = Color.WHITE
	if hearts_ui and hearts_ui.has_method("set_hearts"):
		hearts_ui.set_hearts(health, max_health)
	if stamina_bar:
		stamina_bar.visible = false
	if camera and camera.has_method("reset_to_spawn"):
		camera.reset_to_spawn()
	is_dying = false
	Global.room_reset.emit()

func take_damage(amount: int = 1, from_pos: Vector2 = Vector2.ZERO):
	if invulnerable_timer > 0 or is_dying:
		return
	health -= amount
	invulnerable_timer = INVULNERABILITY_TIME
	
	if hearts_ui and hearts_ui.has_method("set_hearts"):
		hearts_ui.set_hearts(health, max_health)
		
	# Knockback od zdroje poškození
	if from_pos != Vector2.ZERO:
		var to_player = (global_position - from_pos).normalized()
		if to_player == Vector2.ZERO:
			to_player = Vector2.UP
		velocity = to_player * 170.0 + Vector2(0, -120.0 * gravity_dir)
	else:
		velocity = Vector2(-150.0 if (sprite and sprite.flip_h) else 150.0, -120.0 * gravity_dir)
		
	# Červený záblesk poškození
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(3.0, 0.3, 0.3), 0.08)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.08)
		
	if health <= 0:
		die()

func heal(amount: int = 1) -> bool:
	if health >= max_health:
		return false
	health = min(health + amount, max_health)
	if hearts_ui and hearts_ui.has_method("set_hearts"):
		hearts_ui.set_hearts(health, max_health)
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(0.6, 2.0, 0.9), 0.12)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	return true

func add_crystal(amount: int = 1, id: String = ""):
	if not id.is_empty():
		if id in collected_crystal_ids:
			return
		collected_crystal_ids.append(id)
	crystals += amount
	if Global and Global.has_method("on_crystal_collected"):
		Global.on_crystal_collected(amount)
	if crystal_ui and crystal_ui.has_method("set_crystals"):
		crystal_ui.set_crystals(crystals, max_crystals)
	_play_crystal_pickup_fx()

func _play_crystal_pickup_fx():
	var float_label = Label.new()
	float_label.text = "+1 💎"
	float_label.position = Vector2(-12, -26)
	float_label.modulate = Color(0.35, 0.95, 1.0, 1.0)
	float_label.set("theme_override_font_sizes/font_size", 9)
	add_child(float_label)
	
	var tw = create_tween()
	tw.tween_property(float_label, "position:y", -42.0, 0.45)
	tw.parallel().tween_property(float_label, "modulate:a", 0.0, 0.45)
	tw.tween_callback(float_label.queue_free)

func _show_missing_item_popup(msg: String):
	var float_label = Label.new()
	float_label.text = "⚠️ " + msg
	float_label.position = Vector2(-36, -30)
	float_label.modulate = Color(1.0, 0.35, 0.25, 1.0)
	float_label.set("theme_override_font_sizes/font_size", 8)
	add_child(float_label)
	
	var tw = create_tween()
	tw.tween_property(float_label, "position:y", -46.0, 0.55)
	tw.parallel().tween_property(float_label, "modulate:a", 0.0, 0.55)
	tw.tween_callback(float_label.queue_free)

func _process_dash_attack():
	if not grid_inventory or not grid_inventory.has_item("gravity_coil"):
		return
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy in dash_hit_enemies:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= 26.0:
			dash_hit_enemies.append(enemy)
			var kb_dir = (enemy.global_position - global_position).normalized()
			if kb_dir == Vector2.ZERO:
				kb_dir = velocity.normalized()
			if not _hit_enemy(enemy, DASH_DAMAGE, kb_dir) and enemy is CharacterBody2D:
				enemy.velocity = kb_dir * 220.0 + Vector2(0, -90.0)

func get_inventory_save_data() -> Array:
	if grid_inventory:
		return grid_inventory.to_save_data()
	return []

func load_inventory_save_data(data: Array):
	if grid_inventory:
		grid_inventory.load_save_data(data)
		if is_instance_valid(backpack_window) and backpack_window.has_method("setup"):
			backpack_window.setup(grid_inventory)
		if is_instance_valid(inventory_ui) and inventory_ui.has_method("update_ui"):
			inventory_ui.update_ui()

func set_gravity_dir(new_dir: float):
	if new_dir == gravity_dir:
		return
	gravity_dir = new_dir
	up_direction = Vector2(0, -gravity_dir)
	velocity.y *= 0.5
	if sprite:
		sprite.flip_v = gravity_dir < 0

# --- PŘITAHOVACÍ HÁK (GRAPPLING HOOK) S MÍŘENÍM MYŠÍ A POŠKOZENÍM ---

func get_hook_aim_info(custom_target_pos: Vector2 = Vector2.INF) -> Dictionary:
	var mouse_pos = custom_target_pos if custom_target_pos != Vector2.INF else get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var aim_dir = to_mouse.normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT if (sprite and sprite.flip_h) else Vector2.RIGHT
		
	var target_pos = global_position + aim_dir * GRAPPLE_RANGE
	
	var space_state = get_world_2d().direct_space_state
	# Maska 3 = vrstva 1 (zem/zdi) + vrstva 2 (nepřátelé)
	var exclude_list = [get_rid()]
	var hit_enemy = null
	var hit_pos = Vector2.ZERO
	var hit_collider = null
	
	while true:
		var query = PhysicsRayQueryParameters2D.create(global_position, target_pos, 3, exclude_list)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			break
		var collider = result.collider
		hit_pos = result.position
		
		# Kontrola, zda je kolidující objekt nepřítel nebo komponenta nepřítele (HurtArea/StompArea)
		var enemy_candidate = null
		if collider.is_in_group("enemies") or collider.has_method("take_hit") or collider.has_method("take_damage") or collider.name.begins_with("Enemy"):
			enemy_candidate = collider
		elif collider.get_parent() and (collider.get_parent().is_in_group("enemies") or collider.get_parent().has_method("take_hit") or collider.get_parent().has_method("take_damage") or collider.get_parent().name.begins_with("Enemy")):
			enemy_candidate = collider.get_parent()
			
		if enemy_candidate != null:
			hit_enemy = enemy_candidate
			break
			
		# Pokud je to Area2D, která není nepřítel (spouštěcí zóna apod.), ignorujeme ji a hledáme dál
		if collider is Area2D:
			exclude_list.append(result.rid)
			continue
			
		# Pevné těleso (svět, stěna, plošina)
		hit_collider = collider
		break
	
	if hit_enemy != null:
		return {"type": "enemy", "target": hit_enemy, "pos": hit_pos, "in_range": true}

	# Hák se chytá jen kotev (GrapplePoints) v přímé viditelnosti; zeď ho jen zastaví
	var best_anchor = null
	var best_anchor_dist = 28.0
	for anchor in get_tree().get_nodes_in_group("grapple_points"):
		var dist_to_player = global_position.distance_to(anchor.global_position)
		if dist_to_player <= GRAPPLE_RANGE:
			var proj = (anchor.global_position - global_position).project(aim_dir)
			if proj.dot(aim_dir) > 0:
				var perp = (anchor.global_position - (global_position + proj)).length()
				if perp < best_anchor_dist and space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, anchor.global_position, 1, [get_rid()])).is_empty():
					best_anchor = anchor
					best_anchor_dist = perp
	
	if best_anchor:
		return {"type": "anchor", "target": best_anchor, "pos": best_anchor.global_position, "in_range": true}
	if hit_collider != null:
		return {"type": "none", "target": null, "pos": hit_pos, "in_range": false}

	return {"type": "none", "target": null, "pos": target_pos, "in_range": false}

func fire_hook(custom_target_pos: Vector2 = Vector2.INF):
	if not grapple_enabled:
		return
	if _ability_blocked(&"grapple"):
		_show_missing_item_popup("Hák potlačen polem!")
		return
	if not grid_inventory.has_item("grapple_hook"):
		_show_missing_item_popup("Chybí Hák!")
		return
	if not is_item_ready("grapple_hook", 1):
		_show_missing_item_popup("Hák není vybaven v Hotbaru [2]!")
		return
		
	var info = get_hook_aim_info(custom_target_pos)
	var mouse_pos = custom_target_pos if custom_target_pos != Vector2.INF else get_global_mouse_position()
	if sprite:
		sprite.flip_h = (mouse_pos.x < global_position.x)
		
	match info.type:
		"enemy":
			# Zásah nepřítele: udělí poškození
			var enemy = info.target
			var hook_dir = (info.pos - global_position).normalized()
			_hit_enemy(enemy, hook_damage, hook_dir)
			_play_hook_strike_fx(info.pos, true)
			
		"anchor":
			# Záchyt za kotvu: zahájí přitahování (pohyblivou kotvu hák sleduje, křehká začne praskat)
			grapple_point_pos = info.pos
			grapple_anchor = info.target
			if grapple_anchor.has_method("on_grappled"):
				grapple_anchor.on_grappled(self)
			is_grappling = true
			grapple_timer = GRAPPLE_MAX_TIME
			is_dashing = false
			can_dash = true
			air_jumps_left = MAX_AIR_JUMPS
			if grapple_line:
				grapple_line.visible = true
				grapple_line.modulate.a = 1.0
				grapple_line.default_color = Color(0.85, 0.65, 0.25, 1.0)
				grapple_line.points = PackedVector2Array([Vector2.ZERO, to_local(grapple_point_pos)])
				
		_:
			# Výstřel do prázdna
			_play_hook_strike_fx(info.pos, false)

func _process_grapple(delta):
	grapple_timer -= delta
	if is_instance_valid(grapple_anchor):
		grapple_point_pos = grapple_anchor.global_position
	var to_hook = grapple_point_pos - global_position
	var dist = to_hook.length()
	
	# Pokud hráč stiskne skok (W), provede katapultový odskok z háku
	if Input.is_action_just_pressed("jump"):
		_end_grapple(false)
		velocity = to_hook.normalized() * 260.0
		velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
		air_jumps_left = MAX_AIR_JUMPS
		can_dash = true
		can_jump_cut = true
		_apply_lift() # pohyblivá kotva přidá svou rychlost
		return
		
	# Skrčení zruší hák
	if Input.is_action_just_pressed("crouch"):
		_end_grapple(false)
		return
		
	# Dosažení cíle nebo vypršení limitu
	if dist < GRAPPLE_ARRIVE_DISTANCE or grapple_timer <= 0.0:
		_end_grapple(true)
		velocity.y = -100.0 * gravity_dir # Malé vyskočení na plošinu
		return
		
	# Samotné přitahování k záchytnému bodu
	var pull_dir = to_hook.normalized()
	velocity = pull_dir * GRAPPLE_PULL_SPEED
	
	if sprite:
		sprite.flip_h = to_hook.x < 0
		if sprite is AnimatedSprite2D:
			sprite.play("jump")
			
	move_and_slide()
	
	if grapple_line:
		grapple_line.visible = true
		grapple_line.points = PackedVector2Array([Vector2.ZERO, to_local(grapple_point_pos)])

func _end_grapple(keep_momentum: bool):
	if not is_grappling:
		return
	is_grappling = false
	grapple_anchor = null
	if grapple_line:
		grapple_line.clear_points()
		grapple_line.visible = false
	can_dash = true
	air_jumps_left = MAX_AIR_JUMPS
	if keep_momentum:
		velocity *= 0.5
	else:
		velocity = Vector2.ZERO

func _play_hook_strike_fx(target_pos: Vector2, is_hit: bool):
	if not grapple_line:
		return
	grapple_line.visible = true
	grapple_line.modulate.a = 1.0
	grapple_line.default_color = Color(1.0, 0.25, 0.2, 1.0) if is_hit else Color(0.85, 0.65, 0.25, 0.7)
	grapple_line.points = PackedVector2Array([Vector2.ZERO, to_local(target_pos)])
	var tw = create_tween()
	tw.tween_property(grapple_line, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func():
		if not is_grappling:
			grapple_line.clear_points()
			grapple_line.visible = false
			grapple_line.modulate.a = 1.0
			grapple_line.default_color = Color(0.85, 0.65, 0.25, 1.0)
	)

func _texture_platforms():
	var parent = get_parent()
	if not parent:
		return
	
	var block_texture = load("res://assets/aseprite/block-trava.png")
	var bg_texture = load("res://assets/aseprite/background.png")
	
	var bg = parent.get_node_or_null("Background")
	if bg and bg is ColorRect:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "BackgroundCanvas"
		canvas_layer.layer = -100
		
		var tex_rect = TextureRect.new()
		tex_rect.name = "BackgroundTexture"
		tex_rect.texture = bg_texture
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		tex_rect.size = Vector2(320, 180)
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		canvas_layer.add_child(tex_rect)
		parent.add_child(canvas_layer)
		
		parent.remove_child(bg)
		bg.queue_free()
	
	if block_texture:
		_texture_node(parent, block_texture)

func _texture_node(node: Node, block_texture: Texture2D):
	if node == self:
		return
		
	if node is ColorRect:
		if node.name == "Background" or node.name == "BackgroundTexture":
			return
			
		var size = node.size
		var pos = node.position
		var color = node.color
		
		var tex_rect = TextureRect.new()
		tex_rect.name = node.name + "_tex"
		tex_rect.texture = block_texture
		tex_rect.stretch_mode = TextureRect.STRETCH_TILE
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex_rect.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		
		var target_scale = 0.25
		tex_rect.scale = Vector2(target_scale, target_scale)
		tex_rect.size = size / target_scale
		tex_rect.position = pos
		tex_rect.modulate = color
		
		var p = node.get_parent()
		var idx = node.get_index()
		p.add_child(tex_rect)
		p.move_child(tex_rect, idx)
		p.remove_child(node)
		node.queue_free()
		return

	var children = node.get_children()
	for child in children:
		if is_instance_valid(child):
			_texture_node(child, block_texture)
