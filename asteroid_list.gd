# asteroid_list.gd
extends Control
# ============================================================
# Панель со списком астероидов (имя + HP).
# Располагается справа от панели звёзд.
# ============================================================

var info_panel: Panel
var info_label: Label

# Ссылка на игровой мир (устанавливается из main)
var game_world_ref: Node2D = null


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	create_info_panel()
	SettingsManager.settings_changed.connect(_on_settings_changed)


func _on_settings_changed() -> void:
	update_info_panel_colors()


func create_info_panel() -> void:
	info_panel = Panel.new()
	info_panel.mouse_filter = MOUSE_FILTER_IGNORE
	info_panel.modulate = Color(1, 1, 1, 0.7)
	info_panel.z_index = 5

	var style = StyleBoxFlat.new()
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = SettingsManager.get_color("ui_border")
	style.bg_color = SettingsManager.get_color("ui_bg")
	info_panel.add_theme_stylebox_override("panel", style)
	add_child(info_panel)

	info_label = Label.new()
	info_label.text = ""
	info_label.mouse_filter = MOUSE_FILTER_IGNORE
	info_label.position = Vector2(10, 10)
	info_label.modulate = SettingsManager.get_color("ui_text_stars")
	info_label.add_theme_font_override("font", FontManager.custom_font)
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	info_panel.add_child(info_label)


func update_info_panel(viewport_size: Vector2, stars_panel_width: float) -> void:
	# Располагаем справа от панели звёзд
	var panel_width = viewport_size.x * 0.125
	var panel_height = viewport_size.y * 0.4
	var margin = viewport_size.x * 0.01
	var x_pos = stars_panel_width + margin + margin  # отступ от панели звёзд

	info_panel.position = Vector2(x_pos, margin)
	info_panel.size = Vector2(panel_width, panel_height)

	# Собираем данные об астероидах из игрового мира
	var asteroid_texts = []
	if game_world_ref:
		for child in game_world_ref.get_children():
			if child is Asteroid:
				asteroid_texts.append(child.star_name + " HP:" + str(child.hp) + "/" + str(child.max_hp))
	if asteroid_texts.size() == 0:
		asteroid_texts = ["No Asteroids"]

	info_label.text = "\n".join(asteroid_texts)
	info_label.position = Vector2(10, 10)
	info_label.size = info_panel.size - Vector2(20, 20)


func update_info_panel_colors() -> void:
	var style = info_panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		style.border_color = SettingsManager.get_color("ui_border")
		style.bg_color = SettingsManager.get_color("ui_bg")


# Обновление по таймеру или по событию
func refresh() -> void:
	if get_viewport():
		var viewport_size = get_viewport().get_visible_rect().size
		# Получаем ширину панели звёзд (можно вычислить)
		var stars_width = viewport_size.x * 0.125 + viewport_size.x * 0.01 * 2  # panel_width + margin
		update_info_panel(viewport_size, stars_width)
