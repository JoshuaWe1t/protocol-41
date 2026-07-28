extends Node

@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var timer = $Timer

# Переменная для проверки, может ли игрок уже взаимодействовать с аномалией
var is_active: bool = false 

func _ready() -> void:
	# 1. Если этаж равен 0 — значит, аномалии в этом матче нет
	if Global.anomaly_located_floor == 0:
		print("Аномалия на этом уровне не сгенерирована.")
		queue_free() # Удаляем узел аномалии со сцены (или просто выходим через return)
		return

	# 2. Достаем данные с правильными дефолтными типами (Словарь {} и Массив [])
	var anomaly_settings_dict: Dictionary = Settings.settings.get("anomaly_settings", {})
	var anomaly_settings_list: Array = anomaly_settings_dict.get(Global.anomaly_located_floor, [])

	# 3. Проверяем, что список точек не пустой
	if anomaly_settings_list.is_empty():
		print("Ошибка: Точки спавна для этажа %d не найдены!" % Global.anomaly_located_floor)
		return

	# 4. Если все проверки пройдены, выбираем точку
	var random_pos_data: Dictionary = anomaly_settings_list.pick_random()
	var pos_x: float = random_pos_data.get('position_x', 0.0)
	var pos_y: float = random_pos_data.get('position_y', 0.0)
	
	collision_shape.position = Vector2(pos_x, pos_y)
	print("anomaly_manager.collision_shape.position: Vector2(%d, %d)" % [pos_x, pos_y]) 
	
	# 1. Задаем случайную ширину от 50 до 250
	# ВАЖНО: Мы делаем duplicate(), чтобы не изменить базовый ресурс RectangleShape2D,
	# иначе все остальные аномалии в будущих играх тоже изменят размер.
	#var shape = collision_shape.shape.duplicate() as RectangleShape2D
	var shape = collision_shape.shape
	if shape:
		shape.size.x = randf_range(50.0, 250.0)
		collision_shape.shape = shape
	
	# 2. Отключаем взаимодействие на старте
	is_active = false
	# Можно физически отключить Area2D, чтобы сигналы (body_entered) не срабатывали
	area.monitoring = false 
	
	if Global.has_anomaly:
		# 3. Настраиваем таймер активации
		timer.timeout.connect(_on_timer_timeout)
		timer.one_shot = true
		# Задаем случайное время до активации (например, от 10 до 30 секунд)
		timer.wait_time = randf_range(Global.ANOMALY_LIFT_ACTIVE_LOW, Global.ANOMALY_LIFT_ACTIVE_HIGH) 
		timer.start()


func _on_timer_timeout() -> void:
	# Аномалия проявилась и теперь активна
	is_active = true
	area.monitoring = true
	print("Аномалия стала активной! Ширина: ", collision_shape.shape.size.x)
