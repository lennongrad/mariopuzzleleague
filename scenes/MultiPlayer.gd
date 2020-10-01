extends Control

const color_choices = ["red", "green", "blue", "pink"]

var stage
var color_set = [null, null]

var seed_to_use
var player_one
var player_two

var board1_trash_waiting = 0
var board1_trash_list = []
var board2_trash_waiting = 0
var board2_trash_list = []
var trash_timer = 0

var time = 0.0

func _ready():
	randomize()
	color_set[0] = color_choices[randi() % color_choices.size()]
	while color_set[1] == null or color_set[0] == color_set[1]:
		color_set[1] = color_choices[randi() % color_choices.size()]
	start({"difficulty": enums.DIFFICULTY.EASY, "ai": 0, 
			"character": load("res://graphics/characters/bowser/data.tres"), 
			"colors": color_set[0], "speed": 1}, 
		{"difficulty": enums.DIFFICULTY.EASY, "ai": 9, 
			"character": load("res://graphics/characters/seren/data.tres"), 
			"colors": color_set[1], "speed": 1})

func start(player_one_data, player_two_data):
	seed_to_use = randi()
	player_one = player_one_data
	player_two = player_two_data
	$Board1.start(seed_to_use, player_one_data, 1, true, player_two_data)
	$Board2.start(seed_to_use, player_two_data, 2, true, player_one_data)
	
	var _err = $Board1.connect("has_won", $Board2, "lose_game")
	_err = $Board1.connect("has_lost", $Board2, "win_game")
	_err = $Board2.connect("has_won", $Board1, "lose_game")
	_err = $Board2.connect("has_lost", $Board1, "win_game")
	
	$Frame/Character1.change_character(player_one_data["character"])
	$Frame/Character2.change_character(player_two_data["character"])
	
	$Frame/Score1.font = player_one_data["colors"]
	$Frame/Score2.font = player_two_data["colors"]
	$Frame/Level1.font = player_one_data["colors"]
	$Frame/Level2.font = player_two_data["colors"]
	$ItemFrame1.texture = load("res://graphics/colors/" + player_one_data["colors"] + "/itemframe.png")
	$ItemFrame2.texture = load("res://graphics/colors/" + player_two_data["colors"] + "/itemframe.png")
	$Frame/TrashPreview1.color =  player_one_data["colors"]
	$Frame/TrashPreview2.color =  player_two_data["colors"]
	$Frame/TrashPreview1.character =  player_one_data["character"]
	$Frame/TrashPreview2.character =  player_two_data["character"]
	$ItemFrame1.character =  player_one_data["character"]
	$ItemFrame2.character =  player_two_data["character"]
	$Frame.texture = load("res://graphics/colors/" + player_one_data["colors"] + "/leftframe.png")
	$Frame/RightFrame.texture = load("res://graphics/colors/" + player_two_data["colors"] + "/rightframe.png")

func set_stage(p_stage):
	stage = p_stage
	

func _physics_process(_delta):
	if $Board1.has_started and not ($Board1.has_won or $Board1.has_lost):
		time += (1.0 / 60)
	$Frame/Time.text = str(int(floor(time / 60))).pad_zeros(2) + "'" + str(int(time) % 60).pad_zeros(2)
	
	if $Board1.has_won:
		$Frame/Character1.win()
	if $Board1.has_lost:
		$Frame/Character1.loss()
	if $Board2.has_won:
		$Frame/Character2.win()
	if $Board2.has_lost:
		$Frame/Character2.loss()
	
	trash_timer += 1
	if board2_trash_waiting == 0 and trash_timer % 60 == 0:
		if board2_trash_list.size() == 0:
			board2_trash_waiting = -1
		else:
			$Board2.drop_trash(board2_trash_list[0])
			board2_trash_list.remove(0)
			$Frame/TrashPreview2.shown = board2_trash_list.size() - board2_trash_waiting
		$Frame/TrashPreview2.blocks = board2_trash_list
	if board1_trash_waiting == 0 and trash_timer % 60 == 0:
		if board1_trash_list.size() == 0:
			board1_trash_waiting = -1
		else:
			$Board1.drop_trash(board1_trash_list[0])
			board1_trash_list.remove(0)
			$Frame/TrashPreview1.shown = board1_trash_list.size() - board1_trash_waiting
		$Frame/TrashPreview1.blocks = board1_trash_list

