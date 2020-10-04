extends TextureRect

onready var current_target = null
var change_timer = -1
var target_color = null

func _ready():
	randomize()
	start_main_menu()
	$MainMenu.start(true)

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
	if target_color != null:
		self_modulate += (target_color - self_modulate) * .1
	if change_timer != -1:
		change_timer -= 1
		if change_timer > 100:
			$Black.color.v -= $Black.color.v * .1
		elif change_timer == 100:
			if current_target != null:
				current_target.visible = true
				if current_target.name == "MainMenu":
					current_target.start(true)
			else:
				change_timer += 1
		else:
			$Black.color.v += (1 - $Black.color.v) * .1

func start_main_menu():
	current_target = load("res://scenes/MainMenu.tscn").instance()
	add_child(current_target)
	target_color = Color(0.294118, 0.847059, 0.921569)
	current_target.connect("goto_twoplayer", self, "_on_MainMenu_to2p")
	current_target.connect("goto_oneplayer", self, "_on_MainMenu_to1p")

func start_main_menu_begin():
	start_main_menu()
	current_target.start(false)

func start_css(cpu_level, multi):
	current_target = load("res://scenes/CSS.tscn").instance()
	add_child(current_target)
	current_target.start(cpu_level, multi)
	target_color = Color(0.921569, 0.827451, 0.294118)
	current_target.connect("go_back", self, "start_main_menu_begin")
	current_target.connect("done_multi", self, "_on_CSS_done_multi")
	current_target.connect("done_single", self, "_on_CSS_done_single")

func _on_CSS_done_multi(p1_data, p2_data):
	current_target = load("res://scenes/MultiPlayer.tscn").instance()
	add_child(current_target)
	current_target.start(p1_data, p2_data)
	current_target.visible = false
	change_timer = 200
	current_target.connect("rematch", self, "_on_CSS_done_multi")
	current_target.connect("return_to_menu", self, "return_to_main")

func _on_CSS_done_single(p1_data):
	current_target = load("res://scenes/SinglePlayer.tscn").instance()
	add_child(current_target)
	current_target.start(p1_data)
	current_target.visible = false
	change_timer = 200
	current_target.connect("rematch", self, "_on_CSS_done_single")
	current_target.connect("return_to_menu", self, "return_to_main")

func _on_MainMenu_to2p(cpu_level):
	start_css(cpu_level, true)

func _on_MainMenu_to1p(timed):
	if timed:
		start_css(1, false)
	else:
		start_css(0, false)

func return_to_main():
	start_main_menu()
	change_timer = 200
	current_target.visible = false
