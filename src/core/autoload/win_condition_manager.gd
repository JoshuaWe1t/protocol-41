extends Node

# --- Переменные из прошлого шага ---
var infected_floor: int 
var infected_apartment: int 
var collected_evidence: Array[String] = []
var anomalies_encountered: Array[String] = []
var threats_encountered: Array[String] = []
var is_anomaly_exist: bool = false
var anomaly_floor_located: int
var is_spore_exist: bool = false
var spore_floor_located: int

var foo = {
	"infected_floor": infected_floor,
	"infected_apartment": infected_apartment,
	"is_anomaly_exist": is_anomaly_exist,
	"anomaly_floor_located": anomaly_floor_located,
	"is_spore_exist": is_spore_exist,
	"spore_floor_located": spore_floor_located,
	"floor01": {
		"has_anomaly": false,
		"has_spore_activity": false,
		"apartments": [
			{
				"apartment_number": 1,
				"is_infected": false,
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_number": 2,
				"is_infected": false,
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
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
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_number": 4,
				"is_infected": false,
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
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
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			},
			{
				"apartment_number": 6,
				"is_infected": false,
				"water_infected_level": 0, # 0-1 - Green, 2-4 - Yellow, 5-7 - Red, >8 - ExtraRed
				'dweller': {
					"name": "",
					"common_dialog_lines": [],
					"hints_dialog_lines": []
				}
			}
		]
	}
}

# --- Базы данных для случайного выбора ---
# В реальной игре эти данные могут подтягиваться из ресурсов или JSON, 
# но для прототипа достаточно простых массивов.
var all_possible_evidence: Array[String] = ["Следы спор", "Черная вода", "Странный запах", "Слизь на стенах"]
var all_possible_anomalies: Array[String] = ["Искажение пространства", "Аномальный холод", "Радиопомехи"]
var all_possible_threats: Array[String] = ["Агрессивный жилец", "Облако спор", "Мутировавшая крыса"]

# Функция _ready вызывается автоматически при загрузке скрипта
func _ready():
	# КРИТИЧЕСКИ ВАЖНО: инициализируем генератор случайных чисел.
	# Без randomize() игра каждый раз при запуске будет выдавать одни и те же "случайные" значения.
	randomize()
	
	# Запускаем нашу логику генерации уровня
	generate_level_settings()

func generate_level_settings():
	# 1. Случайный этаж от 1 до 3
	infected_floor = randi_range(1, 3)
	
	# 2. Случайная квартира от 1 до 6
	infected_apartment = randi_range(1, 6)
	
	# 3. С вероятностью 50% решаем, будет ли аномалия на объекте
	# randf() возвращает случайное число от 0.0 до 1.0
	is_anomaly_exist = randf() > 0.5 
	
	# Очищаем массивы на случай, если функция вызывается повторно для рестарта матча
	collected_evidence.clear()
	anomalies_encountered.clear()
	threats_encountered.clear()
	
	# 4. Выбираем 2 случайные улики из нашего пула
	var shuffled_evidence = all_possible_evidence.duplicate()
	shuffled_evidence.shuffle() # Перемешиваем массив
	collected_evidence.append(shuffled_evidence[0])
	collected_evidence.append(shuffled_evidence[1])
	
	# 5. Если аномалия существует, выбираем одну случайную
	if is_anomaly_exist:
		# pick_random() автоматически берет один случайный элемент из массива
		anomalies_encountered.append(all_possible_anomalies.pick_random())
		
	# 6. Выбираем одну случайную угрозу
	threats_encountered.append(all_possible_threats.pick_random())
	
	# Вывод в консоль (удобно для дебага)
	print("--- НОВЫЙ МАТЧ СГЕНЕРИРОВАН ---")
	print("Зараженный этаж: ", infected_floor)
	print("Зараженная квартира: ", infected_apartment)
	print("Наличие аномалии: ", is_anomaly_exist)
	print("Улики на уровне: ", collected_evidence)
