extends Control

signal go_back()
signal done(p1_data, p2_data)
var player1_data = {"ai": 0, "colors": -1} 
var player2_data = {"colors": -1}
var is_ai
onready var current_menu = $CharacterSelect

var colors = ["red", "green", "pink", "blue"]

var done_timer = -1

func _ready():
	color_change1()
	color_change2()
	$CharacterSelect.start()

func start(ai_level):
	player2_data["ai"] = ai_level
	if ai_level > 0:
		is_ai = true

func tick(p1_input, p2_input):
	current_menu.tick(p1_input, p2_input, is_ai)
	if p1_input.x:
		color_change1()
	if p2_input.x:
		color_change2()

func color_change1():
	player1_data.colors = (player1_data.colors + 1) % 4
	while player1_data.colors == player2_data.colors:
		player1_data.colors = (player1_data.colors + 1) % 4
	$CharacterSelect.color_change1(colors[player1_data.colors])
	$Stats.color_change1(colors[player1_data.colors])

func color_change2():
	player2_data.colors = (player2_data.colors + 1) % 4
	while player1_data.colors == player2_data.colors:
		player2_data.colors = (player2_data.colors + 1) % 4
	$CharacterSelect.color_change2(colors[player2_data.colors])
	$Stats.color_change2(colors[player2_data.colors])

func _on_CharacterSelect_done(character1, character2):
	player1_data["character"] = character1.data
	player2_data["character"]  = character2.data
	current_menu = $Stats
	$Stats.start(is_ai)

func _on_Stats_go_back():
	current_menu = $CharacterSelect
	$CharacterSelect.start()

func _on_Stats_done(p1_speed, p2_speed, p1_difficulty, p2_difficulty):
	player1_data["speed"] = p1_speed
	player2_data["speed"] = p2_speed
	player1_data["difficulty"] = p1_difficulty
	player2_data["difficulty"] = p2_difficulty
	player1_data["colors"] = colors[player1_data["colors"]]
	player2_data["colors"] = colors[player2_data["colors"]]
	emit_signal("done", player1_data, player2_data)
	done_timer = 0

func _process(_delta):
	if done_timer != -1:
		done_timer += 1
		if done_timer == 100:
			queue_free()
