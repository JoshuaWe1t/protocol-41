extends State

@export var idle_state: State

func enter_state() -> void:
	player.velocity = Vector2.ZERO
	player.anim_player.play("knock")
	
	# Ждем окончания анимации
	await player.anim_player.animation_finished
	
	# Генерируем диалог
	Events.get_text_line.emit(player.current_floor, player.current_apartment)
	
	# Автоматически возвращаемся в Idle
	switch_state.emit(idle_state)


func physics_process(_delta: float) -> void:
	player.move_and_slide()
