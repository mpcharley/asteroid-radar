class_name Asteroid
extends Control
# ============================================================
# Астероид – растёт от центра spawn_pos.
# При наведении – жёлтая обводка.
# При клике – назначается цель для турелей.
# Количество вложенных красных квадратов = количество турелей.
# При достижении 80% от max_size начинает мигать.
# ============================================================

signal asteroid_destroyed(asteroid)
signal asteroid_collided(asteroid)
signal clicked(asteroid)
signal right_clicked(asteroid)

enum SizeCategory { SMALL, MEDIUM, LARGE }

# Константы баланса
const HP_MAP = {
	SizeCategory.SMALL: 5,
	SizeCategory.MEDIUM: 7,
	SizeCategory.LARGE: 11
}
const ENERGY_DROP_MAP = {
	SizeCategory.SMALL: 7500,
	SizeCategory.MEDIUM: 15000,
	SizeCategory.LARGE: 22500
}

var size_category: SizeCategory = SizeCategory.MEDIUM
const GROWTH_SPEED_BASE: float = 110.0
var growth_speed: float = 10.0
var max_size: float = 0.0
var star_name: String = ""
var initial_center: Vector2

var is_hovered: bool = false
var target_count: int = 0
var is_destroyed: bool = false
var hp: int
var max_hp: int

# Параметры мигания
const CRITICAL_SIZE_RATIO: float = 0.8
var is_critical: bool = false
var flash_timer: float = 0.0
const FLASH_INTERVAL: float = 0.2
var flash_alpha: float = 1.0

var label: Label


func initialize(category: SizeCategory, spawn_pos: Vector2, screen_size: Vector2) -> void:
	size_category = category
	initial_center = spawn_pos
	match category:
		SizeCategory.SMALL:
			growth_speed = GROWTH_SPEED_BASE * 0.2
		SizeCategory.MEDIUM:
			growth_speed = GROWTH_SPEED_BASE * 0.5
		SizeCategory.LARGE:
			growth_speed = GROWTH_SPEED_BASE * 0.9
	max_size = max(screen_size.x, screen_size.y)
	star_name = generate_name()
	hp = HP_MAP[category]
	max_hp = hp

	var start_size = Vector2(10, 10)
	size = start_size
	position = initial_center - start_size / 2
	create_label()
	update_label_text()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	SettingsManager.settings_changed.connect(_on_settings_changed)


func _on_settings_changed() -> void:
	if label:
		label.modulate = SettingsManager.get_color("asteroid_text")


func _process(delta: float) -> void:
	if is_destroyed:
		return
	var new_size = size + Vector2(growth_speed * delta, growth_speed * delta)
	if new_size.x >= max_size or new_size.y >= max_size:
		collide()
	else:
		size = new_size
		position = initial_center - size / 2

		if not is_critical and size.x >= max_size * CRITICAL_SIZE_RATIO:
			is_critical = true
			flash_timer = 0.0

		if is_critical:
			flash_timer += delta
			if flash_timer >= FLASH_INTERVAL:
				flash_timer = 0.0
				flash_alpha = 0.5 if flash_alpha == 1.0 else 1.0

		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if is_destroyed:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit(self)


func _on_mouse_entered() -> void:
	if is_destroyed:
		return
	is_hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	if is_destroyed:
		return
	is_hovered = false
	queue_redraw()


func _draw() -> void:
	if is_destroyed:
		return

	var border_color = SettingsManager.get_color("asteroid_border")
	var hover_color = SettingsManager.get_color("asteroid_hover")
	var target_color = SettingsManager.get_color("asteroid_target")

	var alpha = flash_alpha if is_critical else 1.0
	var mod_border = Color(border_color.r, border_color.g, border_color.b, alpha * border_color.a)

	# Основной контур (с миганием)
	draw_rect(Rect2(Vector2.ZERO, size), mod_border, false, 0.5)

	# Жёлтая обводка при наведении (без мигания)
	if is_hovered:
		draw_rect(Rect2(Vector2.ZERO, size), hover_color, false, 2.0)
	# Вложенные красные квадраты (с миганием)
	if target_count > 0:
		var target_color_ = Color(target_color.r, target_color.g, target_color.b, alpha * target_color.a)
		draw_line(Vector2(size.x / 2, size.y / 4), Vector2(size.x / 2, size.y / 4 * 3), target_color_, 2.0)
		draw_line(Vector2(size.x / 4, size.y / 2), Vector2(size.x / 4 * 3, size.y / 2), target_color_, 2.0)
		var step = 10.0
		var max_rect = size.x
		for i in range(target_count):
			var rect_size = max_rect - i * step
			if rect_size <= 0:
				break
			var offset = (size.x - rect_size) / 2.0
			var rect = Rect2(Vector2(offset, offset), Vector2(rect_size, rect_size))
			var mod_target = Color(target_color.r, target_color.g, target_color.b, alpha * target_color.a)
			draw_rect(rect, mod_target, false, 0.5)


func create_label() -> void:
	label = Label.new()
	label.add_theme_font_override("font", FontManager.custom_font)
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = SettingsManager.get_color("asteroid_text")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)


func update_label_text() -> void:
	if label:
		label.text = star_name + " " + get_category_string() + " HP: " + str(hp) + "/" + str(max_hp)


func get_category_string() -> String:
	match size_category:
		SizeCategory.SMALL:
			return "S"
		SizeCategory.MEDIUM:
			return "M"
		SizeCategory.LARGE:
			return "L"
	return "?"


func generate_name() -> String:
	var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var result = ""
	for i in range(3):
		result += letters[randi() % letters.length()]
	for i in range(3):
		result += str(randi() % 10)
	return result


func collide() -> void:
	if is_destroyed:
		return
	asteroid_collided.emit(self)
	destroy()


func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	asteroid_destroyed.emit(self)
	queue_free()


func take_damage() -> void:
	if is_destroyed:
		return
	hp -= 1
	update_label_text()
	if hp <= 0:
		destroy()


func reflect() -> void:
	if is_destroyed:
		return
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var margin = 50.0
	var new_pos = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)
	initial_center = new_pos
	var start_size = Vector2(10, 10)
	size = start_size
	position = initial_center - start_size / 2
	is_critical = false
	flash_alpha = 1.0
	target_count = 0
	queue_redraw()


func set_target_count(count: int) -> void:
	if is_destroyed:
		return
	if target_count != count:
		target_count = count
		queue_redraw()
