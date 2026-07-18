extends Node


var current_appartment: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	$Floor1/Apartment1.body_entered.connect(_on_entered_apartment.bind(1))
	$Floor1/Apartment2.body_entered.connect(_on_entered_apartment.bind(2))
	$Floor2/Apartment3.body_entered.connect(_on_entered_apartment.bind(3))
	$Floor2/Apartment4.body_entered.connect(_on_entered_apartment.bind(4))
	$Floor3/Apartment5.body_entered.connect(_on_entered_apartment.bind(5))
	$Floor3/Apartment6.body_entered.connect(_on_entered_apartment.bind(6))

	$Floor1/Apartment1.body_exited.connect(_on_exited_apartment)
	$Floor1/Apartment2.body_exited.connect(_on_exited_apartment)
	$Floor2/Apartment3.body_exited.connect(_on_exited_apartment)
	$Floor2/Apartment4.body_exited.connect(_on_exited_apartment)
	$Floor3/Apartment5.body_exited.connect(_on_exited_apartment)
	$Floor3/Apartment6.body_exited.connect(_on_exited_apartment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_entered_apartment(body: Node2D, apartment_number: int) -> void:
	print("apartment_manager._on_entered_apartment.apartment_number: ", apartment_number)
	current_appartment = apartment_number
	if body.name == "Player":
		Events.player_entered_apartment.emit(current_appartment)


func _on_exited_apartment(_body: Node2D) -> void:
	Events.player_exited_apartment.emit()
