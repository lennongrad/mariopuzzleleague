extends Control

var seed_to_use
var player_one
var player_two

func _ready():
	start({"difficulty": enums.DIFFICULTY.EASY, "ai": false}, {"difficulty": enums.DIFFICULTY.HARD, "ai": true})

func start(player_one_data, player_two_data):
	randomize()
	seed_to_use = randi()
	player_one = player_one_data
	player_two = player_two_data
	$Board1.start(seed_to_use, player_one_data, true)
	$Board2.start(seed_to_use, player_two_data, true)

func _physics_process(delta):
	$Score/VBoxContainer/SpeedLevel/Value.text = str(floor($Board2.speed))
	$Score/VBoxContainer/Score/Value.text = str(floor($Board1.score))

func _process(_delta):
	$Label.text = str(Engine.get_frames_per_second()) + "fps"
