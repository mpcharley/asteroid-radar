# settings_manager.gd
extends Node

signal settings_changed()

# Используем enum из GameManager
var current_difficulty: int = GameManager.Difficulty.MEDIUM
const DEFAULT_DARK: Color = Color.BLACK
const DEFAULT_LIGHT: Color = Color.ALICE_BLUE

# Настройки звука
var music_enabled: bool = true
var sounds_enabled: bool = true

var music_volume: float = 0.8
var radar_volume: float = 0.5
var shot_volume: float = 0.7
var alarm_volume: float = 0.9

# Настройки языка
enum Language { EN, RU }
var language: int = Language.EN

# Цветовые схемы
const COLOR_SCHEMES = [
	{
		"name": "CLASSIC",
		"colors": {
			"bg": Color(0.0, 0.068, 0.0, 1.0),
			"ui_border": Color.AQUA,
			"ui_bg": Color(0, 0, 0, 0.3),
			"ui_text_energy": Color.LIME_GREEN,
			"ui_text_hp": Color.RED,
			"ui_text_score": Color.YELLOW,
			"ui_text_stars": Color.LIME_GREEN,
			"asteroid_border": Color.WHITE,
			"asteroid_hover": Color.YELLOW,
			"asteroid_target": Color.RED,
			"asteroid_text": Color.WHITE,
			"cursor_line": Color.RED,
			"cursor_rect": Color.RED,
			"radar_line": Color.LIME_GREEN,
			"shot_line": Color.LIME_GREEN,
			"grid_line": Color.LIME_GREEN,
			"grid_line_alt": Color.AQUA,
			"circle_color": Color.AQUAMARINE
		}
	},
	{
		"name": "NEBULA",
		"colors": {
			"bg": Color(0.03, 0.01, 0.08),
			"ui_border": Color(0.6, 0.3, 1.0),
			"ui_bg": Color(0.1, 0.02, 0.2, 0.4),
			"ui_text_energy": Color(0.7, 0.5, 1.0),
			"ui_text_hp": Color(1.0, 0.3, 0.8),
			"ui_text_score": Color(0.4, 0.8, 1.0),
			"ui_text_stars": Color(0.8, 0.6, 1.0),
			"asteroid_border": Color(0.5, 0.2, 0.8),
			"asteroid_hover": Color(0.7, 0.4, 1.0),
			"asteroid_target": Color(1.0, 0.2, 0.6),
			"asteroid_text": Color(0.6, 0.8, 1.0),
			"cursor_line": Color(0.5, 0.5, 1.0),
			"cursor_rect": Color(0.5, 0.5, 1.0),
			"radar_line": Color(0.3, 0.3, 1.0),
			"shot_line": Color(0.2, 0.4, 1.0),
			"grid_line": Color(0.2, 0.1, 0.4),
			"grid_line_alt": Color(0.4, 0.2, 0.6),
			"circle_color": Color(0.6, 0.4, 1.0)
		}
	},
	{
		"name": "PASTEL",
		"colors": {
			"bg": Color(0.08, 0.08, 0.12),
			"ui_border": Color(0.6, 0.7, 1.0),
			"ui_bg": Color(0.15, 0.15, 0.25, 0.4),
			"ui_text_energy": Color(0.8, 0.9, 1.0),
			"ui_text_hp": Color(1.0, 0.6, 0.8),
			"ui_text_score": Color(0.7, 1.0, 0.8),
			"ui_text_stars": Color(0.9, 0.8, 1.0),
			"asteroid_border": Color(0.5, 0.6, 0.8),
			"asteroid_hover": Color(0.7, 0.8, 1.0),
			"asteroid_target": Color(1.0, 0.5, 0.5),
			"asteroid_text": Color(0.8, 0.9, 1.0),
			"cursor_line": Color(0.6, 0.8, 1.0),
			"cursor_rect": Color(0.6, 0.8, 1.0),
			"radar_line": Color(0.5, 0.7, 0.9),
			"shot_line": Color(0.4, 0.9, 0.9),
			"grid_line": Color(0.2, 0.2, 0.3),
			"grid_line_alt": Color(0.3, 0.3, 0.4),
			"circle_color": Color(0.5, 0.7, 1.0)
		}
	},
	{
		"name": "GOLD",
		"colors": {
			"bg": Color(0.05, 0.03, 0.0),
			"ui_border": Color(1.0, 0.8, 0.2),
			"ui_bg": Color(0.1, 0.08, 0.0, 0.4),
			"ui_text_energy": Color(1.0, 0.9, 0.4),
			"ui_text_hp": Color(1.0, 0.3, 0.3),
			"ui_text_score": Color(1.0, 0.8, 0.2),
			"ui_text_stars": Color(1.0, 0.9, 0.5),
			"asteroid_border": Color(0.8, 0.6, 0.1),
			"asteroid_hover": Color(1.0, 0.8, 0.3),
			"asteroid_target": Color(1.0, 0.2, 0.2),
			"asteroid_text": Color(1.0, 0.9, 0.6),
			"cursor_line": Color(1.0, 0.7, 0.1),
			"cursor_rect": Color(1.0, 0.7, 0.1),
			"radar_line": Color(0.8, 0.6, 0.2),
			"shot_line": Color(1.0, 0.8, 0.0),
			"grid_line": Color(0.3, 0.2, 0.0),
			"grid_line_alt": Color(0.6, 0.4, 0.0),
			"circle_color": Color(1.0, 0.8, 0.2)
		}
	},
	{
		"name": "INFERNO",
		"colors": {
			"bg": DEFAULT_DARK,
			"ui_border": Color(1.0, 0.5, 0.0),
			"ui_bg": Color(0.2, 0.0, 0.0, 0.5),
			"ui_text_energy": Color(1.0, 0.6, 0.1),
			"ui_text_hp": Color(1.0, 0.2, 0.1),
			"ui_text_score": Color(1.0, 0.8, 0.1),
			"ui_text_stars": Color(1.0, 0.6, 0.1),
			"asteroid_border": Color(1.0, 0.4, 0.1),
			"asteroid_hover": Color(1.0, 0.8, 0.0),
			"asteroid_target": Color(1.0, 0.1, 0.1),
			"asteroid_text": Color(1.0, 0.7, 0.2),
			"cursor_line": Color(1.0, 0.3, 0.0),
			"cursor_rect": Color(1.0, 0.3, 0.0),
			"radar_line": Color(1.0, 0.5, 0.0),
			"shot_line": Color(1.0, 0.3, 0.0),
			"grid_line": Color(1.0, 0.5, 0.0),
			"grid_line_alt": Color(1.0, 0.3, 0.0),
			"circle_color": Color(1.0, 0.3, 0.0)
		}
	},
	{
		"name": "ICE",
		"colors": {
			"bg": DEFAULT_DARK,
			"ui_border": Color(0.0, 0.8, 1.0),
			"ui_bg": Color(0.0, 0.1, 0.2, 0.4),
			"ui_text_energy": Color(0.3, 1.0, 1.0),
			"ui_text_hp": Color(0.8, 0.3, 1.0),
			"ui_text_score": Color(0.3, 1.0, 0.8),
			"ui_text_stars": Color(0.3, 1.0, 1.0),
			"asteroid_border": Color(0.6, 0.9, 1.0),
			"asteroid_hover": Color(0.2, 1.0, 0.8),
			"asteroid_target": Color(1.0, 0.2, 0.6),
			"asteroid_text": Color(0.7, 1.0, 1.0),
			"cursor_line": Color(0.0, 1.0, 0.8),
			"cursor_rect": Color(0.0, 1.0, 0.8),
			"radar_line": Color(0.2, 0.8, 1.0),
			"shot_line": Color(0.0, 1.0, 1.0),
			"grid_line": Color(0.2, 0.8, 1.0),
			"grid_line_alt": Color(0.0, 1.0, 0.8),
			"circle_color": Color(0.0, 0.8, 1.0)
		}
	},
	{
		"name": "SUNSET",
		"colors": {
			"bg": Color(0.08, 0.02, 0.04),
			"ui_border": Color(1.0, 0.5, 0.2),
			"ui_bg": Color(0.2, 0.05, 0.08, 0.4),
			"ui_text_energy": Color(1.0, 0.7, 0.3),
			"ui_text_hp": Color(1.0, 0.3, 0.5),
			"ui_text_score": Color(1.0, 0.8, 0.4),
			"ui_text_stars": Color(1.0, 0.6, 0.2),
			"asteroid_border": Color(1.0, 0.4, 0.1),
			"asteroid_hover": Color(1.0, 0.8, 0.4),
			"asteroid_target": Color(1.0, 0.2, 0.2),
			"asteroid_text": Color(1.0, 0.9, 0.6),
			"cursor_line": Color(1.0, 0.6, 0.2),
			"cursor_rect": Color(1.0, 0.6, 0.2),
			"radar_line": Color(1.0, 0.5, 0.3),
			"shot_line": Color(1.0, 0.7, 0.1),
			"grid_line": Color(0.8, 0.3, 0.1),
			"grid_line_alt": Color(1.0, 0.5, 0.2),
			"circle_color": Color(1.0, 0.5, 0.2)
		}
	},
	{
		"name": "WHITE",
		"colors": {
			"bg": DEFAULT_LIGHT,
			"ui_border": Color.BLUE_VIOLET,
			"ui_bg": Color(0.0, 0.1, 0.2, 0.4),
			"ui_text_energy": Color.BLUE_VIOLET,
			"ui_text_hp": Color.BLACK,
			"ui_text_score": Color.BLACK,
			"ui_text_stars": Color.BLACK,
			"asteroid_border": Color.BLACK,
			"asteroid_hover": Color.BLACK,
			"asteroid_target": Color.BLACK,
			"asteroid_text": Color.BLACK,
			"cursor_line": Color.RED,
			"cursor_rect": Color.RED,
			"radar_line": Color.BLACK,
			"shot_line": Color.DARK_RED,
			"grid_line": Color.BLACK,
			"grid_line_alt": Color.BLACK,
			"circle_color": Color.BLACK
		}
	},
	{
		"name": "BLACK",
		"colors": {
			"bg": DEFAULT_DARK,
			"ui_border": Color.ANTIQUE_WHITE,
			"ui_bg": Color(0.0, 0.1, 0.2, 0.4),
			"ui_text_energy": Color.ANTIQUE_WHITE,
			"ui_text_hp": Color.ANTIQUE_WHITE,
			"ui_text_score": Color.ANTIQUE_WHITE,
			"ui_text_stars": Color.ANTIQUE_WHITE,
			"asteroid_border": Color.ANTIQUE_WHITE,
			"asteroid_hover": Color.ANTIQUE_WHITE,
			"asteroid_target": Color.ANTIQUE_WHITE,
			"asteroid_text": Color.ANTIQUE_WHITE,
			"cursor_line": Color.ANTIQUE_WHITE,
			"cursor_rect": Color.ANTIQUE_WHITE,
			"radar_line": Color.ANTIQUE_WHITE,
			"shot_line": Color.ANTIQUE_WHITE,
			"grid_line": Color.ANTIQUE_WHITE,
			"grid_line_alt": Color.ANTIQUE_WHITE,
			"circle_color": Color.ANTIQUE_WHITE
		}
	},
	{
		"name": "FOREST",
		"colors": {
			"bg": Color(0.02, 0.08, 0.02),
			"ui_border": Color(0.2, 0.8, 0.2),
			"ui_bg": Color(0.05, 0.15, 0.05, 0.4),
			"ui_text_energy": Color(0.5, 1.0, 0.5),
			"ui_text_hp": Color(1.0, 0.4, 0.4),
			"ui_text_score": Color(0.8, 1.0, 0.4),
			"ui_text_stars": Color(0.6, 1.0, 0.6),
			"asteroid_border": Color(0.3, 0.7, 0.2),
			"asteroid_hover": Color(0.5, 1.0, 0.3),
			"asteroid_target": Color(1.0, 0.3, 0.3),
			"asteroid_text": Color(0.7, 1.0, 0.5),
			"cursor_line": Color(0.3, 1.0, 0.3),
			"cursor_rect": Color(0.3, 1.0, 0.3),
			"radar_line": Color(0.2, 0.8, 0.4),
			"shot_line": Color(0.0, 1.0, 0.2),
			"grid_line": Color(0.1, 0.5, 0.1),
			"grid_line_alt": Color(0.2, 0.7, 0.2),
			"circle_color": Color(0.3, 0.8, 0.3)
		}
	},
	{
		"name": "PINKY",
		"colors": {
			"bg": Color(0.446, 0.024, 0.203, 1.0),
			"ui_border": Color(0.829, 0.812, 0.164, 1.0),
			"ui_bg": Color(0.0, 0.1, 0.2, 0.4),
			"ui_text_energy": Color(0.829, 0.812, 0.164, 1.0),
			"ui_text_hp": Color(0.829, 0.812, 0.164, 1.0),
			"ui_text_score": Color(0.829, 0.812, 0.164, 1.0),
			"ui_text_stars": Color(0.735, 0.794, 0.83, 1.0),
			"asteroid_border": Color(1.0, 1.0, 1.0, 1.0),
			"asteroid_hover": Color(0.537, 0.999, 0.946, 1.0),
			"asteroid_target": Color(1.0, 0.672, 0.795, 1.0),
			"asteroid_text": Color(0.893, 0.693, 1.0, 1.0),
			"cursor_line": Color(0.532, 0.9, 0.0, 1.0),
			"cursor_rect": Color(0.678, 0.865, 0.0, 1.0),
			"radar_line": Color(1.0, 0.649, 0.911, 1.0),
			"shot_line": Color(0.261, 0.884, 0.889, 1.0),
			"grid_line": Color(1.0, 0.81, 0.995, 1.0),
			"grid_line_alt": Color(1.0, 0.696, 0.992, 1.0),
			"circle_color": Color(0.916, 0.68, 1.0, 1.0)
		}
	}
]

