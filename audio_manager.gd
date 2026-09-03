# audio_manager.gd
extends Node

var music_stream: AudioStream
var radar_sound: AudioStream
var shot_sound: AudioStream
var alarm_sound: AudioStream

var music_player: AudioStreamPlayer
var radar_player: AudioStreamPlayer
var shot_player: AudioStreamPlayer
var alarm_player: AudioStreamPlayer

var radar_timer: float = 0.0
const RADAR_INTERVAL: float = 0.5
var alarm_active: bool = false


func _ready() -> void:
	# Загружаем звуки
	music_stream = load("res://sounds/music.ogg") if ResourceLoader.exists("res://sounds/music.ogg") else null
	radar_sound = load("res://sounds/radar.ogg") if ResourceLoader.exists("res://sounds/radar.ogg") else null
	shot_sound = load("res://sounds/shot.ogg") if ResourceLoader.exists("res://sounds/shot.ogg") else null
	alarm_sound = load("res://sounds/alarm.ogg") if ResourceLoader.exists("res://sounds/alarm.ogg") else null

	# Создаём плееры
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = PROCESS_MODE_ALWAYS   # музыка не останавливается при паузе игры
	add_child(music_player)
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = linear_to_db(SettingsManager.music_volume)
		music_player.autoplay = true
		music_player.finished.connect(_on_music_finished)
		if SettingsManager.music_volume > 0:
			music_player.play()

	radar_player = AudioStreamPlayer.new()
	radar_player.process_mode = PROCESS_MODE_ALWAYS
	if radar_sound:
		radar_player.stream = radar_sound
	radar_player.volume_db = linear_to_db(SettingsManager.radar_volume)
	add_child(radar_player)

	shot_player = AudioStreamPlayer.new()
	shot_player.process_mode = PROCESS_MODE_ALWAYS
	if shot_sound:
		shot_player.stream = shot_sound
	shot_player.volume_db = linear_to_db(SettingsManager.shot_volume)
	add_child(shot_player)

	alarm_player = AudioStreamPlayer.new()
	alarm_player.process_mode = PROCESS_MODE_ALWAYS
	if alarm_sound:
		alarm_player.stream = alarm_sound
	alarm_player.volume_db = linear_to_db(SettingsManager.alarm_volume)
	add_child(alarm_player)

	# Подписываемся на изменение настроек
	SettingsManager.settings_changed.connect(_update_volumes)

func _on_music_finished():
	music_player.play()
	
func _update_volumes() -> void:
	# Обновляем громкость всех плееров (без пауз и перезапусков)
	music_player.volume_db = linear_to_db(SettingsManager.music_volume)
	radar_player.volume_db = linear_to_db(SettingsManager.radar_volume)
	shot_player.volume_db = linear_to_db(SettingsManager.shot_volume)
	alarm_player.volume_db = linear_to_db(SettingsManager.alarm_volume)

	# Если громкость музыки > 0 и плеер не играет – запускаем
	if SettingsManager.music_volume > 0 and not music_player.playing and music_stream:
		music_player.play()
	# Если громкость стала 0 – останавливаем
	elif SettingsManager.music_volume == 0 and music_player.playing:
		music_player.set_stream_paused(true)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if radar_sound == null or SettingsManager.radar_volume == 0:
		return

	radar_timer += delta
	if radar_timer >= RADAR_INTERVAL:
		radar_timer = 0.0
		radar_player.play()


# -------------------- Основные звуковые эффекты --------------------
func play_shot() -> void:
	if shot_sound == null or SettingsManager.shot_volume == 0:
		return
	shot_player.play()


func set_alarm(active: bool) -> void:
	if alarm_sound == null or SettingsManager.alarm_volume == 0:
		return
	if active and not alarm_active:
		alarm_active = true
		alarm_player.play()
	elif not active and alarm_active:
		alarm_active = false
		alarm_player.stop()


# -------------------- Тестовое воспроизведение для настроек --------------------
func play_test_radar() -> void:
	if radar_sound == null or SettingsManager.radar_volume == 0:
		return
	radar_player.play()


func play_test_shot() -> void:
	if shot_sound == null or SettingsManager.shot_volume == 0:
		return
	shot_player.play()


func play_test_alarm() -> void:
	if alarm_sound == null or SettingsManager.alarm_volume == 0:
		return
	alarm_player.play()
