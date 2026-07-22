extends Node
# Autoload: EnergyNetwork
#
# Producers (furnaces) are registered explicitly. Consumers (lanterns) are
# discovered via the "lanterns" group each distribution pass, so scene
# lanterns just need to add_to_group("lanterns") in their own _ready() and
# nothing here needs to know about them individually.

signal network_updated(supply: int, demand: int, lit_count: int, total_count: int)

var _furnaces: Array[Furnace] = []

# Fictitious lanterns you haven't placed as real scene objects yet — counted
# toward demand but have no visual to update.
var simulated_lantern_count: int = 0:
	set(value):
		simulated_lantern_count = value
		distribute()
var simulated_lantern_min_energy_required: int = 1
var simulated_lantern_energy_required: int = 5


func register_furnace(furnace: Furnace) -> void:
	if furnace in _furnaces:
		return
	_furnaces.append(furnace)
	furnace.energy_output_changed.connect(_on_furnace_changed)
	furnace.furnace_shutdown.connect(_on_furnace_changed)
	furnace.furnace_ignited.connect(_on_furnace_changed)


func unregister_furnace(furnace: Furnace) -> void:
	if furnace not in _furnaces:
		return
	_furnaces.erase(furnace)
	furnace.energy_output_changed.disconnect(_on_furnace_changed)
	furnace.furnace_shutdown.disconnect(_on_furnace_changed)
	furnace.furnace_ignited.disconnect(_on_furnace_changed)
	distribute()


func _on_furnace_changed(_arg = null) -> void:
	distribute()


func distribute() -> void:
	var supply := _total_supply()
	var entries: Array = _collect_demand_entries()
 
	entries.sort_custom(func(a, b): return a.min_required < b.min_required)
 
	var remaining := supply
	var demand := 0
	var lit_count := 0
 
	# pass 1 — guarantee minimums, cheapest first
	for entry in entries:
		demand += entry.required
		if remaining >= entry.min_required:
			entry.allocated = entry.min_required
			remaining -= entry.min_required
			lit_count += 1
		else:
			entry.allocated = 0
 
	# pass 2 — top up toward full requirement, smallest gap first
	var toppable: Array = entries.filter(func(e): return e.allocated > 0 and e.allocated < e.required)
	toppable.sort_custom(func(a, b): return (a.required - a.allocated) < (b.required - b.allocated))
 
	for entry in toppable:
		var needed: int = entry.required - entry.allocated
		if remaining >= needed:
			entry.allocated = entry.required
			remaining -= needed
		else:
			entry.allocated += remaining
			remaining = 0
 
	for entry in entries:
		entry.apply.call(entry.allocated)
 
	network_updated.emit(supply, demand, lit_count, entries.size())


func _collect_demand_entries() -> Array:
	var entries: Array = []

	for lantern_node in get_tree().get_nodes_in_group(Constants.LANTERNS_GROUP):
		if not (lantern_node.profile is Lantern):
			continue
		entries.append({
			"required": lantern_node.profile.energy_required,
			"min_required": lantern_node.profile.min_energy_required,
			"allocated": 0,
			"apply": func(allocated: int): lantern_node.set_power(allocated)
		})

	for i in range(simulated_lantern_count):
		entries.append({
			"required": simulated_lantern_energy_required,
			"min_required": simulated_lantern_min_energy_required,
			"allocated": 0,
			"apply": func(_allocated: int): pass  # no scene object, counted for demand/UI only
		})
		
	return entries


func _total_supply() -> int:
	var total := 0
	for furnace in _furnaces:
		if furnace.state == Furnace.furnace_state.BURNING:
			total += furnace.energy_output
	return total


#func _set_lantern_lit(lantern_node: Node, lit: bool) -> void:
	#var new_state := Lantern.lantern_state.LIT if lit else Lantern.lantern_state.UNLIT
	#if lantern_node.profile.state == new_state:
		#return
	#lantern_node.profile.state = new_state
	#lantern_node.is_lit = lit
