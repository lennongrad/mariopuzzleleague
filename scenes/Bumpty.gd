extends Node2D

var velocity = Vector2(0,0)
var sliding = false
var flying = false
var gliding = false

func _ready():
	velocity.x = -.4 - (randi() % 4) * .35
	if randi() % 4 == 0:
		sliding = true
		velocity.x -= .2
		$Sprite.play("sliding")

func _process(_delta):
	if position.y < 224 and not gliding:
		velocity.y += .1
	elif not gliding:
		velocity.y = 0
		position.y = 224
	else:
		velocity.y += .05 * float(randi() % 16) / 16
	
	if gliding and position.y > 224:
		gliding = false
		$Sprite.play("default")
		position.y = 224
	
	if velocity.y > 1.5 + (randi() % 16) * .05 and flying:
		velocity.y = 0
		flying = false
		gliding = true
		$Sprite.play("glide")
	
	if flying or gliding:
		velocity.x *= 1.01
	
	if not sliding and not flying and not gliding and randi() % 400 == 0:
		$Sprite.play("flying")
		flying = true
		velocity.y = -3
	
	position += velocity
