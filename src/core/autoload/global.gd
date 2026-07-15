extends Node

# Данные о текущем этаже
var current_floor: int = 1
var TOTAL_FLOORS: int = 3
var transition_duration: float = 3.0

const LIFT_TIMER_WAIT_TIME: float = 10.0
const LIFT_TIMER_ONE_SHOT: bool = true

# Другие глобальные данные
var player_health = 100
var player_score = 0
var inventory = []

func _ready():
	print("GlobalData инициализирован")
