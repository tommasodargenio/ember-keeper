# AUDIO MANAGER COMPONENT
# This component is responsible to manage certain aspects of the audio system

# Give this component a custom icon so we can easily distinguish it in the editor
@icon("uid://dxvwn062uuoft")
# Give this component a class name so we can instance it from the scene editor
class_name AudioManagerCo extends Node

# We need a reference to the user preferences
var user_prefs: Preferences
# Get the ID of each of the custom audio bus set in the audio_bus layout resource
@onready var sound_fx_bus_id = AudioServer.get_bus_index("SoundFX")
@onready var music_bus_id = AudioServer.get_bus_index("Music")

# Mute the sound fx based on the user preferences
func toggle_sound_fx(toggle: bool) -> void:
	# We need to negate the setting as if the user doesn't want sound 
	# the flag will be false, to enable the bus mute we need a true flag
	AudioServer.set_bus_mute(sound_fx_bus_id, !toggle)

# Mute the music based on the user preferences	
func toggle_music(toggle: bool) -> void:
	# We need to negate the setting as if the user doesn't want music 
	# the flag will be false, to enable the bus mute we need a true flag
	AudioServer.set_bus_mute(music_bus_id, !toggle)

# Fade the music volume to the given amound in dB
func music_fade(amount: float = -10) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(MusicPlayer, "volume_db", amount, 2.0)

func _ready() -> void:
	# We need to set the process mode to always as this component
	# will also manage music and sfx when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Get the current user's saved preferences
	user_prefs = GameManager.player_prefs
	# Call the functions to enable/disable the audio bus depending on the user's preferences
	toggle_music(user_prefs.music_toggle)
	toggle_sound_fx(user_prefs.sfx_toggle)
	
	
	# If the sound FX option is set to false we mute the SoundFX channel
	EventBus.sound_toggle.connect(func(toggle):
		if toggle == null: 
			toggle = !user_prefs.sfx_toggle
			user_prefs.sfx_toggle = !user_prefs.sfx_toggle
			user_prefs.save()
		toggle_sound_fx(toggle)
	)
	# If the Music option is set to false we mute the SoundFX channel
	EventBus.music_toggle.connect(func(toggle):
		if toggle == null: 
			toggle = !user_prefs.music_toggle
			user_prefs.music_toggle = !user_prefs.music_toggle
			user_prefs.save()
		toggle_music(toggle)
	)
	
	# When the game start we fade down the music
	EventBus.game_ready.connect(func():
		music_fade(-25)
	)
	# when the game resumes from the pause we fade down the music again
	EventBus.game_resumed.connect(func():
		music_fade(-25)
	)	
	# When the game is paused we increase the music volume a bit
	EventBus.game_paused.connect(func():
		music_fade(-10)
	)
