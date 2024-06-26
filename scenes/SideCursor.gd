extends AnimatedSprite2D

@export var is_right: bool = false

func change_color(color):
	var frames = SpriteFrames.new()
	for i in 2:
		var texture = AtlasTexture.new()
		texture.set_atlas(load( "res://graphics/colors/" + color + "/pointer.png"))
		texture.region = Rect2(8 - i * 8, 0, 8, 8)
		frames.add_frame("default", texture)
		frames.set_animation_speed("default", 30)
		frames.set_animation_loop("default", false)
