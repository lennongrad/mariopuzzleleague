extends AnimatedSprite

var p = Vector2(0,0)
var type setget change_type
var size = Vector2(1, 1) setget change_size

onready var particles = [$BR, $BL, $TL, $TR]

const is_block = true

var block_graphics
var trash_graphics
var tiny_trash

var wobble_timer = 0
var last_p = Vector2(0,0)
var drop_timer = 0
var last_fell = 0
var preview = false
var lost = false
var loss_timer = 0
var going_to_lose = true

var popping_timer = 0

var matching = false
var matching_timer = -1
var matching_visual_timer = 0
var matching_now = false
var match_group

var removed = false

var mod = Color(1,1,1)

func _ready():
	if type == null:
		type = enums.BLOCKTYPE.RED

func change_size(p_size):
	size = p_size

func change_type(p_type):
	type = p_type
	if type == enums.BLOCKTYPE.TRASH:
		var zframes = SpriteFrames.new()
		zframes.add_animation("a")
		zframes.add_frame("a", trash_graphics[size])
		frames = zframes
		play("a")
	else:
		frames = block_graphics[type]
	$Trash.texture = trash_graphics[Vector2(1,1)]

func drop():
	drop_timer += 1
	if drop_timer > 15:
		p.y += 1
		last_fell += 1

func on_bottom(timer):
	if drop_timer > 0:
		set_wobble()
	drop_timer = timer
	last_fell = 0

func set_wobble():
	if wobble_timer <= 0:
		wobble_timer = 16

func set_match(time, total, p_match_group):
	if matching:
		return false
	matching = true
	matching_timer = time
	matching_now = true
	match_group = p_match_group
	matching_visual_timer = matching_timer + 10 * total 
	return true

func update_match():
	matching_timer -= 1
	matching_visual_timer -= 1
	matching_now = false
	if matching_timer <= 0:
		matching_timer = 0
		return true
	return false

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
	play("shock")

func _process(_delta):
	playing = false
	last_p = p
	
	if popping_timer > 20:
		visible = false
	if popping_timer > 14:
		visible = true
		$Trash.visible = true
	elif popping_timer == 14:
		$Trash.visible = false
		for particle in particles:
			particle.play()
	elif lost:
		frame = 1
		playing = false
		loss_timer += 1
		if loss_timer > 50:
			$Dark.modulate.a += (1 - $Dark.modulate.a) * .1
	elif preview:
		play("preview")
	elif wobble_timer > 0 and type != enums.BLOCKTYPE.TRASH:
		if going_to_lose:
			wobble_timer -= .25
		else:
			wobble_timer -= 1
		play("jump")
		frame = 4 - abs(floor(float(wobble_timer) / 2) - 4)
	elif matching:
		play("shock")
		playing = false
		if matching_visual_timer < 60:
			frame = 1
		elif matching_visual_timer < 85:
			frame = 0
		if matching_visual_timer == 35 and type != enums.BLOCKTYPE.TRASH:
			self_modulate.a = 0
			for particle in particles:
				particle.play()
	else:
		play("jump")
		playing = false
		modulate.a += (1 - modulate.a) * .1
		$Trash.visible = false
	
	name = str(p.x) + "_" + str(p.y)
