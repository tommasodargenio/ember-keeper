extends AudioStreamPlayer

var bus_idx: int = 0


## Specify the default volume (normalized from 0.0 to 1.0)
@export_range(0, 1, 0.1) var default_volume: float = 0.5

## The duration of the fade in seconds
@export_range(0, 5, 0.1) var duration: float = 2.0

var _tween: Tween

func _set_volume(vol: float) -> void:
	volume_db = linear_to_db(vol)

## Toggles the volume to fade in/out
func toggle() -> void:
	if _tween and _tween.is_running():
		_tween.stop()
	_tween = get_tree().create_tween()
	
	if !playing:
		_set_volume(0.0)
		play()
		_tween.tween_method(_set_volume, db_to_linear(volume_db), default_volume, duration)
	else:
		_tween.tween_method(_set_volume, db_to_linear(volume_db), 0.0, duration)
		_tween.chain().tween_callback(stop)
			
func _ready() -> void:
	EventBus.music_toggle.connect(func(toggle: bool):
		stream_paused = !toggle
	)
	
	bus_idx = AudioServer.get_bus_index("Music")

	toggle()
