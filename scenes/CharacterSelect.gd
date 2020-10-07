extends NinePatchRect

signal go_back()
signal done(character1, character2)

var characters = []
var characters_list = ["yoshi", "bowser", "lip", "seren", "lakitu", "kamek"]
var p1_selection = 0
var p2_selection = 1
var p1_selected = false
var p2_selected = false
var col_size = 5
var timer = 0

var active = false
var is_multi =  false

func _ready():
	for character in characters_list:
		var choice_path = "res://graphics/characters/" + character + "/data.tres"
		characters.append({"data": load(choice_path)})
	characters.sort_custom(self, "character_comparison")
	
	for i in range(0, characters.size()):
		characters[i].node = load("scenes/CharacterIcon.tscn").instance()
		characters[i].node.position.x = 40 * (i % col_size) + 30
		characters[i].node.position.y = 40 * floor(float(i) / col_size) + 30
		characters[i].node.change_character(characters[i].data)
		add_child(characters[i].node)

func start(multi):
	p1_selected = false
	p2_selected = false
	is_multi = multi

func character_comparison(a, b):
	return a.data.order < b.data.order

func _process(_delta):
	for i in range(0, characters.size()):
		if i != p1_selection and i != p2_selection:
			characters[i].node.set_selected(false)
	characters[p1_selection].node.set_selected(true)
	characters[p2_selection].node.set_selected(true)
	$Cursor1.position += (characters[p1_selection].node.position - $Cursor1.position) * .4
	$Cursor2.position += (characters[p2_selection].node.position - $Cursor2.position) * .4
	if active:
		modulate.v += (1 - modulate.v) * .1
	else:
		modulate.v += (.6 - modulate.v) * .1
		$Cursor1.visible = true
		$Cursor2.visible = is_multi

func tick(p1_input, p2_input, is_ai):
	active = true
	timer += 1
	
	if is_multi:
		if not p2_selected:
			if not is_ai or p1_selected:
				var chosen_input
				if is_ai:
					chosen_input = p1_input
				else:
					chosen_input = p2_input
				var x_place = int(p2_selection) % col_size
				var y_place = int(floor(float(p2_selection) / col_size))
				if chosen_input.just_right:
					p2_selection = min(characters.size() - 1, y_place * col_size + (x_place + 1) % col_size)
				elif chosen_input.just_left:
					p2_selection = min(characters.size() - 1, y_place * col_size + (x_place + col_size - 1) % col_size)
				elif chosen_input.just_up:
					if y_place != 0:
						p2_selection = max(0, p2_selection - col_size)
				elif chosen_input.just_down:
					p2_selection = min(characters.size() - 1, p2_selection + col_size)
				if chosen_input.a:
					p2_selected = true
				$Cursor2.visible = true
		else:
			if timer % 8 < 2:
				$Cursor2.visible = false
			else:
				$Cursor2.visible = true
			if p2_input.b:
				p2_selected = false
	else:
		$Cursor2.visible = false
	
	if not p1_selected:
		var x_place = int(p1_selection) % col_size
		var y_place = int(floor(float(p1_selection) / col_size))
		if p1_input.just_right:
			p1_selection = min(characters.size() - 1, y_place * col_size + (x_place + 1) % col_size)
		elif p1_input.just_left:
			p1_selection = min(characters.size() - 1, y_place * col_size + (x_place + col_size - 1) % col_size)
		elif p1_input.just_up:
			if y_place != 0:
				p1_selection = max(0, p1_selection - col_size)
		elif p1_input.just_down:
			p1_selection = min(characters.size() - 1, p1_selection + col_size)
		if p1_input.a:
			p1_selected = true
		if p1_input.b:
			go_back()
		$Cursor1.visible = true
	else:
		if timer % 8 < 2:
			$Cursor1.visible = false
		else:
			$Cursor1.visible = true
		if p1_input.b:
			p1_selected = false
	
	if p1_selected and (not is_multi or p2_selected):
		emit_signal("done", characters[p1_selection], characters[p2_selection])
		active = false

func go_back():
	emit_signal("go_back")

func color_change1(color):
	$Cursor1.color_change(color)

func color_change2(color):
	$Cursor2.color_change(color)
