extends AnimatedSprite

export(String) var cursor_number = 1

func color_change(color):
	frames = SpriteFrames.new()
	
	for i in 2:
		var texture = AtlasTexture.new()
		texture.set_atlas(load("res://graphics/colors/" + color + "/" + str(cursor_number) + "p_select.png"))
		texture.region = Rect2(i * 36, 0, 36, 36)
		frames.add_frame("default", texture)
