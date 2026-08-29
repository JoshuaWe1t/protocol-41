extends State

@export var idle_state: State

var current_used_item_id: int


func enter_state() -> void:
	player.hide_interaction_icon()
	current_used_item_id = Global.current_item_number

	# ПРОВЕРКА: На перезарядке ли предмет? Есть ли заряды?
	var is_on_cooldown = Global.item_cooldowns.get(current_used_item_id, false)
	var charges_cnt = Global.item_charges.get(current_used_item_id, 0)
	var has_charges = charges_cnt > 0
	var item_name = Global.item_names.get(current_used_item_id, 0)

	if not has_charges:
		player.show_dialogue("У %s не осталось зарядов" % item_name)
	
	if is_on_cooldown and has_charges:
		var sly_charges = "зарядов" if charges_cnt > 1 else "заряд"
		player.show_dialogue("%s Сейчас на перезарядке. Осталось %d %s" % [item_name, charges_cnt, sly_charges])

	if is_on_cooldown or not has_charges:
		print("Предмет на перезарядке или нет зарядов!")
		# Отменяем использование и сразу возвращаемся в idle
		# call_deferred нужен, чтобы безопасно сменить состояние в том же кадре
		#player.refresh_interaction_icon()
		call_deferred("emit_signal", "switch_state", idle_state)
		return
	
	# Если проверки пройдены, проигрываем всё как обычно
	player.velocity = Vector2.ZERO
	#player.anim_player.play("use_item")
	
	match current_used_item_id:
		1:
			player.anim_player.play("use_item")
			await get_tree().create_timer(0.8).timeout
			get_spore_level(current_used_item_id)
		2:
			get_water_sample(current_used_item_id)
		3:
			pass
		_:
			print("Неполучен ID предмета")


func physics_process(_delta: float) -> void:
	# В этом методе мы просто ждем, пока закончится анимация.
	# Самый простой способ (без сигналов) — проверить, проигрывается ли она еще:
	#if not player.anim_player.is_playing() or player.anim_player.current_animation != "use_item":
		## Как только анимация кончилась, возвращаемся в покой
		#switch_state.emit(idle_state)
	pass


func get_spore_level(current_used_item_number: int) -> void:
	if player.at_spore_area:
		print("use_item_state.get_spore_level.get_current_spore_level: ", Global.current_spore_level)
		if Global.current_spore_level:
			player.show_dialogue("Уровень спор - %s" % Global.current_spore_level)
		else:
			player.show_dialogue("Прибор молчит")
			
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)
		
		# Выходим из состояния только когда ВСЁ закончилось!
		switch_state.emit(idle_state)
	else:
		print("denied_get_current_level")
		player.show_dialogue("Прибор молчит")
		
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)
		
		# Выходим из состояния только когда ВСЁ закончилось!
		switch_state.emit(idle_state)


func get_water_sample(current_used_item_number: int) -> void:
	if player.at_door:
		player.anim_player.play("knock")
		# Запускаем звук стука
		player.knock_sound.play()
		await get_tree().create_timer(1.1).timeout
		player.anim_player.play("back")
		player.show_dialogue("Налейте водички, пожалуйста. Горло промочить")
		await get_tree().create_timer(2.3).timeout
		print("use_item_state.get_water_sample.current_apartment:", player.current_apartment)

		var is_empty_apt = false
		var floor_data = WinConditionManager.floor_condition.get(Global.current_floor)
		for apt in floor_data.get("apartments", []):
			if apt["apartment_number"] == Global.current_apartment:
				if apt["dweller"]["common_dialog_lines"].is_empty():
					is_empty_apt = true

		if is_empty_apt:
			player.show_dialogue("Никто не открыл. Не у кого взять воду...")
			Events.item_used.emit(current_used_item_number) # Тратим заряд (или можешь убрать, чтобы не тратился)
			switch_state.emit(idle_state)
			return

# ... дальше идет твой оригинальный код (1. Спавним ответ из-за двери и т.д.)
		
		# 1. Спавним ответ из-за двериd
		_on_get_text_line() 

		# 2. ЖДЕМ, пока реплика двери повисит на экране (например, 3 секунды)
		await get_tree().create_timer(2.7).timeout 
		
		var water_infected_level = get_water_infection_level(Global.current_floor, Global.current_apartment)
		if water_infected_level <= 1:
			water_infected_level = 'green'
		elif water_infected_level > 1 and water_infected_level <= 4:
			water_infected_level = 'yellow'
		else:
			water_infected_level = 'red'

		# 3. Теперь игрок говорит "Проверка"
		player.show_dialogue("Уровень заражения воды %s" % water_infected_level)

		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)
		await get_tree().create_timer(2).timeout
		# Выходим из состояния только когда ВСЁ закончилось!
		switch_state.emit(idle_state)
	else:
		player.show_dialogue("Попрошу воды у жильцев")
		# Выходим из состояния только когда ВСЁ закончилось!
		switch_state.emit(idle_state)


func _on_get_text_line() -> void:
	var current_floor = Global.current_floor
	var current_apartment = Global.current_apartment
	var dialog_box_pox_x: int
	var dialog_box_pox_y: int
	var dialogue_line: String
	var floor_settings = Settings.settings.get("floors_settings").get(current_floor)
	var apartments = floor_settings.get("apartments")
	var dialogue_lines: Array = [
		'Да-Да, прошу',
		'Держите'
	]
	
	for apartment in apartments:
		if apartment.get("id") == current_apartment:
			var dialog_box_settings = apartment.get("dialogue_box")
			dialog_box_pox_x = dialog_box_settings.get("position_x")
			dialog_box_pox_y = dialog_box_settings.get("position_y")
			print("Vector2(x, y): %d, %d" % [dialog_box_pox_x, dialog_box_pox_y])
	
	dialogue_line = dialogue_lines.pick_random()
	player.spawn_door_dialogue(Vector2(dialog_box_pox_x,dialog_box_pox_y), dialogue_line)


func get_water_infection_level(target_floor: int, target_apartment: int) -> int:
	var floor_condition = WinConditionManager.floor_condition
	# 1. Проверяем, существует ли такой этаж в словаре
	if not floor_condition.has(target_floor):
		print("Ошибка: Этаж %d не найден." % target_floor)
		return -1 # Возвращаем -1 как признак ошибки

	# 2. Получаем массив квартир на этом этаже
	var floor_data = floor_condition[target_floor]
	var apartments = floor_data.get("apartments", [])

	# 3. Ищем нужную квартиру в массиве
	for apartment in apartments:
		if apartment.get("apartment_number") == target_apartment:
			# Квартира найдена, возвращаем уровень заражения
			return apartment.get("water_infected_level", 0)

	# 4. Если цикл завершился, а квартира не найдена
	print("Ошибка: Квартира %d на этаже %d не найдена." % [target_apartment, target_floor])
	return -1
