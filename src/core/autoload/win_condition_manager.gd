extends Node

var collected_evidence: Array[String] = []
var anomalies_encountered: Array[String] = []
var threats_encountered: Array[String] = []

# База данных наших монстров (Синтаксис исправлен для GDScript)
const MONSTERS = {
	"perekzhnik": {
		"name": "Перекожник",
		"water": "red",    # Оставляет биологические следы/слизь
		"spores": "red",   # Активно мутирует или разлагается, фон спор зашкаливает
		"anomaly": true   # Сильнейшее искажение пространства
	},
	"mimic": {
		"name": "Мимик",
		"water": "green",  # Идеально маскируется, воду не мутит
		"spores": "yellow",# Спор почти не выделяет
		"anomaly": false    # Излучает аномалию
	},
	"simulacrum": {
		"name": "Симулякр",
		"water": "red",    # Искажает реальность (вода черная)
		"spores": "yellow",# Остаточные фантомные следы
		"anomaly": true    # Сильнейшее искажение пространства
	},
	"infestor": {
		"name": "Заразитель",
		"water": "yellow",    # Заражает воду, но медленно
		"spores": "red", # Покрывает все пространство спорами
		"anomaly": false    #  Биологическая тварь, аномалии нет
	}
}

# Оставляем структуру словаря как базовый шаблон
var floor_condition = {
	"active_monster_id": "",
	"active_monster_name": "",
	"infected_floor": 0,
	"infected_apartment": 0,
	"is_anomaly_exist": false,
	"anomaly_floor_located": 0,
	"is_spore_exist": false,
	"spore_floor_located": 0,
	1 : {
		"has_anomaly": false,
		"has_spore_activity": false,
		"spore_level": "",
		"apartments": [
			{
				"apartment_name": "Apartment1",
				"apartment_number": 1,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment2",
				"apartment_number": 2,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
				}
			}
		]
	},
	2 : {
		"has_anomaly": false,
		"has_spore_activity": false,
		"spore_level": "",
		"apartments": [
			{
				"apartment_name": "Apartment3",
				"apartment_number": 3,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment4",
				"apartment_number": 4,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
				}
			}
		]
	},
	3 : {
		"has_anomaly": false,
		"has_spore_activity": false,
		"spore_level": "",
		"apartments": [
			{
				"apartment_name": "Apartment5",
				"apartment_number": 5,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
				}
			},
			{
				"apartment_name": "Apartment6",
				"apartment_number": 6,
				"is_infected": false,
				"water_infected_level": 0,
				"last_interaction_time": 0,
				"dweller": {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": [],
					"full_dialog_lines": []
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
	
	# === ВЫБОР МОНСТРА ===
	var monster_keys = MONSTERS.keys()
	var selected_monster_id = monster_keys.pick_random()
	var active_monster = MONSTERS[selected_monster_id]
	
	# Генерируем квартиру и ПРИВЯЗЫВАЕМ к ней этаж
	Global.infected_apartment = randi_range(1, 6)
	
	if Global.infected_apartment in [1, 2]:
		Global.infected_floor = 1
	elif Global.infected_apartment in [3, 4]:
		Global.infected_floor = 2
	else:
		Global.infected_floor = 3
		
	# === ГЕНЕРАЦИЯ АКТИВНОСТЕЙ НА ОСНОВЕ МОНСТРА ===
	var is_anomaly_exist = active_monster["anomaly"]
	var anomaly_floor_located = randi_range(1, 3) if is_anomaly_exist else 0
	
	# Общие данные
	floor_condition["active_monster_id"] = selected_monster_id
	floor_condition["active_monster_name"] = active_monster["name"]
	floor_condition["infected_floor"] = Global.infected_floor
	floor_condition["infected_apartment"] = Global.infected_apartment
	floor_condition["is_anomaly_exist"] = is_anomaly_exist
	floor_condition["anomaly_floor_located"] = anomaly_floor_located
	floor_condition["is_spore_exist"] = true # Споры теперь есть всегда (хотя бы у монстра или зеленый фон)
	floor_condition["spore_floor_located"] = Global.infected_floor # Очаг спор всегда на зараженном этаже

	# === НАСТРОЙКА ЭТАЖЕЙ И КВАРТИР ===
	for floor_num in range(1, 4):
		var current_floor_data = floor_condition[floor_num]
		
		# 1. Устанавливаем уровень спор для этажа
		if floor_num == Global.infected_floor:
			current_floor_data["spore_level"] = active_monster["spores"]
			current_floor_data["has_spore_activity"] = true
		else:
			# На других этажах либо чисто (""), либо слабый фон ("green")
			var random_spore = ["", "green"].pick_random()
			current_floor_data["spore_level"] = random_spore
			current_floor_data["has_spore_activity"] = (random_spore == "green")
		
		# 2. Устанавливаем аномалию
		if is_anomaly_exist and floor_num == anomaly_floor_located:
			current_floor_data["has_anomaly"] = true
		else:
			current_floor_data["has_anomaly"] = false
			
		# 3. Настраиваем воду в квартирах
		for apt in current_floor_data["apartments"]:
			if apt["apartment_number"] == Global.infected_apartment:
				apt["is_infected"] = true
				
				# Вода зависит от типа монстра
				match active_monster["water"]:
					"red":
						apt["water_infected_level"] = randi_range(5, 10)
					"yellow":
						apt["water_infected_level"] = randi_range(2, 4)
					"green", _:
						apt["water_infected_level"] = randi_range(0, 1)
			else:
				# У соседей вода чистая или в допустимых пределах
				apt["is_infected"] = false
				apt["water_infected_level"] = randi_range(0, 1) 

	print("--- НОВЫЙ МАТЧ СГЕНЕРИРОВАН ---")
	print("Тип угрозы: ", floor_condition["active_monster_name"])
	print("Зараженный этаж: ", floor_condition["infected_floor"])
	print("Зараженная квартира: ", floor_condition["infected_apartment"])
	print("Споры на зараженном этаже: ", floor_condition[Global.infected_floor]["spore_level"])
	print("Наличие аномалии: ", floor_condition["is_anomaly_exist"], " (на этаже ", floor_condition["anomaly_floor_located"], ")")
	
	# === ЛОГИКА РАСПРЕДЕЛЕНИЯ ДИАЛОГОВ ===
	var available_commons = Dwellers.common_dialog_lines.duplicate()
	available_commons.shuffle()
	
	var available_hints = Dwellers.hints_dialog_lines.duplicate()
	available_hints.shuffle()

	var misleading_lines = Dwellers.misleading_lines.duplicate()
	misleading_lines.shuffle()
	
	var apartments_with_hints = [1, 2, 3, 4, 5, 6]
	apartments_with_hints.erase(Global.infected_apartment)
	apartments_with_hints.shuffle()
	var lucky_apartments = apartments_with_hints.slice(0, 3) 
	
	for floor_num in range(1, 4):
		for apt in floor_condition[floor_num]["apartments"]:
			var apt_num = apt["apartment_number"]
			
			# Шанс 15%, что никого нет дома (зараженный жилец всегда дома)
			if apt_num != Global.infected_apartment and randf() < 0.15:
				continue 
			
			var common_count = randi_range(2, 3)
			for i in range(common_count):
				if available_commons.size() > 0:
					var common_phrase = available_commons.pop_back()
					apt["dweller"]["common_dialog_lines"].append(common_phrase)
					apt["dweller"]["full_dialog_lines"].append(common_phrase)
			
			if apt_num == Global.infected_apartment:
				if misleading_lines.size() > 0:
					var lie = misleading_lines.pop_back()
					apt["dweller"]["hints_dialog_lines"].append(lie)
					apt["dweller"]["full_dialog_lines"].append(lie)
					
			elif apt_num in lucky_apartments:
				if available_hints.size() > 0:
					var raw_hint = available_hints.pop_back()
					
					if "%d" in raw_hint:
						var error_point = randi_range(-1, 1)
						var target_apt = clamp(Global.infected_apartment + error_point, 1, 6)
						raw_hint = raw_hint % target_apt
						
					apt["dweller"]["hints_dialog_lines"].append(raw_hint)
					apt["dweller"]["full_dialog_lines"].append(raw_hint)

	if OS.is_debug_build():
		save_foo_to_debug_file()

func save_foo_to_debug_file():
	var json_string = JSON.stringify(floor_condition, "\t")
	var file = FileAccess.open("res://src/core/logs/floor_conditions/debug_floor_conditions.json", FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
		var absolute_path = ProjectSettings.globalize_path("res://src/core/logs/floor_conditions/debug_floor_conditions.json")
		print("Файл отладки debug_floor_conditions успешно сохранен: ", absolute_path)
	else:
		print("Не удалось сохранить файл! Код ошибки: ", FileAccess.get_open_error())
