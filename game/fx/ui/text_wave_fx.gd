@tool
class_name RichTextTextWaveFx extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [text_wave_fx param=2.0]hello[/text_wave_fx] in text.
var bbcode := "my_wave_fx"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var progress: float = char_fx.env.get("progress", 1.0)
	var amplitude: float = char_fx.env.get("amplitude", 4.0)
	var frequency: float = char_fx.env.get("frequency", 2.0)
	var speed: float = char_fx.env.get("speed", 3.0)
	var char_offset: float = char_fx.relative_index * 0.3

	# progress 0→1 controls how far the wave has travelled through the text
	# once progress reaches 1 the wave is done and characters settle
	var wave_pos: float = progress * (char_fx.relative_index + 1) * speed
	var settled: bool = wave_pos > char_fx.relative_index + frequency

	if settled:
		char_fx.offset = Vector2.ZERO
	else:
		var t: float = char_fx.elapsed_time * speed - char_offset
		char_fx.offset.y = sin(t * frequency) * amplitude * (1.0 - progress)

	return true
