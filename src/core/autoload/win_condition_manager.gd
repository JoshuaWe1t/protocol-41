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
	var infected_apartment = randi_range(1, 6)
	var infected_floor = 1
	
	if infected_apartment in [1, 2]:
		infected_floor = 1
	elif infected_apartment in [3, 4]:
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
	floor_condition["infected_apartment"] = infected_apartment
	floor_condition["is_anomaly_exist"] = is_anomaly_exist
	floor_condition["anomaly_floor_located"] = anomaly_floor_located
	floor_condition["is_spore_exist"] = is_spore_exist
	floor_condition["spore_floor_located"] = spore_floor_located
	
	# Обновляем статус заражения внутри конкретной квартиры в словаре
	var floor_key = "floor0" + str(infected_floor)
	for apt in floor_condition[floor_key]["apartments"]:
		if apt["apartment_number"] == infected_apartment:
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
