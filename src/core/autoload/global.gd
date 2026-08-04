extends Node

# Данные о текущем этаже
var transition_duration: float = 3.0

const TOTAL_FLOORS: int = 3
const LIFT_TIMER_WAIT_TIME: float = 30.0
const LIFT_TIMER_ONE_SHOT: bool = true

var has_anomaly: bool
var anomaly_located_floor: int
const ANOMALY_LIFT_ACTIVE_LOW: float = 10
const ANOMALY_LIFT_ACTIVE_HIGH: float = 30

const TIMER_ACTIVATE_SPORE: float = 25.0
const TIMER_ACTIVATE_SPORE_NEW: float = 10.0

var infected_apartment: int
var infected_floor: int

var current_spore_level: String = ""
var current_item_number: int = 0
var current_apartment: int
var current_floor: int

# Другие глобальные данные
var player_health = 100
var player_score = 0
var inventory = []

var item_cooldowns: Dictionary = {} # Хранит true/false для каждого слота
var item_charges: Dictionary = {}   # Хранит текущее количество зарядов
var item_names: Dictionary = {} 

var icons: Dictionary = {
	"interact": "res://assets/art/interact_icon.png",
	"up": "res://assets/art/up_icon.png",
	"down": "res://assets/art/down_icon.png",
	"updown": "res://assets/art/updown_icon.png"
}

var touch_anomaly_cnt: int = 0
var chance_game_over: float = 0.15

const NAME_OPER_LIST = [
	'Виктор Строгов',
	'Юрий Зимин',
	'Григорий Быков',
	'Алексей Воронов'
]

const SPRITE_OPER_LIST = [
	preload("res://assets/art/avatar1.png"),
	preload("res://assets/art/avatar2.png"),
	preload("res://assets/art/avatar3.png"),
	preload("res://assets/art/avatar4.png")
]

var current_monster: String

func _ready():
	print("GlobalData инициализирован")
