extends State

@export var idle_state: State
@export var knock_state: State
@export var use_item_state: State 

func enter_state() -> void:
	player.anim_player.get_animation("walk").loop_mode = Animation.LOOP_LINEAR
	player.anim_player.play("walk")

func physics_process(_delta: float) -> void:
	var direction := Input.get_axis("backward", "forward")
	
	if direction == 0:
		switch_state.emit(idle_state)
		return
		
	player.velocity.x = direction * player.SPEED
	player.sprite.flip_h = (direction < 0)
	
	# Можно ли взаимодействовать на ходу? Если да:
	if Input.is_action_just_pressed("go_up"):
		player.try_go_up()
	elif Input.is_action_just_pressed("go_down"):
		player.try_go_down()
	elif Input.is_action_just_pressed("interact"):
		if player.at_door:
			switch_state.emit(knock_state)
		elif player.at_lift:
			player.try_use_lift()
	
	if Input.is_action_just_pressed("item1"):
		Global.current_item_number = 1
		switch_state.emit(use_item_state)
		return # Выходим, чтобы другой код физики не перебил состояние
	
	player.move_and_slide()
