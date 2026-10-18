class_name FakeWall
extends TileMapLayer

## Falešná zeď (tajná cesta): kreslí se stejnými dlaždicemi jako zbytek místnosti, ale nemá kolizi.
## Leží nad hráčem a zakrývá, co je za ní; když je hráč uvnitř, zprůhlední se.

const FADED_ALPHA: float = 0.25

func _ready():
	collision_enabled = false
	z_index = 1
	# Detekční oblast přes všechny namalované buňky
	var used := get_used_rect()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(used.size * tile_set.tile_size)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(used.position * tile_set.tile_size) + shape.size / 2.0
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.add_child(col)
	add_child(area)
	area.body_entered.connect(func(body):
		if body.is_in_group("player"):
			_fade(FADED_ALPHA))
	area.body_exited.connect(func(body):
		if body.is_in_group("player"):
			_fade(1.0))

func _fade(alpha: float):
	create_tween().tween_property(self, "modulate:a", alpha, 0.2)
