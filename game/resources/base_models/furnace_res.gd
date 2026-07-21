class_name Furnace extends Resource

enum furnace_type {STONE, BRICK, IRON}
enum furnace_state {OFF, IDLE, BURNING, SHUTDOWN_LOW_PRESSURE}

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
# --- Pressure tuning (expose so you can balance per furnace type/level) ---
@export var pressure_gain_per_burn: float = 8.0      # pressure added when a fuel unit ignites
@export var pressure_passive_decay: float = 1.5       # pressure lost per second, always
@export var pressure_vent_rate: float = 12.0          # pressure lost per second while player vents
@export var pressure_overheat_threshold: float = 85.0 # above this = danger, damages furnace over time
@export var pressure_min_operating: float = 10.0      # below this = forced shutdown
@export var overheat_damage_per_second: float = 2.0   # "health" drained while overheated and unvented

# --- Runtime state (not exported, not part of the saved profile design necessarily —
#     decide separately whether this belongs in your to_dict()/from_dict() save pattern) ---
var current_fuel_units: int = 0
var loaded_fuel: Fuel = null
var pressure: float = 0.0
var health: float = 100.0
var state: furnace_state = furnace_state.OFF
var _burn_time_left: float = 0.0
var _venting: bool = false

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
 
func _try_ignite() -> bool:
	if current_fuel_units <= 0 or loaded_fuel == null:
		return false
	state = furnace_state.BURNING
	_burn_time_left = loaded_fuel.combustion_time
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
		furnace_state.SHUTDOWN_LOW_PRESSURE, furnace_state.OFF, furnace_state.IDLE:
			if energy_output != 0:
				energy_output = 0
				energy_output_changed.emit(energy_output)
 
 
func _process_burn(delta: float) -> void:
	_burn_time_left -= delta
 
	var target_output: int = clamp(loaded_fuel.energy, 0, max_energy_output)
	if energy_output != target_output:
		energy_output = target_output
		energy_output_changed.emit(energy_output)
 
	if _burn_time_left <= 0.0:
		_consume_one_unit()
 
 
func _consume_one_unit() -> void:
	print("One unit of fuel consumed")
	current_fuel_units -= 1
	pressure += pressure_gain_per_burn
	pressure_changed.emit(pressure)
 
	if current_fuel_units <= 0:
		loaded_fuel = null
		state = furnace_state.IDLE
		energy_output = 0
		energy_output_changed.emit(energy_output)
		fuel_depleted.emit()
	else:
		_burn_time_left = loaded_fuel.combustion_time
 
 
func _update_pressure(delta: float) -> void:
	var decay := pressure_passive_decay
	if _venting:
		decay += pressure_vent_rate
 
	pressure = max(0.0, pressure - decay * delta)
	pressure_changed.emit(pressure)
 
	if pressure >= pressure_overheat_threshold:
		health -= overheat_damage_per_second * delta
		overheated.emit()
		if health <= 0.0:
			_shutdown("overheat_damage")
			return
 
	if state == furnace_state.BURNING and pressure < pressure_min_operating:
		_shutdown("low_pressure")
 
 
func _shutdown(reason: String) -> void:
	state = furnace_state.SHUTDOWN_LOW_PRESSURE
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
