# settings_menu.gd
extends Control

signal closed

var diff_buttons: Array = []


func _ready() -> void:
	# Настройка корневого узла
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = MOUSE_FILTER_STOP
	z_index = 100

	# Фон
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	# Основной контейнер
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -240
	vbox.offset_top = -240
	vbox.offset_right = 240
	vbox.offset_bottom = 240
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	# Заголовок
	var title = Label.new()
	title.text = TranslationManager.get_text("settings_title")
	title.add_theme_font_override("font", FontManager.custom_font)
	title.add_theme_font_size_override("font_size", 24)
	title.modulate = Color.WHITE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Сложность
	var diff_label = Label.new()
	diff_label.text = TranslationManager.get_text("difficulty_label")
	diff_label.add_theme_font_override("font", FontManager.custom_font)
	diff_label.add_theme_font_size_override("font_size", 16)
	diff_label.modulate = Color.WHITE
	vbox.add_child(diff_label)

	var diff_hbox = HBoxContainer.new()
	diff_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(diff_hbox)

	var diff_names = [
		TranslationManager.get_text("easy"),
		TranslationManager.get_text("medium"),
		TranslationManager.get_text("hard")
	]
	for i in range(3):
		var btn = Button.new()
		btn.text = diff_names[i]
		btn.custom_minimum_size = Vector2(100, 30)
		btn.pressed.connect(_on_difficulty_selected.bind(i))
		diff_hbox.add_child(btn)
		diff_buttons.append(btn)

	# Цветовая схема
	var color_label = Label.new()
	color_label.text = TranslationManager.get_text("color_scheme_label")
	color_label.add_theme_font_override("font", FontManager.custom_font)
	color_label.add_theme_font_size_override("font_size", 16)
	color_label.modulate = Color.WHITE
	vbox.add_child(color_label)

	var color_select = OptionButton.new()
	for i in range(SettingsManager.COLOR_SCHEMES.size()):
		color_select.add_item(SettingsManager.COLOR_SCHEMES[i]["name"])
	color_select.select(SettingsManager.current_scheme_index)
	color_select.item_selected.connect(_on_color_scheme_selected)
	vbox.add_child(color_select)

	# Звук
	var sound_label = Label.new()
	sound_label.text = TranslationManager.get_text("sound_label")
	sound_label.add_theme_font_override("font", FontManager.custom_font)
	sound_label.add_theme_font_size_override("font_size", 16)
	sound_label.modulate = Color.WHITE
	vbox.add_child(sound_label)

	var sound_hbox = HBoxContainer.new()
	sound_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(sound_hbox)

	var music_check = CheckButton.new()
	music_check.button_pressed = SettingsManager.music_enabled
	music_check.text = TranslationManager.get_text("music")
	music_check.add_theme_font_override("font", FontManager.custom_font)
	music_check.pressed.connect(_on_music_toggled.bind(music_check))
	sound_hbox.add_child(music_check)

	var sounds_check = CheckButton.new()
	sounds_check.button_pressed = SettingsManager.sounds_enabled
	sounds_check.text = TranslationManager.get_text("sounds")
	sounds_check.add_theme_font_override("font", FontManager.custom_font)
	sounds_check.pressed.connect(_on_sounds_toggled.bind(sounds_check))
	sound_hbox.add_child(sounds_check)

	# ---------- Автобой ----------
	var auto_label = Label.new()
	auto_label.text = TranslationManager.get_text("autobattle")+":"
	auto_label.add_theme_font_override("font", FontManager.custom_font)
	auto_label.add_theme_font_size_override("font_size", 16)
	auto_label.modulate = Color.WHITE
	vbox.add_child(auto_label)

	var auto_hbox = HBoxContainer.new()
	auto_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(auto_hbox)

	var auto_check = CheckButton.new()
	auto_check.button_pressed = SettingsManager.autobattle_enabled
	auto_check.add_theme_font_override("font", FontManager.custom_font)
	_update_autobattle_text(auto_check)
	#auto_check.pressed.connect(_on_autobattle_toggled.bind(auto_check))
	#auto_check.text = TranslationManager.get_text("is_on")
	auto_check.pressed.connect(_on_autobattle_toggled.bind(auto_check))
	auto_hbox.add_child(auto_check)
	# -----------------------------

	# Язык
	var lang_label = Label.new()
	lang_label.text = TranslationManager.get_text("language_label")
	lang_label.add_theme_font_override("font", FontManager.custom_font)
	lang_label.add_theme_font_size_override("font_size", 16)
	lang_label.modulate = Color.WHITE
	vbox.add_child(lang_label)

	var lang_hbox = HBoxContainer.new()
	lang_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(lang_hbox)

	var en_btn = Button.new()
	en_btn.text = "English"
	en_btn.custom_minimum_size = Vector2(100, 30)
	en_btn.pressed.connect(_on_language_selected.bind(SettingsManager.Language.EN))
	lang_hbox.add_child(en_btn)

	var ru_btn = Button.new()
	ru_btn.text = "Русский"
	ru_btn.custom_minimum_size = Vector2(100, 30)
	ru_btn.pressed.connect(_on_language_selected.bind(SettingsManager.Language.RU))
	lang_hbox.add_child(ru_btn)

	# Разделитель
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Кнопки действий
	var action_hbox = HBoxContainer.new()
	action_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(action_hbox)

	var restart_btn = Button.new()
	restart_btn.text = TranslationManager.get_text("restart")
	restart_btn.add_theme_font_override("font", FontManager.custom_font)
	restart_btn.custom_minimum_size = Vector2(100, 40)
	restart_btn.pressed.connect(_on_restart_pressed)
	action_hbox.add_child(restart_btn)

	var quit_btn = Button.new()
	quit_btn.text = TranslationManager.get_text("quit")
	quit_btn.add_theme_font_override("font", FontManager.custom_font)
	quit_btn.custom_minimum_size = Vector2(100, 40)
	quit_btn.pressed.connect(_on_quit_pressed)
	action_hbox.add_child(quit_btn)

func _update_autobattle_text(check: CheckButton) -> void:
	if check.button_pressed:
		check.text = TranslationManager.get_text("is_on")
	else:
		check.text = TranslationManager.get_text("is_off")

func open() -> void:
	get_tree().paused = true
	AudioManager.set_music_paused(true)


func close() -> void:
	get_tree().paused = false
	AudioManager.set_music_paused(false)
	closed.emit()


func _on_difficulty_selected(diff: int) -> void:
	SettingsManager.set_difficulty(diff)
	close_and_free()


func _on_color_scheme_selected(index: int) -> void:
	SettingsManager.set_color_scheme(index)
	close_and_free()


func _on_music_toggled(check: CheckButton) -> void:
	SettingsManager.toggle_music()
	check.button_pressed = SettingsManager.music_enabled


func _on_sounds_toggled(check: CheckButton) -> void:
	SettingsManager.toggle_sounds()
	check.button_pressed = SettingsManager.sounds_enabled


func _on_autobattle_toggled(check: CheckButton) -> void:
	SettingsManager.toggle_autobattle()
	check.button_pressed = SettingsManager.autobattle_enabled
	_update_autobattle_text(check)

func _on_language_selected(lang: int) -> void:
	SettingsManager.set_language(lang)
	close_and_free()


func _on_restart_pressed() -> void:
	GameManager.drop_score()
	close_and_free()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


func close_and_free() -> void:
	close()
	queue_free()
