extends Node

var collected_evidence: Array[String] = []
var anomalies_encountered: Array[String] = []
var threats_encountered: Array[String] = []

# Оставляем структуру словаря как базовый шаблон
var floor_condition = {
	"infected_floor": 0,
	"infected_apartment": 0,
	"is_anomaly_exist": false,
	"anomaly_floor_located": 0,
	"is_spore_exist": false,
	"spore_floor_located": 0,
	"floor01": {
		"has_anomaly": false,
		"has_spore_activity": false,
		"apartments": [
			{
				"apartment_name": "Apartment1",
				"apartment_number": 1,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment2",
				"apartment_number": 2,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			}
		]
	},
	"floor02": {
		"has_anomaly": false,
		"has_spore_activity": false,
		"apartments": [
			{
				"apartment_name": "Apartment3",
				"apartment_number": 3,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment4",
				"apartment_number": 4,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			}
		]
	},
	"floor03": {
		"has_anomaly": false,
		"has_spore_activity": false,
		"apartments": [
			{
				"apartment_name": "Apartment5",
				"apartment_number": 5,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment6",
				"apartment_number": 6,
				"is_infected": false,
				"water_infected_level": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			}
		]
	}
}

var all_possible_evidence: Array[String] = ["Следы спор", "Черная вода", "Странный запах", "Слизь на стенах"]
var all_possible_anomalies: Array[String] = ["Искажение пространства", "Аномальный холод", "Радиопомехи"]
var all_possible_threats: Array[String] = ["Агрессивный жилец", "Облако спор", "Мутировавшая крыса"]

func _ready():
	randomize()
	generate_level_settings()

func generate_level_settings():
	# Очищаем данные на случай рестарта уровня
	anomalies_encountered.clear()
	
	# Генерируем квартиру и ПРИВЯЗЫВАЕМ к ней этаж
	Global.infected_apartment = randi_range(1, 6)
	var infected_floor = 1
	
	if Global.infected_apartment in [1, 2]:
		infected_floor = 1
	elif Global.infected_apartment in [3, 4]:
		infected_floor = 2
	else:
		infected_floor = 3
		
	# Генерируем доп. активности
	var is_anomaly_exist = randf() > 0.5 
	var is_spore_exist = randf() > 0.5 
	
	var anomaly_floor_located = randi_range(1, 3) if is_anomaly_exist else 0
	var spore_floor_located = randi_range(1, 3) if is_spore_exist else 0
	
	if is_anomaly_exist:
		anomalies_encountered.append(all_possible_anomalies.pick_random())
		
	# ЗАПИСЫВАЕМ сгенерированные данные в наш главный объект floor_condition
	floor_condition["infected_floor"] = infected_floor
	floor_condition["infected_apartment"] = Global.infected_apartment
	floor_condition["is_anomaly_exist"] = is_anomaly_exist
	floor_condition["anomaly_floor_located"] = anomaly_floor_located
	floor_condition["is_spore_exist"] = is_spore_exist
	floor_condition["spore_floor_located"] = spore_floor_located
	
	# Обновляем статус заражения внутри конкретной квартиры в словаре
	var floor_key = "floor0" + str(infected_floor)
	for apt in floor_condition[floor_key]["apartments"]:
		if apt["apartment_number"] == Global.infected_apartment:
			apt["is_infected"] = true
			apt["water_infected_level"] = randi_range(5, 10) # Делаем воду "Красной" или "ЭкстраКрасной"
			
	# Отмечаем наличие аномалий/спор на конкретных этажах
	if is_anomaly_exist:
		floor_condition["floor0" + str(anomaly_floor_located)]["has_anomaly"] = true
	if is_spore_exist:
		floor_condition["floor0" + str(spore_floor_located)]["has_spore_activity"] = true

	print("--- НОВЫЙ МАТЧ СГЕНЕРИРОВАН ---")
	print("Зараженный этаж: ", floor_condition["infected_floor"])
	print("Зараженная квартира: ", floor_condition["infected_apartment"])
	print("Наличие аномалии: ", floor_condition["is_anomaly_exist"], " (на этаже ", floor_condition["anomaly_floor_located"], ")")

	# === НОВАЯ ЛОГИКА: РАСПРЕДЕЛЕНИЕ ДИАЛОГОВ ===
	
	# 1. Создаем копии массивов и перемешиваем их, чтобы фразы не повторялись
	var available_commons = Dwellers.common_dialog_lines.duplicate()
	available_commons.shuffle()
	
	var available_hints = Dwellers.hints_dialog_lines.duplicate()
	available_hints.shuffle()
	
	# 2. Выбираем, кто из жильцов получит подсказки. 
	# У нас 6 квартир. Пусть 3 квартиры получат подсказки, остальные — только бытовуху.
	var apartments_with_hints = [1, 2, 3, 4, 5, 6]
	apartments_with_hints.shuffle()
	var lucky_apartments = apartments_with_hints.slice(0, 3) # Берем первые 3 случайные квартиры
	
	# 3. Раздаем диалоги по квартирам
	for floor_num in range(1, 4):
		floor_key = "floor0" + str(floor_num)
		for apt in floor_condition[floor_key]["apartments"]:
			var apt_num = apt["apartment_number"]
			
			# У некоторых жильцов может никого не быть дома (например, 15% шанс)
			if randf() < 0.15:
				continue # Оставляем массивы пустыми, ответа не последует
			
			# Раздаем 2-3 обычные фразы
			var common_count = randi_range(2, 3)
			for i in range(common_count):
				if available_commons.size() > 0:
					apt["dweller"]["common_dialog_lines"].append(available_commons.pop_back())
			
			# Если квартира входит в список "везунчиков", даем ей 1 подсказку
			if apt_num in lucky_apartments:
				if available_hints.size() > 0:
					var raw_hint = available_hints.pop_back()
					
					# ВАЖНО: Проверяем, есть ли "%d" в строке, чтобы не было ошибки при форматировании
					if "%d" in raw_hint:
						raw_hint = raw_hint % Global.infected_apartment
						
					apt["dweller"]["hints_dialog_lines"].append(raw_hint)

	# Файл запишется только при запуске из редактора или в дебаг-билде
	if OS.is_debug_build():
		save_foo_to_debug_file()


func save_foo_to_debug_file():
	# Превращаем словарь в читаемую строку JSON с отступами (табуляцией)
	var json_string = JSON.stringify(floor_condition, "\t")
	
	# Открываем файл для записи. 
	var file = FileAccess.open("res://src/core/logs/floor_conditions/debug_floor_conditions.json", FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
		# Выводим в консоль абсолютный путь к файлу для удобства
		var absolute_path = ProjectSettings.globalize_path("res://src/core/logs/floor_conditions/debug_foo.json")
		print("Файл отладки debug_floor_conditions успешно сохранен: ", absolute_path)
	else:
		print("Не удалось сохранить файл! Код ошибки: ", FileAccess.get_open_error())
