@tool

extends Node2D

@export var text: String = "000": set = change_text
@export var font: String = "pink"
@export var separation: int = 6: set = change_separation

const font_locations = {
	"0": 0,
	"1": 1,
	"2": 2,
	"3": 3,
	"4": 4,
	"5": 5,
	"6": 6,
	"7": 7,
	"8": 8,
	"9": 9,
	"'": 10
}

func change_separation(p_separation):
	separation = p_separation
	change_text(text)

func change_text(string):
	text = string
	for child in get_children():
		child.queue_free()
	var i = 0
	for character in string:
		var character_node = Sprite2D.new()
		character_node.texture = load("res://graphics/colors/" + font + "/font.png")
		character_node.region_enabled = true
		character_node.region_rect = Rect2(font_locations[character] * 8,0,8,14)
		character_node.position.x += i * separation
		add_child(character_node)
		i += 1
