extends NinePatchRect

onready var container = $Choices/VBoxContainer

var next_list
var next_rect_size
var next_position
var next_selection
var current_color
var last_count = 1

func set_selected(selected):
	if is_animating():
		next_selection = selected
		return
	var i = 0
	for child in container.get_children():
		child.set_active(i == selected)
		i += 1

func is_animating():
	return next_list != null or next_rect_size != null

func make_choices(list, info, title, color):
	next_list = []
	for element in list:
		next_list.append(info[element])
	$Title/Label.text = title
	current_color = color

func set_count(p_count):
	last_count = p_count
	for child in container.get_children():
		child.set_count(p_count)

func _process(_delta):
	if next_list != null:
		rect_size.y -= 7
		if rect_size.y <= 10:
			for child in container.get_children():
				child.free()
			for element in next_list:
				var new_choice = load("res://scenes/Choice.tscn").instance()
				if element.has("show_count"):
					new_choice.show_count = true
				new_choice.set_text(element.name)
				new_choice.set_color(current_color)
				if element.has("color"):
					new_choice.set_text_color(element.color)
				container.add_child(new_choice)
			next_rect_size = 25 * next_list.size() + 10
			next_position = 107.5 - next_rect_size / 2
			next_list = null 
			visible = true
			var color_lighter = current_color
			color_lighter.v = min(2, current_color.v + .9)
			self_modulate = color_lighter
			set_count(last_count)
	if next_rect_size != null:
		rect_size.y += 7
		if rect_size.y >= next_rect_size:
			rect_size.y = next_rect_size
			next_rect_size = null
	if next_position != null:
		if next_position < rect_position.y:
			rect_position.y -= 1
		if next_position > rect_position.y:
			rect_position.y += 1
		if abs(next_position - rect_position.y) < 1:
			rect_position.y = next_position
			next_position = null
	
	if not is_animating() and next_selection != null:
		set_selected(next_selection)
		next_selection = null
	
	if $Title/Label.text == "":
		$Title.rect_scale.x -= $Title.rect_scale.x * .4
		$AButton.visible = true
		$ABButton.visible = false
	else:
		$Title.rect_scale.x += (1 - $Title.rect_scale.x) * .4
		$AButton.visible = false
		$ABButton.visible = true
