extends Node


var settings: Dictionary = {
	"floors_settings": {
		1 : {
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
			"stairs": {
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
			},
			"apartments": [
				{
					"id": 1,
					"apartment_name": "Apartment1",
					"position_x": 200,
					"position_y": 480,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 45,
						"position_y": 160,
					}
				},
				{
					"id": 2,
					"apartment_name": "Apartment2",
					"position_x": 550,
					"position_y": 480,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 390,
						"position_y": 160,
					}
				}
			]
		},
		2 : {
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
			"stairs": {
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
			},
			"apartments": [
				{
					"id": 3,
					"apartment_name": "Apartment3",
					"position_x": 200,
					"position_y": -240,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 45,
						"position_y": -560,
					}
				},
				{
					"id": 4,
					"apartment_name": "Apartment4",
					"position_x": 550,
					"position_y": -240,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 390,
						"position_y": -560,
					}
				}
			]
		},
		3 : {
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
			"stairs": {
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
			},
			"apartments": [
				{
					"id": 5,
					"apartment_name": "Apartment5",
					"position_x": 200,
					"position_y": -960,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 45,
						"position_y": -1280,
					}
				},
				{
					"id": 6,
					"apartment_name": "Apartment6",
					"position_x": 550,
					"position_y": -960,
					"collision_shape_setup": {
						"shape": "RectangleShape2D",
						"width": 155,
						"hight": 255
					},
					"dialogue_box": {
						"position_x": 390,
						"position_y": -1280,
					}
				}
			]
			}
		},
	"spore_settings": {
		1 : [
			{
				"collision_shape": "CicleShapre2D",
				"radius": 40,
				"position_x": 50,
				"position_y": 400
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 70,
				"position_x": 375,
				"position_y": 390
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 30,
				"position_x": 670,
				"position_y": 450
			}
		],
		2 : [
			{
				"collision_shape": "CicleShapre2D",
				"radius": 40,
				"position_x": 50,
				"position_y": -320
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 70,
				"position_x": 375,
				"position_y": -330
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 30,
				"position_x": 670,
				"position_y": -300
			}
		],
		3 : [
			{
				"collision_shape": "CicleShapre2D",
				"radius": 40,
				"position_x": 50,
				"position_y": -1040
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 70,
				"position_x": 375,
				"position_y": -1050
			},
			{
				"collision_shape": "CicleShapre2D",
				"radius": 30,
				"position_x": 670,
				"position_y": -1020
			}
		]
	}
}


func _ready() -> void:
	print("SettingData инициализирован")
