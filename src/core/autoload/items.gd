extends Node2D

var items: Dictionary = {
	1 : [
		{
			"consumable": 1,
			"total_charges_cnt": 3,
			"current_charges_cnt": 3, 
			"reload_duration": 5,
			"work_time": 1,
			"sprite_path": "",
			"level": 1,
			"hot_key": 1,
			"name": "УСМ-04",
			"decription": "УСМ-04 (уловитель споровых масс, версия 4) - это устройство с тремя разноцветными лампами, которые отражают степень заражения области. Внутри устройства есть тканевый фильтр с активным реагентом для определения спор в атмосфере, светодатчик, насос.",
			"type_item": "spore_detector"
		}
	],
	2 : [
		{
			"consumable": 1,
			"total_charges_cnt": 3,
			"current_charges_cnt": 3, 
			"reload_duration": 0,
			"work_time": 3,
			"sprite_path": "",
			"level": 1,
			"hot_key": 2,
			"name": "Бумажный индикатор",
			"decription": "Обычный бумажный индикатор с цветовыми шкалами, который идет в комплекте с колбой для забора водных проб.",
			"type_item": "water_analizer"
		}
	],
	3 : [
		{
			"consumable": 1,
			"total_charges_cnt": 1,
			"current_charges_cnt": 1, 
			"reload_duration": 0,
			"work_time": 0,
			"sprite_path": "",
			"level": 1,
			"hot_key": 3,
			"name": "САП-13",
			"decription": "САП-13 (считыватель аномальных помех, версия 13) - это устройство с двумя магнитными рамами и дисплеем между ними. Работает от батареек.",
			"type_item": "anomaly_detector"
		}
	]
}
