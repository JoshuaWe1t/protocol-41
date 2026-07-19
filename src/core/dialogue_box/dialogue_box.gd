extends PanelContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	# Подключаем таймер (чтобы не делать это вручную в редакторе)
	timer.timeout.connect(_on_timer_timeout)
	
	# Можно задать таймеру время жизни по умолчанию, например 3 секунды
	timer.wait_time = 1.5
	timer.one_shot = true

# Функция для приёма данных извне при спавне
func setup(text_to_show: String, spawn_position: Vector2) -> void:
	label.text = text_to_show
	
	# ВАЖНО: Ждем один кадр! 
	# PanelContainer должен успеть пересчитать свой размер (size) под новый текст.
	await get_tree().process_frame
	
	# Центрируем облачко текста ровно над переданной координатой.
	# Мы сдвигаем его влево на половину ширины и вверх на всю высоту контейнера.
	#global_position = spawn_position - Vector2(size.x / 2.0, size.y)
	global_position = spawn_position
	
	# Запускаем отсчет времени
	timer.start()

func _on_timer_timeout() -> void:
	# Удаляем объект из оперативной памяти игры (самый эффективный способ для временных UI)
	queue_free()
