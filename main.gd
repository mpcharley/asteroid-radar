extends Node
# ============================================================
# Корневой узел игры. Создаёт игровой мир и UI слой.
# UI слой имеет PROCESS_MODE_ALWAYS, игровой мир – PROCESS_MODE_INHERIT.
# При паузе останавливается только игровой мир.
# ============================================================

var game_world: Node2D
var ui_layer: CanvasLayer
var ui_controller: Control

# Панели UI
var energy_panel: Panel
var energy_label: Label
var hp_panel: Panel
var hp_label: Label
var score_panel: Panel
var score_label: Label

# Панель астероидов
var asteroids_panel: Panel
var asteroids_label: Label

# Меню настроек
var settings_menu: Control = null


func _ready() -> void:
	# Корневой узел НЕ имеет ALWAYS, чтобы пауза останавливала игровой мир
	# (по умолчанию PROCESS_MODE_INHERIT)

	# Создаём игровой мир (будет наследовать режим от корня, т.е. INHERIT)
	game_world = preload("res://game_world.gd").new()
	add_child(game_world)

	# Создаём UI слой с ALWAYS (продолжает работать при паузе)
	ui_layer = CanvasLayer.new()
	ui_layer.process_mode = PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	# Создаём контроллер UI с отдельным скриптом для обработки ввода
	var controller = preload("res://ui_controller.gd").new()
	ui_controller = controller
	ui_controller.anchor_left = 0.0
	ui_controller.anchor_top = 0.0
	ui_controller.anchor_right = 1.0
	ui_controller.anchor_bottom = 1.0
	ui_controller.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_controller)
	ui_controller.settings_menu_toggled.connect(_on_settings_menu_toggled)

	# Создаём UI элементы
	create_custom_cursor()
	create_energy_panel()
	create_hp_panel()
	create_score_panel()
	create_asteroids_panel()

	# Подключаем сигналы GameManager
	GameManager.energy_changed.connect(_on_energy_changed)
	_on_energy_changed(GameManager.current_energy)

	GameManager.ship_hp_changed.connect(_on_ship_hp_changed)
	GameManager.ship_destroyed.connect(_on_ship_destroyed)
	_on_ship_hp_changed(GameManager.ship_hp)

	GameManager.score_changed.connect(_on_score_changed)
	_on_score_changed(GameManager.score)

	SettingsManager.settings_changed.connect(_on_settings_changed)
	game_world.asteroids_updated.connect(_on_asteroids_updated)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	# Первоначальное обновление локализации
	update_ui_texts()


# -------------------- Общие функции для панелей --------------------
func _create_panel_style() -> StyleBoxFlat:
	#Создаёт общий стиль для панелей.
	var style = StyleBoxFlat.new()
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = SettingsManager.get_color("ui_border")
	style.bg_color = SettingsManager.get_color("ui_bg")
	return style


func _create_panel(panel: Panel, label: Label, text: String, font: Font, font_size: int, color: Color, z_index: int) -> void:
	#Общая настройка панели и метки (без размещения/размеров).
	panel.add_theme_stylebox_override("panel", _create_panel_style())
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.text = text
	label.modulate = color
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)
	panel.z_index = z_index


# -------------------- Создание UI --------------------
func create_custom_cursor() -> void:
	var CustomCursor = preload("res://custom_cursor.gd")
	var cursor = CustomCursor.new()
	ui_controller.add_child(cursor)
	cursor.z_index = 10


func create_energy_panel() -> void:
	energy_panel = Panel.new()
	energy_label = Label.new()
	energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	energy_label.anchor_left = 0.0
	energy_label.anchor_top = 0.0
	energy_label.anchor_right = 1.0
	energy_label.anchor_bottom = 1.0
	var text = TranslationManager.get_text("energy") + ": 0"
	_create_panel(energy_panel, energy_label, text, FontManager.custom_font, 11, SettingsManager.get_color("ui_text_energy"), 5)

	energy_panel.anchor_right = 1.0
	energy_panel.anchor_bottom = 1.0
	energy_panel.anchor_left = 1.0
	energy_panel.anchor_top = 1.0
	energy_panel.offset_left = -180
	energy_panel.offset_top = -40
	energy_panel.offset_right = -20
	energy_panel.offset_bottom = -10
	ui_controller.add_child(energy_panel)


