extends Control

signal spawn_trash(combo, chain)
signal has_lost()
signal has_won()

onready var holder = $Wall/Blocks/BlockHolder
var rand = RandomNumberGenerator.new()

# constants
const press_speed_limit = 15
const press_speed_mod = 1
const speed_base = 350
const base_time = 70
const additional_block_time = 10
const combo_values = [0, 0, 0, 0, 20, 30, 50, 60, 70, 80, 100, 140, 170]
const chain_values = [0, 0, 50, 80, 150, 300, 400, 500, 700, 900, 1100, 1300, 1500, 1800]

# info
var data
var is_multiplayer = false
var player_number

# controller data
var unpressed_timer = 0
var pressed_timer = 0
var last_pressed = 0
var ai_time = 1
var ai_timer = 0

# gameplay stats
var row_timer = 0
var bonus_time = 0
var speed = 1
var next_speed = 1
var score = 0.0
var chain = 1
var block_scores = []

# startgame timer
var has_started = false
var start_timer = 0

# misc animations timer
var animation_timer = 0

# endgame timer
var has_lost = false
var has_won = false
var end_timer = -150

func _ready():
	pass

func start(seed_to_use, player_data, p_player_number, multiplayer):
	rand.set_seed(seed_to_use)
	data = player_data
	is_multiplayer = multiplayer
	player_number = p_player_number
	
	$Portrait.texture = load("res://" + data.character + "/portrait.png")
	if player_number == 1:
		$Wall.texture = load("wall_red.png")
		$Portrait.flip_h = true
	else:
		$Wall.texture = load("wall_green.png")
	
	if not multiplayer:
		match data.difficulty:
			enums.DIFFICULTY.EASY:
				holder.set_color_set(enums.COLORSET.EASY_SINGLE)
			enums.DIFFICULTY.MEDIUM:
				holder.set_color_set(enums.COLORSET.EASY_SINGLE)
			enums.DIFFICULTY.HARD:
				holder.set_color_set(enums.COLORSET.HARD_SINGLE)
	else:
		match data.difficulty:
			enums.DIFFICULTY.EASY:
				holder.set_color_set(enums.COLORSET.EASY_MULTI)
			enums.DIFFICULTY.MEDIUM:
				holder.set_color_set(enums.COLORSET.EASY_MULTI)
			enums.DIFFICULTY.HARD:
				holder.set_color_set(enums.COLORSET.HARD_MULTI)
	holder.rand = rand
	holder.generate_preview_blocks()
	for _i in range(0,5):
		holder.push_preview_blocks()
		holder.generate_preview_blocks()

func drop_trash(severity):
	holder.generate_trash_blocks(severity)

func lose_game():
	has_lost = true
	holder.lose_game()

func win_game():
	has_won = true

func announce_win():
	emit_signal("has_won")
	win_game()

func announce_loss():
	emit_signal("has_lost")
	lose_game()

func get_speed_timer():
	return speed_base #- floor(speed) * 2

func increase_score(amt):
	score = min(9999, score + amt)
	if score == 9999:
		announce_win()

