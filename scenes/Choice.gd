extends TextureRect

var show_count = false
var current_count = 1

func _ready():
	$Count.visible = show_count
	if show_count:
		$Label.align = HALIGN_LEFT
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
	$AnimatedSprite.visible = is_active

func set_text(string):
	$Label.text = string
	if show_count:
		$Label.text = " " + $Label.text

func set_text_color(color):
	$Label.add_color_override("font_color", color)
	$Count/Label.add_color_override("font_color", color)

func set_color(color):
	$Label.add_color_override("font_color", color)
	$Count/Label.add_color_override("font_color", color)
	var color_lighter = color
	color_lighter.v = min(1, color.v + .6)
	$Border.self_modulate = color_lighter
