extends Node

@onready var collision_spore1 = $Floor1/CollisionSporeFl1
@onready var collision_spore2 = $Floor2/CollisionSporeFl2
@onready var collision_spore3 = $Floor3/CollisionSporeFl3
@onready var timer_activite = $TimerActivateSpore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Floor1.body_entered.connect(_on_entered_spore_area.bind(1, setup_infected_level(1)))
	$Floor2.body_entered.connect(_on_entered_spore_area.bind(2, setup_infected_level(1)))
	$Floor3.body_entered.connect(_on_entered_spore_area.bind(3, setup_infected_level(1)))
	
	$Floor1.body_exited.connect(_on_exited_spore_area)
	$Floor2.body_exited.connect(_on_exited_spore_area)
	$Floor3.body_exited.connect(_on_exited_spore_area)
	
	setup_position(collision_spore1, 1)
	setup_position(collision_spore2, 2)
	setup_position(collision_spore3, 3)
	
	setup_radious(collision_spore1, 1)
	setup_radious(collision_spore2, 2)
	setup_radious(collision_spore3, 3)


func _on_entered_spore_area(body: Node2D, floor_number: int, spore_level: String) -> void:
	if body.name == "Player":
		print("spore_area._on_entered_spore_area.floor_number: %d, _on_entered_spore_area.spore_level: %s" % [floor_number, spore_level])


func _on_exited_spore_area(_body: Node2D) -> void:
	pass


func setup_radious(colision_obj: CollisionShape2D, floor_number: int) -> void:
	var collision_position_list: Array = Settings.settings.get("spore_settings").get(floor_number)
	print("spore_area.setup_radious.collision_position_list: ", collision_position_list)
	var radious = (collision_position_list.pick_random()).get("radius")
	print("spore_area.setup_radious.radious: ", radious)
	if colision_obj.shape is CircleShape2D:
		colision_obj.shape.radius = radious


func setup_position(colision_obj: CollisionShape2D, floor_number: int) -> void:
	var collision_position_list: Array = Settings.settings.get("spore_settings").get(floor_number)
	var pos_x: float = (collision_position_list.pick_random()).get("position_x")
	var pos_y: float = (collision_position_list.pick_random()).get("position_y")
	colision_obj.position = Vector2(pos_x, pos_y)
	print("spore_area.setup_position.position: ", colision_obj.position)


func setup_infected_level(floor_number: int) -> String:
	var spore_level: String = WinConditionManager.floor_condition\
		.get(floor_number)\
		.get("spore_level")
	return spore_level
