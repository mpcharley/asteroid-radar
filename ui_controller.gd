# ui_controller.gd
extends Control
# ============================================================
# Контроллер UI слоя. Обрабатывает ввод даже при паузе.
# Испускает сигнал при нажатии ESC для открытия/закрытия меню.
# ============================================================

signal settings_menu_toggled()

func _ready() -> void:
	# Убеждаемся, что этот узел обрабатывает ввод всегда
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_PAUSE:
		settings_menu_toggled.emit()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		settings_menu_toggled.emit()
