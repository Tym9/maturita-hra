class_name Gate
extends StaticBody2D

## Mosazná brána otevíraná přepínačem (GateSwitch). Počátek = levý horní roh.
## Otevřená brána ztratí kolizi a zasune se nahoru.

@export var size: Vector2 = Vector2(16, 48)

var col: CollisionShape2D = null

func _ready():
	collision_layer = 1
	col = CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	col.position = size / 2.0
	add_child(col)

func open(animate: bool = true):
	col.set_deferred("disabled", true)
	if not animate:
		hide()
		return
	var tw := create_tween()
	tw.tween_property(self, "scale:y", 0.05, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(hide)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.14, 0.08))
	for x in range(2, int(size.x), 5):
		draw_rect(Rect2(x, 0, 2, size.y), Color(0.85, 0.65, 0.28))
	draw_rect(Rect2(0, 0, size.x, 3), Color(0.55, 0.4, 0.2))
