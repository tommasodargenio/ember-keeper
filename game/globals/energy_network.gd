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

	# cheapest-first: scarce energy goes to the least demanding lanterns before
	# the hungrier ones. Swap this sort key for priority/distance-based logic
	# later if "which lanterns matter most" becomes a gameplay question.
	entries.sort_custom(func(a, b): return a.required < b.required)

	var remaining := supply
	var lit_count := 0
	var demand := 0

	for entry in entries:
		demand += entry.required
		var can_light: bool = remaining >= entry.required
		if can_light:
			remaining -= entry.required
			lit_count += 1
		entry.apply.call(can_light)

	network_updated.emit(supply, demand, lit_count, entries.size())


func _collect_demand_entries() -> Array:
	var entries: Array = []

	for lantern_node in get_tree().get_nodes_in_group(Constants.LANTERNS_GROUP):
		if not (lantern_node.profile is Lantern):
			continue
		entries.append({
			"required": lantern_node.profile.energy_required,
			"apply": func(lit: bool): _set_lantern_lit(lantern_node, lit)
		})

	for i in range(simulated_lantern_count):
		entries.append({
			"required": simulated_lantern_energy_required,
			"apply": func(_lit: bool): pass  # no scene object, counted for demand/UI only
		})

	return entries


func _total_supply() -> int:
	var total := 0
	for furnace in _furnaces:
		if furnace.state == Furnace.furnace_state.BURNING:
			total += furnace.energy_output
	return total


func _set_lantern_lit(lantern_node: Node, lit: bool) -> void:
	var new_state := Lantern.lantern_state.LIT if lit else Lantern.lantern_state.UNLIT
	if lantern_node.profile.state == new_state:
		return
	lantern_node.profile.state = new_state
	lantern_node.is_lit = lit
