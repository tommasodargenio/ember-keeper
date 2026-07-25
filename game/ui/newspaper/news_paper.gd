extends Control

@export var continue_action: String = "ui_accept"    # swap for a custom input action if you have one bound
@export var continue_key_label: String = "SPACE"     # what the prompt displays — doesn't have to match the action name
@export var page_reveal_duration: float = 2.0

@export var continue_prompt_scene: PackedScene
@export var continue_prompt_position: Vector2
@export var continue_key_icon: Texture2D

@onready var intro_article: RichTextLabel = %IntroArticle

var _continue_prompt: FloatingIcon


func _ready() -> void:
	_run_intro_sequence()


func _run_intro_sequence() -> void:
	for article_text in LD.INTRO_ARTICLE:
		await _show_page(article_text)

	EventBus.intro_finished.emit()  # hook whatever comes next (tutorial, gameplay start) to this


func _show_page(article_text: String) -> void:
	intro_article.text = "[font_size=8][color=royal_blue]%s[/color][/font_size]" % article_text
	intro_article.visible_ratio = 0.0

	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(intro_article, "visible_ratio", 1.0, page_reveal_duration).from(0.0)

	# Let the player skip ahead of the typewriter animation by pressing the
	# continue action early — snaps straight to fully revealed instead of
	# making them sit through the rest of the reveal.
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
	# Consume this frame first — if the player just used this same press to
	# skip the typewriter above, we don't want it to also immediately
	# advance the page before they've even seen the full text.
	await get_tree().process_frame

	while true:
		if Input.is_action_just_pressed(continue_action):
			await get_tree().process_frame  # let the "just pressed" flag clear before the next page's skip-check runs
			return
		await get_tree().process_frame


func _show_continue_prompt() -> void:
	_continue_prompt = continue_prompt_scene.instantiate()
	add_child(_continue_prompt)
	_continue_prompt.place_at(continue_prompt_position)
	_continue_prompt.set_icon(continue_key_icon)
	_continue_prompt.set_key_text(continue_key_label)
	_continue_prompt.display_duration = 0.0  # stays on screen until we dismiss it ourselves


func _dismiss_continue_prompt() -> void:
	if _continue_prompt:
		_continue_prompt.dismiss()
		_continue_prompt = null