var trash_timer = 0
func _physics_process(_delta):
	#########################
	# if the end game is here
	#########################
	if has_lost or has_won:
		end_timer += 1
		if has_lost:
			if end_timer < 50:
				pass
			elif end_timer < 75:
				$Wall.position.y = 324 + floor(sin(end_timer) * 2)
			elif end_timer < 175: #324 #132
				$Wall.position.y = 324 + (132 - 324) * pow(float(min(100, end_timer - 65)) / 100, 4)
			elif end_timer < 275:
				$Wall.position.y = 132 + (324 - 132) * pow(float(min(100, end_timer - 175)) / 100, 4)
				$Wall/Loss.visible = true
			else:
				pass
			return
		else:
			if end_timer < 0:
				pass
			elif end_timer < 175: #324 #132
				$Wall.position.y = 324 + (132 - 324) * pow(float(min(100, end_timer * 2)) / 100, 4)
			elif end_timer < 275:
				$Wall.position.y = 132 + (324 - 132) * pow(float(min(100, end_timer - 175)) / 100, 4)
				$Wall/Win.visible = true
				$WinConfetti.emitting = true
				holder.visible = false
			else:
				pass
			return
	
	##########################################
	# if were doing the start sequence still
	#############################################
	if not has_started:
		start_timer += 1
		if start_timer < 75:
			pass
		elif start_timer < 150:
			$Wall/Blocks.modulate.a += (1 - $Wall/Blocks.modulate.a) * .05
			$Portrait.modulate.a += (.33 - $Portrait.modulate.a) * .05
		elif start_timer < 250:
			holder.has_started = true
			if start_timer % 8 == 0:
				holder.ai_cursor()
			$Ready.position.x += (50 - $Ready.position.x) * .7
			$CountDown.position.x += (50 - $CountDown.position.x) * .7
		elif start_timer < 300:
			pass
		elif start_timer < 350:
			$CountDown.texture = load("ready2.png")
			$Ready.modulate.a -= $Ready.modulate.a * .3
		elif start_timer < 400:
			$CountDown.texture = load("ready1.png")
		else:
			has_started = true
		return
	$CountDown.modulate.a -= $CountDown.modulate.a * .3
	
	########################################
	# block maintenance
	###################################
	holder.update_blocks()
	holder.drop()
	
	########################
	# matches
	#######################
	var matches = holder.check_matches()
	if matches["chain"]:
		chain += 1
		holder.show_chain(chain, matches["matches"][floor(float(matches["matches"].size()) / 2)].p, true)
		increase_score(chain_values[min(chain, chain_values.size())])
	if matches["matches"].size() > 3:
		var p = matches["matches"][floor(float(matches["matches"].size()) / 2)].p
		if matches["chain"]:
			p.y -= 30
		holder.show_chain(matches["matches"].size(), p, false)
		emit_signal("spawn_trash", matches["matches"].size() - 1, chain, get_global_position() + holder.get_position_vector(matches["matches"][floor(float(matches["matches"].size()) / 2)].p))
	if matches["matches"].size() > 0:
		for i in range(0, matches["matches"].size()):
			block_scores.append(base_time + i * additional_block_time)
		block_scores.sort()
		increase_score(combo_values[min(matches["matches"].size(), combo_values.size())])

	if holder.update_matches():
		bonus_time += 1.2

	if bonus_time > 0:
		bonus_time -= 1
	else:
		row_timer += 1
		chain = 1
	
	var at_zero = 0
	for i in range(0, block_scores.size()):
		if block_scores[i] > 0:
			block_scores[i] -= 1
		else:
			increase_score(10)
			at_zero += 1
	# remove as many blocks as there are blocks that have time of zero left
	# works because block scores is always in order
	for e in range(0, at_zero):
		block_scores.remove(0)
	
	###################################
	# move the board up / lose game
	##################################	
	if row_timer > get_speed_timer():
		row_timer = 0
		if holder.push_preview_blocks():
			holder.generate_preview_blocks()
		else:
			holder.generate_preview_blocks()
			announce_loss()
			return
		speed = next_speed
	holder.set_progress(float(row_timer) / get_speed_timer())
	
	########### 
	# trash
	############
	if Input.is_action_just_pressed("trash"):
		drop_trash(4)
	if Input.is_action_just_pressed("debug"):
		holder.toggle()
	
	if data.ai:
		############################
		# ai control
		############################
		ai_timer += 1
		if ai_timer > ai_time:
			ai_timer = 0
			holder.ai()
	else:
		############################
		# human control
		############################
		
		##############################
		# determining cursor movement
		##############################
		pressed_timer += 1
		unpressed_timer += 1
		var button_pressed_already = false
		var pressed 
		
		if Input.is_action_pressed("ui_left"):
			button_pressed_already = true
			pressed = enums.DIRECTION.LEFT
		
		if Input.is_action_pressed("ui_right") and not button_pressed_already:
			button_pressed_already = true
			pressed = enums.DIRECTION.RIGHT
		
		if Input.is_action_pressed("ui_up") and not button_pressed_already:
			button_pressed_already = true
			pressed = enums.DIRECTION.UP
		
		if Input.is_action_pressed("ui_down") and not button_pressed_already:
			pressed = enums.DIRECTION.DOWN
		
		if pressed != null:
			if pressed_timer == 2 or (pressed_timer > press_speed_limit and pressed_timer % press_speed_mod == 0):
				holder.move_cursor(pressed)
			unpressed_timer = 0
			if pressed != last_pressed:
				pressed_timer = 0
			last_pressed = pressed
		
		if unpressed_timer > 0:
			pressed_timer = 0
		
		####################
		# other inputs
		####################
		if Input.is_action_just_pressed("ui_accept"):
			holder.swap()
		
		if Input.is_action_just_pressed("ui_focus_next"):
			holder.tab()

func _process(_delta):
	animation_timer += 1
	if animation_timer % 60 < 30:
		$Wall/Win.position.y += (-299 - $Wall/Win.position.y) * .4
	else:
		$Wall/Win.position.y += (-294 - $Wall/Win.position.y) * .4
	if animation_timer % 10 < 5:
		$Wall/Loss.position.y += (-295 - $Wall/Loss.position.y) * .4
	else:
		$Wall/Loss.position.y += (-293 - $Wall/Loss.position.y) * .4
