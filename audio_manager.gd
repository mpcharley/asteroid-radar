# AudioManager.gd
extends Node
# ============================================================
# Менеджер звуков и музыки. Учитывает настройки из SettingsManager.
# ============================================================

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
	# Загружаем звуки (заглушка, если файлов нет)
	music_stream = load("res://sounds/music.ogg") if ResourceLoader.exists("res://sounds/music.ogg") else null
	radar_sound = load("res://sounds/radar.ogg") if ResourceLoader.exists("res://sounds/radar.ogg") else null
	shot_sound = load("res://sounds/shot.ogg") if ResourceLoader.exists("res://sounds/shot.ogg") else null
	alarm_sound = load("res://sounds/alarm.ogg") if ResourceLoader.exists("res://sounds/alarm.ogg") else null

	# Создаём плееры
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = -10

	radar_player = AudioStreamPlayer.new()
	if radar_sound:
		radar_player.stream = radar_sound
	radar_player.volume_db = -15
	add_child(radar_player)

	shot_player = AudioStreamPlayer.new()
	if shot_sound:
		shot_player.stream = shot_sound
	shot_player.volume_db = -5
	add_child(shot_player)

	alarm_player = AudioStreamPlayer.new()
	if alarm_sound:
		alarm_player.stream = alarm_sound
	alarm_player.volume_db = -3
	add_child(alarm_player)

	# Запускаем музыку, если включена
	if music_stream and SettingsManager.music_enabled:
		music_player.play()


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if radar_sound == null or not SettingsManager.sounds_enabled:
		return
	
	radar_timer += delta
	if radar_timer >= RADAR_INTERVAL:
		radar_timer = 0.0
		radar_player.play()


# -------------------- Публичные методы --------------------
func play_shot() -> void:
	if shot_sound == null or not SettingsManager.sounds_enabled:
		return
	shot_player.play()


func set_alarm(active: bool) -> void:
	if alarm_sound == null or not SettingsManager.sounds_enabled:
		return
	if active and not alarm_active:
		alarm_active = true
		alarm_player.play()
	elif not active and alarm_active:
		alarm_active = false
		alarm_player.stop()


func pause_music() -> void:
	if music_stream == null:
		return
	music_player.stop()


func resume_music() -> void:
	if music_stream == null or not SettingsManager.music_enabled:
		return
	music_player.play()


func set_music_paused(paused: bool) -> void:
	if paused:
		pause_music()
	else:
		resume_music()
