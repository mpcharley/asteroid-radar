# ui_controller.gd
extends Control
# ============================================================
# Контроллер UI слоя. Обрабатывает ввод даже при паузе.
# Испускает сигнал при нажатии ESC для открытия/закрытия меню.
# Клавиша A переключает автобой.
# ============================================================

signal settings_menu_toggled()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_PAUSE or event.keycode == KEY_ESCAPE:
			settings_menu_toggled.emit()
		elif event.keycode == KEY_A and not get_tree().paused:
			SettingsManager.toggle_autobattle()
			# Можно вывести сообщение в консоль или UI
			print("Автобой: ", "включен" if SettingsManager.autobattle_enabled else "выключен")
