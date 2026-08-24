extends ColorRect

func _ready() -> void:
	_update_color()
	SettingsManager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed() -> void:
	_update_color()

func _update_color() -> void:
	color = SettingsManager.get_color("bg")
