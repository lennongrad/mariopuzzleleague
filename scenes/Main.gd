extends TextureRect

@onready var current_target = null
var change_timer = -1
var target_color = null
var save_data = {}

func _ready():
	randomize()
	
	#load save data
	if not FileAccess.file_exists("user://savegame.save"):
		var new_save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		new_save_game.store_line(JSON.stringify({}))
		new_save_game.close()
	
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while saved_game.get_position() < saved_game.get_length():
		var test_json_conv = JSON.new()
		test_json_conv.parse(saved_game.get_line())
		save_data = test_json_conv.get_data()
	saved_game.close()
	
	if not save_data.has("high_scores"):
		save_data["high_scores"] = {}
	
	# get input config, go to configuration screen if empty
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK and config.has_section("input"): 
		for action in InputMap.get_actions():
			if action.substr(0, 2) != "ui" and config.has_section_key("input", action) and str(config.get_value("input", action)) != "":
				var key = InputEventKey.new()
				key.set_keycode(int(config.get_value("input", action)))
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, key)
		start_main_menu()
		$MainMenu.start(true)
	else:
		for action in InputMap.get_actions():
			if action.substr(0, 2) != "ui":
				config.set_value("input", action, "")
				InputMap.action_erase_events(action)
		config.save("user://settings.cfg")
		start_control_configuration()

func save_game():
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	saved_game.store_line(JSON.stringify(save_data))
	saved_game.close()

func play_ping():
	$Ping.play()

var last_music = null
func play_music(music):
	if last_music == music:
		return
	$Music.stream = load("res://sounds/music/" + music + ".ogg")
	$Music.play()
	last_music = music

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
		"y": Input.is_action_just_pressed("p1_y"),
		"start": Input.is_action_just_pressed("p1_start")
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
		"y": Input.is_action_just_pressed("p2_y"),
		"start": Input.is_action_just_pressed("p2_start")
	}
	
	if current_target != null:
		save_data = current_target.tick(player_one_input, player_two_input, save_data)

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

func start_control_configuration():
	current_target = load("res://scenes/InputConfig.tscn").instantiate()
	add_child(current_target)
	target_color = Color(0.533333, 0.921569, 0.294118)
	current_target.connect("done", Callable(self, "start_main_menu_begin"))
	current_target.connect("ping", Callable(self, "play_ping"))

func start_main_menu():
	save_game()
	current_target = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(current_target)
	target_color = Color(0.294118, 0.847059, 0.921569)
	current_target.connect("goto_twoplayer", Callable(self, "_on_MainMenu_to2p"))
	current_target.connect("goto_oneplayer", Callable(self, "_on_MainMenu_to1p"))
	current_target.connect("goto_input", Callable(self, "_on_MainMenu_toInput"))
	current_target.connect("ping", Callable(self, "play_ping"))
	play_music("titlescreen")

func start_main_menu_begin(do_animation):
	start_main_menu()
	current_target.start(do_animation)

func start_css(cpu_level, multi):
	current_target = load("res://scenes/CSS.tscn").instantiate()
	add_child(current_target)
	current_target.start(cpu_level, multi)
	target_color = Color(0.921569, 0.827451, 0.294118)
	current_target.connect("go_back", Callable(self, "start_main_menu_begin"))
	current_target.connect("done_multi", Callable(self, "_on_CSS_done_multi"))
	current_target.connect("done_single", Callable(self, "_on_CSS_done_single"))
	current_target.connect("ping", Callable(self, "play_ping"))

func _on_CSS_done_multi(p1_data, p2_data):
	current_target = load("res://scenes/MultiPlayer.tscn").instantiate()
	add_child(current_target)
	current_target.start(p1_data, p2_data)
	current_target.visible = false
	change_timer = 200
	current_target.connect("rematch", Callable(self, "_on_CSS_done_multi"))
	current_target.connect("return_to_menu", Callable(self, "return_to_main"))
	current_target.connect("play_music", Callable(self, "play_music"))
	current_target.connect("ping", Callable(self, "play_ping"))
	$Music.playing = false

func _on_CSS_done_single(p1_data):
	current_target = load("res://scenes/SinglePlayer.tscn").instantiate()
	add_child(current_target)
	current_target.start(p1_data, save_data)
	current_target.visible = false
	change_timer = 200
	current_target.connect("rematch", Callable(self, "_on_CSS_done_single"))
	current_target.connect("return_to_menu", Callable(self, "return_to_main"))
	current_target.connect("play_music", Callable(self, "play_music"))
	current_target.connect("ping", Callable(self, "play_ping"))
	$Music.playing = false

func _on_MainMenu_to2p(cpu_level):
	start_css(cpu_level, true)

func _on_MainMenu_to1p(timed):
	if timed:
		start_css(1, false)
	else:
		start_css(0, false)

func _on_MainMenu_toInput():
	start_control_configuration()

func return_to_main():
	start_main_menu()
	change_timer = 200
	current_target.visible = false

func _on_Music_finished():
	if last_music == "loss":
		play_music("after_loss")
