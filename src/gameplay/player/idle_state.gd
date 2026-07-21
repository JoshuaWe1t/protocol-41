extends State

@export var move_state: State
@export var knock_state: State

func enter_state() -> void:
	player.velocity.x = 0
	player.anim_player.play("idle")

func physics_process(_delta: float) -> void:
	var direction := Input.get_axis("backward", "forward")
	
	if direction != 0:
		switch_state.emit(move_state)
		return
		
	# Обработка интерактива
	if Input.is_action_just_pressed("go_up"):
		player.try_go_up()
	elif Input.is_action_just_pressed("go_down"):
		player.try_go_down()
	elif Input.is_action_just_pressed("interact"):
		if player.at_door:
			switch_state.emit(knock_state)
		elif player.at_lift:
			player.try_use_lift()
