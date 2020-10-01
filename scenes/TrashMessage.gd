extends Sprite

signal done_travelling()

onready var particles = [$BR, $BL, $TL, $TR]

var target = Vector2(160,10)
var velocity = Vector2(0,-20)
var character
var finished_timer = -1
var start_timer = 0

func _ready():
	texture = character.get_trash()
	for particle in particles:
		particle.texture = character.get_particle()
	$Path.texture = character.get_particle()

func _process(delta):
	if finished_timer == -1:
		start_timer += 1
		if start_timer > 40:
			visible = true
			var dir = target - position
			velocity += dir * delta * 4
			position += velocity * delta * .76
			if dir.length() < 20:
				position += dir * delta * 4
				velocity *= .7
			if dir.length() < 2:
				finished_timer = 0
				emit_signal("done_travelling")
				for particle in particles:
					particle.play()
	else:
		finished_timer += 1
		modulate.a -= modulate.a * .2
		if finished_timer == 80:
			queue_free()
