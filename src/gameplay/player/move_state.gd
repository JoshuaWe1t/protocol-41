extends State


@export var move_state: State


func enter_state() -> void:
	pass # play animation


func update(_delta: float) -> void:
	if Input.is_action_just_pressed("backward"):
		switch_state.emit(move_state)
		
	if Input.is_action_just_pressed("forward"):
		switch_state.emit(move_state)
