extends Control

var seed_to_use
var player_one

func _ready():
	start({"difficulty": enums.DIFFICULTY.EASY, "ai": false})

func start(player_one_data):
	randomize()
	seed_to_use = randi()
	player_one = player_one_data
	$Board.start(seed_to_use, player_one_data, true)

func _physics_process(delta):
	$Score/VBoxContainer/SpeedLevel/Value.text = str(floor($Board.speed))
	$Score/VBoxContainer/Score/Value.text = str(floor($Board.score))

func _process(_delta):
	$Label.text = str(Engine.get_frames_per_second()) + "fps"
