extends TextureRect

var show_count = false
var current_count = 1
var name_string

func _ready():
	$Count.visible = show_count
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#if show_count:
		#$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	set_active(false)

func set_count(p_count):
	if current_count < p_count:
		$Count/Right.frame = 0
	else:
		$Count/Left.frame = 0
	current_count = p_count
	$Count/Label.text = str(p_count)
	$Count/Left.visible = current_count != 1
	$Count/Right.visible = current_count != 9

func set_active(is_active):
	$AnimatedSprite2D.visible = is_active

func set_text(string):
	name_string = string
	$Label.text = string

func set_text_color(color):
	$Label.add_theme_color_override("font_color", color)
	$Count/Label.add_theme_color_override("font_color", color)

func set_color(color):
	$Label.add_theme_color_override("font_color", color)
	$Count/Label.add_theme_color_override("font_color", color)
	var color_lighter = color
	color_lighter.v = min(1, color.v + .6)
	$Border.self_modulate = color_lighter
