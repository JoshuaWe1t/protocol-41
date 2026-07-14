extends CharacterBody2D


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
var can_use_lift: bool
# Переменная, которая управляет возможностью ходить
var is_frozen: bool = false
# Запоминаем нормальный масштаб игрока (обычно это 1, 1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)


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
	# Подписываемся на новые сигналы камеры
	Events.camera_transition_started.connect(_on_camera_started)
	Events.camera_transition_finished.connect(_on_camera_finished)


func _physics_process(_delta: float) -> void:

	var direction := Input.get_axis("backward", "forward")
	# ЕСЛИ ИГРОК ЗАМОРОЖЕН, МЫ ПРЕРЫВАЕМ ФУНКЦИЮ И НЕ ПРИНИМАЕМ НАЖАТИЯ КЛАВИШ
	if is_frozen:
		velocity = Vector2.ZERO 
		anim_player.play("idle")
		move_and_slide()
		return 
	
	if direction:
		velocity.x = direction * SPEED
		anim_player.play("walk")
		
		# Разворачиваем спрайт влево или вправо в зависимости от направления движения
		sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim_player.play("idle") # <--- Если никуда не идет, включаем покой
	
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
		else:
			show_dialogue("Лифт сейчас на третьем этаже")

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
	can_use_lift = is_usable


func _on_exited_lift() -> void:
	print("Игрок вышел из зоны лифта")
	can_use_lift = false


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
