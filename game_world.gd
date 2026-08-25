# game_world.gd
extends Node2D
# ============================================================
# Игровой мир: астероиды, турели, спавн, выстрелы, радар.
# При паузе (get_tree().paused = true) всё останавливается.
# Испускает сигнал для обновления панели астероидов.
# ============================================================

signal asteroids_updated(asteroid_list: Array)

var turrets: Array[Turret] = []
var spawn_timer: float = 0.0

# Визуализация выстрелов
var shots: Array[Dictionary] = []   # { "start": Vector2, "end": Vector2, "life": float }

# Радар
var radar_angle: float = 0.0
const RADAR_SPEED: float = 0.1


func _ready() -> void:
	# Создаём 5 турелей
	for i in range(5):
		var t = Turret.new()
		add_child(t)
		turrets.append(t)
		t.shot_fired.connect(_on_turret_shot_fired)

	GameManager.set_difficulty(SettingsManager.current_difficulty)
	SettingsManager.settings_changed.connect(queue_redraw)


func _process(delta: float) -> void:
	# Таймер спавна
	spawn_timer += delta
	if spawn_timer >= GameManager.spawn_interval:
		spawn_timer = 0.0
		var asteroids = get_asteroids()
		if asteroids.size() < 10:
			spawn_asteroid()

	# Обновление выстрелов
	for i in range(shots.size() - 1, -1, -1):
		var shot = shots[i]
		shot.life -= delta
		if shot.life <= 0:
			shots.remove_at(i)

	# Обновление радара
	radar_angle += RADAR_SPEED * delta
	if radar_angle > 2 * PI:
		radar_angle -= 2 * PI

	# Проверка критических астероидов для тревоги
	var has_critical = false
	for child in get_asteroids():
		if child.is_critical:
			has_critical = true
			break
	AudioManager.set_alarm(has_critical)

	queue_redraw()


func _draw() -> void:
	var viewport = get_viewport()
	var rect_size = viewport.get_visible_rect().size
	var color: Color = SettingsManager.get_color("grid_line")
	var color_alt: Color = SettingsManager.get_color("grid_line_alt")
	var line_width: float = 0.7
	var center: Vector2 = rect_size / 2

	# Большой круг (радар)
	draw_circle(center, rect_size.y / 2, SettingsManager.get_color("circle_color"), false, line_width)
	draw_circle(center, rect_size.y / 2 - 10, SettingsManager.get_color("circle_color"), false, line_width)
	draw_circle(center, rect_size.y / 3, SettingsManager.get_color("circle_color"), false, line_width)

	# Рамка
	draw_rect(Rect2(Vector2.ZERO, rect_size), color, false, line_width)

	# Горизонтальная и вертикальная линии
	draw_line(Vector2(0, rect_size.y / 2), Vector2(rect_size.x, rect_size.y / 2), color, line_width)
	draw_line(Vector2(rect_size.x / 2, 0), Vector2(rect_size.x / 2, rect_size.y), color, line_width)

	# Сетка 3x3
	for i in range(1, 15):
		var x: float = rect_size.x * i / 15.0
		draw_line(Vector2(x, 0), Vector2(x, rect_size.y), color, 0.2)
		var y: float = rect_size.y * i / 15.0
		draw_line(Vector2(0, y), Vector2(rect_size.x, y), color_alt, 0.2)

	# Прямоугольник в центре
	var w: float = 100
	var h: float = 100
	draw_rect(Rect2(center - Vector2(w / 2, h / 2), Vector2(w, h)), color, false, line_width)

	# Радар
	var radius = rect_size.y / 2
	var end_point = center + Vector2(cos(radar_angle), sin(radar_angle)) * radius
	draw_line(center, end_point, SettingsManager.get_color("radar_line"), 1.5)

	# Выстрелы
	for shot in shots:
		draw_line(shot.start, shot.end, SettingsManager.get_color("shot_line"), 2.0)


