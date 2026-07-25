@tool
extends MainMenu

@export var normal_label: LabelSettings
@export var title_label : LabelSettings

@onready var credit_container: VBoxContainer = %CreditContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	credit_container.add_child(_create_title_lab("Handcrafted by"))
	credit_container.add_child(_create_lab(Constants.CREDIT_AUTHOR))

	credit_container.add_child(_create_title_lab("with"))
	credit_container.add_child(_create_lab(Constants.CREDIT_ENGINE))
	
	credit_container.add_child(_create_title_lab("Art"))
	if Constants.CREDIT_ART.size() > 0 :
		for a in Constants.CREDIT_ART:
			credit_container.add_child(_create_lab(a))
	else:
			credit_container.add_child(_create_lab("-"))
		
	credit_container.add_child(_create_title_lab("Music"))
	if Constants.CREDIT_MUSIC.size() > 0:
		for a in Constants.CREDIT_MUSIC:
			credit_container.add_child(_create_lab(a))
	else:
			credit_container.add_child(_create_lab("-"))

	credit_container.add_child(_create_title_lab("Sound"))
	if Constants.CREDIT_SFX.size() > 0:
		for a in Constants.CREDIT_SFX:
			credit_container.add_child(_create_lab(a))
	else:
			credit_container.add_child(_create_lab("-"))

	
func _create_title_lab(title: String) -> RichTextLabel:
	var l = RichTextLabel.new()
	l.add_theme_font_override("normal", title_label.font)
	l.add_theme_font_size_override("font_size", title_label.font_size)
	l.text = title
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.bbcode_enabled = true
	l.fit_content = true
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return l
	
func _create_lab(msg : String) -> RichTextLabel:
	var l = RichTextLabel.new()
	l.add_theme_font_override("normal", normal_label.font)
	l.add_theme_font_size_override("font_size", normal_label.font_size)
	l.text = "[color=%s][b]%s[/b][/color]" % [Palette.get_color("error"),msg]
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.bbcode_enabled = true
	l.fit_content = true
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return l