var current_scheme_index: int = 0
var autobattle_enabled: bool = false   # по умолчанию включен


func _ready() -> void:
	load_settings()
	
	
func toggle_autobattle() -> void:
	autobattle_enabled = not autobattle_enabled
	settings_changed.emit()
	save_settings()

func get_color(key: String) -> Color:
	var scheme = COLOR_SCHEMES[current_scheme_index]
	if scheme.colors.has(key):
		return scheme.colors[key]
	return Color.WHITE


func get_current_scheme_name() -> String:
	return COLOR_SCHEMES[current_scheme_index]["name"]


func set_color_scheme(index: int) -> void:
	if index >= 0 and index < COLOR_SCHEMES.size():
		current_scheme_index = index
		settings_changed.emit()
		save_settings()


func set_difficulty(diff: int) -> void:
	current_difficulty = diff
	GameManager.set_difficulty(diff)
	settings_changed.emit()
	save_settings()


# -------------------- Настройки звука --------------------
func toggle_music() -> void:
	music_enabled = not music_enabled
	settings_changed.emit()
	save_settings()
	if music_enabled:
		AudioManager.resume_music()
	else:
		AudioManager.pause_music()


func toggle_sounds() -> void:
	sounds_enabled = not sounds_enabled
	settings_changed.emit()
	save_settings()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	settings_changed.emit()
	save_settings()


