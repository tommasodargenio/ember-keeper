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
	print("starting scroll in %s for %s" % [Time.get_ticks_msec(),object.name])
	tween_purge()
	tweene = object.get_tree().create_tween().set_trans(transition).set_ease(easing).set_parallel(true)
	object.show()
	#object.modulate.a = 0.0
	print("animate in %s" % object.name)
	match entry_direction:
		ANIM_DIRECTION.LEFT:
			tweene.tween_property(object, "position:x", 0.0, animation_duration).from(-get_viewport().size.x)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.RIGHT:
			tweene.tween_property(object, "position:x", 0.0, animation_duration).from(get_viewport().size.x)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.TOP:
			print("Moving from -%s to %s" % [get_viewport().size.y, "0.0"])
			tweene.tween_property(object, "position:y", 0.0, animation_duration).from(-get_viewport().size.y)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
		ANIM_DIRECTION.DOWN:
			print("Moving from %s to %s" % [get_viewport().size.y, "0.0"])
			tweene.tween_property(object, "position:y", 0.0, animation_duration).from(get_viewport().size.y)
			tweene.tween_property(object, "modulate:a", 1.0, 0.01)
			
	tweene.finished.connect(func():
		print("finished scroll in %s " % Time.get_ticks_msec())
	)
	return tweene
func scroll_out(object) -> Tween:
	print("starting scroll out %s for %s" % [Time.get_ticks_msec(), object.name])
	
	tween_purge()
	previous_position = object.position
		
	tweene = object.get_tree().create_tween().set_trans(transition).set_ease(easing).set_parallel(true)
	match exit_direction:
		ANIM_DIRECTION.LEFT:
			tweene.tween_property(object, "position:x", -get_viewport().size.x, animation_duration)
		ANIM_DIRECTION.RIGHT:
			tweene.tween_property(object, "position:x", get_viewport().size.x, animation_duration)
		ANIM_DIRECTION.TOP:
			print("Moving from %s to -%s" % [object.position.y, get_viewport().size.y])
			tweene.tween_property(object, "position:y", -get_viewport().size.y, animation_duration)
		ANIM_DIRECTION.DOWN:
			print("Moving from %s to %s" % [object.position.y, get_viewport().size.y])
			tweene.tween_property(object, "position:y", get_viewport().size.y, animation_duration)
			
	tweene.finished.connect(func():
		print("finished scroll out %s " % Time.get_ticks_msec())
	)
	
	return tweene