func create_hp_panel() -> void:
	hp_panel = Panel.new()
	hp_label = Label.new()
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.anchor_left = 0.0
	hp_label.anchor_top = 0.0
	hp_label.anchor_right = 1.0
	hp_label.anchor_bottom = 1.0
	var text = TranslationManager.get_text("hp") + ": 10/10"
	_create_panel(hp_panel, hp_label, text, FontManager.custom_font, 11, SettingsManager.get_color("ui_text_hp"), 5)

	hp_panel.anchor_left = 0.0
	hp_panel.anchor_bottom = 1.0
	hp_panel.anchor_right = 0.0
	hp_panel.anchor_top = 1.0
	hp_panel.offset_left = 20
	hp_panel.offset_bottom = -10
	hp_panel.offset_right = 180
	hp_panel.offset_top = -40
	ui_controller.add_child(hp_panel)


func create_score_panel() -> void:
	score_panel = Panel.new()
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.anchor_left = 0.0
	score_label.anchor_top = 0.0
	score_label.anchor_right = 1.0
	score_label.anchor_bottom = 1.0
	var text = TranslationManager.get_text("score") + ": 0"
	_create_panel(score_panel, score_label, text, FontManager.custom_font, 11, SettingsManager.get_color("ui_text_score"), 5)

	score_panel.anchor_right = 1.0
	score_panel.anchor_top = 0.0
	score_panel.anchor_left = 1.0
	score_panel.anchor_bottom = 0.0
	score_panel.offset_left = -180
	score_panel.offset_top = 20
	score_panel.offset_right = -20
	score_panel.offset_bottom = 50
	ui_controller.add_child(score_panel)


func create_asteroids_panel() -> void:
	asteroids_panel = Panel.new()
	asteroids_label = Label.new()
	asteroids_label.text = TranslationManager.get_text("asteroids") + ":\n" + TranslationManager.get_text("no_asteroids")
	asteroids_label.add_theme_font_override("font", FontManager.custom_font)
	asteroids_label.add_theme_font_size_override("font_size", 11)
	asteroids_label.modulate = SettingsManager.get_color("ui_text_score")
	asteroids_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	asteroids_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	asteroids_label.anchor_left = 0.0
	asteroids_label.anchor_top = 0.0
	asteroids_label.anchor_right = 1.0
	asteroids_label.anchor_bottom = 1.0
	asteroids_label.position = Vector2(10, 10)
	asteroids_panel.add_child(asteroids_label)
	asteroids_panel.add_theme_stylebox_override("panel", _create_panel_style())
	asteroids_panel.z_index = 5

	asteroids_panel.anchor_left = 0.0
	asteroids_panel.anchor_top = 0.0
	asteroids_panel.anchor_right = 0.0
	asteroids_panel.anchor_bottom = 0.0
	ui_controller.add_child(asteroids_panel)

	_update_asteroids_panel_position()


func _update_asteroids_panel_position() -> void:
	if not asteroids_panel:
		return
	var viewport = get_viewport()
	var size = viewport.get_visible_rect().size
	var margin = size.x * 0.01
	var panel_width = size.x * 0.125
	var panel_height = size.y * 0.3
	var star_panel_right = margin + panel_width
	asteroids_panel.offset_left = star_panel_right + margin
	asteroids_panel.offset_top = margin
	asteroids_panel.offset_right = star_panel_right + margin + panel_width
	asteroids_panel.offset_bottom = margin + panel_height
	asteroids_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


# -------------------- Обновление UI --------------------
func _on_energy_changed(new_energy: float) -> void:
	if energy_label:
		energy_label.text = TranslationManager.get_text("energy") + ": " + str(round(new_energy)) + "/" + str(round(GameManager.MAX_ENERGY))


func _on_ship_hp_changed(new_hp: int) -> void:
	if hp_label:
		hp_label.text = TranslationManager.get_text("hp") + ": " + str(new_hp) + "/" + str(GameManager.max_ship_hp)


func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = TranslationManager.get_text("score") + ": " + str(new_score)


func _on_ship_destroyed() -> void:
	#get_tree().paused = true
	#AudioManager.set_music_paused(true)

	var game_over_label = Label.new()
	game_over_label.text = TranslationManager.get_text("game_over")
	game_over_label.add_theme_font_override("font", FontManager.custom_font)
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.modulate = Color.RED
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.anchor_left = 0.0
	game_over_label.anchor_top = 0.0
	game_over_label.anchor_right = 1.0
	game_over_label.anchor_bottom = 1.0
	ui_controller.add_child(game_over_label)
	game_over_label.z_index = 20
	open_settings_menu()

