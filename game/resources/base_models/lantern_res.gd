class_name Lantern extends Resource

enum lantern_state {LIT, UNLIT}
enum power_state {OFF, LOW, FULL}
 
@export var name : String = ""
@export var description : String = ""

@export var min_energy_required: int = 0
@export var energy_required : int = 0
@export var state: power_state = power_state.OFF
 
# Given however much energy the network actually allocated this lantern,
# work out which logical band it falls into. This is the *target* state —
# the scene script handles animating toward it (ignite/shutdown transitions).
func compute_state(allocated_energy: int) -> power_state:
	if allocated_energy < min_energy_required:
		return power_state.OFF
	if allocated_energy < energy_required:
		return power_state.LOW
	return power_state.FULL
