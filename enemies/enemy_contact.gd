class_name EnemyContact

## Dotyk hráče s nepřítelem (oblast `area`, překryv podle tvarů jako u hazardů).
## Dopad "shora" vůči gravitaci hráče = odraz + obnovený dash (jako odraz od seekera v Celeste),
## jinak hráč utrží zásah (1 HP + odhoz). `stomp_normal` = vnější strana nepřítele, na kterou jde
## skočit (ZERO = z kterékoli strany, kam hráč padá - létající nepřátelé).

enum { NONE, STOMP, HIT }

const STOMP_BOUNCE := 280.0

static func resolve(enemy: Node2D, area: Area2D, stomp_normal: Vector2 = Vector2.ZERO, harmful: bool = true, damage: int = 1) -> int:
	var player = HazardKill.player_in(area)
	if player == null or player.is_dying:
		return NONE
	var g: float = player.gravity_dir
	var stompable := stomp_normal == Vector2.ZERO or stomp_normal.dot(Vector2(0.0, -g)) > 0.7
	var falling_onto: bool = player.velocity.y * g > 0.0 and (enemy.global_position.y - player.global_position.y) * g > 4.0
	if stompable and falling_onto:
		player.launch(Vector2(player.velocity.x, -STOMP_BOUNCE * g))
		player.refill_dash()
		return STOMP
	if not harmful:
		return NONE
	player.take_damage(damage, enemy.global_position)
	return HIT
