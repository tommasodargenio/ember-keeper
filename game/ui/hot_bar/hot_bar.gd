extends Control

@export var max_items : int = 4
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	_register_events()

func _register_events() -> void:
	EventBus.add_to_hotbar.connect(func(item_name: String, tex: Texture, quantity: int, item_shortcut: String):
		_add_item(item_name, tex, quantity, item_shortcut)
	)
	EventBus.update_hotbar.connect(func(item_name : String, quantity : int): 
		_update_item(item_name, quantity)
	)
	EventBus.reset_hotbar.connect(func():
		for i in grid.get_children():
			i.queue_free()
	)

func _item_in_grid(item_name: String) -> HotBarItem:
	for i: HotBarItem in grid.get_children():
		if i.item_name ==  item_name:
			return i
	return null

func _update_item(item_name: String, quantity: int):
	var existing_item = _item_in_grid(item_name)
	if existing_item:
		if quantity <= 0:
			existing_item.queue_free()
		else:
			existing_item.quantity = quantity
		return

func _add_item(item_name: String, sprite: Texture, quantity: int, item_shortcut: String) -> void:
	var existing_item = _item_in_grid(item_name)
	if existing_item:
		existing_item.quantity += quantity
		return
	var item = preload(Constants.SCENE_PATHS["HotBarItem"]).instantiate()
	item.item_name = item_name
	item.item_tex = sprite
	item.quantity = quantity
	item.item_shortcut = item_shortcut
	if grid.get_child_count() < max_items:
		grid.add_child(item)
		self.reset_size()
