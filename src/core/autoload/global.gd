extends Node

# Данные о текущем этаже
var transition_duration: float = 3.0

const TOTAL_FLOORS: int = 3
const LIFT_TIMER_WAIT_TIME: float = 10.0
const LIFT_TIMER_ONE_SHOT: bool = true

const TIMER_ACTIVATE_SPORE: float = 30.0
const TIMER_ACTIVATE_SPORE_NEW: float = 25.0

var infected_apartment: int
var infected_floor: int

var current_spore_level: String = ""
var current_item_number: int = 0

# Другие глобальные данные
var player_health = 100
var player_score = 0
var inventory = []

var item_cooldowns: Dictionary = {} # Хранит true/false для каждого слота
var item_charges: Dictionary = {}   # Хранит текущее количество зарядов
var item_names: Dictionary = {} 

func _ready():
	print("GlobalData инициализирован")
