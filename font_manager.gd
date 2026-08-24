# FontManager.gd
extends Node

# Загружаем шрифты для разных языков
var custom_font_en: Font = load("res://RU.ttf") if ResourceLoader.exists("res://RU.ttf") else null
var custom_font_ru: Font = load("res://RU.ttf") if ResourceLoader.exists("res://RU.ttf") else null

# Текущий активный шрифт (по умолчанию английский)
var custom_font: Font:
	get:
		if SettingsManager.language == SettingsManager.Language.RU and custom_font_ru:
			return custom_font_ru
		return custom_font_en
