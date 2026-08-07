extends Node

@export var spore_tex_1: Texture2D = preload("res://src/levels/spore_manager/spore1.png")
@export var spore_tex_2: Texture2D = preload("res://src/levels/spore_manager/spore2.png")
@export var spore_tex_3: Texture2D = preload("res://src/levels/spore_manager/spore3.png")

@onready var collision_spore1 = $Floor1/CollisionSporeFl1
@onready var collision_spore2 = $Floor2/CollisionSporeFl2
@onready var collision_spore3 = $Floor3/CollisionSporeFl3
@onready var timer_activite = $TimerActivateSpore

@onready var spore_sprite_1 = $Floor1/CollisionSporeFl1/Sprite2D
@onready var spore_sprite_2 = $Floor2/CollisionSporeFl2/Sprite2D
@onready var spore_sprite_3 = $Floor3/CollisionSporeFl3/Sprite2D

# Словарь для отслеживания текущей стадии каждой споры и её спрайта
@onready var floor_spore_stages: Dictionary = {
	1: {"current_stage": 0, "sprite_node": spore_sprite_1},
	2: {"current_stage": 0, "sprite_node": spore_sprite_2},
	3: {"current_stage": 0, "sprite_node": spore_sprite_3}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Отключаем детекцию до первого тика таймера
	$Floor1.monitoring = false
	$Floor2.monitoring = false
	$Floor3.monitoring = false
	
	$Floor1.body_entered.connect(_on_entered_spore_area.bind(1, setup_infected_level(1)))
	$Floor2.body_entered.connect(_on_entered_spore_area.bind(2, setup_infected_level(2)))
	$Floor3.body_entered.connect(_on_entered_spore_area.bind(3, setup_infected_level(3)))
	
	$Floor1.body_exited.connect(_on_exited_spore_area)
	$Floor2.body_exited.connect(_on_exited_spore_area)
	$Floor3.body_exited.connect(_on_exited_spore_area)
	
	# Вызываем нашу новую универсальную функцию для каждого этажа
	setup_spore_properties(1, collision_spore1, spore_sprite_1)
	setup_spore_properties(2, collision_spore2, spore_sprite_2)
	setup_spore_properties(3, collision_spore3, spore_sprite_3)

	# Настраиваем и запускаем таймер на первые 30 секунд
	timer_activite.wait_time = Global.TIMER_ACTIVATE_SPORE
	timer_activite.timeout.connect(_on_spore_timer_timeout)
	timer_activite.start()

	# Скрываем все спрайты при старте (стадия 0)
	for floor_num in floor_spore_stages.keys():
		update_spore_sprite(floor_spore_stages[floor_num]["sprite_node"], 0)


func _on_entered_spore_area(body: Node2D, floor_number: int, spore_level: String) -> void:
	var spore_lvl = spore_level
	if body.name == "Player":
		print("spore_area._on_entered_spore_area.floor_number: %d, _on_entered_spore_area.spore_level: %s" % [floor_number, spore_lvl])
		Events.player_entered_spore_area.emit(spore_lvl)


func _on_exited_spore_area(_body: Node2D) -> void:
	Events.player_exited_spore_area.emit()


func setup_radious(colision_obj: CollisionShape2D, floor_number: int) -> void:
	var collision_position_list: Array = Settings.settings.get("spore_settings").get(floor_number)
	print("spore_area.setup_radious.collision_position_list: ", collision_position_list)
	var radious = (collision_position_list.pick_random()).get("radius")
	print("spore_area.setup_radious.radious: ", radious)
	if colision_obj.shape is CircleShape2D:
		colision_obj.shape.radius = radious


func setup_position(colision_obj: CollisionShape2D, floor_number: int) -> void:
	var collision_position_list: Array = Settings.settings.get("spore_settings").get(floor_number)
	# Небольшое исправление: вызываем pick_random() один раз, 
	# чтобы X и Y брались из одной и той же точки настроек!
	var random_pos_data = collision_position_list.pick_random()
	var pos_x: float = random_pos_data.get("position_x")
	var pos_y: float = random_pos_data.get("position_y")
	
	colision_obj.position = Vector2(pos_x, pos_y)
	print("spore_area.setup_position.position: ", colision_obj.position)


func setup_infected_level(floor_number: int) -> String:
	var spore_level: String = WinConditionManager.floor_condition\
		.get(floor_number)\
		.get("spore_level")
	print("spore_area.setup_infected_level.spore_level:", spore_level)
	return spore_level


func _on_spore_timer_timeout() -> void:
	# Если это был первый тик, меняем время для следующих тиков
	if timer_activite.wait_time == Global.TIMER_ACTIVATE_SPORE:
		print("spore_area._on_spore_timer_timeout.timer_changed: ", true)
		timer_activite.wait_time = Global.TIMER_ACTIVATE_SPORE_NEW
		
		# Включаем взаимодействие с зонами спор
		$Floor1.monitoring = true
		$Floor2.monitoring = true
		$Floor3.monitoring = true
		
	for floor_num in [1, 2, 3]:
		var current_level = setup_infected_level(floor_num)
		grow_spore(floor_num, current_level)


func grow_spore(floor_num: int, level: String) -> void:
	var data = floor_spore_stages[floor_num]
	var current = data["current_stage"]
	
	if current == 0:
		# Первая активация
		if level == "yellow":
			current = 1
		elif level == "red":
			current = randi_range(1, 2) # Может быть 1 или 2
	else:
		# Последующий рост
		if level == "yellow" and current < 2:
			current += 1
		elif level == "red" and current < 3:
			current += 1
			
	# Если уровень green, current останется 0
	data["current_stage"] = current
	update_spore_sprite(data["sprite_node"], current)


func update_spore_sprite(sprite: Sprite2D, stage: int) -> void:
	match stage:
		0:
			sprite.texture = null # Не отображаем спрайт (green или до активации)
		1:
			sprite.texture = spore_tex_1
		2:
			sprite.texture = spore_tex_2
		3:
			sprite.texture = spore_tex_3


func setup_spore_properties(floor_number: int, collision_obj: CollisionShape2D, sprite_obj: Sprite2D) -> void:
	# Получаем массив настроек для конкретного этажа
	var spore_configs: Array = Settings.settings.get("spore_settings").get(floor_number)

	# ВЫБИРАЕМ СЛУЧАЙНЫЕ НАСТРОЙКИ ОДИН РАЗ ДЛЯ ЭТАЖА
	var random_spore_data: Dictionary = spore_configs.pick_random()

	# 1. Настраиваем позицию (т.к. Sprite2D дочерний у CollisionShape2D, он передвинется вместе с ним)
	var pos_x: float = random_spore_data.get("position_x")
	var pos_y: float = random_spore_data.get("position_y")
	collision_obj.position = Vector2(pos_x, pos_y)

	# 2. Настраиваем радиус коллизии
	var radius: float = random_spore_data.get("radius")
	if collision_obj.shape is CircleShape2D:
		collision_obj.shape.radius = radius
		
	# 3. Настраиваем размер (Scale) спрайта
	var scale_x: float = random_spore_data.get("scale_x")
	var scale_y: float = random_spore_data.get("scale_y")
	sprite_obj.scale = Vector2(scale_x, scale_y)

	print("Spore Area [Floor %d] Setup: Pos(%f, %f), Radius(%f), Scale(%f, %f)" % [floor_number, pos_x, pos_y, radius, scale_x, scale_y])