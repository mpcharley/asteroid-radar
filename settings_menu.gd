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

	# Контейнер для слайдеров (с вертикальным расположением)
	var sound_vbox = VBoxContainer.new()
	sound_vbox.add_theme_constant_override("separation", 5)
	vbox.add_child(sound_vbox)

	# Создаём слайдеры для каждого канала
	_create_volume_slider(sound_vbox, TranslationManager.get_text("music_volume"), SettingsManager.music_volume, SettingsManager.set_music_volume)
	_create_volume_slider(sound_vbox, TranslationManager.get_text("radar_volume"), SettingsManager.radar_volume, SettingsManager.set_radar_volume)
	_create_volume_slider(sound_vbox, TranslationManager.get_text("shot_volume"), SettingsManager.shot_volume, SettingsManager.set_shot_volume)
	_create_volume_slider(sound_vbox, TranslationManager.get_text("alarm_volume"), SettingsManager.alarm_volume, SettingsManager.set_alarm_volume)

	# Автобой
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
	auto_check.pressed.connect(_on_autobattle_toggled.bind(auto_check))
	auto_hbox.add_child(auto_check)

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


# -------------------- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ --------------------

# Функция для создания слайдера с меткой (ИСПРАВЛЕНА)
func _create_volume_slider(parent: VBoxContainer, label_text: String, initial_value: float, callback: Callable) -> void:
	var hbox = HBoxContainer.new()
	parent.add_child(hbox)

	var label = Label.new()
	label.text = label_text + ":"
	label.add_theme_font_override("font", FontManager.custom_font)
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color.WHITE
	label.custom_minimum_size = Vector2(120, 0)
	label.mouse_filter = MOUSE_FILTER_IGNORE   # чтобы не перехватывать события
	hbox.add_child(label)

	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.value = initial_value * 100
	slider.size_flags_horizontal = SIZE_EXPAND
	slider.custom_minimum_size = Vector2(100, 20)   # минимальная высота для захвата
	slider.mouse_filter = MOUSE_FILTER_STOP          # получает события мыши
	slider.focus_mode = FOCUS_ALL                    # может получать фокус
	slider.value_changed.connect(func(value): callback.call(value / 100.0))
	hbox.add_child(slider)

	var value_label = Label.new()
	value_label.text = str(round(slider.value)) + "%"
	value_label.add_theme_font_override("font", FontManager.custom_font)
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.modulate = Color.WHITE
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.mouse_filter = MOUSE_FILTER_IGNORE
	hbox.add_child(value_label)

	# Обновляем значение при изменении слайдера
	slider.value_changed.connect(func(value): value_label.text = str(round(value)) + "%")


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


# -------------------- ОБРАБОТЧИКИ --------------------

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
	get_tree().paused = false
	close_and_free()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


func close_and_free() -> void:
	close()
	queue_free()
