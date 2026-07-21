extends State

func enter_state() -> void:
	player.velocity = Vector2.ZERO
	player.anim_player.play("idle")


func physics_process(_delta: float) -> void:
	pass
