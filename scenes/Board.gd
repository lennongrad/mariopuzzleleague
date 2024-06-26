extends Control

signal spawn_trash(combo, chain)
signal has_lost()
signal has_won()
signal won_item()
signal use_item()
signal play_music(music)

@onready var holder = $Wall/BlockHolder
var rand = RandomNumberGenerator.new()

# constants
const press_speed_limit = 15
const press_speed_mod = 1
const speed_base = .001
const speed_base_modifier = .0005
const base_time = 70
const additional_block_time = 10
const combo_values = [0, 0, 0, 0, 20, 30, 50, 60, 70, 80, 100, 140, 170]
const chain_values = [0, 0, 50, 80, 150, 300, 400, 500, 700, 900, 1100, 1300, 1500, 1800]

# info
var data
var is_multiplayer = false
var player_number
var other_player_has_star = false

# controller data
var unpressed_timer = 0
var pressed_timer = 0
var last_pressed = 0
var ai_timer = 0

# gameplay stats
var row_timer = 0
var bonus_time = 0
var score = 0.0
var chain = 1
var block_scores = []

# startgame timer
var has_started = false
var start_timer = 0

# misc animations timer
var animation_timer = 0

# power ups
var star_timer = 0
var ghost_timer = 0

# endgame timer
var is_has_lost = false
var is_has_won = false
var has_stopped = false
var end_timer = -150

func _ready():
	$Portrait.material = ShaderMaterial.new()
	$Portrait.material.set_shader(load("res://shaders/Rainbow.gdshader"))
	$Portrait.material.set_shader_parameter("noiseTexture", load("res://graphics/noise.png")) 

func start(seed_to_use, player_data, p_player_number, multiplayer, opponent):
	rand.set_seed(seed_to_use)
	data = player_data
	is_multiplayer = multiplayer
	player_number = p_player_number
	holder.character = data.character
	if multiplayer:
		holder.opponent = opponent.character
	
	$Portrait.texture = data.character.get_portrait()
	$Wall/Wall.texture = load("res://graphics/colors/" + player_data.colors + "/wall.png")
	if player_number == 1:
		$Portrait.flip_h = true
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
	if star_timer == 0:
		holder.generate_trash_blocks(severity)

func start_star():
	star_timer = 600
	holder.destroy_all_trash()
	ghost_timer = min(1, ghost_timer)
	$StarActivated.play(45)

func start_ghost():
	if star_timer == 0:
		ghost_timer = 800

func win_game():
	if data.ai == 0:
		emit_signal("play_music", "win")
	else:
		emit_signal("play_music", "loss")
	is_has_won = true
	game_over()

func lose_game():
	if not is_multiplayer:
		emit_signal("play_music", "loss")
	is_has_lost = true
	holder.lose_game()
	game_over()

func game_over():
	ghost_timer = 0
	star_timer = 0
	$BooSmoke.modulate.a = 0
	$BooParticles.emitting = false
	$Portrait.material.set_shader_parameter("active", false)

func announce_win():
	emit_signal("has_won")
	win_game()

func announce_loss():
	emit_signal("has_lost")
	lose_game()

func increase_score(amt):
	score = min(9999, score + amt)
	if score == 9999:
		print("Won by score")
		announce_win()

func get_velocity():
	return min(99, data.speed + score / 100)

