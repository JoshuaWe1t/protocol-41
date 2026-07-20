extends Node

# Данные о текущем этаже
var transition_duration: float = 3.0

const TOTAL_FLOORS: int = 3
const LIFT_TIMER_WAIT_TIME: float = 10.0
const LIFT_TIMER_ONE_SHOT: bool = true

var infected_apartment: int
var infected_floor: int

# Другие глобальные данные
var player_health = 100
var player_score = 0
var inventory = []

func _ready():
	print("GlobalData инициализирован")
