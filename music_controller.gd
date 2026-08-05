extends AudioStreamPlayer

# Загружаем аудиофайлы (замените пути на ваши)
var menu_music = preload("res://assets/audio/music/myuu - MSP#1FORSAKEN.mp3") # или .mp3 / .wav
var game_music = preload("res://assets/audio/music/myuu - Into the Depths.mp3")

func play_menu_music():
	# Проверяем, не играет ли уже этот трек, чтобы он не начинался заново
	if stream == menu_music and playing:
		return
	stream = menu_music
	volume_db = -15.0 # Делаем музыку тише
	play()

func play_game_music():
	if stream == game_music and playing:
		return
	stream = game_music
	volume_db = -15.0 # Делаем музыку тише
	play()
