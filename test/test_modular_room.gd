extends Node2D

@onready var player = $Player
var step_count = 0
var initial_spawn = Vector2.ZERO

func _ready():
	print("[TEST_MODULAR_ROOM] Starting player interaction test with modular grid...")
	initial_spawn = player.global_position

func _physics_process(delta):
	step_count += 1
	
	# Krok 1-30: Hráč dopadne na GridPlatform podlahu
	if step_count == 30:
		assert(player.is_on_floor(), "Player should be standing on GridPlatform floor")
		print("[TEST_MODULAR_ROOM] Step 1 (Player grounded on GridPlatform): PASS")
		# Simulace skoku
		player.velocity.y = -280.0
		player.velocity.x = 80.0
	
	# Krok 60: Hráč ve vzduchu po skoku z modulární plošiny
	if step_count == 60:
		assert(not player.is_on_floor(), "Player should be airborne after jump")
		print("[TEST_MODULAR_ROOM] Step 2 (Player jumping over modular terrain): PASS")
	
	# Krok 90: Zkouška zásahu bodáků (GridSpikes)
	if step_count == 90:
		# Teleportujeme hráče do bodáků pro ověření detekce
		var spikes = $GridSpikes
		player.global_position = spikes.global_position + Vector2(16, 8)
	
	# Krok 100: Ověření, že bodáky zranily/zabili hráče a proběhl respawn
	if step_count == 100:
		# Po úmrtí na bodácích se hráč respawnuje na spawn_pointu místnosti
		assert(player.global_position.distance_to(player.spawn_point) < 40.0, "Player should respawn at room entrance")
		print("[TEST_MODULAR_ROOM] Step 3 (GridSpikes kill & room respawn): PASS")
		print("[TEST_MODULAR_ROOM] ALL MODULAR ROOM INTERACTION TESTS PASSED!")
		get_tree().quit(0)
