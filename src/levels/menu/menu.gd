extends Control


@onready var level_1_button: TextureButton = $Menu/Levels/level1
@onready var level_2_button: TextureButton = $Menu/Levels/level2
@onready var level_3_button: TextureButton = $Menu/Levels/level3
@onready var level_4_button: TextureButton = $Menu/Levels/level4

@onready var exit_button = $ExitButton

@onready var info_plate = $InfoPlate
@onready var info_label = $InfoPlate/Description
# Путь к сцене самого уровня (замени на свой)
const LEVEL_1_SCENE_PATH = "res://src/levels/sand_box/sand_box.tscn"
const LEVELS_DESCKRIPTION: Dictionary = {
	1 : {
		"text": "Вас отправили в старую хрущевку с подозрением на биологическое заражение.\n\nДействуя под прикрытием полицейского, вы должны за ограниченное время обойти 3 этажа и опросить жильцов.\n\nНайдите источник распространения спор О-41, отметьте все улики в журнале и составьте Акт обследования, чтобы успешно завершить миссию."
	},
	2 : {
		"text": "Вас отправили на производственный объект, где зафиксированы странные недомогания среди рабочих.\n\nДействуя под прикрытием инспектора по охране труда, вы должны за ограниченное время обойти цеха и опросить персонал.\n\nНайдите источник распространения спор О-41, отметьте все улики в журнале и составьте Акт обследования, чтобы успешно завершить миссию."
	},
	3 : {
		"text": "Вас направили в старую больницу из-за резкого всплеска неизвестных заболеваний.\n\nДействуя под прикрытием сотрудника санэпидемстанции, вы должны за ограниченное время проверить палаты и опросить пациентов.\n\nНайдите источник распространения спор О-41, отметьте все улики в журнале и составьте Акт обследования, чтобы успешно завершить миссию."
	},
	4 : {
		"text": "Вас вызвали в здание горисполкома, где приборы зафиксировали аномальные помехи в кабинетах чиновников.\n\nДействуя под прикрытием архивариуса, вы должны за ограниченное время исследовать этажи и осторожно опросить сотрудников.\n\nНайдите источник распространения спор О-41, отметьте все улики в журнале и составьте Акт обследования, чтобы успешно завершить миссию."
	}
}

func _ready():
	# Запускаем музыку для меню
	#MusicController.play_menu_music()
	# Гарантируем, что в меню курсор всегда включен
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# 1. При запуске сцены скрываем плашку
	info_plate.visible = false
	
	# 2. Подключаем сигналы наведения мыши
	level_1_button.mouse_entered.connect(_on_level1_mouse_entered.bind(1))
	level_1_button.mouse_exited.connect(_on_level1_mouse_exited)
	level_2_button.mouse_entered.connect(_on_level2_mouse_entered.bind(2))
	level_2_button.mouse_exited.connect(_on_level2_mouse_exited)
	level_3_button.mouse_entered.connect(_on_level3_mouse_entered.bind(3))
	level_3_button.mouse_exited.connect(_on_level3_mouse_exited)
	level_4_button.mouse_entered.connect(_on_level4_mouse_entered.bind(4))
	level_4_button.mouse_exited.connect(_on_level4_mouse_exited)
	
	# Подключаем сигнал нажатия кнопки выхода
	exit_button.pressed.connect(_on_exit_pressed)
	
	# 3. Подключаем сигнал нажатия на кнопку
	level_1_button.pressed.connect(_on_level1_pressed)


# Срабатывает, когда курсор заходит на кнопку
func _on_level1_mouse_entered(key_messege: int):
	# Задаем текст брифинга
	info_label.text = LEVELS_DESCKRIPTION.get(key_messege, 0).get("text", "...")
	# Показываем плашку
	info_plate.visible = true


# Срабатывает, когда курсор уходит с кнопки
func _on_level1_mouse_exited():
	# Прячем плашку
	info_plate.visible = false


# Срабатывает, когда курсор заходит на кнопку
func _on_level2_mouse_entered(key_messege: int):
	# Задаем текст брифинга
	info_label.text = LEVELS_DESCKRIPTION.get(key_messege, 0).get("text", "...")
	# Показываем плашку
	info_plate.visible = true


# Срабатывает, когда курсор уходит с кнопки
func _on_level2_mouse_exited():
	# Прячем плашку
	info_plate.visible = false


# Срабатывает, когда курсор заходит на кнопку
func _on_level3_mouse_entered(key_messege: int):
	# Задаем текст брифинга
	info_label.text = LEVELS_DESCKRIPTION.get(key_messege, 0).get("text", "...")
	# Показываем плашку
	info_plate.visible = true


# Срабатывает, когда курсор уходит с кнопки
func _on_level3_mouse_exited():
	# Прячем плашку
	info_plate.visible = false


# Срабатывает, когда курсор заходит на кнопку
func _on_level4_mouse_entered(key_messege: int):
	# Задаем текст брифинга
	info_label.text = LEVELS_DESCKRIPTION.get(key_messege, 0).get("text", "...")
	# Показываем плашку
	info_plate.visible = true


# Срабатывает, когда курсор уходит с кнопки
func _on_level4_mouse_exited():
	# Прячем плашку
	info_plate.visible = false


# Срабатывает при клике ЛКМ
func _on_level1_pressed():
	# Запускаем переход на сцену уровня
	get_tree().change_scene_to_file(LEVEL_1_SCENE_PATH)


# Функция, которая сработает при нажатии на кнопку выхода
func _on_exit_pressed():
	get_tree().quit()
