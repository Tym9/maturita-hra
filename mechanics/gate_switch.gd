class_name GateSwitch
extends Area2D

## Přepínač pro zpětné / klíčové cesty: dotyk hráče ho přepne a otevře propojené brány (Gate).
## Stav se ukládá trvale pro kapitolu (SaveManager flag "room_id/název"), brána zůstane otevřená
## i po restartu. Signál `activated` může zjevit HIDDEN krystal (reveal_source).

signal activated

@export var gates: Array[NodePath] = []

var is_on: bool = false
var flag_key: String = ""

func _ready():
	collision_layer = 0
	collision_mask = 1
	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		col.shape = RectangleShape2D.new()
		col.shape.size = Vector2(12, 16)
		add_child(col)
	var room := Room.of(self)
	flag_key = "%s/%s" % [room.room_id if room else owner.scene_file_path if owner else "", name]
	body_entered.connect(_on_body_entered)
	if SaveManager.get_flag(flag_key):
		_switch_on(false)
		activated.emit.call_deferred() # až budou připojení posluchači (HIDDEN krystaly)

func _on_body_entered(body):
	if is_on or not body.is_in_group("player"):
		return
	_switch_on(true)
	SaveManager.set_flag(flag_key)
	activated.emit()

func _switch_on(animate: bool):
	is_on = true
	queue_redraw()
	for path in gates:
		var gate = get_node_or_null(path)
		if gate and gate.has_method("open"):
			gate.open(animate)

func _draw():
	# Mosazná páka: vypnutá nakloněná doleva, zapnutá doprava s tyrkysovým světlem
	draw_rect(Rect2(-6, 4, 12, 4), Color(0.55, 0.4, 0.2))
	var tip := Vector2(5, -6) if is_on else Vector2(-5, -6)
	draw_line(Vector2(0, 5), tip, Color(0.85, 0.65, 0.28), 2.0)
	draw_circle(tip, 2.5, Color(0.25, 0.95, 0.8) if is_on else Color(0.85, 0.65, 0.28))
