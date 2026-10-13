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
var stamina_max: float = 8.0
var stamina: float = 8.0

var crystals: int = 0
var max_crystals: int = 5
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

func _init_ui():
	if inventory_ui and inventory_ui.has_method("update_ui"):
		inventory_ui.update_ui()
	if hearts_ui and hearts_ui.has_method("set_hearts"):
		hearts_ui.set_hearts(health, max_health)
	if crystal_ui and crystal_ui.has_method("set_crystals"):
		crystal_ui.set_crystals(crystals, max_crystals)

func _unhandled_input(event):
	if is_talking:
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
				if enemy.has_method("take_damage"):
					enemy.take_damage(MELEE_DAMAGE, kb_dir)
				elif enemy is CharacterBody2D:
					enemy.velocity = kb_dir * 180.0 + Vector2(0, -90.0)

func _physics_process(delta):
	if is_talking:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		if not is_on_floor():
			velocity.y += gravity * delta * gravity_dir
		move_and_slide()
		if sprite and sprite is AnimatedSprite2D and sprite.animation != "idle":
			sprite.play("idle")
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
	var pressing_into_wall = on_wall and direction == -sign(wall_normal.x)

	if on_wall:
		if pressing_into_wall and stamina > 0:
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
	else:
		if is_crouching:
			is_crouching = false
			if collision_shape and collision_shape.shape is RectangleShape2D:
				collision_shape.shape.size.y = original_shape_extents.y
				collision_shape.position.y = 0

	# Horizontální pohyb
	var current_speed = SPEED
	if is_crouching:
		current_speed = SPEED * 0.4
		
	if direction:
		velocity.x = move_toward(velocity.x, direction * current_speed, ACCELERATION * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Skok a dvojskok
	if Input.is_action_just_pressed("jump"):
		if coyote_timer > 0 and not is_crouching:
			velocity.y = JUMP_VELOCITY * gravity_dir
			coyote_timer = 0
		elif (is_on_wall() and not is_on_floor()) and stamina > 0:
			stamina -= 0.3
			if stamina < 0:
				stamina = 0
			var wall_normal_jump = get_wall_normal()
			
			if direction == -sign(wall_normal_jump.x):
				velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
				velocity.x = -wall_normal_jump.x * SPEED
			else:
				velocity.x = wall_normal_jump.x * WALL_JUMP_VELOCITY.x
				velocity.y = WALL_JUMP_VELOCITY.y * gravity_dir
				
			sprite.flip_h = wall_normal_jump.x < 0
			air_jumps_left = MAX_AIR_JUMPS
		elif double_jump_enabled and air_jumps_left > 0 and not is_on_floor():
			velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
			air_jumps_left -= 1
			if sprite is AnimatedSprite2D:
				sprite.stop()
				sprite.play("jump")

	# Jump Cut
	if Input.is_action_just_released("jump") and velocity.y * gravity_dir < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Dash (Gravity Coil jako zbraň a pohon)
	if Input.is_action_just_pressed("dash"):
		perform_dash()

	# Aktualizace animací
	if sprite is AnimatedSprite2D:
		if on_wall and pressing_into_wall and stamina > 0:
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
	
	if death_label:
		death_label.text = "Smrti: " + str(Global.death_count)
	if kill_label:
		kill_label.text = "Zabití: " + str(Global.kill_count)
	
	# Bezpečný záchytný bod (checkpoint) na pevné zemi uvnitř platné místnosti
	if is_on_floor() and not is_dashing and not is_grappling:
		var rx = int(floor(global_position.x / 320.0))
		var ry = int(floor(global_position.y / 180.0))
		if not camera or camera.valid_rooms.is_empty() or camera.valid_rooms.has(Vector2i(rx, ry)):
			spawn_point = global_position
	
	# Okamžitá detekce vypadnutí z mapy
	if camera and not camera.valid_rooms.is_empty():
		var rx = int(floor(global_position.x / 320.0))
		var ry = int(floor(global_position.y / 180.0))
		if not camera.valid_rooms.has(Vector2i(rx, ry)):
			die()
	elif global_position.y > 600 or global_position.y < -400:
		die()

func perform_dash():
	if not grid_inventory.has_item("gravity_coil"):
		_show_missing_item_popup("Chybí Gravity Coil!")
		return
	if not is_item_ready("gravity_coil", 2):
		_show_missing_item_popup("Gravity Coil není vybavena v Hotbaru [3]!")
		return
	if can_dash and dash_cooldown <= 0 and not is_crouching:
		is_dashing = true
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
	Global.death_count += 1
	player_died.emit()
	get_tree().call_group("celeste_keys", "on_player_died")
	_end_grapple(false)
	set_gravity_dir(1.0)
	global_position = spawn_point
	velocity = Vector2.ZERO
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

func take_damage(amount: int = 1, from_pos: Vector2 = Vector2.ZERO):
	if invulnerable_timer > 0:
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
			if enemy.has_method("take_damage"):
				enemy.take_damage(DASH_DAMAGE, kb_dir)
			elif enemy is CharacterBody2D:
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

func get_hook_aim_info() -> Dictionary:
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var aim_dir = to_mouse.normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT if (sprite and sprite.flip_h) else Vector2.RIGHT
		
	var target_pos = global_position + aim_dir * GRAPPLE_RANGE
	
	var space_state = get_world_2d().direct_space_state
	# Maska 3 = vrstva 1 (zem/zdi) + vrstva 2 (nepřátelé)
	var query = PhysicsRayQueryParameters2D.create(global_position, target_pos, 3, [get_rid()])
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result.collider
		var hit_pos = result.position
		if collider.is_in_group("enemies") or collider.has_method("take_damage") or collider.name.begins_with("Enemy"):
			return {"type": "enemy", "target": collider, "pos": hit_pos, "in_range": true}
		else:
			return {"type": "world", "target": collider, "pos": hit_pos, "in_range": true}
			
	# Kontrola kotev (GrapplePoints)
	var best_anchor = null
	var best_anchor_dist = 28.0
	for anchor in get_tree().get_nodes_in_group("grapple_points"):
		var dist_to_player = global_position.distance_to(anchor.global_position)
		if dist_to_player <= GRAPPLE_RANGE:
			var proj = (anchor.global_position - global_position).project(aim_dir)
			if proj.dot(aim_dir) > 0:
				var perp = (anchor.global_position - (global_position + proj)).length()
				if perp < best_anchor_dist:
					best_anchor = anchor
					best_anchor_dist = perp
	
	if best_anchor:
		return {"type": "anchor", "target": best_anchor, "pos": best_anchor.global_position, "in_range": true}
		
	return {"type": "none", "target": null, "pos": target_pos, "in_range": false}

func fire_hook():
	if not grapple_enabled:
		return
	if not grid_inventory.has_item("grapple_hook"):
		_show_missing_item_popup("Chybí Hák!")
		return
	if not is_item_ready("grapple_hook", 1):
		_show_missing_item_popup("Hák není vybaven v Hotbaru [2]!")
		return
		
	var info = get_hook_aim_info()
	var mouse_pos = get_global_mouse_position()
	if sprite:
		sprite.flip_h = (mouse_pos.x < global_position.x)
		
	match info.type:
		"enemy":
			# Zásah nepřítele: udělí poškození
			var enemy = info.target
			var hook_dir = (info.pos - global_position).normalized()
			if enemy.has_method("take_damage"):
				enemy.take_damage(hook_damage, hook_dir)
			_play_hook_strike_fx(info.pos, true)
			
		"world", "anchor":
			# Záchyt za povrch nebo kotvu: zahájí přitahování
			grapple_point_pos = info.pos
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
	var to_hook = grapple_point_pos - global_position
	var dist = to_hook.length()
	
	# Pokud hráč stiskne skok (W), provede katapultový odskok z háku
	if Input.is_action_just_pressed("jump"):
		_end_grapple(false)
		velocity = to_hook.normalized() * 260.0
		velocity.y = JUMP_VELOCITY * 0.9 * gravity_dir
		air_jumps_left = MAX_AIR_JUMPS
		can_dash = true
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
