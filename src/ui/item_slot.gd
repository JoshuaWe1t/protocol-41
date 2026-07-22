extends TextureRect

@onready var item_icon: TextureRect = $"."
@onready var cooldown_bar: TextureProgressBar = $CooldownOverlay
@onready var charges_container: HBoxContainer = $Charges
#
## 1. Запоминаем первую панель из контейнера как "шаблон" для копирования
#@onready var charge_template: Panel = $Charges.get_child(0).duplicate()

var max_charges: int = 3
var current_charges: int = 3
var is_on_cooldown: bool = false

func _ready() -> void:
	# 2. При запуске игры удаляем все панели, которые ты создал в редакторе руками, 
	# чтобы контейнер был пустым и готовым к функции setup()
	for child in charges_container.get_children():
		child.queue_free()
	
	#setup()

# Вызывай эту функцию при старте игры, чтобы настроить слот
func setup(texture: Texture2D, charges: int) -> void:
	item_icon.texture = texture
	max_charges = charges
	current_charges = charges
	
	# Очищаем контейнер на случай, если в этот слот кладут уже другой предмет
	for child in charges_container.get_children():
		child.queue_free()
		
	## 3. Добавляем ровно столько панелей-зарядов, сколько передано в charges
	#for i in range(max_charges):
		#var new_charge = charge_template.duplicate()
		#charges_container.add_child(new_charge)
		
	_update_charges_ui()

# Вызывай эту функцию, когда игрок нажимает 1, 2 или 3
func use_item(cooldown_time: float) -> void:
	if current_charges > 0 and not is_on_cooldown:
		current_charges -= 1
		_update_charges_ui()
		_start_cooldown(cooldown_time)
		print("Предмет использован!")
	elif current_charges <= 0:
		print("Нет зарядов!")

func _update_charges_ui() -> void:
	# Проходимся по всем кружочкам в контейнере и скрываем лишние
	for i in range(charges_container.get_child_count()):
		var charge_icon = charges_container.get_child(i)
		charge_icon.visible = i < current_charges

func _start_cooldown(time: float) -> void:
	is_on_cooldown = true
	cooldown_bar.max_value = time
	cooldown_bar.value = time
	
	var tween = create_tween()
	tween.tween_property(cooldown_bar, "value", 0.0, time)
	
	tween.finished.connect(func(): is_on_cooldown = false)
