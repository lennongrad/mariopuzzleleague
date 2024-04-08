extends AnimatedSprite2D

@export var cursor_number: int = 1

func color_change(color):
	var frames = SpriteFrames.new()
	
	for i in 2:
		var texture = AtlasTexture.new()
		texture.set_atlas(load("res://graphics/colors/" + color + "/" + str(cursor_number) + "p_select.png"))
		texture.region = Rect2(i * 36, 0, 36, 36)
		frames.add_frame("default", texture)
