extends Resource

@export var character_name: String
@export var character_identifier: String
@export var trash_color: Color
@export var order: int
@export var do_tongue: bool
@export var frames_default: int
@export var frames_attack: int
@export var frames_jump: int
@export var frames_loss: int
@export var frames_sad: int

func get_portrait():
	var file_location = "res://graphics/characters/" + character_identifier + "/portrait.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_portrait()
	return load(file_location)

func get_face():
	var file_location = "res://graphics/characters/" + character_identifier + "/face.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_face()
	return load(file_location)

func get_particle():
	var file_location = "res://graphics/characters/" + character_identifier + "/particle.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_particle()
	return load(file_location)

func get_trash():
	var file_location = "res://graphics/characters/" + character_identifier + "/trash.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_trash()
	return load(file_location)

func get_frames():
	var file_location = "res://graphics/characters/" + character_identifier + "/main.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_frames()
	
	var frames = SpriteFrames.new()
	var current_animation = "default"
	frames.add_animation("attack")
	frames.add_animation("jump")
	frames.add_animation("loss")
	frames.add_animation("sad")
	frames.set_animation_speed("attack", frames_attack * 2)
	frames.set_animation_loop("attack", false)
	
	var e = 0
	for i in range(0, frames_default + frames_attack + frames_jump + frames_loss + frames_sad):
		var texture = AtlasTexture.new()
		texture.set_atlas(load(file_location))
		texture.region = Rect2(i * 64, 0, 64, 64)
		if current_animation == "default" and e > frames_default - 1:
			current_animation = "attack"
			e = 0
		if current_animation == "attack" and e > frames_attack - 1:
			current_animation = "jump"
			e = 0
		if current_animation == "jump" and e > frames_jump - 1:
			current_animation = "loss"
			e = 0
		if current_animation == "loss" and e > frames_loss - 1:
			current_animation = "sad"
			e = 0
		frames.add_frame(current_animation, texture)
		e += 1
	return frames

func get_css():
	var file_location = "res://graphics/characters/" + character_identifier + "/css.png"
#	var directory = Directory.new();
#	if not directory.file_exists(file_location):
#		return load("res://graphics/characters/default/data.tres").get_css()
	
	var frames = SpriteFrames.new()
	var size_x = load(file_location).get_size().x
	size_x /= 32
	
	for i in (size_x * 2 - 1):
		var texture = AtlasTexture.new()
		texture.set_atlas(load(file_location))
		if i < size_x:
			texture.region = Rect2(i * 32, 0, 32, 32)
		else:
			texture.region = Rect2((size_x * 2 - 1 - i) * 32, 0, 32, 32)
		frames.add_frame("default", texture)
	return frames
