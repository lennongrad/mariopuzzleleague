extends Control

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
	start({"difficulty": enums.DIFFICULTY.EASY, "ai": false, "character": "lip"}, 
		{"difficulty": enums.DIFFICULTY.EASY, "ai": true, "character": "seren"})

func start(player_one_data, player_two_data):
	randomize()
	seed_to_use = randi()
	player_one = player_one_data
	player_two = player_two_data
	$Board1.start(seed_to_use, player_one_data, 1, true)
	$Board2.start(seed_to_use, player_two_data, 2, true)
	
	$Board1.connect("has_won", $Board2, "lose_game")
	$Board1.connect("has_lost", $Board2, "win_game")
	$Board2.connect("has_won", $Board1, "lose_game")
	$Board2.connect("has_lost", $Board1, "win_game")

func _physics_process(_delta):
	time += (1.0 / 60)
	$Frame/Time.text = str(floor(time / 60)).pad_zeros(2) + "'" + str(int(time) % 60).pad_zeros(2)
	
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

func _on_Board1_spawn_trash(combo, chain, p):
	var trash = load("TrashMessage.tscn").instance()
	trash.position = p
	if board2_trash_waiting == -1:
		board2_trash_waiting = 1
	else:
		board2_trash_waiting += 1
	board2_trash_list.append(combo - 3)
	$Frame/TrashPreview2.blocks = board2_trash_list
	$Frame/TrashPreview2.shown = board2_trash_list.size() - board2_trash_waiting
	trash.connect("done_travelling", self, "remove_Board2_trash")
	trash.target = $Frame/TrashPreview2.last_pos() - Vector2(7, 0)
	add_child(trash)

func _on_Board2_spawn_trash(combo, chain, p): 
	var trash = load("TrashMessage.tscn").instance()
	trash.position = p
	if board1_trash_waiting == -1:
		board1_trash_waiting = 1
	else:
		board1_trash_waiting += 1
	board1_trash_list.append(combo - 3)
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

