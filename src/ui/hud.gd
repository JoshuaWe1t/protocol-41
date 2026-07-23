extends CanvasLayer # Это скрипт твоего главного HUD

# 1. Загружаем текстуру предмета. 
# Укажи здесь точный путь до твоей картинки зелья, аптечки или шестеренки!
const ITEM_GEAR_TEXTURE = preload("res://icon.svg")
const ITEM_MEDKIT_TEXTURE = preload("res://icon.svg")

# 2. Получаем ссылки на наши слоты (пути могут немного отличаться, проверь свои)
@onready var slot_1 = $UIRoot/HBoxContainer/ItemSlot
@onready var slot_2 = $UIRoot/HBoxContainer/ItemSlot2
@onready var slot_3 = $UIRoot/HBoxContainer/ItemSlot3

func _ready() -> void:
	# 3. Вызываем функцию setup у первого слота
	# Передаем картинку шестеренки и говорим, что у нее 3 заряда
	slot_1.setup(ITEM_GEAR_TEXTURE, 3)
	
	# Можно сразу настроить и второй слот, дав ему другой предмет и 5 зарядов
	slot_2.setup(ITEM_MEDKIT_TEXTURE, 5)


func get_iteam_data() -> void:
	pass
