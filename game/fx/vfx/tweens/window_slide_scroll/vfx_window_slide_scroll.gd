@icon("res://fx/vfx/tweens/window_slide_scroll/icon.svg")
class_name VFXWindowSlideScroll extends Node
enum ANIM_DIRECTION {LEFT, RIGHT, TOP, DOWN}


@export var animation_duration : float = 0.2
@export var transition: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
@export var easing: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var exit_direction : ANIM_DIRECTION
@export var entry_direction : ANIM_DIRECTION
var previous_position: Vector2 = Vector2.ZERO
var tweene: Tween

func tween_purge() -> void:
	if tweene and tweene.is_running():
		tweene.kill()
		
func scroll_in(object) -> Tween:
	tween_purge()
	tweene = object.create_tween().set_trans(transition).set_ease(easing).set_parallel(true)
	object.show()
	#object.modulate.a = 0.0
	match entry_direction:
		ANIM_DIRECTION.LEFT:
			tweene.tween_property(object, "position:x", 0.0, animation_duration).from(-get_viewport().size.x)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.RIGHT:
			tweene.tween_property(object, "position:x", 0.0, animation_duration).from(get_viewport().size.x)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.TOP:
			tweene.tween_property(object, "position:y", 0.0, animation_duration).from(-get_viewport().size.y)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.DOWN:
			tweene.tween_property(object, "position:y", 0.0, animation_duration).from(get_viewport().size.y)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
			

	return tweene
func scroll_out(object) -> Tween:
	
	tween_purge()
	previous_position = object.position
		
	tweene = object.create_tween().set_trans(transition).set_ease(easing).set_parallel(true)
	match exit_direction:
		ANIM_DIRECTION.LEFT:
			tweene.tween_property(object, "position:x", -get_viewport().size.x, animation_duration)
		ANIM_DIRECTION.RIGHT:
			tweene.tween_property(object, "position:x", get_viewport().size.x, animation_duration)
		ANIM_DIRECTION.TOP:
			tweene.tween_property(object, "position:y", -get_viewport().size.y, animation_duration)
		ANIM_DIRECTION.DOWN:
			tweene.tween_property(object, "position:y", get_viewport().size.y, animation_duration)

	
	return tweene
