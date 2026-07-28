extends Node

@export var outage_ratio_threshold: float = 0.5     # fraction of lanterns dark that counts as "trouble"
@export var outage_grace_seconds: float = 8.0        # how long that has to persist before it's reported
@export var incident_mood_penalty: int = 12
@export var incident_cooldown_seconds: float = 20.0  # minimum gap between incidents, so one long blackout doesn't spam them

@export var win_min_mood: int = 50
@export var win_max_incidents: int = 6

@export var mood_recovery_rate: float = 1.5          # mood points per second, while the network is healthy
@export var mood_recovery_min_lit_ratio: float = 0.8   # network needs to be at least this lit for mood to recover at all

signal danger_level_changed(level: float)  # 0.0 = network fine, 1.0 = incident about to fire

var _current_dark_ratio: float = 0.0
var _outage_timer: float = 0.0
var _incident_cooldown: float = 0.0
var _game_over: bool = false
var _mood_recovery_accum: float = 0.0 

func _ready() -> void:
	EnergyNetwork.network_updated.connect(_on_network_updated)
	GameClock.dawn_reached.connect(_on_dawn_reached)

	EventBus.active_furnace_changed.connect(_watch_furnace)
	if GameManager.current_furnace:
		_watch_furnace(GameManager.current_furnace)


func _reset() -> void:
	_outage_timer = 0.0
	_incident_cooldown = 0.0
	_current_dark_ratio = 0.0
	_game_over = false
	_mood_recovery_accum = 0.0
	
func _watch_furnace(furnace: Furnace) -> void:
	if furnace:
		furnace.furnace_shutdown.connect(_on_furnace_shutdown)


func _process(delta: float) -> void:
	if _incident_cooldown > 0.0:
		_incident_cooldown -= delta
	
	if _current_dark_ratio >= outage_ratio_threshold:
		_outage_timer += delta
		danger_level_changed.emit(clamp(_outage_timer / outage_grace_seconds, 0.0, 1.0))
		if _outage_timer >= outage_grace_seconds and _incident_cooldown <= 0.0:
			_report_incident()
	else:
		if _outage_timer != 0.0:
			danger_level_changed.emit(0.0)
		_outage_timer = 0.0
	_process_mood_recovery(delta)

func _process_mood_recovery(delta: float) -> void:
	if GameManager.town_mood >= 100:
		return
 
	var lit_ratio: float = 1.0 - _current_dark_ratio
	if lit_ratio < mood_recovery_min_lit_ratio:
		return
 
	_mood_recovery_accum += mood_recovery_rate * delta
	while _mood_recovery_accum >= 1.0:
		_mood_recovery_accum -= 1.0
		GameManager.town_mood = min(100, GameManager.town_mood + 1)
 	
func _on_network_updated(_supply: int, _demand: int, lit_count: int, total_count: int) -> void:
	if total_count == 0:
		_current_dark_ratio = 0.0
	else:
		_current_dark_ratio = 1.0 - (float(lit_count) / float(total_count))


func _report_incident() -> void:
	GameManager.reported_incidents += 1
	GameManager.town_mood -= incident_mood_penalty
	_incident_cooldown = incident_cooldown_seconds
	_outage_timer = 0.0

	EventBus.show_message.emit(
		Constants.MESSAGE_WINDOW_FLAG.WARNING,
		"Incident",
		"Too many lanterns went dark — travelers are in trouble.",
		"TIMEOUT"
	)

	if GameManager.town_mood <= 0:
		_end_game(false, LD.PLAYER_LOSE_MOOD)


func _on_furnace_shutdown(reason: String) -> void:
	if reason == "overheat_damage":
		_end_game(false, LD.PLAYER_LOSE_FURNACE_EXPLOSION)


func _on_dawn_reached() -> void:
	var won: bool = GameManager.town_mood >= win_min_mood and GameManager.reported_incidents <= win_max_incidents
	_end_game(won, LD.PLAYER_WON)


func _end_game(won: bool, forced_reason: String) -> void:
	if _game_over:
		return
	_game_over = true
	GameClock.stop()
	EventBus.game_ended.emit(won, forced_reason)
