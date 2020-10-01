extends Particles2D

var timer = 0

func ready():
	emitting = false

func play(v):
	timer = v

func _process(_delta):
	if timer > 0:
		timer -= 1
		emitting = true
	else:
		emitting = false
