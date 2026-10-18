class_name HazardKill

## Překryv hazardu s hráčem podle tvarů (první CollisionShape2D oblasti) a aktuálních pozic ve scéně.
## Fyzikální server (get_overlapping_bodies i intersect_shape) vidí teleport kinematického těla až po
## dalším kroku, takže hazard by po respawnu zasáhl hráče podle jeho staré pozice (smrt hned po respawnu).

## Zabije hráče, který se právě teď překrývá s oblastí.
static func check(area: Area2D) -> void:
	var player = player_in(area)
	if player:
		player.die()

## Hráč, který se právě teď překrývá s oblastí (nebo null).
static func player_in(area: Area2D) -> Node:
	var col := area.get_child(0) as CollisionShape2D
	for player in area.get_tree().get_nodes_in_group("player"):
		var player_col := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if player_col and col.shape.collide(col.global_transform, player_col.shape, player_col.global_transform):
			return player
	return null
