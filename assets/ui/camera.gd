extends Camera2D


var screen_height: float = 720.0 


func _ready() -> void:
	Events.player_entered_floor.connect(_on_player_entered_floor)


func _on_player_entered_floor(floor_number: int) -> void:
	print("camera._on_player_entered_floor.floor_number: ", floor_number)
	move_camera_to_floor(floor_number)


func move_camera_to_floor(floor_number: int, duration: float = 3.0) -> void:
	var target_y = - (floor_number - 1) * screen_height
	
	# --- НОВАЯ ПРОВЕРКА ---
	# Если камера уже находится на целевой высоте (с небольшой погрешностью),
	# значит мы только что запустили игру или уже на этом этаже.
	# Прерываем функцию, чтобы не замораживать игрока!
	if abs(global_position.y - target_y) < 1.0:
		return
	
	# Сразу сообщаем игре, что камера начала движение
	Events.camera_transition_started.emit()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "global_position:y", target_y, duration)
	
	# Ждем, пока анимация завершится
	tween.finished.connect(_on_transition_finished)


func _on_transition_finished() -> void:
	# Сообщаем игре, что переход окончен (игрок снова может ходить)
	Events.camera_transition_finished.emit()
