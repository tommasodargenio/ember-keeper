class_name HotBarItem extends PanelContainer

@export var item_name : String = ""

@export var quantity : int = 0:
	set(value):
		quantity = value
		_update_data()

@export var item_shortcut : String = "":
	set(value):
		item_shortcut = value
		_update_data()

@export var item_tex : Texture:
	set(value):
		item_tex = value
		_update_data()

@onready var tex: TextureRect = %Tex
@onready var qty: RichTextLabel = %Qty
@onready var short_cut: RichTextLabel = %ShortCut


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_data()
	
func _update_data() -> void:
	if is_node_ready():
		qty.text =  "[font_size=%s][color=%s]%s[/color][/font_size]" % [6, Palette.get_color("bright"), quantity]
		tex.texture = item_tex
		short_cut.text = " %s" % item_shortcut
		self.reset_size()
