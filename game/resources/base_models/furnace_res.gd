class_name Furnace extends Resource

enum furnace_type {STONE, BRICK, IRON}
enum furnace_state {OFF, IDLE, BURNING, SHUTDOWN_OVERHEAT}

@export var name : String = ""
@export var description: String = ""

@export var level : int = 1:
	set(value):
		level = clamp(value, 1, max_level)
		
@export var type : furnace_type
		
var max_level : int = 3

@export var max_fuel_capacity : int = 0
@export var energy_burning_capacity : int = 0

@export var energy_output : int = 0
@export var max_energy_output: int = 0

@export var fuel_type : Fuel.fuel_type
# --- Pressure tuning ---
# Pressure chases a target proportional to current fuel intensity (how full
# the furnace is right now), but asymmetrically: quick to climb, slow to
# fall — thermal inertia, like a stove that stays hot well after the fire's
# mostly out. min_operating_pressure is informational only (a "running
# efficiently" reference line on the gauge) — it doesn't force a shutdown,
# since low pressure from low fuel is expected, not a malfunction.
# max_operating_pressure is the one real hard limit: overheating from not
# venting is a genuine mismanagement failure, independent of fuel level.
@export var pressure_rise_rate: float = 15.0             # pressure units/sec climbing toward target
@export var pressure_cooldown_rate: float = 2.0           # pressure units/sec falling toward target — much slower, thermal mass
@export var pressure_vent_rate: float = 12.0              # extra pressure lost per second while player actively vents
@export var min_operating_pressure: float = 10.0          # visual reference only — "running efficiently" line on the gauge
@export var max_operating_pressure: float = 85.0          # at/above this = overheat, damages furnace over time
@export var overheat_damage_per_second: float = 2.0

# --- Output tuning ---
# Guarantees the furnace keeps producing at least a trickle of energy as
# long as ANY fuel is loaded, so it never goes fully dark from scarcity
# alone — output fades toward this floor as fuel runs low instead of
# cutting off. Tune per furnace type if some models should sputter more
# gracefully than others.
@export var min_output_floor: int = 1

# --- Runtime state (not exported, not part of the saved profile design necessarily —
#     decide separately whether this belongs in your to_dict()/from_dict() save pattern) ---
var current_fuel_units: int = 0
var loaded_fuel: Fuel = null
var pressure: float = 0.0
var health: float = 100.0
var state: furnace_state = furnace_state.OFF
var _burn_time_left: float = 0.0
var _venting: bool = false
var _has_reached_operating_pressure: bool = false


signal fuel_loaded(amount_accepted: int)
signal fuel_depleted
signal energy_output_changed(new_output: int)
signal pressure_changed(new_pressure: float)
signal overheated
signal furnace_shutdown(reason: String)
signal furnace_ignited

func can_accept_fuel(fuel: Fuel) -> bool:
	if fuel.type != fuel_type:
		return false
	if loaded_fuel != null and loaded_fuel.type != fuel.type:
		return false
	return current_fuel_units < max_fuel_capacity
 
func load_fuel(fuel: Fuel, amount: int) -> int:
	if fuel.type != fuel_type:
		return 0
	if loaded_fuel == null:
		loaded_fuel = fuel
 
	var space_left := max_fuel_capacity - current_fuel_units
	var accepted : int = clamp(amount, 0, space_left)
	current_fuel_units += accepted
 
	if accepted > 0:
		fuel_loaded.emit(accepted)
		if state == furnace_state.OFF or state == furnace_state.IDLE:
			_try_ignite()
 
	return accepted
 
func ignite() -> bool:
	if state == furnace_state.BURNING:
		return true
	if current_fuel_units <= 0:
		return false
	return _try_ignite()
	
func _try_ignite() -> bool:
	if current_fuel_units <= 0 or loaded_fuel == null:
		return false
	state = furnace_state.BURNING
	_burn_time_left = loaded_fuel.combustion_time
	_has_reached_operating_pressure = false
	furnace_ignited.emit()
	return true
 
func vent_pressure(is_venting: bool) -> void:
	_venting = is_venting
 
#region Furnace Operations
func tick(delta: float) -> void:
	_update_pressure(delta)
 
	match state:
		furnace_state.BURNING:
			_process_burn(delta)
		furnace_state.SHUTDOWN_OVERHEAT, furnace_state.OFF, furnace_state.IDLE:
			if energy_output != 0:
				energy_output = 0
				energy_output_changed.emit(energy_output)
 
func _process_burn(delta: float) -> void:
	_burn_time_left -= delta
	_update_output()
 
	if _burn_time_left <= 0.0:
		_consume_one_unit()

# Fuel level sets the CEILING (how much energy this furnace could put out at
# full pressure). Current pressure gates how much of that ceiling is actually
# delivered right now — so output ramps up alongside pressure instead of
# snapping instantly. min_output_floor still guarantees a small trickle the
# moment the furnace is burning, so it's never fully dark while fuel remains,
# even before pressure has had time to build.
func _update_output() -> void:
	var fuel_ratio := get_fuel_ratio()
	var ceiling: int = int(round(loaded_fuel.energy * fuel_ratio))
	ceiling = clamp(ceiling, 0, max_energy_output)
 
	var spool_ratio: float = clamp(pressure / 100.0, 0.0, 1.0)
	var scaled: int = int(round(ceiling * spool_ratio))
	var target_output: int = clamp(max(scaled, min_output_floor), 0, max_energy_output)
 
	if energy_output != target_output:
		energy_output = target_output
		energy_output_changed.emit(energy_output)
 
func _consume_one_unit() -> void:
	print("One unit of fuel consumed")
	current_fuel_units -= 1
	
	if current_fuel_units <= 0:
		loaded_fuel = null
		state = furnace_state.IDLE
		energy_output = 0
		energy_output_changed.emit(energy_output)
		fuel_depleted.emit()
	else:
		_burn_time_left = loaded_fuel.combustion_time
		_update_output()  # fuel_ratio just dropped, reflect it immediately
 
# Target is proportional to current fuel intensity — a full hopper pulls
# pressure toward 100, an empty/off furnace pulls it toward 0. Climbing
# toward the target is fast (pressure_rise_rate); falling toward it is slow
# (pressure_cooldown_rate) — thermal inertia, so pressure lingers even as
# fuel runs low or the fire goes out. Venting is a separate, faster, active
# release that always applies regardless of which direction pressure is
# already heading.
func _update_pressure(delta: float) -> void:
	var target: float = get_fuel_ratio() * 100.0 if state == furnace_state.BURNING else 0.0
 
	if pressure < target:
		pressure = move_toward(pressure, target, pressure_rise_rate * delta)
	else:
		pressure = move_toward(pressure, target, pressure_cooldown_rate * delta)
 
	if _venting:
		pressure = max(0.0, pressure - pressure_vent_rate * delta)
 
	pressure = clamp(pressure, 0.0, 100.0)
	pressure_changed.emit(pressure)
 
	if pressure >= max_operating_pressure:
		health -= overheat_damage_per_second * delta
		overheated.emit()
		if health <= 0.0:
			_shutdown("overheat_damage")
 
func _shutdown(reason: String) -> void:
	state = furnace_state.SHUTDOWN_OVERHEAT
	energy_output = 0
	energy_output_changed.emit(energy_output)
	furnace_shutdown.emit(reason)
 
 
func get_pressure_ratio() -> float:
	return pressure / 100.0
 
 
func get_fuel_ratio() -> float:
	if max_fuel_capacity == 0:
		return 0.0
	return float(current_fuel_units) / float(max_fuel_capacity)
#endregion
