extends Control

signal go_back()
signal done_multi(p1_data, p2_data)
signal done_single(p1_data)
signal ping()
var player1_data = {"ai": 0, "colors": -1} 
var player2_data = {"colors": -1}
var is_ai = false
var is_multi
onready var current_menu = $CharacterSelect

var colors = ["red", "green", "pink", "blue"]

var done_timer = -1
var return_timer = -1

func _ready():
	modulate.a = 0
	color_change1()
	color_change2()

func start(ai_level, multi):
	player2_data["ai"] = ai_level
	if ai_level > 0:
		is_ai = true
	is_multi = multi
	if is_multi:
		$Stats.visible = true
		$Stats_Single.visible = false
	else:
		$Stats.visible = false
		$Stats_Single.visible = true
		$Stats_Single.set_timed(is_ai)
	$CharacterSelect.start(is_multi)

func tick(p1_input, p2_input, save_data):
	current_menu.tick(p1_input, p2_input, is_ai)
	
	var has_pinged = false
	for input in p1_input.keys() + p2_input.keys():
		var do_ping = true
		if has_pinged: 
			do_ping = false
		match input:
			"left": do_ping = false
			"right": do_ping = false
			"up": do_ping = false
			"down": do_ping = false
		if do_ping and (p1_input[input] or p2_input[input]):
			emit_signal("ping")
			has_pinged = true
	if p1_input.x:
		emit_signal("ping")
		color_change1()
	if p2_input.x:
		emit_signal("ping")
		color_change2()
	return save_data

func color_change1():
	player1_data.colors = (player1_data.colors + 1) % 4
	while player1_data.colors == player2_data.colors:
		player1_data.colors = (player1_data.colors + 1) % 4
	$CharacterSelect.color_change1(colors[player1_data.colors])
	$Stats.color_change1(colors[player1_data.colors])
	$Stats_Single.color_change1(colors[player1_data.colors])

func color_change2():
	player2_data.colors = (player2_data.colors + 1) % 4
	while player1_data.colors == player2_data.colors:
		player2_data.colors = (player2_data.colors + 1) % 4
	$CharacterSelect.color_change2(colors[player2_data.colors])
	$Stats.color_change2(colors[player2_data.colors])

func _on_CharacterSelect_go_back():
	emit_signal("go_back", false)
	return_timer = 0

func _on_CharacterSelect_done(character1, character2):
	player1_data["character"] = character1.data
	player2_data["character"]  = character2.data
	
	if is_multi:
		current_menu = $Stats
		$Stats.start(is_ai)
	else:
		current_menu = $Stats_Single
		$Stats_Single.start()

func _on_Stats_go_back():
	current_menu = $CharacterSelect
	$CharacterSelect.start(is_multi)

func _on_Stats_done(p1_speed, p2_speed, p1_difficulty, p2_difficulty):
	player1_data["speed"] = p1_speed
	player2_data["speed"] = p2_speed
	player1_data["difficulty"] = p1_difficulty
	player2_data["difficulty"] = p2_difficulty
	player1_data["colors"] = colors[player1_data["colors"]]
	player2_data["colors"] = colors[player2_data["colors"]]
	emit_signal("done_multi", player1_data, player2_data)
	done_timer = 0

func _on_Stats_Single_done(p1_speed, p1_difficulty, p1_time):
	player1_data["speed"] = p1_speed
	player1_data["difficulty"] = p1_difficulty
	player1_data["time"] = p1_time
	player1_data["colors"] = colors[player1_data["colors"]]
	emit_signal("done_single", player1_data)
	done_timer = 0

func _process(_delta):
	if done_timer != -1:
		done_timer += 1
		if done_timer == 100:
			queue_free()
	elif return_timer != -1:
		return_timer += 1
		modulate.a -= modulate.a * .1
		if return_timer > 100:
			queue_free()
	else:
		modulate.a += (1 - modulate.a) * .1
