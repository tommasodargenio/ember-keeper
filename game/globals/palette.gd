class_name Palette extends Node

static var default_palette = PaletteNames.green

enum PaletteNames {green, amber}

const PALETTES : Dictionary = { 
		"green" : {
			"dark": "#193404",
			"lighter_dark" : "#47980D",
			"bright": "#75EC21",
			"muted": "#59BF11",
			"normal": "#58BB10",
			"danger": "#DBEC21",
			"error": "#ff0000",
			"warning": "#ff8000",
			"info": "#75EC21", 
		},
		"amber" : {
			"dark": "#261B0D",
			"lighter_dark" : "#9E5D07",
			"bright": "#FC9505",
			"muted": "#C56306",
			"normal": "#DB7D02",
			"danger": "#FC1A05",
			"error": "#df9b5b",
			"warning": "#ff8800",
			"info": "#FC9505", 
		},
}

static func get_stylebox(box : StyleBox) -> StyleBox :
	if box.bg_color.to_html(false) == get_color("lighter_dark"): 
		return box
	box.bg_color = get_color("lighter_dark")
	box.border_color = get_color("bright")
	return box
		

static func get_icon(icon_file: String, isUID: bool = true) -> Texture2D:
	var svg : String
	
	if isUID:
		svg = Utility.get_file_as_string_by_uid(icon_file)
	else:
		svg = FileAccess.get_file_as_string(icon_file)
	var regex := RegEx.new()
	regex.compile("fill=\"#([0-9a-fA-F]{3,8})\"")
	var updated_svg := regex.sub(svg, "fill=\"%s\"" % get_color("dark"), true)
	regex.compile("stroke=\"#([0-9a-fA-F]{3,8})\"")
	updated_svg = regex.sub(updated_svg, "stroke=\"%s\"" % get_color("bright"), true)
	var img := Image.new()
	
	var byte_data := updated_svg.to_utf8_buffer() 
	var load_err := img.load_svg_from_buffer(byte_data)
	if load_err != OK:
		push_error("Failed to load the SVG from buffer")
		return
	
	var tex := ImageTexture.create_from_image(img)
	return tex
	
	
static func get_color(color_name : String, color_palette : Variant = "") -> String:
	if Constants.GAME_PALETTE in PALETTES or not color_palette.is_empty():
		if not color_palette.is_empty and color_palette in PALETTES and color_name in PALETTES[color_palette]:
			return PALETTES[color_palette][color_name]
		elif color_name in PALETTES[Constants.GAME_PALETTE]:
			return PALETTES[Constants.GAME_PALETTE][color_name]
	return "#ffffff"
