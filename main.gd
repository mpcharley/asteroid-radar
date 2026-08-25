extends Control

var game_world: Node2D
var ui_layer: CanvasLayer
var hud: Control
var settings_menu_instance: Control = null


func _ready() -> void:
	# Игровой мир
	game_world = preload("res://game_world.gd").new()
	add_child(game_world)

	# UI слой (всегда активен)
	ui_layer = CanvasLayer.new()
	ui_layer.process_mode = PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	# HUD – все панели и курсор
	hud = preload("res://hud.gd").new()
	hud.anchor_left = 0.0
	hud.anchor_top = 0.0
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	# Пропускаем события мыши к игровому миру
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud)
	hud.set_game_world(game_world)
	hud.settings_requested.connect(_open_settings_menu)

	# Обработчик ввода (ESC / Pause)
	var input_handler = preload("res://ui_controller.gd").new()
	ui_layer.add_child(input_handler)
	input_handler.settings_menu_toggled.connect(_toggle_settings_menu)


func _toggle_settings_menu() -> void:
	if settings_menu_instance == null:
		_open_settings_menu()
	else:
		_close_settings_menu()


func _open_settings_menu() -> void:
	if settings_menu_instance != null:
		return
	settings_menu_instance = preload("res://settings_menu.gd").new()
	ui_layer.add_child(settings_menu_instance)
	settings_menu_instance.open()


func _close_settings_menu() -> void:
	if settings_menu_instance:
		settings_menu_instance.close()
		settings_menu_instance.queue_free()
		settings_menu_instance = null
