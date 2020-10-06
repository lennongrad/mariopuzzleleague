extends Control

signal goto_online()
signal goto_twoplayer(cpu)
signal goto_oneplayer(rules)
signal goto_input()
signal ping()

enum CHOICE{ONE_PLAYER, TWO_PLAYER, OPTIONS, ENDLESS, TIME_TRIAL, LOCAL, ONLINE, AI, INPUT}
var choice_info = {
	CHOICE.ONE_PLAYER: {"name": "1Player", "color": Color(0.682353, 0, 0.368627)},
	CHOICE.TWO_PLAYER: {"name": "2Player", "color": Color(0.682353, 0.368627, 0)},
	CHOICE.OPTIONS: {"name": "Options", "color": Color(0.192461, 0.605469, 0.00473)},
	CHOICE.ENDLESS: {"name": "Endless"},
	CHOICE.TIME_TRIAL: {"name": "TimeTrial"},
	CHOICE.LOCAL: {"name": "Local"},
	CHOICE.AI: {"name": "vs.CPU", "show_count": true},
	CHOICE.ONLINE: {"name": "Online"},
	CHOICE.INPUT: {"name": "Input"}
	}

var store_selection = {}
var first_choices = [CHOICE.ONE_PLAYER, CHOICE.TWO_PLAYER, CHOICE.OPTIONS]

var current_choices
var current_selection = 0
var bumpty_timer = 250
var last_bumpty = 0
var final_bumpty = 950
var menu_ended = false
var has_started = false
var do_animation = false

var cpu_level = 1

func _ready():
	change_choices(first_choices, "", Color(0, 0.294118, 0.682353))

func tick(p1, _p2, save_data):
	if has_started:
		if do_animation:
			if bumpty_timer > 0:
				bumpty_timer -= 1
				last_bumpty -= 1
				if randi() % 16 == 0 and last_bumpty <= 0:
					var new_bumpty = load("res://scenes/Bumpty.tscn").instance()
					new_bumpty.position = Vector2(266, 224)
					add_child(new_bumpty)
					last_bumpty = 10
			
			if final_bumpty > 0:
				final_bumpty -= 1
				if final_bumpty == 0:
					var new_bumpty = load("res://scenes/Bumpty.tscn").instance()
					new_bumpty.position = Vector2(266, 224)
					add_child(new_bumpty)
			
			$Yoshi.position.x -= 2.5
		
		if not $Choices.is_animating():
			if p1.just_up:
				emit_signal("ping")
				current_selection = (current_selection + current_choices.size() - 1) % current_choices.size()
				$Choices.set_selected(current_selection)
			if p1.just_down:
				emit_signal("ping")
				current_selection = (current_selection + 1) % current_choices.size()
				$Choices.set_selected(current_selection)
			if p1.a:
				emit_signal("ping")
				match current_choices[current_selection]:
					CHOICE.ONE_PLAYER: change_choices([CHOICE.ENDLESS, CHOICE.TIME_TRIAL], "1Player", Color(0.682353, 0, 0.368627))
					CHOICE.TWO_PLAYER: change_choices([CHOICE.LOCAL, CHOICE.AI#, CHOICE.ONLINE
					], "2Player", Color(0.682353, 0.368627, 0))
					CHOICE.OPTIONS: change_choices([CHOICE.INPUT#, CHOICE.AI#, CHOICE.ONLINE
					], "Options", Color(0.192461, 0.605469, 0.00473))
					CHOICE.ENDLESS:
						emit_signal("goto_oneplayer", false)
						end_menu()
					CHOICE.TIME_TRIAL:
						emit_signal("goto_oneplayer", true)
						end_menu()
					CHOICE.AI:
						emit_signal("goto_twoplayer", cpu_level)
						end_menu()
					CHOICE.LOCAL:
						emit_signal("goto_twoplayer", 0)
						end_menu()
					CHOICE.INPUT:
						emit_signal("goto_input")
						end_menu()
			if p1.b:
				emit_signal("ping")
				match current_choices[current_selection]:
					CHOICE.ENDLESS: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
					CHOICE.TIME_TRIAL: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
					CHOICE.LOCAL: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
					CHOICE.AI: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
					CHOICE.ONLINE: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
					CHOICE.INPUT: change_choices(first_choices, "", Color(0, 0.294118, 0.682353))
			if p1.just_left:
				emit_signal("ping")
				match current_choices[current_selection]:
					CHOICE.AI:
						cpu_level = max(1, cpu_level - 1)
						$Choices.set_count(cpu_level)
			if p1.just_right:
				emit_signal("ping")
				match current_choices[current_selection]:
					CHOICE.AI:
						cpu_level = min(9, cpu_level + 1)
						$Choices.set_count(cpu_level)
	return save_data

func change_choices(choices, title, color):
	store_selection[current_choices] = current_selection
	current_choices = choices
	$Choices.make_choices(current_choices, choice_info, title, color)
	if store_selection.has(current_choices):
		current_selection = store_selection[current_choices]
	else:
		current_selection = 0
	$Choices.set_selected(current_selection)

func start(do_yoshis):
	has_started = true
	if do_yoshis and randi() % 2 == 0:
		do_animation = true
	if not do_animation:
		$Yoshi.visible = false

func end_menu():
	menu_ended = true

func _process(_delta):
	if menu_ended:
		modulate.a -= modulate.a * .1
		if modulate.a < .01:
			queue_free()

func _on_Button_pressed():
	emit_signal("goto_input")
	end_menu()
