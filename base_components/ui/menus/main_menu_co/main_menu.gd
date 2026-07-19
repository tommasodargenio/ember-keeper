@tool
class_name MainMenu extends Control

enum animation_type {SCALE, SLIDE_IN_LEFT, SLIDE_IN_RIGHT, SLIDE_IN_TOP, SLIDE_IN_BOTTOM}
enum animation_order_type {START_ON_TOP, START_ON_BOTTOM}
enum scale_from_type {CENTER, TOP_LEFT, TOP_CENTER}

@export_category("General Settings")
@export var start_hidden : bool = false:
	set(value):
		start_hidden = value
		if is_node_ready():
			self.visible = !start_hidden

@export var hide_as_close : bool = false
			
@export_category("Labels Settings")

@export var menu_title: String = Constants.GAME_NAME:
	set(value):
		menu_title = value
		_update_labels()

@export var menu_footer: String = "":
	set(value):
		menu_footer = value
		_update_labels()

@export var label_setting: LabelSettings:
	set(value):
		label_setting = value
		font = label_setting.font
		font_size = label_setting.font_size		

@export var animate_title : bool = false:
	set(value):
		animate_title = value
		if menu_title_label:
			menu_title_label.animate_on_show = animate_title

@export var show_copyright: bool = true:
	set(value):
		show_copyright = value
		_update_labels()

@export var show_game_name: bool = true:
	set(value):
		show_game_name = value
		_update_labels()
		
@export_category("Menu Items")
@export var menu_items: Array[MenuItem] = []:
	set(value):
		menu_items = value
		_update_menu()

@export var menu_item_min_size: Vector2 = Vector2(215, 0):
	set(value):
		menu_item_min_size = value
		_update_menu()
		
@export var idle_animation: bool = false
@export var hover_animation : bool = true

@export_category("Menu Items Animation")
@export var container_animation : bool = false
@export var target_container : Control
@export var container_animation_type : animation_type = animation_type.SLIDE_IN_LEFT
@export var container_animation_order : animation_order_type = animation_order_type.START_ON_TOP
@export var scale_from: scale_from_type = scale_from_type.CENTER
@export var duration: float = 0.2
@export var delay_appear: float = 0.2
@export var delay_between_elements: float = 0.05


@onready var menu_item_container: VBoxContainer = %MenuItemContainer
@onready var menu_title_label: AnimatedLabel = %MenuTitleLabel
@onready var menu_footer_label: RichTextLabel = %MenuFooterLabel
@onready var center_container: CenterContainer = %CenterContainer
@onready var vfx_window_slide_scroll: VFXWindowSlideScroll = %VFXWindowSlideScroll

var font : Font
var font_size : float
var font_color : Color
var tween : Tween

func _ready() -> void:
	print("Game is paused: %s" % get_tree().paused)
	if start_hidden:
		self.hide()
	
	_update_labels()
	_update_menu()
	if label_setting:
		font = label_setting.font
		font_size = label_setting.font_size
		font_color = label_setting.font_color
	
	#call_deferred("_on_menu_show")	
	#call_deferred("_animate_menu_items")
	#if not Engine.is_editor_hint():
		#EventBus.close_menu.connect(func():
			#print("call animate exit on close_menu event triggered")
			#var t: = _animate_menu_exit()
			#if t and t.is_valid():
				#await t.finished
				#print("scroll out finished captured in animate_menu_items close_menu event: %s" % Time.get_ticks_msec())		
				#if not hide_as_close: 
					#self.queue_free()
					#print("deleting scene %s [%s/%s]" % [Time.get_ticks_msec(),self.name, self.is_queued_for_deletion()])
				#else: 
					#print("hiding scene %s " % Time.get_ticks_msec())					
					#self.hide()
		#)
	await get_tree().process_frame
	await get_tree().process_frame
	if not start_hidden:
		_pop_up_menu()

func _pop_out_menu() -> void:
	print("call animate exit on close_menu event triggered")
	var t: = _animate_menu_exit()
	if t and t.is_valid():
		await t.finished
		print("scroll out finished captured in animate_menu_items close_menu event: %s" % Time.get_ticks_msec())		
		if not hide_as_close: 
			self.queue_free()
			print("deleting scene %s [%s/%s]" % [Time.get_ticks_msec(),self.name, self.is_queued_for_deletion()])
		else: 
			print("hiding scene %s " % Time.get_ticks_msec())					
			self.hide()	
			print("reset position to 0.0 from %s" % position )
			self.position.y = 0.0
			
func _pop_up_menu() -> void:
	if Engine.is_editor_hint():
		return
	print("pop up menu called %s" % Time.get_ticks_msec())
	self.show()
	_on_menu_show()
	await _animate_menu_items()
	EventBus.menu_loaded.emit()

func _on_menu_show() -> void:
	print("on menu show %s " % Time.get_ticks_msec())
	if animate_title:
		menu_title_label.play_wave()
	
func _enter_tree() -> void:
	if menu_footer == "":
		menu_footer = "%s Copyright (c) 2026-%s" % [Constants.GAME_VERSION, Time.get_datetime_dict_from_system().year]

func _update_labels() -> void:
	# @onready vars aren't available before _ready in editor, so fetch manually
	var title = get_node_or_null("%MenuTitleLabel") as AnimatedLabel
	var footer = get_node_or_null("%MenuFooterLabel")
	if title:
		title.text = menu_title if show_game_name else ""
	if footer:
		footer.text = menu_footer if show_copyright else ""
		if font:
			footer.add_theme_font_override("normal_font", font)
		
