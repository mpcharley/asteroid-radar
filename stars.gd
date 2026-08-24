extends Control

const STAR_COUNT: int = 9
const SPEED_MIN: float = 12.0
const SPEED_MAX: float = 115.0
const SPAWN_RADIUS_MIN: float = 40.0
const SPAWN_RADIUS_MAX: float = 130.0
const LABEL_OFFSET: Vector2 = Vector2(8, -8)

var stars_data: Array[Dictionary] = []
var info_panel: Panel
var info_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_info_panel()
	for i in range(STAR_COUNT):
		var data = create_new_star()
		var label = Label.new()
		label.text = data.star_name
		label.add_theme_font_override("font", FontManager.custom_font)
		label.add_theme_font_size_override("font_size", 14)
		label.modulate = SettingsManager.get_color("ui_text_stars")
		add_child(label)
		data.label = label
		stars_data.append(data)

	SettingsManager.settings_changed.connect(_on_settings_changed)
	update_info_panel_title()


func _on_settings_changed() -> void:
	for data in stars_data:
		if data.label:
			data.label.modulate = SettingsManager.get_color("ui_text_stars")
	if info_label:
		info_label.modulate = SettingsManager.get_color("ui_text_stars")
	update_info_panel_colors()
	update_info_panel_title()


func _process(delta: float) -> void:
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var margin = 50

	for data in stars_data:
		data.pos += data.dir * data.speed * delta
		if data.pos.x < -margin or data.pos.x > screen_size.x + margin or data.pos.y < -margin or data.pos.y > screen_size.y + margin:
			var new_data = create_new_star()
			print("Вышла из экрана", new_data["star_name"])
			data.pos = new_data.pos
			data.dir = new_data.dir
			data.speed = new_data.speed
			data.size = new_data.size
			data.star_name = new_data.star_name
		data.label.position = data.pos + LABEL_OFFSET

	update_info_panel(screen_size)
	queue_redraw()


func _draw() -> void:
	for data in stars_data:
		draw_circle(data.pos, data.size, Color.WHITE)


func create_new_star() -> Dictionary:
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var center = screen_size / 2.0

	var angle = randf_range(0, 2 * PI)
	var radius = randf_range(SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX)
	var local_pos = Vector2(cos(angle), sin(angle)) * radius

	return {
		"pos": center + local_pos,
		"dir": local_pos.normalized(),
		"speed": randf_range(SPEED_MIN, SPEED_MAX),
		"size": randf_range(0.8, 2.5),
		"star_name": generate_star_name(),
		"label": null
	}


func generate_star_name() -> String:
	var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var result = ""
	for i in range(3):
		result += letters[randi() % letters.length()]
	for i in range(3):
		result += str(randi() % 10)
	return result


func create_info_panel() -> void:
	info_panel = Panel.new()
	info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_label.modulate = SettingsManager.get_color("ui_text_stars")
	info_label.add_theme_font_override("font", FontManager.custom_font)
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	info_panel.add_child(info_label)


func update_info_panel_title() -> void:
	# обновляем заголовок при смене языка (используется в update_info_panel)
	update_info_panel(get_viewport().get_visible_rect().size)


func update_info_panel(viewport_size: Vector2) -> void:
	var panel_width = viewport_size.x * 0.125
	var panel_height = viewport_size.y * 0.3
	var margin = viewport_size.x * 0.01

	info_panel.position = Vector2(margin, margin)
	info_panel.size = Vector2(panel_width, panel_height)

	var title = TranslationManager.get_text("stars_title")
	var text_lines = [title + ":"]
	for data in stars_data:
		var pos_str = "(%d, %d)" % [data.pos.x, data.pos.y]
		text_lines.append(data.star_name + " — " + pos_str)

	info_label.text = "\n".join(text_lines)
	info_label.position = Vector2(10, 10)
	info_label.size = info_panel.size - Vector2(20, 20)


func update_info_panel_colors() -> void:
	var style = info_panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		style.border_color = SettingsManager.get_color("ui_border")
		style.bg_color = SettingsManager.get_color("ui_bg")
