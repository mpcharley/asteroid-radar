extends Control

# ============================================================
# HUD – все панели интерфейса, курсор, обновление значений
# ============================================================

# Константы позиционирования (якоря и смещения)
const ANCHOR_TOP_RIGHT = { "left": 1.0, "top": 0.0, "right": 1.0, "bottom": 0.0 }

const OFFSET_SCORE = { "left": -180, "top": 20,  "right": -20, "bottom": 50 }
const OFFSET_ENERGY = { "left": -180, "top": 60,  "right": -20, "bottom": 90 }
const OFFSET_HP     = { "left": -180, "top": 100, "right": -20, "bottom": 130 }

# Панели
var energy_panel: UIPanel
var hp_panel: UIPanel
var score_panel: UIPanel
var asteroids_panel: Panel
var asteroids_label: Label

# Текущие значения (для обновления текста при смене языка)
var _current_energy: float = GameManager.MAX_ENERGY
var _current_hp: int = GameManager.max_ship_hp
var _current_score: int = 0

var game_world_ref: Node2D = null

signal settings_requested


func _ready() -> void:
	create_custom_cursor()
	create_energy_panel()
	create_hp_panel()
	create_score_panel()
	create_asteroids_panel()

	# Подписка на сигналы GameManager
	GameManager.energy_changed.connect(_on_energy_changed)
	_on_energy_changed(GameManager.current_energy)

	GameManager.ship_hp_changed.connect(_on_ship_hp_changed)
	GameManager.ship_destroyed.connect(_on_ship_destroyed)
	_on_ship_hp_changed(GameManager.ship_hp)

	GameManager.score_changed.connect(_on_score_changed)
	_on_score_changed(GameManager.score)

	SettingsManager.settings_changed.connect(_on_settings_changed)
	update_ui_texts()


func set_game_world(world: Node2D) -> void:
	game_world_ref = world
	if game_world_ref:
		game_world_ref.asteroids_updated.connect(_on_asteroids_updated)
		get_viewport().size_changed.connect(_on_viewport_size_changed)


# ====== Фабричный метод для создания UIPanel ======
func _create_ui_panel(
	text: String,
	color_key: String,
	anchors: Dictionary,
	offsets: Dictionary,
	z_idx: int = 5
) -> UIPanel:
	var panel = UIPanel.new()
	panel.initialize(
		text,
		SettingsManager.get_color(color_key),
		FontManager.custom_font,
		11
	)
	panel.z_index = z_idx

	if anchors.has("left"):   panel.anchor_left = anchors["left"]
	if anchors.has("top"):    panel.anchor_top = anchors["top"]
	if anchors.has("right"):  panel.anchor_right = anchors["right"]
	if anchors.has("bottom"): panel.anchor_bottom = anchors["bottom"]

	if offsets.has("left"):   panel.offset_left = offsets["left"]
	if offsets.has("top"):    panel.offset_top = offsets["top"]
	if offsets.has("right"):  panel.offset_right = offsets["right"]
	if offsets.has("bottom"): panel.offset_bottom = offsets["bottom"]

	add_child(panel)
	return panel


# ====== Создание конкретных панелей ======
func create_energy_panel() -> void:
	energy_panel = _create_ui_panel(
		TranslationManager.get_text("energy") + ": 0/0",
		"ui_text_energy",
		ANCHOR_TOP_RIGHT,
		OFFSET_ENERGY,
		5
	)


func create_hp_panel() -> void:
	hp_panel = _create_ui_panel(
		TranslationManager.get_text("hp") + ": 0/0",
		"ui_text_hp",
		ANCHOR_TOP_RIGHT,
		OFFSET_HP,
		5
	)


func create_score_panel() -> void:
	score_panel = _create_ui_panel(
		TranslationManager.get_text("score") + ": 0",
		"ui_text_score",
		ANCHOR_TOP_RIGHT,
		OFFSET_SCORE,
		5
	)


