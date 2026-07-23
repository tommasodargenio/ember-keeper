extends Control

@export var gauge_pressure: bool = true
@export var gauge_health : bool = false


# Tune these two in the editor by watching the needle at pressure 0 and 100 —
# they depend entirely on how your needle texture is drawn (which way it
# points at 0 rotation) and how much arc your dial face covers.
@export var needle_min_angle_deg: float = -85.0  # angle at pressure 0
@export var needle_max_angle_deg: float = 165.0   # angle at pressure 100
 
@export var decimals: int = 0
@export var min_marker_rotation_offset_deg: float = 62.0:
	set(value):
		min_marker_rotation_offset_deg = value
		if is_node_ready():
			_update_safe_zone_markers()
@export var max_marker_rotation_offset_deg: float = 231.0:
	set(value):
		max_marker_rotation_offset_deg = value
		if is_node_ready():
			_update_safe_zone_markers()
		
@onready var mano_meter: TextureRect = %ManoMeter
@onready var pressure_read: RichTextLabel = %PressureRead
@onready var needle: TextureRect = %Needle
@onready var marker_min_pressure: TextureRect = %MarkerMinPressure
@onready var marker_max_pressure: TextureRect = %MarkerMaxPressure
@onready var gauge_type: RichTextLabel = %GaugeType
 
var furnace: Furnace

func _ready() -> void:
	if gauge_health:
		gauge_type.text = "[color=%s][font_size=10]HP[/font_size][/color]" % [Palette.get_color("dark")]
	elif gauge_pressure:
		gauge_type.text = "[color=%s][font_size=10]bar[/font_size][/color]" % [Palette.get_color("dark")]

	EventBus.active_furnace_changed.connect(_set_furnace)
	if GameManager.current_furnace:
		_set_furnace(GameManager.current_furnace)


func _set_furnace(new_furnace: Furnace) -> void:
	if furnace and gauge_pressure and furnace.pressure_changed.is_connected(_on_meter_changed):
		furnace.pressure_changed.disconnect(_on_meter_changed)
	if furnace and gauge_health and furnace.health_changed.is_connected(_on_meter_changed):
		furnace.health_changed.disconnect(_on_meter_changed)

	furnace = new_furnace
	if furnace:
		if gauge_pressure:
			furnace.pressure_changed.connect(_on_meter_changed)
			_on_meter_changed(furnace.pressure)
		elif gauge_health:
			furnace.health_changed.connect(_on_meter_changed)
			_on_meter_changed(furnace.health)
		_update_safe_zone_markers()

func _on_meter_changed(value: float) -> void:
	needle.rotation_degrees = _angle_for(value)
	pressure_read.text = "[color=%s][font_size=10]%.*f[/font_size][/color]" % [Palette.get_color("dark"),decimals, value]
 
func _update_safe_zone_markers() -> void:
	marker_min_pressure.rotation_degrees = _angle_for(furnace.min_operating_pressure) + min_marker_rotation_offset_deg
	marker_max_pressure.rotation_degrees = _angle_for(furnace.max_operating_pressure) + max_marker_rotation_offset_deg
 
func _angle_for(pressure_value: float) -> float:
	var t: float = clamp(pressure_value, 0.0, 100.0) / 100.0
	return lerp(needle_min_angle_deg, needle_max_angle_deg, t)
 
