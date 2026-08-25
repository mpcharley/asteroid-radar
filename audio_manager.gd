# AudioManager.gd
extends Node
# ============================================================
# Менеджер звуков и музыки. Громкость регулируется через SettingsManager.
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
	# Загружаем звуки
	music_stream = load("res://sounds/music.ogg") if ResourceLoader.exists("res://sounds/music.ogg") else null
	radar_sound = load("res://sounds/radar.ogg") if ResourceLoader.exists("res://sounds/radar.ogg") else null
	shot_sound = load("res://sounds/shot.ogg") if ResourceLoader.exists("res://sounds/shot.ogg") else null
	alarm_sound = load("res://sounds/alarm.ogg") if ResourceLoader.exists("res://sounds/alarm.ogg") else null

	# Создаём плееры
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = linear_to_db(SettingsManager.music_volume)
		music_player.autoplay = true

	radar_player = AudioStreamPlayer.new()
	if radar_sound:
		radar_player.stream = radar_sound
	radar_player.volume_db = linear_to_db(SettingsManager.radar_volume)
	add_child(radar_player)

	shot_player = AudioStreamPlayer.new()
	if shot_sound:
		shot_player.stream = shot_sound
	shot_player.volume_db = linear_to_db(SettingsManager.shot_volume)
	add_child(shot_player)

	alarm_player = AudioStreamPlayer.new()
	if alarm_sound:
		alarm_player.stream = alarm_sound
	alarm_player.volume_db = linear_to_db(SettingsManager.alarm_volume)
	add_child(alarm_player)

	# Подписываемся на изменение настроек (для обновления громкости)
	SettingsManager.settings_changed.connect(_update_volumes)


func _update_volumes() -> void:
	"""Обновляет громкость всех плееров при изменении настроек."""
	music_player.volume_db = linear_to_db(SettingsManager.music_volume)
	radar_player.volume_db = linear_to_db(SettingsManager.radar_volume)
	shot_player.volume_db = linear_to_db(SettingsManager.shot_volume)
	alarm_player.volume_db = linear_to_db(SettingsManager.alarm_volume)
	
	# Если громкость музыки равна 0, останавливаем плеер, иначе запускаем, если ещё не играет
	if SettingsManager.music_volume == 0:
		music_player.stop()
	elif not music_player.playing and music_stream:
		music_player.play()


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if radar_sound == null or SettingsManager.radar_volume == 0:
		return
	
	radar_timer += delta
	if radar_timer >= RADAR_INTERVAL:
		radar_timer = 0.0
		radar_player.play()


# -------------------- Публичные методы --------------------
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


func pause_music() -> void:
	if music_stream == null:
		return
	music_player.stop()


func resume_music() -> void:
	if music_stream == null or SettingsManager.music_volume == 0:
		return
	music_player.play()


func set_music_paused(paused: bool) -> void:
	if paused:
		pause_music()
	else:
		resume_music()