func _update_menu() -> void:
	var container = get_node_or_null("%MenuItemContainer")
	if not container:
		return
	# Clear existing buttons
	for child in container.get_children():
		child.queue_free()
	# Rebuild
	for entry in menu_items:
		if not entry:
			continue
			
		var btn = MenuBtn.new()
		btn.text = entry.name
		btn.min_height = menu_item_min_size.y
		btn.min_width = menu_item_min_size.x
		
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		var label_settings : LabelSettings = load(Constants.UI_RESOURCES["labelsGeneric"])
		
		btn.label_font = label_settings.font
		btn.label_font_size = label_settings.font_size
		
		entry.menu_item_parent = self
		#if container_animation:
			#btn.modulate.a = 0.0
		
		container.add_child(btn)
		# Only connect signals at runtime, not in editor
		if not Engine.is_editor_hint():
			btn.pressed.connect(entry._run)


func _animate_menu_enter() -> Tween:
	if not Engine.is_editor_hint():
		print("animate menu enter %s " % Time.get_ticks_msec())
		return vfx_window_slide_scroll.scroll_in(self)
	return null

func _animate_menu_exit() -> Tween:
	print("animate menu exit %s " % Time.get_ticks_msec())
	return vfx_window_slide_scroll.scroll_out(self)


func _animate_menu_items() -> void:
	print("animate menu entered %s " % Time.get_ticks_msec())
	if not container_animation: return
	if not target_container: return
	print("animate menu items %s " % Time.get_ticks_msec())

	match container_animation_type:
		animation_type.SCALE:
			for c: Control in target_container.get_children():
				print("animating [%s] %s " % [animation_type.keys()[container_animation_type],c.name])
				c.scale = Vector2.ZERO
				c.modulate.a = 0.0
				_set_pivot(c, scale_from)
		animation_type.SLIDE_IN_LEFT, animation_type.SLIDE_IN_RIGHT:
			for c: Control in target_container.get_children():
				print("animating [%s] %s " % [animation_type.keys()[container_animation_type],c.name])
				c.modulate.a = 0.0
		animation_type.SLIDE_IN_TOP, animation_type.SLIDE_IN_BOTTOM:				
			for c: Control in target_container.get_children():
				print("animating [%s] %s " % [animation_type.keys()[container_animation_type],c.name])				
				c.modulate.a = 0.0

	var t : Tween =  _animate_menu_enter()
	print("Process mode in main_menu.gd: %s" % self.process_mode)
	#print("tween returned by vfx scroll: %s - is it valid? %s - is it running? %s" % [t, t.is_valid(), t.is_running()])
	if t and t.is_valid():
		#print("Tween is valid awaiting - how long it has been running: %s" % t.get_total_elapsed_time())
		var  p = get_tree().get_processed_tweens()
		#print("process tweens found %s" % p.size())
		#print("Processed tweens: %s" % JSON.stringify(p))
		await t.finished
		await get_tree().process_frame
		print("scroll in finished captured in animate_menu_items: %s" % Time.get_ticks_msec())
	else:
		print("balls")
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	
	if delay_appear > 0.0:
		tween.tween_interval(delay_appear)
		tween.chain().tween_interval(0.01)
	
	var children : Array = target_container.get_children()
	if container_animation_order == animation_order_type.START_ON_BOTTOM:
		children.reverse()
	
	var final_positions : Dictionary = {}
	for c: Control in children:
		final_positions[c] = c.global_position
	print("start tweening buttons, how about the window tween? is it still valid? %s - is it still running? %s" % [t.is_valid(), t.is_running()])
	var idx: int = 0
	for c: Control in children:
		match container_animation_type:
			animation_type.SCALE:
				tween.tween_property(c, "scale", Vector2.ONE, duration).from(Vector2.ZERO).set_delay(delay_between_elements*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.01).set_delay(delay_between_elements*idx)
			animation_type.SLIDE_IN_LEFT:
				tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x-c.size.x).set_delay(delay_between_elements*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elements*idx)
			animation_type.SLIDE_IN_RIGHT:
				tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x+c.size.x).set_delay(delay_between_elements*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elements*idx)
			animation_type.SLIDE_IN_TOP:
				var gpos = final_positions[c]
				c.global_position = Vector2(gpos.x, gpos.y - c.size.y)
				tween.tween_property(c, "global_position:y", gpos.y, duration).set_delay(delay_between_elements*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elements*idx)
			animation_type.SLIDE_IN_BOTTOM:
				var gpos = final_positions[c]
				c.global_position = Vector2(gpos.x, gpos.y + c.size.y)
				tween.tween_property(c, "global_position:y", gpos.y, duration).set_delay(delay_between_elements*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elements*idx)
		
		idx += 1
	
func _set_pivot(control: Control, pivot: scale_from_type) -> void:
	match pivot:
		scale_from_type.CENTER:
			control.pivot_offset = control.size / 2.0
		scale_from_type.TOP_LEFT:
			control.pivot_offset = Vector2(0.0, 0.0)
		scale_from_type.TOP_CENTER:
			control.pivot_offset = Vector2(control.size.x / 2.0, 0.0)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
