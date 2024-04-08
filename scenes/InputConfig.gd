extends Control

signal done()
signal ping()

var selected 
var inputs = []
var binding_input = null
var done_timer = -1
var start_timer = 0
func _ready():
	for child in get_children():
		if child.get("is_listening") != null:
			inputs.append(child)
			child.connect("bound", Callable(self, "_on_Input_bound"))
			child.connect("pressed", Callable(self, "_on_Input_pressed"))
			child.connect("already_bound", Callable(self, "_on_Input_already_bound"))
	selected = inputs[0]
	set_first_needs_input()
	$InputUp.grab_focus()

func tick(_p1, _p2, save_data):
	return save_data

func _process(_delta):
	start_timer += 1
	if done_timer != -1:
		done_timer += 1
		modulate.a -= modulate.a * .2
		if done_timer > 30:
			queue_free()
		return
	var focused = $PlayerNumber.get_viewport().gui_get_focus_owner()
	$Cursor.position = focused.position + focused.size / 2
	$Cursor.position.y -= 10
	if is_binding():
		$Cursor.visible = false
		$ControllerDiagram/Feedback.text = "PRESS KEY FOR: " + binding_input.action_name.capitalize()
		$ControllerDiagram/AButton.visible = false
	else:
		$Cursor.visible = true
		$ControllerDiagram/Feedback.text = ""
		if focused.get("is_listening") != null:
			$ControllerDiagram/AButton.visible = true
		else:
			$ControllerDiagram/AButton.visible = false
	
	var next
	if Input.is_action_just_pressed("p1_down"):
		emit_signal("ping")
		next = focused.get_node(focused.focus_neighbor_bottom)
	if Input.is_action_just_pressed("p1_up"):
		emit_signal("ping")
		next = focused.get_node(focused.focus_neighbor_top)
	if Input.is_action_just_pressed("p1_left"):
		emit_signal("ping")
		next = focused.get_node(focused.focus_neighbor_left)
	if Input.is_action_just_pressed("p1_right"):
		emit_signal("ping")
		next = focused.get_node(focused.focus_neighbor_right)
	if next != null: 
		next.grab_focus()
	
	if Input.is_action_just_pressed("p1_a") and start_timer > 50:
		emit_signal("ping")
		if focused.name == "PlayerNumber":
			toggle_player_number()
		elif focused.name == "SaveExit":
			save_and_exit()
		elif focused.name == "Reset":
			reset_inputs()
		else:
			set_ready(focused)
	
	if Input.is_action_just_pressed("p1_x") and start_timer > 50:
		emit_signal("ping")
		toggle_player_number()

func is_binding():
	for input in inputs:
		if input.is_listening:
			binding_input = input
			return true
	return false

func set_first_needs_input():
	var has_set = false
	for input in inputs:
		if not has_set and input.needs_binding():
			input.is_listening = true
			has_set = true
		else:
			input.is_listening = false
	return has_set

func set_ready(p_input):
	for input in inputs:
		if input != p_input:
			input.is_listening = false
	p_input.is_listening = true

func toggle_player_number():
	if set_first_needs_input():
		return
	var new_player_number = $PlayerNumber.toggle()
	for input in inputs:
		if new_player_number:
			input.prefix = "p1_"
		else:
			input.prefix = "p2_"

func save_and_exit():
	if set_first_needs_input():
		return
	var config = ConfigFile.new()
	for action in InputMap.get_actions():
		if action.substr(0, 2) != "ui":
			if InputMap.action_get_events(action).size() > 0:
				config.set_value("input", action, InputMap.action_get_events(action)[0].get_keycode())
	config.save("user://settings.cfg")
	emit_signal("done", true)
	done_timer = 0

func reset_inputs():
	InputMap.load_from_project_settings()
	set_first_needs_input()

func _on_Input_bound(input):
	set_first_needs_input()

func _on_Input_already_bound(input):
	print("oof")

func _on_Input_pressed(input):
	set_ready(input)