func set_radar_volume(value: float) -> void:
	radar_volume = clamp(value, 0.0, 1.0)
	settings_changed.emit()
	save_settings()


func set_shot_volume(value: float) -> void:
	shot_volume = clamp(value, 0.0, 1.0)
	settings_changed.emit()
	save_settings()


func set_alarm_volume(value: float) -> void:
	alarm_volume = clamp(value, 0.0, 1.0)
	settings_changed.emit()
	save_settings()
	
# -------------------- Настройки языка --------------------
func set_language(lang: int) -> void:
	if lang == Language.EN or lang == Language.RU:
		language = lang
		settings_changed.emit()
		save_settings()


func get_language_string() -> String:
	match language:
		Language.EN:
			return "English"
		Language.RU:
			return "Русский"
	return ""


# -------------------- Сохранение и загрузка --------------------
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "difficulty", current_difficulty)
	config.set_value("settings", "color_scheme", current_scheme_index)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "radar_volume", radar_volume)
	config.set_value("settings", "shot_volume", shot_volume)
	config.set_value("settings", "alarm_volume", alarm_volume)
	config.set_value("settings", "autobattle", autobattle_enabled)
	config.set_value("settings", "language", language)
	config.save("user://settings.cfg")


func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		current_difficulty = config.get_value("settings", "difficulty", GameManager.Difficulty.MEDIUM)
		GameManager.set_difficulty(current_difficulty)
		current_scheme_index = config.get_value("settings", "color_scheme", 0)
		music_volume = config.get_value("settings", "music_volume", 0.8)
		radar_volume = config.get_value("settings", "radar_volume", 0.5)
		shot_volume = config.get_value("settings", "shot_volume", 0.7)
		alarm_volume = config.get_value("settings", "alarm_volume", 0.9)
		language = config.get_value("settings", "language", Language.EN)
		autobattle_enabled = config.get_value("settings", "autobattle", true)
	else:
		current_difficulty = GameManager.Difficulty.MEDIUM
		current_scheme_index = 0
		music_volume = 0.8
		radar_volume = 0.5
		shot_volume = 0.7
		alarm_volume = 0.9
		language = Language.EN
		autobattle_enabled = false
		GameManager.set_difficulty(GameManager.Difficulty.MEDIUM)
