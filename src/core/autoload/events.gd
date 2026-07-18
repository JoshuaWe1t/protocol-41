extends Node

# Сигналы для этажа
@warning_ignore("unused_signal")
signal player_entered_floor(floor_number: int)

# Сигналы для взаимодействия с лестницей
@warning_ignore("unused_signal")
signal player_entered_stairs(is_can_up: bool, is_can_down: bool)
@warning_ignore("unused_signal")
signal player_exited_stairs

# Сигналы для взаимодействия с лифтом
@warning_ignore("unused_signal")
signal player_entered_lift(is_usable: bool)
@warning_ignore("unused_signal")
signal player_exited_lift
@warning_ignore("unused_signal")
signal lift_crashed

# Сигналы для апартаментов
@warning_ignore("unused_signal")
signal player_entered_apartment(apartment_number: int)
@warning_ignore("unused_signal")
signal player_exited_apartment()
@warning_ignore("unused_signal")
signal get_text_line(floor_number: int, apartment_number: int)

# Сигналы для игрока
#@warning_ignore("unused_signal")
#signal player_health_changed(new_health)
#@warning_ignore("unused_signal")
#signal player_died

# Сигналы для UI
@warning_ignore("unused_signal")
signal floor_changed(floor_number)
@warning_ignore("unused_signal")
signal item_collected(item_name)

@warning_ignore("unused_signal")
signal camera_transition_started
@warning_ignore("unused_signal")
signal camera_transition_finished

func _ready():
	print("Events система инициализирована")