# ====== Астероидная панель (слева, динамическая высота) ======
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
	# Панель астероидов будет позиционироваться через offset'ы (без якорей)
	asteroids_panel.anchor_left = 0.0
	asteroids_panel.anchor_top = 0.0
	asteroids_panel.anchor_right = 0.0
	asteroids_panel.anchor_bottom = 0.0
	asteroids_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(asteroids_panel)

	_update_asteroids_panel_position()


# ====== Вспомогательные методы ======
func _create_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = SettingsManager.get_color("ui_border")
	style.bg_color = SettingsManager.get_color("ui_bg")
	return style


func create_custom_cursor() -> void:
	var cursor = preload("res://custom_cursor.gd").new()
	add_child(cursor)
	cursor.z_index = 10


func _update_asteroids_panel_position() -> void:
	if not asteroids_panel:
		return
	var viewport = get_viewport()
	if not viewport:
		return
	var screen_size = viewport.get_visible_rect().size
	var margin = screen_size.x * 0.01
	var panel_width = screen_size.x * 0.125
	var panel_height = screen_size.y * 0.3

	# Позиция: слева, под верхним отступом + высота панели звёзд (если она есть)
	var top_offset = margin + panel_height + margin  # предполагаем, что панель звёзд занимает panel_height + margin сверху
	var left_offset = margin
	asteroids_panel.offset_left = left_offset
	asteroids_panel.offset_top = top_offset
	asteroids_panel.offset_right = left_offset + panel_width
	asteroids_panel.offset_bottom = top_offset + panel_height   # явно задаём высоту


# ====== Обновление значений ======
func _on_energy_changed(new_energy: float) -> void:
	_current_energy = new_energy
	_update_energy_text()


func _update_energy_text() -> void:
	if energy_panel:
		var prefix = TranslationManager.get_text("energy")
		energy_panel.set_text(prefix + ": " + str(round(_current_energy)) + "/" + str(round(GameManager.MAX_ENERGY)))


func _on_ship_hp_changed(new_hp: int) -> void:
	_current_hp = new_hp
	_update_hp_text()


func _update_hp_text() -> void:
	if hp_panel:
		var prefix = TranslationManager.get_text("hp")
		hp_panel.set_text(prefix + ": " + str(_current_hp) + "/" + str(GameManager.max_ship_hp))


func _on_score_changed(new_score: int) -> void:
	_current_score = new_score
	_update_score_text()


func _update_score_text() -> void:
	if score_panel:
		var prefix = TranslationManager.get_text("score")
		score_panel.set_text(prefix + ": " + str(_current_score))


func _on_ship_destroyed() -> void:
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
	add_child(game_over_label)
	game_over_label.z_index = 20
	settings_requested.emit()


# ====== Обновление цветов и текстов при смене настроек ======
func _on_settings_changed() -> void:
	update_ui_colors()
	update_ui_texts()


func update_ui_colors() -> void:
	for panel in [energy_panel, hp_panel, score_panel]:
		if panel:
			panel.update_style()
			if panel == energy_panel:
				panel.set_text_color(SettingsManager.get_color("ui_text_energy"))
			elif panel == hp_panel:
				panel.set_text_color(SettingsManager.get_color("ui_text_hp"))
			elif panel == score_panel:
				panel.set_text_color(SettingsManager.get_color("ui_text_score"))

	if asteroids_panel:
		var style = asteroids_panel.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = SettingsManager.get_color("ui_border")
			style.bg_color = SettingsManager.get_color("ui_bg")
	if asteroids_label:
		asteroids_label.modulate = SettingsManager.get_color("ui_text_score")


func update_ui_texts() -> void:
	# Обновляем тексты панелей с учётом текущего языка и сохранённых значений
	_update_energy_text()
	_update_hp_text()
	_update_score_text()

	# Обновляем заголовок панели астероидов
	if asteroids_label:
		var lines = asteroids_label.text.split("\n")
		if lines.size() > 0:
			lines[0] = TranslationManager.get_text("asteroids") + ":"
			asteroids_label.text = "\n".join(lines)


# ====== Список астероидов ======
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


func _on_viewport_size_changed() -> void:
	_update_asteroids_panel_position()
