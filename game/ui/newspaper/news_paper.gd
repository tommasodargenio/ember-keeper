extends Control

@export var continue_action: String = "ui_right"    
@export var continue_key_label: String = ""     
@export var page_reveal_duration: float = 2.0
@export var start_hidden : bool = true
@export var continue_prompt_scene: PackedScene
@export var continue_prompt_position: Vector2
@export var continue_key_icon: Texture2D
@export var blur_rect : ColorRect
@export_group("Newspaper Intro")
@export var newspaper_spin_start_rotation_deg: float = -720.0  # total degrees it spins through before settling — multiples of 360 for a clean whole-spin count
@export var newspaper_start_scale: float = 0.05
@export var newspaper_settle_duration: float = 1.0
 



@onready var intro_article: RichTextLabel = %IntroArticle

var _continue_prompt: FloatingIcon
var tween : Tween
var tutorial_shown : bool = false
var blur_tween : Tween
func _ready() -> void:
	
	show()
	if start_hidden:
		self.modulate.a = 0.0
	else:
		self.modulate.a = 1.0
	if GameManager.show_tutorial and not tutorial_shown:
		EventBus.hide_ui.emit()
		await get_tree().process_frame
		_blur_on()
		_play_intro()
	else:
		_move_on()

func _play_intro() -> void:
	self.pivot_offset = self.size / 2.0
 
	self.scale = Vector2.ONE * newspaper_start_scale
	self.rotation_degrees = newspaper_spin_start_rotation_deg
	
	if tween and tween.is_running():
		tween.kill() 
	tween = get_tree().create_tween()
	tween.set_parallel(true)
 
	tween.tween_property(self, "scale", Vector2.ONE, newspaper_settle_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) 
	tween.tween_property(self, "rotation_degrees", 0.0, newspaper_settle_duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)  
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_callback(_run_intro_sequence)
 
 
func _run_intro_sequence() -> void:
	for article_text in LD.INTRO_ARTICLE:
		await _show_page(article_text)
	
	tutorial_shown = true
	_transition_out()


func _show_page(article_text: String) -> void:
	intro_article.text = "[font_size=8][color=royal_blue]%s[/color][/font_size]" % article_text
	intro_article.visible_ratio = 0.0

	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(intro_article, "visible_ratio", 1.0, page_reveal_duration).from(0.0)


	while tween.is_running():
		if Input.is_action_just_pressed(continue_action):
			tween.kill()
			intro_article.visible_ratio = 1.0
			break
		await get_tree().process_frame

	_show_continue_prompt()
	await _wait_for_continue_press()
	_dismiss_continue_prompt()


func _wait_for_continue_press() -> void:

	await get_tree().process_frame

	while true:
		if Input.is_action_just_pressed(continue_action):
			await get_tree().process_frame 
			return
		await get_tree().process_frame


func _show_continue_prompt() -> void:
	_continue_prompt = continue_prompt_scene.instantiate()
	add_child(_continue_prompt)
	_continue_prompt.place_at(continue_prompt_position)
	_continue_prompt.set_icon(continue_key_icon)
	_continue_prompt.set_key_text(continue_key_label)
	_continue_prompt.display_duration = 0.0


func _dismiss_continue_prompt() -> void:
	if _continue_prompt:
		_continue_prompt.dismiss()
		_continue_prompt = null
		
func _transition_in() -> void:
	_blur_on()
	if tween and tween.is_running():
		tween.kill()
	print("newspaper in")
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()	
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2.ZERO)
	tween.tween_callback(_run_intro_sequence)

func _transition_out() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(_move_on)

func _move_on() -> void:
	EventBus.intro_finished.emit()
	hide()
	_blur_off()
	EventBus.show_ui.emit()

func _blur_on() -> void:
	if not blur_rect: return
	if blur_tween and blur_tween.is_running():
		blur_tween.kill()
		
	blur_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	blur_tween.tween_property(blur_rect, "color:a", 1.0, 0.01)
	
func _blur_off() -> void:
	if not blur_rect: return
	if blur_tween and blur_tween.is_running():
		blur_tween.kill()
		
	blur_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	blur_tween.tween_property(blur_rect, "color:a", 0.0, 0.01)	
