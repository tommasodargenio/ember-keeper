@tool
class_name AnimatedLabel extends Control

@export var text: String = "":
	set(value):
		text = value
		if is_node_ready():
			_build_chars()

@export var label_settings : LabelSettings
@export var animate_on_ready: bool = true
@export var animate_on_click : bool = false
@export var wave_amplitude: float = 6.0
@export var wave_stagger: float = 0.08   # delay between each character
@export var wave_duration: float = 0.35  # how long each char takes to wave up and back
@export_range(0.0, 1.0) var wave_height_curve: float = 0.5

var _char_labels: Array[Label] = []
var _container: HBoxContainer
var _animated_count : int = 0

func _ready() -> void:
	_build_chars()
	if animate_on_ready and not Engine.is_editor_hint():
		play_wave()
	if animate_on_click:
		mouse_filter = Control.MOUSE_FILTER_STOP
		gui_input.connect(_on_gui_input)
		
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		play_wave()
		
func _build_chars() -> void:
# Clear previous
	if _container:
		_container.queue_free()
		_char_labels.clear()

	_container = HBoxContainer.new()
	_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_container.add_theme_constant_override("separation", 0)
	_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(_container)

	for ch in text:
		var lbl := Label.new()
		lbl.text = ch
		if label_settings:
			lbl.label_settings = label_settings
		_container.add_child(lbl)
		_char_labels.append(lbl)
	await get_tree().process_frame
	_update_minimum_size()
	
func _update_minimum_size() -> void:
	if not _container: return
	if not label_settings: return
	var height := label_settings.font_size + wave_amplitude * 2
	var width := _container.size.x
	
	custom_minimum_size = Vector2(width, height)

func play_wave() -> void:
	_animated_count += 1
	for i in _char_labels.size():
		var lbl = _char_labels[i]
		# Reset position
		lbl.position.y = 0.0
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		# Wave up
		tween.tween_property(lbl, "position:y", -wave_amplitude, wave_duration * 0.5).set_delay(i * wave_stagger)
		# Wave back down
		tween.tween_property(lbl, "position:y", 0.0, wave_duration * 0.5).set_ease(Tween.EASE_IN)

#class_name AnimatedLabel extends RichTextLabel
#
#@export var animate_on_show: bool = true
#@export var wave_amplitude: float = 4.0
#@export var wave_frequency: float = 2.0
#@export var wave_speed: float = 5.0
#@export var wave_duration: float = 59.0  # how long before wave settles
#
#var _wave_effect: RichTextTextWaveFx
#var _progress: float = 0.0
#var _animating: bool = false
#var _original_text: String = ""
#
#func _ready() -> void:
## Register the custom effect
	#_wave_effect = RichTextTextWaveFx.new()
	#install_effect(_wave_effect)
	#_original_text = text
	#if animate_on_show:
		#_start_wave()
#
#func _process(delta: float) -> void:
	#if not _animating:
		#return
	#_progress = minf(_progress + delta / wave_duration, 1.0)
	## Update the progress env variable via bbcode
	#_refresh_bbcode()
	##if _progress >= 1.0:
		##_animating = false
	## Restore plain text once animation is done
	##text = _original_text
#
#func _start_wave() -> void:
	#_progress = 0.0
	#_animating = true
	#bbcode_enabled = true
	#_refresh_bbcode()
#
#func _refresh_bbcode() -> void:
	#var params = "amplitude=%s frequency=%s speed=%s progress=%s" % [
	#wave_amplitude, wave_frequency, wave_speed, _progress
	#]
	#text = "[my_wave_fx %s]%s aa[/my_wave_fx]" % [params, _original_text]
#
## Call this externally to trigger the wave at any point
#func play_wave() -> void:
	#_original_text = text
	#_start_wave()
