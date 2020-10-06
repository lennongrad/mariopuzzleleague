extends ColorRect

signal bound(input)
signal pressed(input)
signal already_bound(input)

export(String) var action_name
export(String) var prefix
#export(NodePath) var left_input
#export(NodePath) var down_input
#export(NodePath) var right_input
#export(NodePath) var up_input
var is_listening = false

func needs_binding():
	return  InputMap.get_action_list(get_action_name()).size() == 0

func get_action_name():
	return prefix + action_name

func _unhandled_input(event):
	if is_listening:
		if event is InputEventKey:
			if event.pressed:
				for action in InputMap.get_actions():
					if action != get_action_name() and action.substr(0, 2) != "ui":
						for action_event in InputMap.get_action_list(action):
							if action_event.as_text() == event.as_text():
								emit_signal("already_bound", self)
								return
				InputMap.action_erase_events(get_action_name())
				InputMap.action_add_event(get_action_name(), event)
#				if get_action_name() == "p1_down":
#					InputMap.action_erase_events("ui_down")
#					InputMap.action_add_event("ui_down", event)
#				if get_action_name() == "p1_left":
#					InputMap.action_erase_events("ui_left")
#					InputMap.action_add_event("ui_left", event)
#				if get_action_name() == "p1_right":
#					InputMap.action_erase_events("ui_right")
#					InputMap.action_add_event("ui_right", event)
#				if get_action_name() == "p1_up":
#					InputMap.action_erase_events("ui_up")
#					InputMap.action_add_event("ui_up", event)
				is_listening = false
				emit_signal("bound", self)

func _process(_delta):
	if is_listening:
		color = Color(0, 0, 0, 0.341176)
	elif needs_binding():
		color = Color(1, 0, 0, 0.341176)
	else:
		color = Color(0,0,0,0)
	
	if is_listening or needs_binding():
		$Label.text = ""
	else:
		$Label.text = InputMap.get_action_list(get_action_name())[0].as_text()


func _on_Button_pressed():
	emit_signal("pressed", self)