# -------------------- Обновление цветов UI --------------------
func _on_settings_changed() -> void:
	update_ui_colors()
	update_ui_texts()


func update_ui_colors() -> void:
	for panel in [energy_panel, hp_panel, score_panel, asteroids_panel]:
		if panel:
			var style = panel.get_theme_stylebox("panel")
			if style is StyleBoxFlat:
				style.border_color = SettingsManager.get_color("ui_border")
				style.bg_color = SettingsManager.get_color("ui_bg")

	if energy_label:
		energy_label.modulate = SettingsManager.get_color("ui_text_energy")
	if hp_label:
		hp_label.modulate = SettingsManager.get_color("ui_text_hp")
	if score_label:
		score_label.modulate = SettingsManager.get_color("ui_text_score")
	if asteroids_label:
		asteroids_label.modulate = SettingsManager.get_color("ui_text_score")


func update_ui_texts() -> void:
	# Обновляем тексты панелей (не динамические части)
	if energy_label:
		var current_value = energy_label.text.split(":")[1].strip_edges() if ":" in energy_label.text else "0"
		energy_label.text = TranslationManager.get_text("energy") + ": " + current_value
	if hp_label:
		var current_value = hp_label.text.split(":")[1].strip_edges() if ":" in hp_label.text else "10/10"
		hp_label.text = TranslationManager.get_text("hp") + ": " + current_value
	if score_label:
		var current_value = score_label.text.split(":")[1].strip_edges() if ":" in score_label.text else "0"
		score_label.text = TranslationManager.get_text("score") + ": " + current_value
	if asteroids_label:
		var lines = asteroids_label.text.split("\n")
		if lines.size() > 0:
			lines[0] = TranslationManager.get_text("asteroids") + ":"
			asteroids_label.text = "\n".join(lines)


# -------------------- Список астероидов --------------------
func _on_asteroids_updated(asteroid_list: Array) -> void:
	if not asteroids_label:
		return
	var title = TranslationManager.get_text("asteroids") + ":"
	if asteroid_list.is_empty():
		asteroids_label.text = title + "\n" + TranslationManager.get_text("no_asteroids")
	else:
		var lines = [title]
		for a in asteroid_list:
			lines.append("%s (%s)" % [a.star_name, TranslationManager.get_text("hp_format") % [a.hp, a.max_hp]])
		asteroids_label.text = "\n".join(lines)


# -------------------- Обработка ESC через сигнал от ui_controller --------------------
func _on_settings_menu_toggled() -> void:
	if settings_menu == null:
		open_settings_menu()
	else:
		close_settings_menu()


# -------------------- Меню настроек --------------------
func open_settings_menu() -> void:
	if settings_menu != null:
		return
	get_tree().paused = true
	AudioManager.set_music_paused(true)

	settings_menu = Control.new()
	settings_menu.anchor_left = 0.0
	settings_menu.anchor_top = 0.0
	settings_menu.anchor_right = 1.0
	settings_menu.anchor_bottom = 1.0
	settings_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_menu.z_index = 100
	ui_controller.add_child(settings_menu)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	settings_menu.add_child(bg)

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
	settings_menu.add_child(vbox)

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
	var current_index = SettingsManager.current_scheme_index
	color_select.item_selected.connect(_on_color_scheme_selected)
	color_select.select(current_index)
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

	# Кнопки действий
	var sep = HSeparator.new()
	vbox.add_child(sep)

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


func _on_difficulty_selected(diff: int) -> void:
	SettingsManager.set_difficulty(diff)
	close_settings_menu()


func _on_color_scheme_selected(index: int) -> void:
	SettingsManager.set_color_scheme(index)
	close_settings_menu()


func _on_music_toggled(check: CheckButton) -> void:
	SettingsManager.toggle_music()
	check.button_pressed = SettingsManager.music_enabled


func _on_sounds_toggled(check: CheckButton) -> void:
	SettingsManager.toggle_sounds()
	check.button_pressed = SettingsManager.sounds_enabled


func _on_language_selected(lang: int) -> void:
	SettingsManager.set_language(lang)
	close_settings_menu()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	close_settings_menu()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


func close_settings_menu() -> void:
	if settings_menu:
		settings_menu.queue_free()
		settings_menu = null
		if GameManager.ship_hp > 0:
			get_tree().paused = false
			AudioManager.set_music_paused(false)


func _on_viewport_size_changed() -> void:
	_update_asteroids_panel_position()
