extends Sprite

var character
var selected

func change_character(p_char):
	character = p_char
	$Portrait.frames = character.get_css()

func set_selected(p_selected):
	selected = p_selected
	if selected:
		$Portrait.playing = true
		$Portrait.modulate = Color(1,1,1)
	else:
		$Portrait.playing = false
		$Portrait.frame = 0
		$Portrait.modulate = Color(.6,.6,.6)
