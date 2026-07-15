extends Node


var current_floor: int
var total_floors: int = Global.TOTAL_FLOORS

@onready var lift_timer: Timer = $TimerLiftAccess


func _ready() -> void:
	lift_timer.wait_time = Global.LIFT_TIMER_WAIT_TIME
	lift_timer.one_shot = Global.LIFT_TIMER_ONE_SHOT
	lift_timer.start()
	
	# 1. Привязываем номера этажей не только к входу, но и к ВЫХОДУ с лестниц
	get_node("Floor1/Stairs").body_entered.connect(_on_stairs_entered.bind(1))
	get_node("Floor2/Stairs").body_entered.connect(_on_stairs_entered.bind(2))
	get_node("Floor3/Stairs").body_entered.connect(_on_stairs_entered.bind(3))
	
	get_node("Floor1/Stairs").body_exited.connect(_on_stairs_exited.bind(1))
	get_node("Floor2/Stairs").body_exited.connect(_on_stairs_exited.bind(2))
	get_node("Floor3/Stairs").body_exited.connect(_on_stairs_exited.bind(3))
	
	# Подключаемся к сигналам зон этажей
	get_node("Floor1/FloorZone1").body_entered.connect(_on_floor_zone_entered.bind(1))
	get_node("Floor2/FloorZone2").body_entered.connect(_on_floor_zone_entered.bind(2))
	get_node("Floor3/FloorZone3").body_entered.connect(_on_floor_zone_entered.bind(3))
	
	# 2. Привязываем номера этажей к ВЫХОДУ из лифта
	get_node("Floor1/Lift").body_entered.connect(_on_lift_entered.bind(1))
	get_node("Floor2/Lift").body_entered.connect(_on_lift_entered.bind(2))
	get_node("Floor3/Lift").body_entered.connect(_on_lift_entered.bind(3))

	get_node("Floor1/Lift").body_exited.connect(_on_lift_exited.bind(1))
	get_node("Floor2/Lift").body_exited.connect(_on_lift_exited.bind(2))
	get_node("Floor3/Lift").body_exited.connect(_on_lift_exited.bind(3))

	# managment lift life timer
	lift_timer.timeout.connect(_on_timer_lift_access_timeout)


func _on_stairs_entered(body: Node2D, floor_number: int) -> void:
	current_floor = floor_number
	if body.name == "Player":
		Events.player_entered_stairs.emit(can_go_up(), can_go_down())


# 3. Принимаем номер этажа и проверяем его
func _on_stairs_exited(body: Node2D, floor_number: int) -> void:
	if body.name == "Player":
		# Если номер лестницы, с которой мы ушли, совпадает с нашим ТЕКУЩИМ этажом, 
		# значит игрок реально отошел от лестницы ножками.
		# Если не совпадает — значит это фантомный сигнал от телепортации, игнорируем его!
		if current_floor == floor_number:
			Events.player_exited_stairs.emit()


func _on_lift_entered(body: Node2D, floor_number: int) -> void:
	current_floor = floor_number
	Events.player_entered_floor.emit(current_floor)
	if body.name == "Player" and current_floor == 3:
		Events.player_entered_lift.emit(true)
	elif body.name == "Player":
		Events.player_entered_lift.emit(false)


# 4. То же самое делаем для лифта
func _on_lift_exited(body: Node2D, floor_number: int) -> void:
	if body.name == "Player":
		if current_floor == floor_number:
			Events.player_exited_lift.emit()


func _on_floor_zone_entered(body: Node2D, floor_number: int) -> void:
	current_floor = floor_number
	if body.name == "Player":
		Events.player_entered_floor.emit(current_floor)


func get_current_floor():
	return current_floor


func can_go_up():
	return current_floor < total_floors


func can_go_down():
	return current_floor > 1


func _on_timer_lift_access_timeout() -> void:
	Events.lift_crashed.emit()
