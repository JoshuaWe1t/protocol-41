extends CanvasLayer


# --- Ссылки на UI элементы ---
@onready var journal_ui = $JournalUI
@onready var results_ui = $ResultsUI
@onready var pages_container = $JournalUI/Pages
@onready var result_text = $ResultsUI/ResultText
@onready var btn_next = $JournalUI/NextBtn
@onready var btn_prev = $JournalUI/PrevBtn

# Ссылки на форму отчета
@onready var floor_option = $JournalUI/Pages/PageReport/FloorOption
@onready var apt_option = $JournalUI/Pages/PageReport/AptOption
@onready var monster_option = $JournalUI/Pages/PageReport/MonsterOption
@onready var anomaly_check = $JournalUI/Pages/PageReport/AnomalyCheck
@onready var anomaly_floor_option = $JournalUI/Pages/PageReport/AnomalyFloorOption

# --- Переменные состояния ---
var is_journal_open: bool = false
var current_page_index: int = 0
var pages: Array = []

# --- Правильные ответы для текущего уровня (в реальной игре их передает LevelManager) ---
var correct_floor: int = Global.infected_floor
var correct_apt: int = Global.infected_apartment
var correct_monster: String = Global.current_monster
var correct_has_anomaly: bool = Global.has_anomaly
var correct_anomaly_floor: int = Global.anomaly_located_floor if Global.has_anomaly else -1


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


#func _unhandled_input(event):
	## Если нажали J и мы не на экране итогов
	#if event.is_action_pressed("journal") and not results_ui.visible:
		#toggle_journal()


# Заменили _unhandled_input на _input
func _input(event):
	# Если нажали J и мы не на экране итогов
	if event.is_action_pressed("journal") and not results_ui.visible:
		toggle_journal()


func toggle_journal():
	is_journal_open = !is_journal_open
	journal_ui.visible = is_journal_open

	if is_journal_open:
		# Ставим игру на паузу и показываем курсор
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Снимаем паузу и прячем курсор (если игра от 1-го лица)
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# --- Логика перелистывания страниц ---
func _on_next_btn_pressed():
	if current_page_index < pages.size() - 1:
		current_page_index += 1
		update_pages_visibility()

func _on_prev_btn_pressed():
	if current_page_index > 0:
		current_page_index -= 1
		update_pages_visibility()


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
	
	# Считываем данные от игрока
	# Для OptionButton получаем текст выбранного пункта
	var guessed_floor = floor_option.get_item_id(floor_option.selected)# .get_item_text(floor_option.selected).to_int()
	var guessed_apt = apt_option.get_item_id(apt_option.selected)# .get_item_text(floor_option.selected).to_int()
	var guessed_monster = monster_option.get_item_text(monster_option.selected)
	var guessed_has_anomaly = anomaly_check.button_pressed
	var guessed_anomaly_floor = anomaly_floor_option.get_item_id(anomaly_floor_option.selected) # .get_item_text(anomaly_floor_option.selected).to_int()

	# Сравниваем ответы
	var report = "[center][b]ИТОГИ РАССЛЕДОВАНИЯ[/b][/center]\n\n"

	if guessed_floor == correct_floor and guessed_apt == correct_apt:
		report += "[color=green]Очаг заражения определен верно.[/color]\n"
	else:
		report += "[color=red]Ошибка! Настоящий очаг был в квартире " + str(correct_apt) + " на " + str(correct_floor) + " этаже.[/color]\n"
		
	if guessed_monster == correct_monster:
		report += "[color=green]Тип сущности установлен верно (" + correct_monster + ").[/color]\n"
	else:
		report += "[color=red]Неверный тип сущности. Это был " + correct_monster + ".[/color]\n"
		
	if guessed_has_anomaly == correct_has_anomaly:
		if guessed_has_anomaly and guessed_anomaly_floor == correct_anomaly_floor:
			report += "[color=green]Аномалия локализована точно.[/color]\n"
		elif guessed_has_anomaly:
			report += "[color=red]Аномалия есть, но этаж указан неверно.[/color]\n"
		else:
			report += "[color=green]Отсутствие аномалий подтверждено.[/color]\n"
	else:
		report += "[color=red]Ошибка в определении аномального фона.[/color]\n"

	# Показываем результаты (в RichTextLabel обязательно включите bbcode_enabled = true)
	result_text.text = report
	results_ui.visible = true
