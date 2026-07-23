extends State

#@export var idle_state: State


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func enter_state() -> void:
	player.velocity = Vector2.ZERO
	player.anim_player.play("use_item")


func physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("item1"):
		if player.at_spore_area:
			print("get_current_spore_level")
		else:
			print("denied_get_current_level")
