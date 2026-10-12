extends Node2D

# Mířidlo a indikátor akcí (útok hasákem / přitahovací hák) podle kurzoru myši a aktivního slotu.

var player: CharacterBody2D = null
var pulse_time: float = 0.0

func _ready():
	player = get_parent() as CharacterBody2D
	z_index = 20

func _process(delta):
	pulse_time += delta
	if not is_instance_valid(player):
		visible = false
		return
	
	visible = true
	global_position = get_global_mouse_position()
	queue_redraw()

func _draw():
	if not is_instance_valid(player):
		return
		
	var active_slot: int = player.get("active_slot") if player.get("active_slot") != null else 0
	var pulse = sin(pulse_time * 6.0) * 1.5
	var local_player = to_local(player.global_position)
	var dist_to_player = player.global_position.distance_to(global_position)
	
	if active_slot == 0:
		# --- MELEE / HASÁK MÍŘIDLO ---
		var enemy_near = false
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(enemy):
				if player.global_position.distance_to(enemy.global_position) <= 46.0:
					enemy_near = true
					break
					
		if enemy_near:
			# ČERVENO-ORANŽOVÝ bojový indikátor (nepřítel v dosahu úderu)
			var col = Color(1.0, 0.25, 0.15, 0.95)
			var r = 6.5 + pulse * 0.5
			draw_circle(Vector2.ZERO, 2.0, col)
			# 4 záseky útočného hasáku
			draw_line(Vector2(-r, 0), Vector2(-r - 3, 0), col, 1.8)
			draw_line(Vector2(r, 0), Vector2(r + 3, 0), col, 1.8)
			draw_line(Vector2(0, -r), Vector2(0, -r - 3), col, 1.8)
			draw_line(Vector2(0, r), Vector2(0, r + 3), col, 1.8)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 16, col, 1.2)
		elif dist_to_player <= 42.0:
			# V dosahu švihu (bronzový indikátor)
			var col = Color(1.0, 0.8, 0.25, 0.85)
			draw_circle(Vector2.ZERO, 1.5, col)
			draw_arc(Vector2.ZERO, 5.0, 0.0, TAU, 12, col, 1.1)
		else:
			# Běžný křížek zbraně na blízko
			var col = Color(0.8, 0.75, 0.65, 0.6)
			draw_circle(Vector2.ZERO, 1.2, col)
			draw_line(Vector2(-4, 0), Vector2(4, 0), col, 1.0)
			draw_line(Vector2(0, -4), Vector2(0, 4), col, 1.0)
			
	elif active_slot == 1:
		# --- HÁK MÍŘIDLO ---
		if not player.has_method("get_hook_aim_info"):
			return
		var info: Dictionary = player.get_hook_aim_info()
		var type: String = info.get("type", "none")
		var hit_pos: Vector2 = info.get("pos", global_position)
		var local_hit: Vector2 = to_local(hit_pos)
		
		match type:
			"enemy":
				# ČERVENÉ mířidlo - Zásah nepřítele (Damage)
				var col = Color(1.0, 0.2, 0.2, 0.95)
				var s = 7.0 + pulse * 0.5
				draw_line(Vector2(-s, -s), Vector2(-s + 3, -s), col, 1.5)
				draw_line(Vector2(-s, -s), Vector2(-s, -s + 3), col, 1.5)
				draw_line(Vector2(s, -s), Vector2(s - 3, -s), col, 1.5)
				draw_line(Vector2(s, -s), Vector2(s, -s + 3), col, 1.5)
				draw_line(Vector2(-s, s), Vector2(-s + 3, s), col, 1.5)
				draw_line(Vector2(-s, s), Vector2(-s, s - 3), col, 1.5)
				draw_line(Vector2(s, s), Vector2(s - 3, s), col, 1.5)
				draw_line(Vector2(s, s), Vector2(s, -s + 3), col, 1.5)
				draw_circle(Vector2.ZERO, 1.5, col)
				draw_line(local_player, local_hit, Color(1.0, 0.3, 0.2, 0.45), 1.0)
				
			"world", "anchor":
				# ZLATÉ / TYRKYSOVÉ mířidlo - Lze se přitáhnout
				var col = Color(0.25, 0.95, 0.7, 0.95) if type == "world" else Color(1.0, 0.85, 0.25, 0.95)
				var r = 5.5 + pulse * 0.4
				draw_arc(Vector2.ZERO, r, 0.0, TAU, 16, col, 1.2)
				draw_line(Vector2(-r - 3, 0), Vector2(-r + 1, 0), col, 1.2)
				draw_line(Vector2(r - 1, 0), Vector2(r + 3, 0), col, 1.2)
				draw_line(Vector2(0, -r - 3), Vector2(0, -r + 1), col, 1.2)
				draw_line(Vector2(0, r - 1), Vector2(0, r + 3), col, 1.2)
				draw_circle(Vector2.ZERO, 1.2, col)
				draw_line(local_player, local_hit, Color(col.r, col.g, col.b, 0.4), 1.0)
				
			_:
				# ŠEDO-BRONZOVÉ mířidlo - Mimo dosah
				var col = Color(0.8, 0.65, 0.4, 0.45)
				draw_arc(Vector2.ZERO, 4.0, 0.0, TAU, 12, col, 1.0)
				draw_line(Vector2(-6, 0), Vector2(-2, 0), col, 1.0)
				draw_line(Vector2(2, 0), Vector2(6, 0), col, 1.0)
				draw_line(Vector2(0, -6), Vector2(0, -2), col, 1.0)
				draw_line(Vector2(0, 2), Vector2(0, 6), col, 1.0)
	else:
		# Prázdný slot
		var col = Color(0.6, 0.6, 0.6, 0.3)
		draw_circle(Vector2.ZERO, 1.5, col)
