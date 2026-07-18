extends CharacterBody2D


# Загружаем сцену диалогового окна один раз при старте игры
const DIALOGUE_BUBBLE = preload("res://src/core/dialogue_box/dialogue_box.tscn")


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D # Ссылка на спрайт для разворота
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var dialogue_label: Label = $DialogueBox/DialogueBox
@onready var dialogue_timer: Timer = $DialogueBox/DialogueTimer


const SPEED: float = 300.0


var current_floor: int
var at_stairs: bool = false
var can_up: bool
var can_down: bool
var at_lift: bool = false
var can_use_lift: bool 
var is_lift_broken: bool = false
# Переменная, которая управляет возможностью ходить
var is_frozen: bool = false
# Запоминаем нормальный масштаб игрока (обычно это 1, 1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var current_apartment: int
var at_door: bool = false
var is_knocking: bool = false


func _ready() -> void:
	print("PlayerPosition: ", self.position)
	anim_player.play("idle")
	
	# Прячем диалог при старте на всякий случай
	dialogue_box.hide() 
	
	# Подключаем таймер
	dialogue_timer.timeout.connect(_on_dialogue_timeout)
	# Подключаемся к сигналу
	Events.player_entered_floor.connect(_on_entered_floor)
	Events.player_entered_stairs.connect(_on_entered_stairs)
	Events.player_exited_stairs.connect(_on_exited_stairs)
	Events.player_entered_lift.connect(_on_entered_lift)
	Events.player_exited_lift.connect(_on_exited_lift)
	Events.lift_crashed.connect(_on_lift_denied)
	# Подписываемся на новые сигналы камеры
	Events.camera_transition_started.connect(_on_camera_started)
	Events.camera_transition_finished.connect(_on_camera_finished)
	# Подписываемся под новые сигналы для взаимодействия с дверьми
	Events.player_entered_apartment.connect(_on_entered_apartment)
	Events.player_exited_apartment.connect(_on_exited_apartment)
	Events.get_text_line.connect(_on_get_text_line)


func _physics_process(_delta: float) -> void:

	var direction := Input.get_axis("backward", "forward")
	# ЕСЛИ ИГРОК ЗАМОРОЖЕН, МЫ ПРЕРЫВАЕМ ФУНКЦИЮ И НЕ ПРИНИМАЕМ НАЖАТИЯ КЛАВИШ
	if is_frozen:
		velocity = Vector2.ZERO 
		anim_player.play("idle")
		move_and_slide()
		return 
	elif is_frozen and at_door:
		velocity = Vector2.ZERO
		
	
	if direction:
		velocity.x = direction * SPEED
		if not is_knocking: # <--- Добавили проверку
			anim_player.play("walk")
		sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_knocking: # <--- Добавили проверку
			anim_player.play("idle")
	
	# Обработка движения ВВЕРХ
	if Input.is_action_just_pressed("go_up"):
		if can_up:
			self.position.y -= 720
			print("PlayerPosition: ", self.position)
			dialogue_box.hide() 
		elif at_stairs: # <--- ДОБАВЛЕНО: Показываем диалог, только если стоим у лестницы
			show_dialogue("Выше подниматься некуда...")

	# Обработка движения ВНИЗ
	if Input.is_action_just_pressed("go_down"):
		if can_down:
			self.position.y += 720
			print("PlayerPosition: ", self.position)
			dialogue_box.hide()
		elif at_stairs: # <--- ДОБАВЛЕНО: Показываем диалог, только если стоим у лестницы
			show_dialogue("Спускаться некуда...")


	if Input.is_action_just_pressed("interact"):
		if can_use_lift:
			self.position.y += 1440
			print("PlayerPosition: ", self.position)
			dialogue_box.hide()
		elif is_lift_broken and at_lift:
			show_dialogue("Лифт застрял и больше не работает")
		elif at_lift:
			show_dialogue("Лифт сейчас на третьем этаже")
	
	
	if Input.is_action_just_pressed("interact"):
		print("Interact")
		if at_door and not is_knocking: # <--- Проверяем, что уже не стучим
			is_knocking = true          # Включаем блокировку анимаций
			anim_player.play("knock")   # Запускаем стук
			
			# Ждем завершения именно этой анимации
			await anim_player.animation_finished 
			
			is_knocking = false         # Снимаем блокировку
			Events.get_text_line.emit(current_floor, current_apartment)

	move_and_slide()


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


# Функции-обработчики сигналов камеры
func _on_camera_started() -> void:
	is_frozen = true
	# Здесь также можно остановить анимацию бега игрока, 
	# чтобы он не "бежал на месте" во время движения камеры.
	# $AnimatedSprite2D.play("idle") 

func _on_camera_finished() -> void:
	is_frozen = false


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


func _on_get_text_line(floor_number: int, apartment_number: int) -> void:
	current_floor = floor_number
	current_apartment = apartment_number
	var dialog_box_pox_x: int
	var dialog_box_pox_y: int
	var floor_settings = Settings.settings.get("floors_settings").get(floor_number)
	var apartments = floor_settings.get("apartments")
	
	for apartment in apartments:
		if apartment.get("id") == current_apartment:
			var dialog_box_settings = apartment.get("dialogue_box")
			dialog_box_pox_x = dialog_box_settings.get("position_x")
			dialog_box_pox_y = dialog_box_settings.get("position_y")
			print("Vector2(x, y): ", dialog_box_pox_x, ", ", dialog_box_pox_y)
	
	
	
	spawn_door_dialogue(Vector2(dialog_box_pox_x,dialog_box_pox_y))


# Эта функция вызывается, когда игрок успешно постучал в дверь
func spawn_door_dialogue(door_global_position: Vector2, text: String = "...") -> void:
	# 2. Создаем копию загруженной сцены
	var bubble_instance = DIALOGUE_BUBBLE.instantiate()
	
	# 3. Добавляем облачко на основную сцену игры.
	# Лучше всего добавлять его в текущую сцену (current_scene), а не внутрь двери.
	# Если добавить внутрь двери, текст может случайно отмасштабироваться вместе с ней.
	get_tree().current_scene.add_child(bubble_instance)
	
	# 4. Передаем координаты (например, позицию двери, поднятую чуть выше) и текст
	var offset_position = door_global_position + Vector2(0, -20) # Поднимаем на 20 пикселей выше центра двери
	
	bubble_instance.setup(text, offset_position)
