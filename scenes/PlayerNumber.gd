extends NinePatchRect

#export(NodePath) var left_input
#export(NodePath) var down_input
#export(NodePath) var right_input
#export(NodePath) var up_input

var current_player_is_1 = true

func toggle():
	current_player_is_1 = not current_player_is_1
	if current_player_is_1:
		$Label.text = "Player 1"
	else:
		$Label.text = "Player 2"
	return current_player_is_1
