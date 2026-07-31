extends CanvasLayer


# --- Ссылки на UI элементы ---
@onready var journal_ui = $JournalUI
@onready var pages_container = $JournalUI/Pages
@onready var results_ui = $ResultsUI
@onready var title_1: RichTextLabel = $ResultsUI/Mask/TextureRect/Title1
@onready var article_1: RichTextLabel = $ResultsUI/Mask/TextureRect/Article1
@onready var title_2: RichTextLabel = $ResultsUI/Mask/TextureRect/Title2
@onready var article_2: RichTextLabel = $ResultsUI/Mask/TextureRect/Article2
@onready var btn_next = $JournalUI/NextBtn
@onready var btn_prev = $JournalUI/PrevBtn

# Ссылки на форму отчета
@onready var floor_option = $JournalUI/Pages/PageReport/FloorOption
@onready var apt_option = $JournalUI/Pages/PageReport/AptOption
@onready var monster_option = $JournalUI/Pages/PageReport/MonsterOption
@onready var anomaly_check = $JournalUI/Pages/PageReport/AnomalyCheck
@onready var anomaly_floor_option = $JournalUI/Pages/PageReport/AnomalyFloorOption
# Добавляем ссылку на звук
@onready var page_sound: AudioStreamPlayer = $PageSound
@onready var journal_open_sound: AudioStreamPlayer = $JournalOpenSound
@onready var journal_close_sound: AudioStreamPlayer = $JournalCloseSound
@onready var result_bg_texture: TextureRect = $ResultsUI/Mask/TextureRect

# Настройки камеры (панорамирования)
@export var pan_speed: float = 700.0 # Скорость движения фона
@export var edge_margin: float = 50.0 # Расстояние от края экрана (в пикселях), где срабатывает движение

# --- Переменные состояния ---
var is_journal_open: bool = false
var current_page_index: int = 0
var pages: Array = []
var is_transitioning: bool = false

var key_result: String

func _ready() -> void:
	# ЭТА СТРОКА ГАРАНТИРУЕТ, ЧТО СКРИПТ БУДЕТ РАБОТАТЬ ВО ВРЕМЯ ПАУЗЫ
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	journal_ui.visible = false
	btn_next.visible = true 
	btn_prev.visible = true
	$JournalUI/Pages/PagePlayer/Title.text = Global.NAME_OPER_LIST.pick_random()
	$JournalUI/Pages/PagePlayer/Item1.texture = Global.SPRITE_OPER_LIST.pick_random()
	
	# Собираем все страницы в массив и показываем только первую
	pages = pages_container.get_children()
	update_pages_visibility()

	# Скрываем поле этажа аномалии, если галочка не стоит
	anomaly_floor_option.visible = anomaly_check.button_pressed
	anomaly_check.toggled.connect(_on_anomaly_check_toggled)


# Заменили _unhandled_input на _input
func _input(event):
	# Если нажали J и мы не на экране итогов
	if event.is_action_pressed("journal") and not results_ui.visible:
		if not is_transitioning:
			toggle_journal()


# --- Вставьте эту новую функцию в любое место скрипта (например, перед _on_next_btn_pressed) ---
func _process(delta: float) -> void:
	# Двигаем фон только если экран итогов открыт
	if not results_ui.visible:
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size

	var move_dir = Vector2.ZERO
	
	# Проверяем мышь по оси X (Влево / Вправо)
	if mouse_pos.x < edge_margin:
		move_dir.x = 1 # Мышь слева -> двигаем картинку вправо
	elif mouse_pos.x > viewport_size.x - edge_margin:
		move_dir.x = -1 # Мышь справа -> двигаем картинку влево
		
	# Проверяем мышь по оси Y (Вверх / Вниз)
	if mouse_pos.y < edge_margin:
		move_dir.y = 1 # Мышь сверху -> двигаем картинку вниз
	elif mouse_pos.y > viewport_size.y - edge_margin:
		move_dir.y = -1 # Мышь снизу -> двигаем картинку вверх

	# Если мышь у края экрана, начинаем двигать
	if move_dir != Vector2.ZERO:
		var new_pos = result_bg_texture.position + (move_dir * pan_speed * delta)

		# --- ОГРАНИЧЕНИЕ ДВИЖЕНИЯ (чтобы не уйти за края текстуры) ---
		# Максимальная позиция всегда (0, 0) - левый верхний угол
		var max_pos = Vector2.ZERO

		# Минимальная позиция - это разница между размером экрана и размером текстуры
		var min_x = min(viewport_size.x - result_bg_texture.size.x, 0)
		var min_y = min(viewport_size.y - result_bg_texture.size.y, 0)

		# Функция clamp не дает позиции выйти за рамки min и max
		new_pos.x = clamp(new_pos.x, min_x, max_pos.x)
		new_pos.y = clamp(new_pos.y, min_y, max_pos.y)

		# Применяем новую позицию
		result_bg_texture.position = new_pos


func toggle_journal():
	is_transitioning = true
	is_journal_open = !is_journal_open
	journal_ui.visible = is_journal_open

	if is_journal_open:
		# Ставим игру на паузу и показываем курсор
		get_tree().paused = true
		journal_open_sound.play()
		await journal_open_sound.finished
		journal_ui.visible = is_journal_open
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Снимаем паузу и прячем курсор (если игра от 1-го лица)
		journal_ui.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		journal_close_sound.play()
		await journal_close_sound.finished
		
		get_tree().paused = false
	
	is_transitioning = false


