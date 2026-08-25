class_name Turret
extends Node
# ============================================================
# Турель – автоматически стреляет по цели, если есть энергия.
# Испускает сигнал для отрисовки выстрела и воспроизводит звук.
# ============================================================

signal shot_fired(target: Asteroid)

const FIRE_RATE: float = 3.0

var target: Asteroid = null
var fire_timer: float = 0.0


func _process(delta: float) -> void:
	if target == null:
		return
	if target.is_destroyed:
		target = null
		return

	fire_timer += delta
	if fire_timer >= 1.0 / FIRE_RATE:
		fire_timer = 0.0
		try_fire()


func try_fire() -> void:
	var current_target = target
	if current_target == null:
		return
	var cost = get_shot_cost(current_target.size_category)
	if GameManager.spend_energy(cost):
		current_target.take_damage()
		shot_fired.emit(current_target)
		AudioManager.play_shot()
		if current_target.is_destroyed:
			var drop = Asteroid.ENERGY_DROP_MAP[current_target.size_category]
			GameManager.add_energy(drop)
			GameManager.add_score(current_target.max_hp)


func get_shot_cost(category: int) -> float:
	match category:
		Asteroid.SizeCategory.SMALL:
			return 1700.0
		Asteroid.SizeCategory.MEDIUM:
			return 1833.0
		Asteroid.SizeCategory.LARGE:
			return 2000.0
	return 0.0
