extends State


@export var idle_state: State
#@onready var anim_player: AnimationPlayer = $AnimationPlayer

func enter_state() -> void:
	#anim_player.play("idle")
	pass


func update(_delta: float) -> void:
	if Input.get_vector("backward", "forward", "ui_up", "ui_down") == Vector2.ZERO:
		switch_state.emit(idle_state)
