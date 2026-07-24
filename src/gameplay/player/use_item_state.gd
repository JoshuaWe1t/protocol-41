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
	
	if player.at_spore_area:
		print("get_current_spore_level")
		if Global.current_spore_level:
			player.show_dialogue("Уровень спор - %s" % Global.current_spore_level)
		else:
			player.show_dialogue("Прибор молчит")
			
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_id)
	else:
		print("denied_get_current_level")
		player.show_dialogue("Прибор молчит")
		
		# Сигнал интерфейсу на снятие заряда и запуск перезарядки
		Events.item_used.emit(current_used_item_id)


func physics_process(_delta: float) -> void:
	# В этом методе мы просто ждем, пока закончится анимация.
	# Самый простой способ (без сигналов) — проверить, проигрывается ли она еще:
	if not player.anim_player.is_playing() or player.anim_player.current_animation != "use_item":
		# Как только анимация кончилась, возвращаемся в покой
		switch_state.emit(idle_state)
