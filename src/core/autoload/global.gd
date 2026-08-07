extends Node

# common variables
var transition_duration: float = 3.0
var chance_game_over: float = 0.15
var infected_apartment: int
var infected_floor: int
var current_apartment: int
var current_floor: int
var current_monster: String
var monster_texture: Texture
var current_item_number: int = 0

# spores
const TOTAL_FLOORS: int = 3
const LIFT_TIMER_WAIT_TIME: float = 60.0
const LIFT_TIMER_ONE_SHOT: bool = true

# anomaly
var has_anomaly: bool
var anomaly_located_floor: int
var touch_anomaly_cnt: int = 0
const ANOMALY_LIFT_ACTIVE_LOW: float = 15
const ANOMALY_LIFT_ACTIVE_HIGH: float = 30

var current_spore_level: String = ""
const TIMER_ACTIVATE_SPORE: float = 20.0
const TIMER_ACTIVATE_SPORE_NEW: float = 10.0

var icons: Dictionary = {
	"interact": "res://assets/art/interact_icon.png",
	"up": "res://assets/art/up_icon.png",
	"down": "res://assets/art/down_icon.png",
	"updown": "res://assets/art/updown_icon.png"
}

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

func _ready():
	print("GlobalData инициализирован")
