extends Control

# Ссылки на узлы
@onready var background: TextureRect = $Background
@onready var interactive_areas: Node = $InteractiveAreas
@onready var tooltip_label: RichTextLabel = $TooltipLabel
@onready var dimming_overlay: ColorRect = $DimmingOverlay
@onready var central_msg: RichTextLabel = $DimmingOverlay/CentredMessage


# Ключи словаря должны точно совпадать с именами узлов в InteractiveAreas
var tips_data = {
	"Npc_1": {
		"title": "Оперативник К.О.Н.Т.У.Р'а",
		"desc": "Управление: WASD (или стрелки) для перемещения.\n E - для взаимодействия с окружением"
	},
	"Door_2": {
		"title": "Дверь апартаментов",
		"desc": "Управление: Нажмите [E] рядом с дверью, чтобы провести опрос жильца.\nЕсли ответа не последовало, кварти ра пуста"
	},
	"Door_3": {
		"title": "Дверь апартаментов",
		"desc": "Механика: Нажмиет <2>, чтобы использовать 2ой предмет из инвентаря для сбора данных"
	},
	"Stairs_4": {
		"title": "Лестница",
		"desc": "Управление: Стрелки вверх/вниз для подъема/спуска."
	},
	"Elevator_5": {
		"title": "Лифт",
		"desc": "Нажмите E для спуска с максимального (3-его) этажа на первый.\nЛифт со временем выходит из строя"
	},
	"InterfaceBar_6": {
		"title": "Панель инструментов и информации",
		"desc": "Доступные предметы, оставшееся время раследования и журнал оперативника"
	},
	"Item_7": {
		"title": "УСМ-04",
		"desc": "Небольшое устройство, которое позволяет зафиксировать частички спор в атмосфере.\nНажмите <1>, чтобы использовать предмет, когда вы находитесь в зоне распостранения спор."
	},
	"Item_8": {
		"title": "Бумажный индикатор",
		"desc": "Позволяет проверить пробы воды на наличие в них спор 0-41.\nНажмите <2> у входа в квартиру, чтобы попросить образец воды.\nПолучив образец, вы сможете провести анализ и получить уровень заражения"
	},
	"Item_9": {
		"title": "САП-13",
		"desc": "Данное устройство включено по умолчанию и срабатывает в непосредственной близости к аномалии, после срабатывания устройство непригодно к использованию"
	},
	"Item_10": {
		"title": "Таймер уровня",
		"desc": "Время до завершения расследования."
	},
	"Item_11": {
		"title": "Журнал",
		"desc": "Содержит дополнительную информацию об операции\nПоследняя страница журнала для заполения отчета расследования"
	}
}

var is_initial_screen_active = true
const MENU = "res://src/levels/menu/menu.tscn"


func _ready():
	# При старте включаем затемнение
	dimming_overlay.visible = true
	# Отключаем интерактивность зон, пока активно затемнение
	interactive_areas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Скрываем лейбл подсказки
	tooltip_label.visible = false
	
	# Автоматически подключаем сигналы для всех зон
	for button in interactive_areas.get_children():
		# Используем TextureButton, так как они наследуют от BaseButton и имеют сигналы наведения
		if button is BaseButton:
			button.mouse_entered.connect(_on_mouse_entered_area.bind(button))
			button.mouse_exited.connect(_on_mouse_exited_area)
			button.mouse_entered.connect(_on_button_hovered.bind(button))
			button.mouse_exited.connect(_on_button_unhovered.bind(button))


func _process(_delta):
	# Отслеживаем нажатие ESC
	if Input.is_action_just_pressed("ui_cancel"): # По умолчанию ESC в Godot
		#get_tree().quit() # Выход из игры (можно заменить на смену сцены)
		get_tree().change_scene_to_file(MENU)
		
	# При первом клике убираем затемнение
	if is_initial_screen_active and Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		_dismiss_initial_screen()


# Обработчик нажатия на саму сцену для снятия затемнения
func _input(event):
	if is_initial_screen_active and event is InputEventMouseButton and event.pressed:
		_dismiss_initial_screen()


func _dismiss_initial_screen():
	is_initial_screen_active = false
	dimming_overlay.visible = false
	# Включаем интерактивность зон
	interactive_areas.mouse_filter = Control.MOUSE_FILTER_PASS
	print("Обучение началось.")


# --- Функция наведения мыши ---
func _on_mouse_entered_area(area_node):
	if is_initial_screen_active: return # Игнорируем, если еще на начальном экране

	var area_name = area_node.name
	if tips_data.has(area_name):
		var data = tips_data[area_name]
		
		# Форматируем текст
		var text = "[b]%s[/b]\n%s" % [data.title, data.desc]
		tooltip_label.text = text
		tooltip_label.visible = true

		print("Наведено на: " + area_name)
	else:
		print("Подсказка для " + area_name + " не найдена!")


func _on_mouse_exited_area():
	tooltip_label.visible = false


func _on_button_hovered(btn: BaseButton):
	# Ищем узел подсветки прямо внутри кнопки
	var highlight = btn.get_node_or_null("ColorRect")
	if highlight:
		highlight.visible = true


func _on_button_unhovered(btn: BaseButton):
	var highlight = btn.get_node_or_null("ColorRect")
	if highlight:
		highlight.visible = false
