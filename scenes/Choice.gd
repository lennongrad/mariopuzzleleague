extends TextureRect

func _ready():
	set_active(false)

func set_active(is_active):
	$AnimatedSprite.visible = is_active

func set_text(string):
	$Label.text = string

func set_text_color(color):
	$Label.add_color_override("font_color", color)

func set_color(color):
	$Label.add_color_override("font_color", color)
	var color_lighter = color
	color_lighter.v = min(1, color.v + .6)
	$Border.self_modulate = color_lighter