var trash_timer = 0
func tick(input):
	#########################
	# if the end game is here
	#########################
	if has_stopped:
		if player_number == 1:
			$Wall/A.position.x += (-4 - $Wall/A.position.x) * .1
			$Wall/B.position.x += (-4 - $Wall/B.position.x) * .1
		return
	
	if (is_has_lost or is_has_won) and not has_stopped:
		end_timer += 1
		if is_has_lost:
			if end_timer < 50:
				pass
			elif end_timer < 75:
				$Wall.position.y = 324 + floor(sin(end_timer) * 2)
			elif end_timer < 175: #324 #132
				$Wall.position.y = 324 + (132 - 324) * pow(float(min(100, end_timer - 65)) / 100, 4)
			elif end_timer < 275:
				$Wall.position.y = 132 + (324 - 132) * pow(float(min(100, end_timer - 175)) / 100, 4)
				$Wall/Loss.visible = true
			elif end_timer < 350:
				$Wall/Wall.position.y = -abs(sin(.2 * (end_timer - 275))) * (30 / pow(end_timer - 274, 1))
			else:
				$Wall/Wall.position.y = 0
				has_stopped = true
			return
		else:
			if end_timer < 0:
				pass
			elif end_timer < 175: #324 #132
				$Wall.position.y = 324 + (132 - 324) * pow(float(min(100, end_timer * 2)) / 100, 4)
			elif end_timer < 265:
				$Wall.position.y = 132 + (324 - 132) * pow(float(min(90, end_timer - 175)) / 90, 4)
				$Wall/Win.visible = true
				$WinConfetti.emitting = true
				holder.visible = false
			elif end_timer < 325:
				$Wall/Wall.position.y = -abs(sin(.2 * (end_timer - 265))) * (30 / pow(end_timer - 264, 1))
			else:
				$Wall/Wall.position.y = 0
				has_stopped = true
			return
	
	##########################################
	# if were doing the start sequence still
	#############################################
	if not has_started:
		start_timer += 1
		if start_timer < 75:
			pass
		elif start_timer < 150:
			holder.modulate.a += (1 - holder.modulate.a) * .075
			$Portrait.modulate.a += (.33 - $Portrait.modulate.a) * .05
		elif start_timer < 250:
			holder.has_started = true
			if int(start_timer) % 8 == 0:
				holder.ai_cursor()
			$Ready.position.x += (50 - $Ready.position.x) * .7
			$CountDown.position.x += (50 - $CountDown.position.x) * .7
			if start_timer == 205:
				$StartTick.play()
		elif start_timer < 350:
			$CountDown.texture = load("res://graphics/ready2.png")
			$Ready.modulate.a -= $Ready.modulate.a * .3
			if start_timer == 275:
				$StartTick.pitch_scale = 1.1
				$StartTick.play()
		elif start_timer < 425:
			$CountDown.texture = load("res://graphics/ready1.png")
			if start_timer == 350:
				$StartTick.pitch_scale = 1.2
				$StartTick.play()
		else:
			has_started = true
			$KickOff.play()
		return
	$CountDown.modulate.a -= $CountDown.modulate.a * .3
	
	########################
	# matches
	#######################
	var matches = holder.check_matches()
	if matches["chain"]:
		chain += 1
		holder.show_chain(chain, matches["matches"][floor(float(matches["matches"].size()) / 2)].p, true)
		increase_score(chain_values[min(chain, chain_values.size())])
	if matches["matches"].size() > 3:
		if data.ai == 0:
			$Spin.play()
		var p = matches["matches"][floor(float(matches["matches"].size()) / 2)].p
		if matches["chain"]:
			p.y -= 30
		holder.show_chain(matches["matches"].size(), p, false)
		emit_signal("spawn_trash", matches["matches"].size() - 1, chain, get_global_position() + holder.get_position_vector(matches["matches"][floor(float(matches["matches"].size()) / 2)].p))
	if matches["matches"].size() > 0:
		if data.ai == 0:
			$Clap.play()
		for i in range(0, matches["matches"].size()):
			block_scores.append(base_time + i * additional_block_time)
		block_scores.sort()
		increase_score(combo_values[min(matches["matches"].size(), combo_values.size())])
	if matches["item"]:
		emit_signal("won_item")
#
	if holder.update_matches():
		bonus_time += 1.2

	var at_zero = 0
	for i in range(0, block_scores.size()):
		if block_scores[i] > 0:
			block_scores[i] -= 1
		else:
			if data.ai == 0:
				$MatchBroke.play()
			increase_score(10)
			at_zero += 1
	# remove as many blocks as there are blocks that have time of zero left
	# works because block scores is always in order
	for _e in range(0, at_zero):
		block_scores.erase(0)
	
	########################################
	# block maintenance
	###################################
	holder.update_blocks()
	holder.drop()
	
	######################### 
	# power ups
	#########################
	if star_timer > 0:
		star_timer -= 1
		$Portrait.material.set_shader_parameter("active", true)
	else:
		$Portrait.material.set_shader_parameter("active", false)
	
	if ghost_timer > 0:
		ghost_timer -= 1
		$BooSmoke.modulate.a += (1 - $BooSmoke.modulate.a) * .1
		$BooParticles.emitting = true
		if ghost_timer % 4 == 0 and randi() % 4 == 0:
			holder.swap_random()
	else:
		$BooSmoke.modulate.a -= $BooSmoke.modulate.a * .1
		$BooParticles.emitting = false
	
	###################################
	# move the board up / lose game
	##################################	
	if bonus_time > 0 or star_timer > 0:
		bonus_time -= 1
	else:
		row_timer += (speed_base + speed_base_modifier * get_velocity())
		chain = 1
	
	if row_timer >= 1:
		row_timer -= 1
		if holder.push_preview_blocks():
			holder.generate_preview_blocks()
		else:
			holder.generate_preview_blocks()
			print("Lost by block height")
			announce_loss()
			return
	holder.set_progress(min(1, row_timer))
	
	if data.ai:
		############################
		# ai control
		############################
		ai_timer += 1
		if ai_timer > (10 - data["ai"]):
			ai_timer = 0
			holder.ai()
		
		if not other_player_has_star and randi() % 100 == 0:
			emit_signal("use_item")
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
		var pressed = null
		
		if input.left:
			button_pressed_already = true
			pressed = enums.DIRECTION.LEFT
		
		if input.right and not button_pressed_already:
			button_pressed_already = true
			pressed = enums.DIRECTION.RIGHT
		
		if input.up and not button_pressed_already:
			button_pressed_already = true
			pressed = enums.DIRECTION.UP
		
		if input.down and not button_pressed_already:
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
		if input.a:
			holder.swap_cursor()
		
		if input.y:
			holder.tab()
		
		if input.x:
			emit_signal("use_item")

func _process(_delta):
	animation_timer += 1
	if animation_timer % 60 < 30:
		$Wall/Win.position.y += (-294 - $Wall/Win.position.y) * .4
	else:
		$Wall/Win.position.y += (-289 - $Wall/Win.position.y) * .4
	if animation_timer % 10 < 5:
		$Wall/Loss.position.y += (-295 - $Wall/Loss.position.y) * .4
	else:
		$Wall/Loss.position.y += (-293 - $Wall/Loss.position.y) * .4