func _process(_delta):
	$Label.text = str(Engine.get_frames_per_second()) + "fps"
	$Frame/Score1.text = str($Board1.score).pad_zeros(4)
	$Frame/Score2.text = str($Board2.score).pad_zeros(4)
	$Frame/Level1.text = str(int($Board1.get_speed())).pad_zeros(2)
	$Frame/Level2.text = str(int($Board2.get_speed())).pad_zeros(2)
	
	if $Board1.ghost_timer > 0:
		$BlackWhite1.modulate.a += (1 - $BlackWhite1.modulate.a) * .1
	else:
		$BlackWhite1.modulate.a -= $BlackWhite1.modulate.a * .1
	
	if $Board2.ghost_timer > 0:
		$BlackWhite2.modulate.a += (1 - $BlackWhite2.modulate.a) * .1
	else:
		$BlackWhite2.modulate.a -= $BlackWhite2.modulate.a * .1
	
	$Board1.other_player_has_star = $Board2.star_timer > 0
	$Board2.other_player_has_star = $Board1.star_timer > 0
	if $Board1.star_timer > 0:
		$Frame.material.set_shader_param("active", true)
	else:
		$Frame.material.set_shader_param("active", false)
	if $Board2.star_timer > 0:
		$Frame/RightFrame.material.set_shader_param("active", true)
	else:
		$Frame/RightFrame.material.set_shader_param("active", false)

func _on_Board1_spawn_trash(combo, _chain, p):
	var trash = load("res://scenes/TrashMessage.tscn").instance()
	trash.position = p
	trash.character = $Board1.data["character"]
	if board2_trash_waiting == -1:
		board2_trash_waiting = 1
	else:
		board2_trash_waiting += 1
	board2_trash_list.append(combo - 3)
	$Frame/Character1.attack()
	$Frame/TrashPreview2.blocks = board2_trash_list
	$Frame/TrashPreview2.shown = board2_trash_list.size() - board2_trash_waiting
	trash.connect("done_travelling", self, "remove_Board2_trash")
	trash.target = $Frame/TrashPreview2.last_pos() - Vector2(7, 0)
	add_child(trash)

func _on_Board2_spawn_trash(combo, _chain, p): 
	var trash = load("res://scenes/TrashMessage.tscn").instance()
	trash.position = p
	trash.character = $Board2.data["character"] 
	if board1_trash_waiting == -1:
		board1_trash_waiting = 1
	else:
		board1_trash_waiting += 1
	board1_trash_list.append(combo - 3)
	$Frame/Character2.attack()
	$Frame/TrashPreview1.blocks = board1_trash_list
	$Frame/TrashPreview1.shown = board1_trash_list.size() - board1_trash_waiting
	trash.connect("done_travelling", self, "remove_Board1_trash")
	trash.target = $Frame/TrashPreview1.last_pos() - Vector2(7, 0)
	add_child(trash)

func remove_Board1_trash():
	board1_trash_waiting -= 1
	$Frame/TrashPreview1.shown = board1_trash_list.size() - board1_trash_waiting

func remove_Board2_trash():
	board2_trash_waiting -= 1
	$Frame/TrashPreview2.shown = board2_trash_list.size() - board2_trash_waiting

func _on_Board1_use_item():
	if used_item($Board1, $Board2, $ItemFrame1.use_item()):
		$Frame/Character1.attack()

func _on_Board1_won_item():
	won_item($ItemFrame1)

func _on_Board2_use_item():
	if used_item($Board2, $Board1, $ItemFrame2.use_item()):
		$Frame/Character2.attack()

func _on_Board2_won_item():
	won_item($ItemFrame2)

func used_item(user, target, item):
	match item:
		enums.ITEMS.STAR: 
			user.start_star(); 
			return true;
		enums.ITEMS.BOO: 
			target.start_ghost(); 
			return true;
		enums.ITEMS.COIN: 
			user.increase_score(50); 
			return true;
	return false

func won_item(target):
	target.start([enums.ITEMS.BOO, enums.ITEMS.COIN, enums.ITEMS.STAR, enums.ITEMS.COIN])
