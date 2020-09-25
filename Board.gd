extends Control

onready var holder = $Blocks/BlockHolder

const press_speed_limit = 15
const press_speed_mod = 1
const speed_base = 500

var data
var is_multiplayer = false

var unpressed_timer = 0
var pressed_timer = 0
var last_pressed = 0

var row_timer = 0
var bonus_time = 0
var speed = 1
var next_speed = 1

var score = 0.0
var combo = 0

var ai_time = 1
var ai_timer = 0

var has_lost = false

var rand = RandomNumberGenerator.new()

func _ready():
	pass

func start(seed_to_use, player_data, multiplayer):
	rand.set_seed(seed_to_use)
	data = player_data
	is_multiplayer = multiplayer
	
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
	for i in range(0,5):
		holder.push_preview_blocks()
		holder.generate_preview_blocks()
	holder.connect("removed", self, "removed")

func removed():
	combo += 1
	var add_score = 10
	if combo > 3:
		add_score *= combo - 3
	score += add_score
	next_speed = floor(float(score) / 40)

func lose_game():
	has_lost = true
	holder.lose_game()

func stop_game():
	has_lost = true

func get_speed_timer():
	return speed_base #- floor(speed) * 2

var trash_timer = 0
func _physics_process(_delta):
	if has_lost:
		return
	holder.update_blocks()
	########################
	# block falling
	#######################
	holder.drop()
	var matches = holder.check_matches()
	if matches.matches > 0:
		print("Match:" + str(matches))

	if holder.update_matches():
		bonus_time += 1.2

	if bonus_time > 0:
		bonus_time -= 1
	else:
		row_timer += 1
		combo = 0
	
	if row_timer > get_speed_timer() or (not holder.going_to_lose() and Input.is_action_just_pressed("ui_focus_next")):
		row_timer = 0
		if holder.push_preview_blocks():
			holder.generate_preview_blocks()
		else:
			holder.generate_preview_blocks()
			lose_game()
			return
		speed = next_speed
	holder.set_progress(float(row_timer) / get_speed_timer())
	
	########### 
	# trash
	############
	if Input.is_action_just_pressed("trash"):
		holder.generate_trash_blocks(4)
	if Input.is_action_just_pressed("debug"):
		holder.toggle()
	
	if data.ai:
		ai_timer += 1
		if ai_timer > ai_time:
			ai_timer = 0
			holder.ai()
	else:
		
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
