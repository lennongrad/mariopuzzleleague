extends TextureRect

onready var current_target = $CSS
var change_timer = -1

func _ready():
	$CSS.start(1)

func _physics_process(_delta):
	var player_one_input = {
		"left": Input.is_action_pressed("p1_left"),
		"right": Input.is_action_pressed("p1_right"),
		"up": Input.is_action_pressed("p1_up"),
		"down": Input.is_action_pressed("p1_down"),
		"just_left": Input.is_action_just_pressed("p1_left"),
		"just_right": Input.is_action_just_pressed("p1_right"),
		"just_up": Input.is_action_just_pressed("p1_up"),
		"just_down": Input.is_action_just_pressed("p1_down"),
		"a": Input.is_action_just_pressed("p1_a"),
		"b": Input.is_action_just_pressed("p1_b"),
		"x": Input.is_action_just_pressed("p1_x"),
		"y": Input.is_action_just_pressed("p1_y")
	}
	var player_two_input = {
		"left": Input.is_action_pressed("p2_left"),
		"right": Input.is_action_pressed("p2_right"),
		"up": Input.is_action_pressed("p2_up"),
		"down": Input.is_action_pressed("p2_down"),
		"just_left": Input.is_action_just_pressed("p2_left"),
		"just_right": Input.is_action_just_pressed("p2_right"),
		"just_up": Input.is_action_just_pressed("p2_up"),
		"just_down": Input.is_action_just_pressed("p2_down"),
		"a": Input.is_action_just_pressed("p2_a"),
		"b": Input.is_action_just_pressed("p2_b"),
		"x": Input.is_action_just_pressed("p2_x"),
		"y": Input.is_action_just_pressed("p2_y")
	}
	
	if current_target != null:
		current_target.tick(player_one_input, player_two_input)

func _process(_delta):
	if change_timer != -1:
		change_timer -= 1
		if change_timer > 100:
			$Black.color.v -= $Black.color.v * .1
		elif change_timer == 100:
			current_target.visible = true
		else:
			$Black.color.v += (1 - $Black.color.v) * .1

func _on_CSS_done(p1_data, p2_data):
	current_target = null
	current_target = load("res://scenes/MultiPlayer.tscn").instance()
	add_child(current_target)
	current_target.start(p1_data, p2_data)
	current_target.visible = false
	change_timer = 200
