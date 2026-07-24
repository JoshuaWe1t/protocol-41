extends CanvasLayer

# Перетащи сюда сцену ItemSlot.tscn через инспектор
@export var item_slot_scene: PackedScene = preload("res://src/ui/item_slot.tscn")

# Путь до твоего контейнера (проверь, чтобы имя совпадало с твоим деревом)
@onready var hbox: HBoxContainer = $UIRoot/HBoxContainer

var items: Dictionary = Items.items

func _ready() -> void:
	# Инициализируем генератор случайных чисел
	randomize() 
	generate_random_inventory()


func generate_random_inventory() -> void:
	# Проходим по каждому ключу в словаре (1, 2, 3 — это наши слоты)
	for key in items.keys():
		var item_variants: Array = items[key]
		
		# Защита от ошибок: если массив пустой, просто пропускаем этот слот
		if item_variants.is_empty():
			continue
			
		# Godot 4 сам выберет один случайный элемент из массива
		var random_item = item_variants.pick_random()
		
		# Назначаем горячую клавишу строго по ключу словаря, 
		# чтобы предмет из ключа 1 всегда нажимался на "1"
		random_item["hot_key"] = key
		
		# Создаем экземпляр сцены слота
		var slot_instance = item_slot_scene.instantiate()
		
		# Добавляем его в HBoxContainer
		hbox.add_child(slot_instance)
		
		# Передаем данные выбранного предмета в слот
		slot_instance.setup(random_item)
