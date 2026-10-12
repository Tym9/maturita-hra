extends Node2D

const GridPlatform = preload("res://mechanics/grid_platform.gd")
const GridSpikes = preload("res://mechanics/grid_spikes.gd")
const RoomBackdrop = preload("res://mechanics/room_backdrop.gd")

func _ready():
	print("[TEST_GRID_MODULAR] Starting modular grid unit tests...")
	
	# Test 1: GridPlatform properties & collision shape
	var plat = GridPlatform.new()
	plat.tiles_x = 6
	plat.tiles_y = 2
	plat.cell_size = 16
	plat.theme = GridPlatform.THEME_STEAM_BRONZE
	add_child(plat)
	plat._ready()
	
	var col = plat.get_node_or_null("CollisionShape2D")
	assert(col != null, "GridPlatform should create a CollisionShape2D")
	var shape = col.shape as RectangleShape2D
	assert(shape != null, "Shape should be RectangleShape2D")
	assert(shape.size == Vector2(96, 32), "Shape size should match 6*16 x 2*16 = (96, 32), got: %s" % shape.size)
	assert(col.position == Vector2(48, 16), "Col position should be centered at (48, 16), got: %s" % col.position)
	print("[TEST_GRID_MODULAR] TEST 1 (GridPlatform geometry): PASS")
	
	# Test 2: GridSpikes properties & collision shape
	var spikes = GridSpikes.new()
	spikes.count = 3
	spikes.orientation = GridSpikes.ORIENTATION_UP
	spikes.cell_size = 16
	add_child(spikes)
	spikes._ready()
	
	var spike_col = spikes.get_node_or_null("CollisionShape2D")
	assert(spike_col != null, "GridSpikes should create a CollisionShape2D")
	var spike_shape = spike_col.shape as RectangleShape2D
	assert(spike_shape != null, "Spike shape should be RectangleShape2D")
	print("[TEST_GRID_MODULAR] TEST 2 (GridSpikes geometry): PASS")
	
	# Test 3: RoomBackdrop positioning
	var backdrop = RoomBackdrop.new()
	backdrop.room_x = 2
	backdrop.room_y = 1
	add_child(backdrop)
	backdrop._ready()
	assert(backdrop.position == Vector2(640, 180), "RoomBackdrop position should be (640, 180), got: %s" % backdrop.position)
	print("[TEST_GRID_MODULAR] TEST 3 (RoomBackdrop coordinates): PASS")
	
	print("[TEST_GRID_MODULAR] ALL TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
