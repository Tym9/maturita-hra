extends Area2D

# Lékárnička / steampunková souprava první pomoci
# Obnovuje 1 srdíčko hráči, jemně se vznáší a po sebrání zmizí se zábleskem.

var hover_time: float = 0.0
var base_y: float = 0.0
var is_collected: bool = false

func _ready():
	base_y = position.y
	body_entered.connect(_on_body_entered)
	z_index = 5

func _process(delta):
	if is_collected:
		return
	hover_time += delta
	position.y = base_y + sin(hover_time * 3.5) * 3.0
	queue_redraw()

func _draw():
	if is_collected:
		return
	# Vykreslení stylové steampunk lékárničky
	# Bronzová brašna
	var bag_rect = Rect2(-6, -5, 12, 10)
	draw_rect(bag_rect, Color(0.2, 0.12, 0.08, 0.95))
	draw_rect(Rect2(-5, -4, 10, 8), Color(0.65, 0.42, 0.22, 1.0))
	
	# Zlaté rohy brašny
	draw_rect(Rect2(-6, -5, 2, 2), Color(0.9, 0.75, 0.3, 1.0))
	draw_rect(Rect2(4, -5, 2, 2), Color(0.9, 0.75, 0.3, 1.0))
	draw_rect(Rect2(-6, 3, 2, 2), Color(0.9, 0.75, 0.3, 1.0))
	draw_rect(Rect2(4, 3, 2, 2), Color(0.9, 0.75, 0.3, 1.0))
	
	# Červený kříž první pomoci
	var col_cross = Color(0.95, 0.2, 0.22, 1.0)
	draw_rect(Rect2(-1, -3, 2, 6), col_cross)
	draw_rect(Rect2(-3, -1, 6, 2), col_cross)
	
	# Jemná zelenkavá léčivá aura
	var aura_pulse = (sin(hover_time * 4.0) + 1.0) * 0.5
	draw_arc(Vector2.ZERO, 9.0 + aura_pulse * 1.5, 0.0, TAU, 16, Color(0.3, 0.95, 0.6, 0.25 + aura_pulse * 0.2), 1.0)

func _on_body_entered(body):
	if is_collected:
		return
	if body.name == "Player":
		if body.has_method("heal"):
			var healed = body.heal(1)
			if healed:
				is_collected = true
				_play_pickup_fx()

func _play_pickup_fx():
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
	tw.chain().tween_callback(queue_free)