# --- Логика перелистывания страниц ---
func _on_next_btn_pressed():
	if current_page_index < pages.size() - 1:
		current_page_index += 1
		update_pages_visibility()
		# Меняем высоту звука на случайное значение от 0.9 (чуть ниже) до 1.1 (чуть выше)
		page_sound.pitch_scale = randf_range(0.9, 1.1)
		page_sound.play()


func _on_prev_btn_pressed():
	if current_page_index > 0:
		current_page_index -= 1
		update_pages_visibility()
		# Меняем высоту звука на случайное значение от 0.9 (чуть ниже) до 1.1 (чуть выше)
		page_sound.pitch_scale = randf_range(0.9, 1.1)
		page_sound.play()


func update_pages_visibility():
	for i in range(pages.size()):
		pages[i].visible = (i == current_page_index)


# --- Логика формы ---
func _on_anomaly_check_toggled(toggled_on: bool):
	# Показываем выбор этажа аномалии только если она есть
	anomaly_floor_option.visible = toggled_on


# Эту функцию нужно привязать к сигналу pressed кнопки SubmitBtn
func _on_submit_btn_pressed():
	# Закрываем сам журнал, но оставляем игру на паузе
	journal_ui.visible = false
	is_journal_open = false
	btn_next.visible = false 
	btn_prev.visible = false
	
	journal_close_sound.play()
	await get_tree().create_timer(0.5, true).timeout
	
	# --- Правильные ответы для текущего уровня (в реальной игре их передает LevelManager) ---
	var correct_floor: int = Global.infected_floor
	var correct_apt: int = Global.infected_apartment
	var correct_monster: String = Global.current_monster
	var correct_has_anomaly: bool = Global.has_anomaly
	var correct_anomaly_floor: int = Global.anomaly_located_floor if Global.has_anomaly else -1

	# [infected_floor, infected_apartment, current_monster, has_anomaly, anomaly_located_floor]
	
	# Считываем данные от игрока
	# Для OptionButton получаем текст выбранного пункта
	var guessed_floor = floor_option.get_item_id(floor_option.selected)# .get_item_text(floor_option.selected).to_int()
	var guessed_apt = apt_option.get_item_id(apt_option.selected)# .get_item_text(floor_option.selected).to_int()
	var guessed_monster = monster_option.get_item_text(monster_option.selected)
	var guessed_has_anomaly = anomaly_check.button_pressed
	var guessed_anomaly_floor = anomaly_floor_option.get_item_id(anomaly_floor_option.selected) # .get_item_text(anomaly_floor_option.selected).to_int()
	
	key_result += "1" if guessed_floor == correct_floor else "0"
	key_result += "1" if guessed_apt == correct_apt else "0"
	key_result += "1" if guessed_monster == correct_monster else "0"
	key_result += "1" if guessed_has_anomaly == correct_has_anomaly else "0"
	
	if guessed_has_anomaly == correct_has_anomaly:
		if guessed_has_anomaly and guessed_anomaly_floor == correct_anomaly_floor:
			key_result += "1"
		elif guessed_has_anomaly:
			key_result += "0"
		else:
			key_result += "1"
	else:
		key_result += "0"
	
	print("key_result: ", key_result)
	
	var checker = {
		"guessed_floor": guessed_floor,
		"guessed_apt": guessed_apt, 
		"guessed_monster": guessed_monster,
		"guessed_has_anomaly": guessed_has_anomaly,
		"guessed_anomaly_floor": guessed_anomaly_floor,
		"correct_floor": correct_floor,
		"correct_apt": correct_apt,
		"correct_monster": correct_monster,
		"correct_has_anomaly": correct_has_anomaly,
		"correct_anomaly_floor": correct_anomaly_floor
	}
	print("journal_manager.checker: ", checker)
	
	var newspaper_data: Dictionary = VictoriesCombinations.victory_combinations.get(key_result, "-1")
	var title_1_txt: String = newspaper_data.get("title1", "-1")
	var article_1_txt: String = newspaper_data.get("article1", "-1")
	var title_2_txt: String = newspaper_data.get("title2", "-1")
	var article_2_txt: String = newspaper_data.get("article2", "-1")

	# Сравниваем ответы
	#var report = "[center][b]ИТОГИ РАССЛЕДОВАНИЯ[/b][/center]\n\n"
#
	#if guessed_floor == correct_floor and guessed_apt == correct_apt:
		#report += "[color=green]Очаг заражения определен верно.[/color]\n"
	#else:
		#report += "[color=red]Ошибка! Настоящий очаг был в квартире " + str(correct_apt) + " на " + str(correct_floor) + " этаже.[/color]\n"
		#
	#if guessed_monster == correct_monster:
		#report += "[color=green]Тип сущности установлен верно (" + correct_monster + ").[/color]\n"
	#else:
		#report += "[color=red]Неверный тип сущности. Это был " + correct_monster + ".[/color]\n"
		#
	#if guessed_has_anomaly == correct_has_anomaly:
		#if guessed_has_anomaly and guessed_anomaly_floor == correct_anomaly_floor:
			#report += "[color=green]Аномалия локализована точно.[/color]\n"
		#elif guessed_has_anomaly:
			#report += "[color=red]Аномалия есть, но этаж указан неверно.[/color]\n"
		#else:
			#report += "[color=green]Отсутствие аномалий подтверждено.[/color]\n"
	#else:
		#report += "[color=red]Ошибка в определении аномального фона.[/color]\n"

	## Показываем результаты (в RichTextLabel обязательно включите bbcode_enabled = true)
	#result_text.text = report
	results_ui.visible = true
