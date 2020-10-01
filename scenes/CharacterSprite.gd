extends Node2D

onready var sprite = $AnimatedSprite

var win_timer = -1
var pause_timer = 0
var loss_timer = -1
var attack_timer = -1

var do_tongue = false

func change_character(character):
	sprite.frames = character.get_frames()
	do_tongue = character.do_tongue
	sprite.play("default")

func win():
	if win_timer == -1:
		win_timer = 0

func loss():
	if loss_timer == -1:
		loss_timer = 0
		sprite.play("loss")

func attack():
	if attack_timer == -1:
		attack_timer = 0
		sprite.play("attack")

func _process(_delta):
	if attack_timer != -1:
		attack_timer += 1
		if attack_timer > 15:
			$Tongue.visible = do_tongue
			$Tongue.position.x = min(15, (attack_timer - 15) * 3)
		if attack_timer == 45:
			attack_timer = -1
			sprite.play("default")
			$Tongue.visible = false
	
	if win_timer != -1:
		pause_timer -= 1
		if pause_timer < 0:
			win_timer += 1
		sprite.position.y = -20 * pow(abs(sin(float(win_timer) * .025 * PI)), .85)
		if sprite.position.y > -.1:
			if pause_timer < 0:
				sprite.position.y = 0
				sprite.play("default")
				sprite.playing = false
				pause_timer = 8
		else:
			sprite.play("jump")
	
	if loss_timer != -1:
		loss_timer += 1
		if loss_timer == 300:
			sprite.play("sad")