# -------------------- Спавн астероидов --------------------
func spawn_asteroid() -> void:
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var composition = GameManager.wave_composition
	var r = randf()
	var category: int
	if r < composition[0]:
		category = Asteroid.SizeCategory.SMALL
	elif r < composition[0] + composition[1]:
		category = Asteroid.SizeCategory.MEDIUM
	else:
		category = Asteroid.SizeCategory.LARGE

	var margin = 50.0
	var spawn_pos = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)
	var asteroid = Asteroid.new()
	asteroid.initialize(category, spawn_pos, screen_size)
	add_child(asteroid)

	asteroid.clicked.connect(_on_asteroid_clicked)
	asteroid.right_clicked.connect(_on_asteroid_right_clicked)
	asteroid.asteroid_destroyed.connect(_on_asteroid_destroyed)
	asteroid.asteroid_collided.connect(_on_asteroid_collided)

	update_asteroid_targets()
	emit_asteroids_updated()


# -------------------- Обработка кликов --------------------
func _on_asteroid_clicked(asteroid: Asteroid) -> void:
	assign_turret(asteroid)


func _on_asteroid_right_clicked(asteroid: Asteroid) -> void:
	var cost = get_shield_cost(asteroid.size_category)
	if GameManager.spend_energy(cost):
		asteroid.reflect()
		for t in turrets:
			if t.target == asteroid:
				t.target = null
		update_asteroid_targets()
		emit_asteroids_updated()
	else:
		print("Недостаточно энергии для щита!")


func get_shield_cost(category: int) -> float:
	match category:
		Asteroid.SizeCategory.SMALL:
			return 3000.0
		Asteroid.SizeCategory.MEDIUM:
			return 6000.0
		Asteroid.SizeCategory.LARGE:
			return 9000.0
	return 0.0


# -------------------- Управление турелями --------------------
func assign_turret(asteroid: Asteroid) -> void:
	var free_turret: Turret = null
	for t in turrets:
		if t.target == null:
			free_turret = t
			break

	if free_turret != null:
		free_turret.target = asteroid
	else:
		for t in turrets:
			if t.target != null and t.target != asteroid:
				t.target = asteroid
				break
	update_asteroid_targets()


func update_asteroid_targets() -> void:
	for child in get_asteroids():
		var count = 0
		for t in turrets:
			if t.target == child:
				count += 1
		child.set_target_count(count)


# -------------------- Обработка событий астероидов --------------------
func _on_asteroid_destroyed(asteroid: Asteroid) -> void:
	for t in turrets:
		if t.target == asteroid:
			t.target = null
	update_asteroid_targets()
	emit_asteroids_updated()


func _on_asteroid_collided(asteroid: Asteroid) -> void:
	print("💥 Столкновение с астероидом!")
	GameManager.take_damage(1)
	for t in turrets:
		if t.target == asteroid:
			t.target = null
	update_asteroid_targets()
	emit_asteroids_updated()


# -------------------- Визуализация выстрелов --------------------
func _on_turret_shot_fired(target: Asteroid) -> void:
	var viewport = get_viewport()
	var screen_center = viewport.get_visible_rect().size / 2
	var target_center = target.position + target.size / 2
	shots.append({
		"start": screen_center,
		"end": target_center,
		"life": 0.2
	})


# -------------------- Список астероидов для UI --------------------
func get_asteroids() -> Array:
	#Возвращает массив всех дочерних узлов типа Asteroid.
	var list = []
	for child in get_children():
		if child is Asteroid:
			list.append(child)
	return list


func get_asteroid_list() -> Array:
	#Алиас для get_asteroids() для обратной совместимости.
	return get_asteroids()


func emit_asteroids_updated() -> void:
	asteroids_updated.emit(get_asteroids())


# -------------------- Тестовый спавн по клавишам --------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		spawn_asteroid()
	if event is InputEventKey and event.pressed and event.keycode == KEY_CTRL:
		spawn_asteroid()
