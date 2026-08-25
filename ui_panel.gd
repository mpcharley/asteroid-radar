# ui_panel.gd
class_name UIPanel
extends Panel

# Это будет наш кастомный узел, который содержит панель и метку внутри себя.

var label: Label


func _init() -> void:
	# Инициализация, но создание label делаем в конструкторе с параметрами
	pass


# Конструктор с параметрами
func initialize(
	text: String,
	color: Color,
	font: Font,
	font_size: int = 11,
	horizontal_align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER,
	vertical_align: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER
) -> void:
	# Создаём метку
	label = Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	label.horizontal_alignment = horizontal_align
	label.vertical_alignment = vertical_align
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Настройка панели
	add_theme_stylebox_override("panel", _create_default_style())
	add_child(label)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _create_default_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = SettingsManager.get_color("ui_border")
	style.bg_color = SettingsManager.get_color("ui_bg")
	return style


# Методы для обновления
func set_text(new_text: String) -> void:
	if label:
		label.text = new_text


func set_text_color(new_color: Color) -> void:
	if label:
		label.modulate = new_color


func update_style() -> void:
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		style.border_color = SettingsManager.get_color("ui_border")
		style.bg_color = SettingsManager.get_color("ui_bg")


# Удобный метод для обновления и текста, и стиля (при смене языка/цвета)
func refresh(text: String = "", color: Color = Color.WHITE) -> void:
	if text != "":
		set_text(text)
	if color != Color.WHITE:
		set_text_color(color)
	update_style()
