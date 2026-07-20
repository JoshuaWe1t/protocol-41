extends Area2D

@onready var collision_spore = $CollisionSporeFl1
@onready var timer_activite = $TimerActivateSpore

var collision_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_position_list: Array = Settings.settings.get("spore_settings").get(Global.infected_floor)
	var pos_x: float = (collision_position_list.pick_random()).get("position_x")
	var pos_y: float = (collision_position_list.pick_random()).get("position_y")
	collision_position = Vector2(pos_x, pos_y)
	
	Events.player_entered_spore_area.connect(_on_entered_spore_area)
	Events.player_exited_spore_area.connect(_on_exited_spore_area)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_entered_spore_area() -> void:
	pass


func _on_exited_spore_area() -> void:
	pass
