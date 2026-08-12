extends Node


var current_appartment: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	%Apartment1.body_entered.connect(_on_entered_apartment.bind(1))
	%Apartment2.body_entered.connect(_on_entered_apartment.bind(2))
	%Apartment3.body_entered.connect(_on_entered_apartment.bind(3))
	%Apartment4.body_entered.connect(_on_entered_apartment.bind(4))
	%Apartment5.body_entered.connect(_on_entered_apartment.bind(5))
	%Apartment6.body_entered.connect(_on_entered_apartment.bind(6))

	%Apartment1.body_exited.connect(_on_exited_apartment)
	%Apartment2.body_exited.connect(_on_exited_apartment)
	%Apartment3.body_exited.connect(_on_exited_apartment)
	%Apartment4.body_exited.connect(_on_exited_apartment)
	%Apartment5.body_exited.connect(_on_exited_apartment)
	%Apartment6.body_exited.connect(_on_exited_apartment)


func _on_entered_apartment(body: Node2D, apartment_number: int) -> void:
	print("apartment_manager._on_entered_apartment.apartment_number: ", apartment_number)
	current_appartment = apartment_number
	if body.name == "Player":
		Events.player_entered_apartment.emit(current_appartment)


func _on_exited_apartment(_body: Node2D) -> void:
	Events.player_exited_apartment.emit()
