extends Node2D


@onready var room_entrance_sensor: Area2D = %RoomEntranceSensor

var room_name = "Furnace"


func _ready() -> void:
	room_entrance_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			EventBus.player_entered_room.emit(room_name)
			GameManager.player_in_furnace_room = true
			GameManager.player_in_chair_room = false
	)
