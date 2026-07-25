class_name FloatingIcon extends Control
## Generic floating UI prompt — an icon (and optional short key-label) that
## fades in, gently bobs up and down, then fades out and frees itself either
## after display_duration or when dismiss() is called manually.
##
## Usage:
##   var prompt = preload("res://path/to/floating_prompt.tscn").instantiate()
##   parent.add_child(prompt)
##   prompt.global_position = some_world_or_screen_position
##   prompt.set_icon(arrow_texture)
##   prompt.dismissed.connect(_on_arrow_dismissed)  # e.g. to chain the next prompt
##
## For a key-shortcut prompt instead, also call:
##   prompt.set_key_text("E")

signal dismissed

@export_group("Animation")
@export var float_amplitude: float = 6.0    # pixels up/down from rest position
@export var float_speed: float = 1.2         # bob cycles per second
@export var display_duration: float = 3.0    # seconds before auto-dismiss; 0 = stays until dismiss() is called manually
@export var fade_duration: float = 0.35
@export_group("Text")
@export var font_size : int = 12
@export var font_color : Color = Color.BLACK


@onready var icon: TextureRect = %Icon
@onready var key_label: RichTextLabel = %KeyLabel

var _base_position: Vector2
var _bob_time: float = 0.0
var _tween: Tween
var _dismissing: bool = false


func _ready() -> void:
	modulate.a = 0.0
	key_label.visible = false

	_fade_in()




func _process(delta: float) -> void:
	_bob_time += delta * float_speed
	position.y = _base_position.y + sin(_bob_time * TAU) * float_amplitude

# Sets where this prompt appears AND locks in that spot as the bob
# animation's resting point. Use this instead of setting global_position
# directly — global_position alone gets silently overwritten on the next
# frame, since _process() re-centers the bob around _base_position.
func place_at(global_pos: Vector2) -> void:
	global_position = global_pos
	_base_position = position
	
func set_icon(tex: Texture2D) -> void:
	icon.texture = tex

func _start_timer() -> void:
	if display_duration > 0.0:
		var timer := get_tree().create_timer(display_duration)
		timer.timeout.connect(dismiss)	

# Optional — for prompts showing a keyboard shortcut (e.g. "E", "Q") rather
# than just a directional icon. Leave unset if this prompt is icon-only.
func set_key_text(text: String) -> void:
	key_label.text = "[font_size=%s][color=%s]%s[/color][/font_size]" % [font_size,font_color.to_html(),text]
	key_label.visible = text != ""


# Optional — for static directional arrows (e.g. pointing toward a doorway).
# Does NOT continuously track a moving target; set once based on where the
# prompt is placed relative to what it's pointing at.
func set_icon_rotation_degrees(degrees: float) -> void:
	icon.rotation_degrees = degrees


func dismiss() -> void:
	if _dismissing:
		return
	_dismissing = true

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	_tween.finished.connect(func():
		dismissed.emit()
		queue_free()
	)


func _fade_in() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	_tween.tween_callback(_start_timer)
