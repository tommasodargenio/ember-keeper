extends StaticBody2D

@export var show_chain : bool = false:
	set(value):
		show_chain = value
		if is_node_ready():
			_update_chain()	
	
@export var is_lit: bool = false:
	set(value):
		is_lit = value
		if is_node_ready():
			_update_chain()	

@export var use_fx: bool = false

@export var profile : Lantern:
	set(value):
		profile = value
		if is_node_ready():
			_update_chain()

@onready var tex: AnimatedSprite2D = %Tex
@onready var chain: Sprite2D = %Chain

# power_state: the settled, logical state (what's actually true right now).
# _target_power_state: the latest state EnergyNetwork wants us to reach —
#   may be ahead of power_state while a transition animation is still playing.
var power_state: Lantern.power_state = Lantern.power_state.OFF
var _target_power_state: Lantern.power_state = Lantern.power_state.OFF
var _transitioning: bool = false
var _ignite_target: Lantern.power_state = Lantern.power_state.LOW  # brightness this ignite is heading toward
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Constants.LANTERNS_GROUP)
	tex.animation_finished.connect(_on_animation_finished)
	_update_chain()
	_play_steady_animation()
 
 
# Called by EnergyNetwork with however much energy it decided to give this
# lantern this pass (0 if it couldn't even meet min_energy_required).
func set_power(allocated_energy: int) -> void:
	if profile == null:
		return
 
	_target_power_state = profile.compute_state(allocated_energy)
 
	if _transitioning:
		# Let the current ignite/shutdown animation finish; _on_animation_finished
		# will check _target_power_state again once it settles.
		return
 
	_begin_transition_if_needed()
 
 
func _begin_transition_if_needed() -> void:
	if _target_power_state == power_state:
		return
 
	_transitioning = true
 
	if power_state == Lantern.power_state.OFF:
		# turning on — ignite toward whichever brightness is currently wanted
		_ignite_target = _target_power_state
		tex.play("lit_ignite")
	elif _target_power_state == Lantern.power_state.OFF:
		# turning off
		tex.play("lit_shutting_down")
	else:
		# already lit, shifting between LOW and FULL
		_ignite_target = _target_power_state
		tex.play("lit_ignite")
 
 
func _on_animation_finished() -> void:
	match tex.animation:
		"lit_ignite":
			power_state = _ignite_target
		"lit_shutting_down":
			power_state = Lantern.power_state.OFF
		_:
			return  # steady-state loops don't need handling here
 
	_transitioning = false
	profile.state = power_state
	_play_steady_animation()
 
	# target may have moved on again while we were mid-transition
	if _target_power_state != power_state:
		_begin_transition_if_needed()
 
 
func _play_steady_animation() -> void:
	match power_state:
		Lantern.power_state.OFF:
			tex.play("unlit")
		Lantern.power_state.LOW:
			tex.play("lit_low")
		Lantern.power_state.FULL:
			tex.play("lit_full")
 
 
func _update_chain() -> void:
	chain.show() if show_chain else chain.hide()
