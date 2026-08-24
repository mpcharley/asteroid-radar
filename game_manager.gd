extends Node
# ============================================================
# GameManager – управляет энергией, HP, сложностью и счётом.
# ============================================================

signal energy_changed(new_energy: float)
signal energy_depleted()
signal energy_refilled()
signal ship_hp_changed(new_hp: int)
signal ship_destroyed()
signal score_changed(new_score: int)

const MAX_ENERGY: float = 50000.0
const MIN_ENERGY: float = 0.0

var current_energy: float = MAX_ENERGY:
	set(value):
		var clamped_value: float = clamp(value, MIN_ENERGY, MAX_ENERGY)
		if not is_equal_approx(clamped_value, current_energy):
			current_energy = clamped_value
			energy_changed.emit(current_energy)
			if current_energy <= MIN_ENERGY:
				energy_depleted.emit()
			elif is_equal_approx(current_energy, MAX_ENERGY):
				energy_refilled.emit()
	get:
		return current_energy

# Здоровье корабля
var ship_hp: int = 10
var max_ship_hp: int = 10

# Счёт (сумма HP уничтоженных астероидов)
var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)
		update_spawn_interval()

# Настройки сложности
enum Difficulty { EASY, MEDIUM, HARD }

var difficulty: Difficulty = Difficulty.MEDIUM
var energy_regen_rate: float = 3000.0
var base_spawn_interval: float = 3.0
var _spawn_interval: float = 3.0
var wave_composition: Array[float] = [0.5, 0.4, 0.1]


func _ready() -> void:
	current_energy = MAX_ENERGY
	ship_hp = max_ship_hp
	score = 0
	set_difficulty(Difficulty.MEDIUM)


func _process(delta: float) -> void:
	current_energy += energy_regen_rate * delta


# -------------------- Энергия --------------------
func spend_energy(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if current_energy - amount >= MIN_ENERGY - 0.001:
		current_energy -= amount
		return true
	return false


func add_energy(amount: float) -> void:
	if amount <= 0.0:
		return
	current_energy += amount


func reset_energy() -> void:
	current_energy = MAX_ENERGY


func has_enough_energy(amount: float) -> bool:
	return current_energy >= amount - 0.001


# -------------------- Здоровье --------------------
func take_damage(amount: int) -> void:
	if ship_hp <= 0:
		return
	ship_hp -= amount
	if ship_hp < 0:
		ship_hp = 0
	ship_hp_changed.emit(ship_hp)
	if ship_hp <= 0:
		ship_destroyed.emit()


func heal(amount: int) -> void:
	ship_hp = min(ship_hp + amount, max_ship_hp)
	ship_hp_changed.emit(ship_hp)


func reset_hp() -> void:
	ship_hp = max_ship_hp
	ship_hp_changed.emit(ship_hp)


# -------------------- Счёт и спавн --------------------
func add_score(amount: int) -> void:
	if amount <= 0:
		return
	score += amount


func update_spawn_interval() -> void:
	var multiplier = 1.0
	if score >= 300:
		multiplier = 0.6
	elif score >= 100:
		multiplier = 0.8
	_spawn_interval = base_spawn_interval * multiplier


func get_spawn_interval() -> float:
	return _spawn_interval


var spawn_interval: float:
	get:
		return _spawn_interval


# -------------------- Сложность --------------------
func set_difficulty(new_difficulty: Difficulty) -> void:
	difficulty = new_difficulty
	match difficulty:
		Difficulty.EASY:
			energy_regen_rate = 6000.0
			base_spawn_interval = 4.0
			wave_composition = [0.8, 0.2, 0.0]
		Difficulty.MEDIUM:
			energy_regen_rate = 3000.0
			base_spawn_interval = 3.0
			wave_composition = [0.5, 0.4, 0.1]
		Difficulty.HARD:
			energy_regen_rate = 2000.0
			base_spawn_interval = 2.0
			wave_composition = [0.3, 0.4, 0.3]
	update_spawn_interval()


func _debug_print_state() -> void:
	print("Энергия: ", current_energy, "/", MAX_ENERGY)
	print("HP: ", ship_hp, "/", max_ship_hp)
	print("Счёт: ", score)
	print("Интервал спавна: ", _spawn_interval)
