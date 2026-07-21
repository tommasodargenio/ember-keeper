extends StaticBody2D

@export var show_chain : bool = false:
	set(value):
		show_chain = value
		if is_node_ready():
			_update_tex()	
	
@export var is_lit: bool = false:
	set(value):
		is_lit = value
		if is_node_ready():
			_update_tex()	

@export var use_fx: bool = false

@export var profile : Lantern:
	set(value):
		profile = value
		if is_node_ready():
			_update_tex()

@onready var tex: AnimatedSprite2D = %Tex
@onready var chain: Sprite2D = %Chain


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Constants.LANTERNS_GROUP)

func _update_tex() -> void:
	chain.show() if show_chain else chain.hide()
	tex.play("lit") if is_lit else tex.stop()
