extends Control

@onready var item_icon: TextureRect = %ItemIcon
@onready var cooldown_bar: TextureProgressBar = %CooldownOverlay
@onready var hotkey_label: Label = %HotkeyText

var max_charges: int = 3
var current_charges: int = 3
var item_id: int = 0
var reload_time: float = 0.0

# ДОБАВЛЕНО: Храним ссылку на оригинальный словарь предмета
var item_data_ref: Dictionary 

func _ready() -> void:
	Events.item_uses.connect(_on_item_uses)
	Events.item_used.connect(_on_item_used)

func setup(item_data: Dictionary) -> void:
	# Сохраняем ссылку. Теперь любые изменения item_data_ref 
	# изменят данные в самом HUD!
	item_data_ref = item_data 

	var tex_path = item_data.get("sprite_path", "")
	var item_name: String
	if tex_path != "":
		var loaded_texture = load(tex_path)
		item_icon.texture = loaded_texture
		cooldown_bar.texture_progress = loaded_texture
		cooldown_bar.tint_progress = Color(0, 0, 0, 0.5)
		
	max_charges = item_data.get("total_charges_cnt", 1)
	# Берем текущие заряды из словаря (на случай, если они уже потрачены)
	current_charges = item_data.get("current_charges_cnt", max_charges) 

	item_id = item_data.get("hot_key", 1)
	hotkey_label.text = str(item_id)
	reload_time = item_data.get("reload_duration", 0.0)

	item_name = item_data.get("name", "")

	# ДОБАВЛЕНО: Регистрируем статус предмета в Global
	Global.item_cooldowns[item_id] = false
	Global.item_charges[item_id] = current_charges
	Global.item_names[item_id] = item_name

func _on_item_used(item_number: int) -> void:
	if item_number == item_id: 
		if current_charges > 0 and not Global.item_cooldowns.get(item_id, false):
			# 1. Отнимаем заряд
			current_charges -= 1

			# 2. ОБНОВЛЯЕМ ОРИГИНАЛЬНУЮ СТРУКТУРУ!
			item_data_ref["current_charges_cnt"] = current_charges

			# 3. Обновляем глобальный статус для игрока
			Global.item_charges[item_id] = current_charges

			_start_cooldown(reload_time)


func _start_cooldown(time: float) -> void:
	if time <= 0:
		return
		
	# Блокируем использование глобально
	Global.item_cooldowns[item_id] = true 
	cooldown_bar.max_value = time
	cooldown_bar.value = time

	var tween = create_tween()
	tween.tween_property(cooldown_bar, "value", 0.0, time)

	# Когда анимация закончится — снимаем блокировку
	tween.finished.connect(func(): Global.item_cooldowns[item_id] = false)


func _on_item_uses():
	pass
