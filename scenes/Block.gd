extends AnimatedSprite2D

var p = Vector2(0,0)
var type : set = change_type
var size = Vector2(1, 1): set = change_size
var character
var opponent

var has_thudded = false

var destination_p = Vector2(0,0)
var current_p = Vector2(0,0)

@onready var particles = [$BR, $BL, $TL, $TR]

const is_block = true

var block_graphics
var trash_graphics
var tiny_trash

var wobble_timer = 0
var last_p = Vector2(0,0)
var drop_timer = 0
var last_fell = 0
var fell_from_match = false
var preview = false
var lost = false
var loss_timer = 0
var going_to_lose = true

var popping_timer = -1
var matching_timer = -1

var removed = false

var mod = Color(1,1,1)

func _ready():
	if type == null:
		type = enums.BLOCKTYPE.RED
	for particle in particles:
		particle.texture = character.get_particle()

func change_size(p_size):
	size = p_size

func change_type(p_type):
	type = p_type
	if type == enums.BLOCKTYPE.TRASH:
		var zframes = SpriteFrames.new()
		zframes.add_animation("a")
		zframes.add_frame("a", trash_graphics[size])
		sprite_frames = zframes
		play("a")
		self_modulate = opponent.trash_color
		self_modulate.v += .3
		$Face.texture =  opponent.get_face()
		$Face.visible = true
	else:
		sprite_frames = block_graphics[type]
		$Face.visible = false
	$Trash.texture = trash_graphics[Vector2(1,1)]
	if opponent != null:
		$Trash.self_modulate = opponent.trash_color

func drop():
	drop_timer += 1
	if drop_timer > 15:
		p.y += 1

func on_bottom(timer):
	if drop_timer > 0:
		set_wobble()
		if not has_thudded:
			if type == enums.BLOCKTYPE.TRASH:
				$Thud.play()
			else:
				$Minithud.play()
			has_thudded = true
		last_fell = 5
	drop_timer = timer
	if last_fell > 0:
		last_fell -= 1
	elif timer == 0:
		fell_from_match = true

func set_wobble():
	if wobble_timer <= 0:
		wobble_timer = 16

# dealing with matches
func set_match(time):
	matching_timer = time

func update_match():
	if matching_timer > 1:
		matching_timer -= 1
		return true
	return false

func can_match():
	return not (
		type == enums.BLOCKTYPE.TRASH or
		popping_timer > 0 or
		matching_timer > 0 or
		drop_timer > 0
	)

func pop(time):
	popping_timer = time

func update_popping():
	popping_timer -= 1
	if popping_timer <= 0:
		popping_timer = 0
		return true
	return false

func remove():
	removed = true
	queue_free()

func lose():
	lost = true
	if not type == enums.BLOCKTYPE.TRASH:
		play("shock")

func _process(_delta):
	last_p = p
	
	current_p += (destination_p - current_p) * .45
	position.x = round(current_p.x)
	position.y = round(current_p.y)
	
	if popping_timer > 20:
		visible = false
	if popping_timer > 14:
		visible = true
		$Trash.visible = true
		$Face.visible = false
	elif popping_timer == 14:
		$Trash.visible = false
		for particle in particles:
			particle.play()
	elif lost:
		frame = 1
		
		loss_timer += 1
		if loss_timer > 50:
			$Face.visible = false
			$Dark.modulate.a += (1 - $Dark.modulate.a) * .1
			if type == enums.BLOCKTYPE.TRASH:
				self_modulate.v -= self_modulate.v * .25
		if loss_timer > 125:
			scale.y -= scale.y * .1
		if loss_timer > 150:
			visible = false
	elif preview:
		play("preview")
	elif matching_timer != -1:
		play("shock")
		$Face.visible = false
		if matching_timer < 60:
			frame = 1
		else:
			frame = 0
			if matching_timer % 16 < 8:
				modulate.a = .8
			else:
				modulate.a = 1
		if matching_timer == 35 and type != enums.BLOCKTYPE.TRASH:
			self_modulate.a = 0
			for particle in particles:
				particle.play()
	elif wobble_timer > 0 and type != enums.BLOCKTYPE.TRASH:
		if going_to_lose:
			wobble_timer -= .25
		else:
			wobble_timer -= 1
		play("jump")
		frame = 4 - abs(floor(float(wobble_timer) / 2) - 4)
	elif type != enums.BLOCKTYPE.TRASH:
		play("default")
		modulate.a += (1 - modulate.a) * .1
		$Trash.visible = false
	
	name = str(p.x) + "_" + str(p.y)
