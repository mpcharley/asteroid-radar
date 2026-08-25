extends Control

var cursor_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0


func _process(_delta: float) -> void:
	cursor_pos = get_local_mouse_position()
	queue_redraw()


func _draw() -> void:
	if cursor_pos == Vector2.ZERO:
		return

	# Используем размер всего экрана, а не размер родителя
	var control_size: Vector2 = get_viewport().get_visible_rect().size
	var line_color = SettingsManager.get_color("cursor_line")
	var rect_color = SettingsManager.get_color("cursor_rect")

	draw_line(
		Vector2(cursor_pos.x, 0),
		Vector2(cursor_pos.x, control_size.y),
		line_color,
		1.0
	)
	draw_line(
		Vector2(0, cursor_pos.y),
		Vector2(control_size.x, cursor_pos.y),
		line_color,
		1.0
	)
	var half: float = 10.0 / 2.0
	var rect: Rect2 = Rect2(
		cursor_pos - Vector2(half, half),
		Vector2(10, 10)
	)
	draw_rect(rect, rect_color, false)
