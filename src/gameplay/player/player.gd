extends CharacterBody2D

const DIALOGUE_BUBBLE = preload("res://src/core/dialogue_box/dialogue_box.tscn")
const SPEED: float = 300.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var dialogue_label: Label = $DialogueBox/DialogueBox
@onready var dialogue_timer: Timer = $DialogueBox/DialogueTimer
@onready var state_machine: StateMachine = $StateMachine # Ссылка на твою машину состояний

var current_floor: int
var at_stairs: bool = false
var can_up: bool
var can_down: bool
var at_lift: bool = false
var can_use_lift: bool 
var is_lift_broken: bool = false
var current_apartment: int
var at_door: bool = false
var at_spore_area: bool = false

func _ready() -> void:
	dialogue_box.hide() 
	dialogue_timer.timeout.connect(_on_dialogue_timeout)
	
	# Подписки на сигналы окружения
	Events.player_entered_floor.connect(_on_entered_floor)
	Events.player_entered_stairs.connect(_on_entered_stairs)
	Events.player_exited_stairs.connect(_on_exited_stairs)
	Events.player_entered_lift.connect(_on_entered_lift)
	Events.player_exited_lift.connect(_on_exited_lift)
	Events.lift_crashed.connect(_on_lift_denied)
	Events.camera_transition_started.connect(_on_camera_started)
	Events.camera_transition_finished.connect(_on_camera_finished)
	Events.player_entered_apartment.connect(_on_entered_apartment)
	Events.player_exited_apartment.connect(_on_exited_apartment)
	Events.get_text_line.connect(_on_get_text_line)
	Events.player_entered_spore_area.connect(_on_entered_spore)
	Events.player_exited_spore_area.connect(_on_exited_spore)


func try_go_up() -> void:
	if can_up:
		position.y -= 720
		dialogue_box.hide() 
	elif at_stairs:
		show_dialogue("Выше подниматься некуда...")


func try_go_down() -> void:
	if can_down:
		position.y += 720
		dialogue_box.hide()
	elif at_stairs:
		show_dialogue("Спускаться некуда...")


func try_use_lift() -> void:
	if can_use_lift:
		position.y += 1440
		dialogue_box.hide()
	elif is_lift_broken and at_lift:
		show_dialogue("Лифт застрял и больше не работает")
	elif at_lift:
		show_dialogue("Лифт сейчас на третьем этаже")


func _on_camera_started() -> void:
	state_machine.change_state(state_machine.get_node("FrozenState"))


func _on_camera_finished() -> void:
	state_machine.change_state(state_machine.get_node("IdleState"))


func _on_entered_stairs(is_can_up: bool, is_can_down: bool) -> void:
	print("Игрок может подняться: %s, Игрок может спуститься: %s" % [is_can_up, is_can_down])
	can_up = is_can_up
	can_down = is_can_down
	at_stairs = true # <--- ДОБАВЛЕНО: Игрок подошел к лестнице


func _on_exited_stairs() -> void:
	print("Игрок вышел из зоны лестницы")
	can_up = false
	can_down = false
	at_stairs = false # <--- ДОБАВЛЕНО: Игрок ушел от лестницы


func _on_entered_lift(is_usable: bool) -> void:
	print("Игрок может спуститься: ", is_usable)
	can_use_lift = false if is_lift_broken else is_usable
	at_lift = true


func _on_exited_lift() -> void:
	print("Игрок вышел из зоны лифта")
	can_use_lift = false
	at_lift = false


func _on_entered_floor(floor_number: int) -> void:
	current_floor = floor_number
	print("Игрок на этаже: ", current_floor)


func show_dialogue(text: String) -> void:
	dialogue_label.text = text
	dialogue_box.show()
	dialogue_timer.start() # Запускаем отсчет 2 секунд


func _on_dialogue_timeout() -> void:
	dialogue_box.hide() # Прячем окно, когда таймер заканчивается


func _on_lift_denied() -> void:
	can_use_lift = false
	is_lift_broken = true
	print("Lift is broken: ", is_lift_broken)


func _on_entered_apartment(apartment_number: int) -> void:
	current_apartment = apartment_number
	at_door = true
	print("Вход в зону кв ", apartment_number, " | at_door: ", at_door)


func _on_exited_apartment() -> void:
	at_door = false
	print("Выход из зоны кв | at_door: ", at_door)


func _on_entered_spore(spore_level: String) -> void:
	print("player._on_entered_spore.spore_level: ", spore_level)
	at_spore_area = true


func _on_exited_spore() -> void:
	at_spore_area = false


func _on_get_text_line(floor_number: int, apartment_number: int) -> void:
	current_floor = floor_number
	current_apartment = apartment_number
	var dialog_box_pox_x: int
	var dialog_box_pox_y: int
	var dialogue_line: String
	var floor_settings = Settings.settings.get("floors_settings").get(floor_number)
	var apartments = floor_settings.get("apartments")
	
	for apartment in apartments:
		if apartment.get("id") == current_apartment:
			var dialog_box_settings = apartment.get("dialogue_box")
			dialog_box_pox_x = dialog_box_settings.get("position_x")
			dialog_box_pox_y = dialog_box_settings.get("position_y")
			print("Vector2(x, y): ", dialog_box_pox_x, ", ", dialog_box_pox_y)
	
	dialogue_line = get_unique_dialogue_line(floor_number, apartment_number)
	
	spawn_door_dialogue(Vector2(dialog_box_pox_x,dialog_box_pox_y), dialogue_line)


func spawn_door_dialogue(door_global_position: Vector2, text: String = "...") -> void:
	var bubble_instance = DIALOGUE_BUBBLE.instantiate()
	
	get_tree().current_scene.add_child(bubble_instance)
	
	var offset_position = door_global_position + Vector2(0, -20) # Поднимаем на 20 пикселей выше центра двери
	
	bubble_instance.setup(text, offset_position)


func get_unique_dialogue_line(floor_number: int, apt_number: int) -> String:
	var win_condition = WinConditionManager.floor_condition.get(floor_number)
	
	if win_condition == null:
		return "..." 
		
	var apartments = win_condition.get("apartments", [])
	
	for apt in apartments:
		if apt["apartment_number"] == apt_number:
			
			# Получаем текущее время работы игры в миллисекундах
			var current_time = Time.get_ticks_msec()
			
			# Проверяем, стучали ли мы уже в эту дверь (если нет, по умолчанию 0)
			var last_interact_time = apt.get("last_interaction_time", 0)
			
			# Если время записано и прошло меньше 15000 миллисекунд (15 сек)
			if last_interact_time > 0 and (current_time - last_interact_time) < 15000:
				return "Не беспокойте меня хотя бы немного..."
				
			# Обновляем таймер: записываем текущее время как момент последнего стука
			apt["last_interaction_time"] = current_time
			
			# Получаем доступ к массиву фраз
			var dialog_lines: Array = apt["dweller"]["full_dialog_lines"]
			
			if dialog_lines.is_empty():
				return "..." 
				
			var random_index = randi() % dialog_lines.size()
			var selected_line = dialog_lines[random_index]
			dialog_lines.remove_at(random_index)
			
			return selected_line
			
	return "Дверь заперта."
