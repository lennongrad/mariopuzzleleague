extends Sprite2D

var character
var timer = 0

func _ready():
	pass

func _process(_delta):
	timer += 1
	if timer < 50:
		scale += Vector2(1, 1) * .005
		if timer == 40:
			for particle in [$BR, $BL, $TL, $TR]:
				particle.texture = character.get_particle()
				particle.play()
	elif timer < 140:
		modulate.a -= modulate.a * .08
	else:
		queue_free()
