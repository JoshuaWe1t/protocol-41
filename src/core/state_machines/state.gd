class_name State extends Node


var player: CharacterBody2D 

@warning_ignore("unused_signal")
signal switch_state(state: State)

func enter_state() -> void:
    pass
    

func exit_state() -> void:
    pass
    

func update(_delta: float) -> void:
    pass
    
	
func physics_process(_delta: float) -> void:
    pass