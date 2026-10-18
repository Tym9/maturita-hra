extends Node2D

## Test držení zdi v obou režimech nastavení (Shift Grab / automaticky).

@onready var player = $Player
var step = 0
var original_mode = 0
var held_y = 0.0
var held_stamina = 0.0

func _ready():
	print("[TEST_WALL_GRAB] start")
	original_mode = Global.grab_mode
	Global.grab_mode = Global.GRAB_BUTTON
	Input.action_press("move_right")

func _physics_process(_delta):
	step += 1
	if step == 30:
		assert(player.is_on_wall(), "Hráč musí být na zdi")
		assert(player.velocity.y > 0.0, "Bez Grabu hráč po zdi sjíždí")
		print("[TEST_WALL_GRAB] Button mode bez Shiftu: sjíždí PASS")
		Input.action_press("grab")
	if step == 45:
		assert(player.velocity.y == 0.0, "S Grabem hráč visí")
		Input.action_release("move_right")
		held_y = player.global_position.y
		held_stamina = player.stamina
	if step == 70:
		assert(player.is_on_wall(), "Grab drží hráče na zdi i bez směru")
		assert(is_equal_approx(player.global_position.y, held_y), "Grab: žádné sjíždění")
		assert(player.stamina < held_stamina, "Grab ubírá staminu")
		print("[TEST_WALL_GRAB] Button mode se Shiftem: visí a ubírá staminu PASS")
		Input.action_release("grab")
	if step == 90:
		assert(player.velocity.y > 0.0, "Po puštění Grabu hráč sjíždí")
		Global.grab_mode = Global.GRAB_AUTO
	if step == 110:
		assert(player.velocity.y == 0.0, "Auto režim: hráč visí bez tlačítek")
		print("[TEST_WALL_GRAB] Auto mode: visí bez tlačítek PASS")
		player.stamina = 0.05
	if step == 130:
		assert(player.stamina == 0.0, "Stamina došla")
		assert(player.velocity.y > player.WALL_SLIDE_SPEED, "Bez staminy hráč padá")
		print("[TEST_WALL_GRAB] Auto mode: bez staminy padá PASS")
		Global.grab_mode = original_mode
		print("[TEST_WALL_GRAB] ALL PASSED")
		get_tree().quit()
