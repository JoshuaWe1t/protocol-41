extends State

@export var idle_state: State

var current_used_item_id: int


func enter_state() -> void:
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
		call_deferred("emit_signal", "switch_state", idle_state)
		return
	
	# Если проверки пройдены, проигрываем всё как обычно
	player.velocity = Vector2.ZERO
	player.anim_player.play("use_item")
	
	match current_used_item_id:
		1:
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
	if not player.anim_player.is_playing() or player.anim_player.current_animation != "use_item":
		# Как только анимация кончилась, возвращаемся в покой
		switch_state.emit(idle_state)


func get_spore_level(current_used_item_number: int) -> void:
	if player.at_spore_area:
		print("use_item_state.get_spore_level.get_current_spore_level: ", Global.current_spore_level)
		if Global.current_spore_level:
			player.show_dialogue("Уровень спор - %s" % Global.current_spore_level)
		else:
			player.show_dialogue("Прибор молчит")
			
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)
	else:
		print("denied_get_current_level")
		player.show_dialogue("Прибор молчит")
		
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)


func get_water_sample(current_used_item_number: int) -> void:
	if player.at_door:
		player.show_dialogue("Налейте водички, пожалуйста. Горло промочить")
		print("use_item_state.get_water_sample.current_apartment:", player.current_apartment)
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_number)
	else:
		player.show_dialogue("Попрошу воды у жильцев")


#func _on_get_text_line(floor_number: int, apartment_number: int) -> void:
	#current_floor = floor_number
	#current_apartment = apartment_number
	#var dialog_box_pox_x: int
	#var dialog_box_pox_y: int
	#var dialogue_line: String
	#var floor_settings = Settings.settings.get("floors_settings").get(floor_number)
	#var apartments = floor_settings.get("apartments")
	#
	#for apartment in apartments:
		#if apartment.get("id") == current_apartment:
			#var dialog_box_settings = apartment.get("dialogue_box")
			#dialog_box_pox_x = dialog_box_settings.get("position_x")
			#dialog_box_pox_y = dialog_box_settings.get("position_y")
			## print("Vector2(x, y): ", dialog_box_pox_x, ", ", dialog_box_pox_y)
			#print("Vector2(x, y): %d, %d" % [dialog_box_pox_x, dialog_box_pox_y])
	#
	#dialogue_line = get_unique_dialogue_line(floor_number, apartment_number)
	#
	#spawn_door_dialogue(Vector2(dialog_box_pox_x,dialog_box_pox_y), dialogue_line)
