extends Control

signal go_back()
signal done(p1_speed, p2_speed, p1_difficulty, p2_difficulty)

var is_timed = false
var p1_level = 0
var done = false
var p1_difficulty = enums.DIFFICULTY.EASY

func color_change1(color):
	$Player_Time.color_change(color)

func start():
	$Player_Time.start()

func set_timed(timed):
	is_timed = timed
	$Player_Time.set_timed(timed)

func tick(p1, p2, _ai):
	if not $Player_Time.is_done():
		$Player_Time.tick(p1)
	if $Player_Time.is_inactive():
		emit_signal("go_back")
	if $Player_Time.is_done() and not done:
		done = true
		emit_signal("done", $Player_Time.level, $Player_Time.difficulty, $Player_Time.time)
