extends Control

signal go_back()
signal done(p1_speed, p2_speed, p1_difficulty, p2_difficulty)

var ai = true
var p1_level = 0
var p2_level = 0
var is_done = false
var p1_difficulty = enums.DIFFICULTY.EASY
var p2_difficulty = enums.DIFFICULTY.EASY

func color_change1(color):
	$Player1.color_change(color)

func color_change2(color):
	pass
	$Player2.color_change(color)

func start(is_ai):
	ai = is_ai
	$Player1.start()
	if not is_ai:
		$Player2.start()

func tick(p1, p2, _ai):
	if not ai:
		$Player1.tick(p1)
		$Player2.tick(p2)
	else:
		if not $Player1.is_done():
			$Player1.tick(p1)
		else:
			if $Player2.is_inactive():
				$Player2.start()
			$Player2.tick(p1)
	if $Player1.is_inactive() and $Player2.is_inactive():
		emit_signal("go_back")
	if $Player1.is_done() and $Player2.is_done() and not is_done:
		is_done = true
		emit_signal("done", $Player1.level, $Player2.level, $Player1.difficulty, $Player2.difficulty)

func _on_Player2_go_back():
	if ai:
		$Player1.start()
