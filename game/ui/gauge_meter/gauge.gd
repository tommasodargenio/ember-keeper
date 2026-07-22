extends Control

@onready var mano_meter: TextureRect = %ManoMeter
@onready var pressure_read: RichTextLabel = %PressureRead
@onready var needle: TextureRect = %Needle

# Tune these two in the editor by watching the needle at pressure 0 and 100 —
# they depend entirely on how your needle texture is drawn (which way it
# points at 0 rotation) and how much arc your dial face covers.
@export var needle_min_angle_deg: float = -85.0  # angle at pressure 0
@export var needle_max_angle_deg: float = 165.0   # angle at pressure 100
 
@export var decimals: int = 0
 
var furnace: Furnace

func _ready() -> void:
	EventBus.active_furnace_changed.connect(_set_furnace)
	if GameManager.current_furnace:
		_set_furnace(GameManager.current_furnace)


func _set_furnace(new_furnace: Furnace) -> void:
	if furnace and furnace.pressure_changed.is_connected(_on_pressure_changed):
		furnace.pressure_changed.disconnect(_on_pressure_changed)
	furnace = new_furnace
	if furnace:
		furnace.pressure_changed.connect(_on_pressure_changed)
		_on_pressure_changed(furnace.pressure)
		#_update_safe_zone_markers()

func _on_pressure_changed(value: float) -> void:
	needle.rotation_degrees = _angle_for(value)
	pressure_read.text = "[color=%s][font_size=10]%.*f[/font_size][/color]" % [Palette.get_color("dark"),decimals, value]
 
#func _update_safe_zone_markers() -> void:
	#min_marker.rotation_degrees = _angle_for(furnace.min_operating_pressure)
	#max_marker.rotation_degrees = _angle_for(furnace.max_operating_pressure)
 #
 #
func _angle_for(pressure_value: float) -> float:
	var t: float = clamp(pressure_value, 0.0, 100.0) / 100.0
	return lerp(needle_min_angle_deg, needle_max_angle_deg, t)
 
