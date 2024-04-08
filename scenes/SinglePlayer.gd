extends Control

@export var debug: bool = false

signal rematch(p1)
signal return_to_menu()
signal ping()
signal play_music(music)

const color_choices = ["red", "green", "blue", "pink"]
var stage
var color_set = [null, null]
var seed_to_use
var player_one
var done_timer = -1
var high_score

var time = 0.0
var count_down = false

func _ready():
	randomize()
	$Board.connect("play_music", Callable(self, "do_play_music"))
	color_set[0] = color_choices[randi() % color_choices.size()]
	while color_set[1] == null or color_set[0] == color_set[1]:
		color_set[1] = color_choices[randi() % color_choices.size()]
	high_score = 200
	if debug:
		start({"difficulty": enums.DIFFICULTY.EASY, "ai": 0, 
				"character": load("res://graphics/characters/bowser/data.tres"), 
				"colors": color_set[0], "speed": 1}, {})

func do_play_music(music):
	emit_signal("play_music", music)

func start(player_one_data, save_data):
	seed_to_use = randi()
	player_one = player_one_data
	$Board.start(seed_to_use, player_one_data, 1, false, null)
	
	if player_one_data.has("time"):
		time = player_one_data["time"]
		count_down = true
	else:
		player_one_data["time"] = 0
	#if not save_data.high_scores.has(str(player_one["time"])):
	#	save_data.high_scores[str(player_one["time"])] = str(0)
	
	$Frame/Score.font = player_one_data["colors"]
	$Frame/HighScore.font = player_one_data["colors"]
	$Frame/Level.font = player_one_data["colors"]
	
	match player_one_data.difficulty:
		enums.DIFFICULTY.EASY:
			$Frame/Difficulty.texture = load("res://graphics/easy.png")
		enums.DIFFICULTY.MEDIUM:
			$Frame/Difficulty.texture = load("res://graphics/normal.png")
		enums.DIFFICULTY.HARD:
			$Frame/Difficulty.texture = load("res://graphics/hard.png")

func set_stage(p_stage):
	stage = p_stage

func do_rematch():
	emit_signal("rematch", player_one)
	done_timer = 0
 
func do_return_to_menu():
	emit_signal("return_to_menu")
	done_timer = 0

func tick(p1, _p2, save_data):
	if $Board.has_stopped:
		if p1.a: do_rematch()
		if p1.b: do_return_to_menu()
	
	#if $Board.score > int(save_data.high_scores[str(player_one["time"])]):
		#$Frame/HighScore.text = str($Board.score).pad_zeros(4)
		#save_data.high_scores[str(player_one["time"])] = str($Board.score)
	
	if $Board.has_started and not ($Board.is_has_won or $Board.is_has_lost):
		if count_down:
			time -= (1.0 / 60)
			if time < 0:
				time = 0
				if false:# $Board.score > int(save_data.high_scores[str(player_one["time"])]):
					$Board.announce_win()
				else:
					$Board.announce_loss()
		else:
			time += (1.0 / 60)
	$Frame/Time.text = str(int(floor(time / 60))).pad_zeros(2) + "'" + str(int(time) % 60).pad_zeros(2)
	#$Frame/HighScore.text = save_data.high_scores[str(player_one["time"])].pad_zeros(4)
	
	$Board.tick(p1)
	
	return save_data

var has_begun = false
func _process(_delta):
	if $Board.has_started and not has_begun:
		do_play_music("athletic")
		has_begun = true
	$Frame/Score.text = str($Board.score).pad_zeros(4)
	$Frame/Level.text = str(int($Board.get_velocity())).pad_zeros(2)
	
	if done_timer != -1:
		done_timer += 1
		if done_timer > 100:
			queue_free()
