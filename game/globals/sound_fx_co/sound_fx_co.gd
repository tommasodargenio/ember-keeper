# SOUND FX COMPONENT
# This component is responsible to play a given sound effect on demand

# Give this component a custom icon so we can easily distinguish it in the editor
@icon("uid://dvpfu2ivrbo4l")
# Give this component a class name so we can instance it from the scene editor
class_name SoundFxCo extends AudioStreamPlayer

# If set to true it will play the sound attached in the ready function
@export var auto_play: bool = false

# Get the ID of each of the custom audio bus set in the audio_bus layout resource
@onready var sound_fx_bus_id = AudioServer.get_bus_index("SoundFX")
@onready var music_bus_id = AudioServer.get_bus_index("Music")

# If autplay it's enabled will play the sound as soon as the object is ready
func _ready() -> void:
	# preselect the SoundFX bus
	bus = "SoundFX"
	if auto_play:
		play(0.0)

func play_with_random_pitch() -> void:
	randomize()
	pitch_scale = randf_range(1.0,1.2)
	play()

# Plays the effect on the left side using the pan effect
func play_left() -> void:
	# Access to the first effect loaded on the SoundFX bus, this would be the pan
	var effect = AudioServer.get_bus_effect(sound_fx_bus_id,0)
	# pan all to the left
	effect.pan = -1.0
	play(0.0)
	# reset the pan to the center
	effect.pan = 0.0
	
# Plays the effect on the right side using the pan effect
func play_right() -> void:
	# Access to the first effect loaded on the SoundFX bus, this would be the pan
	var effect = AudioServer.get_bus_effect(sound_fx_bus_id,0)
	# pan all to the right
	effect.pan = 1.0
	play(0.0)
	# reset the pan to the center
	effect.pan = 0.0
