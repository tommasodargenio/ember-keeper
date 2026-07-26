extends Node

signal hour_passed(hour: int)
signal dawn_reached
signal clock_updated(time_str: String)
signal clock_parts_updated(hours_str: String, minutes_str: String, ampm_str: String)

@export var night_duration_hours: float = 1.0
@export var real_seconds_per_game_hour: float = 50.0 

@export_group("Clock Display")
@export var night_start_clock_hour: float = 20.0  
@export var use_24_hour_format: bool = false

var current_hour: float = 0.0
var _running: bool = false
var _last_whole_hour: int = 0
var _last_emitted_total_minutes: int = -1


func start_night() -> void:
	current_hour = 0.0
	_last_whole_hour = 0
	_last_emitted_total_minutes = -1
	_running = true
	clock_updated.emit(get_clock_string())
	_emit_parts()


func stop() -> void:
	_running = false


func _process(delta: float) -> void:
	if not _running:
		return

	current_hour += delta / real_seconds_per_game_hour

	var whole_hour: int = int(current_hour)
	if whole_hour > _last_whole_hour:
		_last_whole_hour = whole_hour
		hour_passed.emit(whole_hour)

	_check_clock_display()

	if current_hour >= night_duration_hours:
		_running = false
		dawn_reached.emit()


func _check_clock_display() -> void:
	var total_minutes: int = _total_display_minutes()
	if total_minutes != _last_emitted_total_minutes:
		_last_emitted_total_minutes = total_minutes
		clock_updated.emit(get_clock_string())
		_emit_parts()


func _emit_parts() -> void:
	var parts: Dictionary = get_clock_parts()
	clock_parts_updated.emit(parts["hours"], parts["minutes"], parts["ampm"])


func _total_display_minutes() -> int:
	var real_clock_hour: float = fmod(night_start_clock_hour + current_hour, 24.0)
	return int(real_clock_hour * 60.0)

func _get_sunset_time() -> String:
	var sunset : float = fmod(night_start_clock_hour, 24.0)
	var minutes : int = int(sunset * 60.0)
	return get_clock_string(minutes)

func _get_sunrise_time() -> String:
	var sunrise : float = fmod(night_start_clock_hour + night_duration_hours, 24.0)
	var minutes : int = int(sunrise * 60.0)
	return get_clock_string(minutes)
	
func get_clock_parts(tot_minutes: int = -1) -> Dictionary:	
	var total_minutes: int 
	if tot_minutes == -1: total_minutes = _total_display_minutes()
	else: total_minutes = tot_minutes
	
	@warning_ignore("integer_division")
	var hours: int = total_minutes / 60
	var minutes: int = total_minutes % 60

	if use_24_hour_format:
		return {"hours": "%02d" % hours, "minutes": "%02d" % minutes, "ampm": ""}

	var period: String = "AM" if hours < 12 else "PM"
	var hours_12: int = hours % 12
	if hours_12 == 0:
		hours_12 = 12
	return {"hours": "%d" % hours_12, "minutes": "%02d" % minutes, "ampm": period}



func get_clock_string(tot_minutes: int = -1) -> String:
	var parts: Dictionary = get_clock_parts(tot_minutes)
	if use_24_hour_format:
		return "%s:%s" % [parts["hours"], parts["minutes"]]
	return "%s:%s %s" % [parts["hours"], parts["minutes"], parts["ampm"]]
