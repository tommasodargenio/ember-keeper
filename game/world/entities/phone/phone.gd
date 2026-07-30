class_name Phone extends StaticBody2D


signal mayor_calls
signal mayor_hangups
signal mayor_voicemail
signal player_calls
signal player_pickups
signal player_hangups

# phone event triggered
# mayor calls player with some tasks or info
	# SFX phone rings xx seconds
		# - SFX phone rings tone
		# - VFX phone rings animation
		# player pick-up
			# SFX pickup sound
			# SFX jibberish voice 
			# dialogue starts
				# mayor hangups
					# SFX phone hangup sound
					# SFX phone line tone 
				# player hangups
					# SFX hangup sound
		# timeout player doesn't pick up
			# SFX phone stops ringing
			# VFX phone ring animation stops
# player calls mayor to request something
	# VFX phone pickup animation
	# SFX phone pickup sound
	# SFX phone dialing number sound
	# SFX phone calls tone
		# mayor or somebody pick-up
			# stop SFX phone calls tone
			# SFX pickup sound
			# SFX jibberish voice
			# dialogue start
				# mayor hangups
					# SFX phone hangup sound
					# SFX phone line tone 
				# player hangups
					# SFX hangup sound
		# mayor hangup
			# stop SFX phone calls tone
			# SFX phone hangup tone
			# SFX phone line tone 
		# mayor doens't pickup
			# stop SFX phone calls tone	
			# SFX phone busy line	
			# SFX voicemail
			# SFX phone hangup tone
			# SFX phone line tone 
		 



@onready var interact_sensor: Area2D = %InteractSensor
@onready var icon_position: Marker2D = %IconPosition

var can_interact : bool = false
var tutorial_shown : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_register_events()

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()	

func _register_events() -> void:
	interact_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_interact = true
			if  GameManager and \
			GameManager.player_prefs and \
			not GameManager.player_prefs.tutorial_phone_shown and \
			GameManager.show_tutorial:			
				_tutorial_sequence()
				GameManager.player_prefs.tutorial_phone_shown = true
				EventBus.tutorial_progress.emit()				
	)
	interact_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_interact = false
	)

func _handle_interact() -> void:
	pass
	
func _tutorial_sequence() -> void:
	var tutorial := preload(Constants.SCENE_PATHS["FloatingIcon"]).instantiate()
	add_child(tutorial)
	tutorial.place_at(icon_position.global_position)
	tutorial.set_icon(preload(Constants.RESOURCES["EmpytEmote"]))
	tutorial.set_key_text(Utility.get_action_key_binding("interact"))
	tutorial.display_duration = 2.0
