extends Node2D

var blocks = []: set = change_blocks
var shown = 0: set = change_shown
var color = "blue"
var character

var last_position = Vector2(0,3)
var has_displayed = 0

func last_pos():
	return get_global_position() + last_position

func change_shown(p_shown):
	if has_displayed > 2:
		if p_shown < shown:
			for child in $Particles.get_children():
				child.play()
				child.texture = character.get_particle()
	else:
		has_displayed += 1
	shown = p_shown
	change_blocks(blocks)

func change_blocks(p_blocks):
	blocks = p_blocks
	for child in get_children():
		if child.name != "Particles":
			child.queue_free()
	if shown == 0:
		return
	var i = 0
	for block in blocks.slice(0, shown - 1):
		for e in range(0, block + 1):
			var sprite = Sprite2D.new()
			sprite.position.x += (i + e % 4) * 7
			sprite.position.y += floor(float(e) / 4) * 7
			sprite.texture = load("res://graphics/colors/" + color + "/trash.png")
			add_child(sprite)
			last_position.x = max(last_position.x, sprite.position.x + 3)
		if block + 1 > 3:
			last_position.x -= 14
		i += min(4, block + 1) + 1
	if has_node("Particles"):
		$Particles.position = last_position
