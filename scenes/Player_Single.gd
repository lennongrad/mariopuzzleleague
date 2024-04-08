extends NinePatchRect

signal go_back()

@export var player_number: String = "1"

var level = 1
var difficulty = enums.DIFFICULTY.EASY
var time = 120

var do_time = true

enum SEQUENCE{LEVEL, DIFFICULTY, TIME, INACTIVE, DONE}
var current_sequence = SEQUENCE.INACTIVE

var counter_timer = 0
var successive_count = 0
var last_direction = 0

var action_timer = 0

func color_change(color):
	texture = load("res://graphics/colors/" + color + "/css_ridge.png")
	$Time/Text.font = color
	change_time()
	$Level/Text.font = color
	$Level.texture = load("res://graphics/colors/" + color + "/level.png")
	$Level/Left.change_color(color)
	$Level/Right.change_color(color)
	$Difficulty/Up.change_color(color)
	$Difficulty/Down.change_color(color)
	$Time/Up.change_color(color)
	$Time/Down.change_color(color)

func change_time():
	$Time/Text.text = str(int(floor(time / 60))).pad_zeros(2) + "'" + str(int(time) % 60).pad_zeros(2)

func set_timed(timed):
	do_time = timed
	if not timed:
		$Time.visible = false
		position.x = -33
		size.x = 102

func start():
	current_sequence = SEQUENCE.LEVEL

func tick(input):
	action_timer += 1
	match current_sequence:
		SEQUENCE.INACTIVE:
			if input.a:
				current_sequence = SEQUENCE.LEVEL
		SEQUENCE.DONE:
			if input.b:
				current_sequence = SEQUENCE.LEVEL
		SEQUENCE.LEVEL:
			counter_timer += 1
			if counter_timer > (10 - successive_count):
				if input.right:
					$Level/Right.frame = 0
					level = min(99, level + 1)
					counter_timer = 0
					if last_direction != 1:
						successive_count = 0
					else:
						successive_count = min(9, successive_count + 1)
					last_direction = 1
					action_timer = 0
				if input.left:
					$Level/Left.frame = 0
					level = max(1, level - 1)
					counter_timer = 0
					if last_direction != -1:
						successive_count = 0
					else:
						successive_count = min(9, successive_count + 1)
					last_direction = -1
					action_timer = 0
			if counter_timer > (10 - successive_count) or (not input.left and not input.right):
				successive_count = 0
			if input.a:
				current_sequence = SEQUENCE.DIFFICULTY
				action_timer = 0
			if input.b:
				current_sequence = SEQUENCE.INACTIVE
				emit_signal("go_back")
		SEQUENCE.DIFFICULTY:
			if input.just_down:
				$Difficulty/Down.frame = 0
				match difficulty:
					enums.DIFFICULTY.MEDIUM: difficulty = enums.DIFFICULTY.EASY
					enums.DIFFICULTY.HARD: difficulty = enums.DIFFICULTY.MEDIUM
				action_timer = 0
			if input.just_up:
				$Difficulty/Down.frame = 0
				match difficulty:
					enums.DIFFICULTY.EASY: difficulty = enums.DIFFICULTY.MEDIUM
					enums.DIFFICULTY.MEDIUM: difficulty = enums.DIFFICULTY.HARD
				action_timer = 0
			if input.b:
				current_sequence = SEQUENCE.LEVEL
				action_timer = 0
			if input.a:
				if do_time:
					current_sequence = SEQUENCE.TIME
				else:
					finish()
				action_timer = 0
		SEQUENCE.TIME:
			counter_timer += 1
			if counter_timer > (10 - successive_count):
				if input.up or input.right:
					$Time/Up.frame = 0
					var increment = 1
					if input.right:
						increment = 15
					time = min(60 * 60 - 1, time + increment)
					counter_timer = 0
					if last_direction != 1:
						successive_count = 0
					else:
						successive_count = min(9, successive_count + 1)
					last_direction = 1
					action_timer = 0
				if input.down or input.left:
					$Time/Down.frame = 0
					var increment = 1
					if input.left:
						increment = 15
					time = max(1, time - increment)
					counter_timer = 0
					if last_direction != -1:
						successive_count = 0
					else:
						successive_count = min(9, successive_count + 1)
					last_direction = -1
					action_timer = 0
			if counter_timer > (10 - successive_count) or not (input.down or input.up or input.left or input.right):
				successive_count = 0
			change_time()
			if input.b:
				current_sequence = SEQUENCE.DIFFICULTY
				action_timer = 0
			if input.a:
				finish()
				action_timer = 0

func _process(_delta):
	$Level/Text.text = str(level).pad_zeros(2)
	match difficulty:
		enums.DIFFICULTY.EASY:
			$Difficulty/Text.texture = load("res://graphics/easy.png")
		enums.DIFFICULTY.MEDIUM:
			$Difficulty/Text.texture = load("res://graphics/normal.png")
		enums.DIFFICULTY.HARD:
			$Difficulty/Text.texture = load("res://graphics/hard.png")
	match current_sequence:
		SEQUENCE.LEVEL:
			if level != 1:
				$Level/Left.visible = true
			else:
				$Level/Left.visible = false
			if level != 99:
				$Level/Right.visible = true
			else:
				$Level/Right.visible = false
			$Difficulty/Up.visible = false
			$Difficulty/Down.visible = false
			$Time/Up.visible = false
			$Time/Down.visible = false
			modulate.v += (1 - modulate.v) * .1
			if action_timer > 150:
				$AButton.visible = true
			else:
				$AButton.visible = false
		SEQUENCE.DIFFICULTY:
			if difficulty != enums.DIFFICULTY.EASY:
				$Difficulty/Down.visible = true
			else:
				$Difficulty/Down.visible = false
			if difficulty != enums.DIFFICULTY.HARD:
				$Difficulty/Up.visible = true
			else:
				$Difficulty/Up.visible = false
			$Level/Left.visible = false
			$Level/Right.visible = false
			$Time/Up.visible = false
			$Time/Down.visible = false
			modulate.v += (1 - modulate.v) * .1
			if action_timer > 150:
				$AButton.visible = true
			else:
				$AButton.visible = false
		SEQUENCE.TIME:
			if time > 1:
				$Time/Down.visible = true
			else:
				$Time/Down.visible = false
			if time < (60 * 60 - 1):
				$Time/Up.visible = true
			else:
				$Time/Up.visible = false
			$Level/Left.visible = false
			$Level/Right.visible = false
			$Difficulty/Up.visible = false
			$Difficulty/Down.visible = false
			modulate.v += (1 - modulate.v) * .1
			if action_timer > 150:
				$AButton.visible = true
			else:
				$AButton.visible = false
		SEQUENCE.DONE:
			$Level/Left.visible = false
			$Level/Right.visible = false
			$Difficulty/Up.visible = false
			$Difficulty/Down.visible = false
			$Time/Up.visible = false
			$Time/Down.visible = false
			modulate.v += (.6 - modulate.v) * .1
			$AButton.visible = false
		SEQUENCE.INACTIVE:
			$Level/Left.visible = false
			$Level/Right.visible = false
			$Difficulty/Up.visible = false
			$Difficulty/Down.visible = false
			$Time/Up.visible = false
			$Time/Down.visible = false
			modulate.v += (.6 - modulate.v) * .1
			$AButton.visible = false

func finish():
	pass
	current_sequence = SEQUENCE.DONE

func is_inactive():
	return current_sequence == SEQUENCE.INACTIVE

func is_done():
	return current_sequence == SEQUENCE.DONE
