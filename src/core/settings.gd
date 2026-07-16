extends Node


var settings: Dictionary = {
	"floors_settings": {
		"floor1": {
			"name": "Floor1",
			"floor_zone": {
				"name": "FloorZone1",
				"position_x": 645,
				"position_y": 585,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 1245,
					"hight": 50
				}
			},
			"satirs": {
				"name": "Stairs",
				"position_x": 825,
				"position_y": 482,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 117,
					"hight": 255
				}
			},
			"lift": {
				"name": "Lift",
				"position_x": 1125,
				"position_y": 449,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 230,
					"hight": 320
				}
			}
		},
		"floor2": {
			"name": "Floor2",
			"floor_zone": {
				"name": "FloorZone2",
				"position_x": 645,
				"position_y": -140,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 1245,
					"hight": 50
				}
			},
			"satirs": {
				"name": "Stairs",
				"position_x": 825,
				"position_y": -240,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 117,
					"hight": 255
				}
			},
			"lift": {
				"name": "Lift",
				"position_x": 1125,
				"position_y": -270,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 230,
					"hight": 320
				}
			}
		},
		"floor3": {
			"name": "Floor3",
			"floor_zone": {
				"name": "FloorZone3",
				"position_x": 645,
				"position_y": -863,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 1245,
					"hight": 50
				}
			},
			"satirs": {
				"name": "Stairs",
				"position_x": 825,
				"position_y": -962,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 117,
					"hight": 255
				}
			},
			"lift": {
				"name": "Lift",
				"position_x": 1125,
				"position_y": -990,
				"collision_shape_setup": {
					"shape": "RectangleShape2D",
					"width": 230,
					"hight": 320
				}
			}
		}
	}
}


func _ready() -> void:
	print("SETTINGS LOADED")
