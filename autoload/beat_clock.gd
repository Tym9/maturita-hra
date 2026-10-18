extends Node

## Sdílené rytmické hodiny hazardů (pístové drtiče, tesla oblouky, pily). Každý hazard počítá svou
## fázi z `time`, takže jsou všechny v místnosti synchronní. Stojí, když je hra pozastavená
## (i během zmrazení přechodu); room_reset je vrací na nulu, takže po respawnu začne rytmus stejně.

var time: float = 0.0

func _ready():
	Global.room_reset.connect(func(): time = 0.0)

func _physics_process(delta):
	time += delta

## Čas uvnitř cyklu délky `period` posunutého o `offset` (0 .. period).
func phase(period: float, offset: float = 0.0) -> float:
	return fposmod(time + offset, maxf(period, 0.01))
