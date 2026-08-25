# TranslationManager.gd
extends Node
# ============================================================
# Менеджер локализации. Хранит все тексты на разных языках.
# ============================================================

var translations = {
	"en": {
		# Главное меню
		"settings_title": "SETTINGS",
		"difficulty_label": "Difficulty:",
		"easy": "EASY",
		"medium": "MEDIUM",
		"hard": "HARD",
		"color_scheme_label": "Color scheme:",
		"sound_label": "Sound:",
		"music": "Music",
		"sounds": "Sounds",
		"language_label": "Language:",
		"restart": "RESTART",
		"quit": "QUIT",
		# Панели
		"energy": "ENERGY",
		"hp": "HP",
		"score": "SCORE",
		"asteroids": "ASTEROIDS",
		"no_asteroids": "0",
		"game_over": "GAME OVER",
		# Астероиды (будут использоваться в списке)
		"hp_format": "HP: %d/%d",
		# Звёзды (заголовок панели)
		"stars_title": "Stars",
		"autobattle": "Auto-battle",
		"is_on":"ON",
		"is_off":"OFF",
		"music_volume": "Music",
		"radar_volume": "Radar",
		"shot_volume": "Shots",
		"alarm_volume": "Alarm",
	},
	"ru": {
		"settings_title": "НАСТРОЙКИ",
		"difficulty_label": "Сложность:",
		"easy": "ЛЕГКО",
		"medium": "СРЕДНЕ",
		"hard": "СЛОЖНО",
		"color_scheme_label": "Цветовая схема:",
		"sound_label": "Звук:",
		"music": "Музыка",
		"sounds": "Эффекты",
		"language_label": "Язык:",
		"restart": "РЕСТАРТ",
		"quit": "ВЫХОД",
		"energy": "ЭНЕРГИЯ",
		"hp": "ЗДОРОВЬЕ",
		"score": "СЧЁТ",
		"asteroids": "АСТЕРОИДЫ",
		"no_asteroids": "0",
		"game_over": "ИГРА ОКОНЧЕНА",
		"hp_format": "HP: %d/%d",
		"stars_title": "Звёзды",
		"autobattle": "Автобой",
		"is_on":"Включен",
		"is_off":"Выключен",
		"music_volume": "Музыка",
		"radar_volume": "Радар",
		"shot_volume": "Выстрелы",
		"alarm_volume": "Тревога",
	}
}


func get_text(key: String) -> String:
	var lang = "en" if SettingsManager.language == SettingsManager.Language.EN else "ru"
	if translations.has(lang) and translations[lang].has(key):
		return translations[lang][key]
	return key
