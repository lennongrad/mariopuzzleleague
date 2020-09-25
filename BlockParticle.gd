tool

extends Particles2D

var test = false
var timer = 0
var test_timer = 0

func play():
	timer = 4

func _process(_delta):
	if test:
		test_timer += 1
		if test_timer > 64:
			test_timer = 0
			play()
	
	timer -= 1
	if timer > 0:
		emitting = true
	else:
		emitting = false
