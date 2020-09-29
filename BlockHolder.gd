extends Node2D

var cursor_p = Vector2(4,-4)
var preview_blocks = []

const width = 6
const height = 12
const block_size = 16
const base_time = 105
const additional_block_time = 10
const falling_time = 20
var block_graphics = {
	enums.BLOCKTYPE.RED: load("res://paneldepon/red.tres"),
	enums.BLOCKTYPE.BLUE: load("res://paneldepon/blue.tres"),
	enums.BLOCKTYPE.GREEN: load("res://paneldepon/green.tres"),
	enums.BLOCKTYPE.YELLOW: load("res://paneldepon/yellow.tres"),
	enums.BLOCKTYPE.PURPLE: load("res://paneldepon/purple.tres"),
	enums.BLOCKTYPE.CYAN: load("res://paneldepon/cyan.tres"),
	enums.BLOCKTYPE.ITEM: load("res://paneldepon/item.tres")
}
var trash_graphics = {
	Vector2(1,1): load("res://characters/lip/1.png"),
	Vector2(3,1): load("res://characters/lip/2.png"),
	Vector2(4,1): load("res://characters/lip/3.png"),
	Vector2(5,1): load("res://characters/lip/4.png"),
	Vector2(6,1): load("res://characters/lip/5.png"),
	Vector2(6,2): load("res://characters/lip/6.png")
}
var chain_graphics = {
	2: load("res://chain/2.png"),
	3: load("res://chain/3.png"),
	4: load("res://chain/4.png"),
	5: load("res://chain/5.png"),
	6: load("res://chain/6.png"),
	7: load("res://chain/7.png"),
	8: load("res://chain/8.png"),
	9: load("res://chain/9.png"),
}
var combo_graphics = {
	4: load("res://combo/4.png"),
	5: load("res://combo/5.png"),
	6: load("res://combo/6.png"),
	7: load("res://combo/7.png"),
	8: load("res://combo/8.png"),
	9: load("res://combo/9.png"),
}
var severity_sizes = [Vector2(3,1), Vector2(4,1), Vector2(5,1), Vector2(6,1), Vector2(6,2)]

var progress = 0
var rand

var block_children
var block_children_null

var has_lost = false
var has_started = false

var match_sets = []

var cursor_target = Vector2(2, 7)
var block_targets = []
var ai_stalling = 0
var first_time = true

func _ready():
	pass

var colors = []

func set_color_set(p_set):
	match p_set:
		enums.COLORSET.EASY_SINGLE:
			colors = [enums.BLOCKTYPE.RED, enums.BLOCKTYPE.BLUE, enums.BLOCKTYPE.GREEN, enums.BLOCKTYPE.PURPLE,
				enums.BLOCKTYPE.YELLOW]
		enums.COLORSET.HARD_SINGLE:
			colors = [enums.BLOCKTYPE.RED, enums.BLOCKTYPE.BLUE, enums.BLOCKTYPE.GREEN, enums.BLOCKTYPE.PURPLE,
				enums.BLOCKTYPE.YELLOW, enums.BLOCKTYPE.CYAN]
		enums.COLORSET.EASY_MULTI:
			colors = [enums.BLOCKTYPE.RED, enums.BLOCKTYPE.BLUE, enums.BLOCKTYPE.GREEN, enums.BLOCKTYPE.PURPLE,
				enums.BLOCKTYPE.YELLOW, enums.BLOCKTYPE.ITEM]
		enums.COLORSET.HARD_MULTI:
			colors = [enums.BLOCKTYPE.RED, enums.BLOCKTYPE.BLUE, enums.BLOCKTYPE.GREEN, enums.BLOCKTYPE.PURPLE,
				enums.BLOCKTYPE.YELLOW, enums.BLOCKTYPE.CYAN, enums.BLOCKTYPE.ITEM]

func get_random_color():
	var color
	while color == null or (color != enums.BLOCKTYPE.ITEM and rand.randi() %7 < 3):
		color = colors[rand.randi() % (colors.size())]
	return color

func shuffle_list(list):
	var shuffledList = [] 
	var indexList = range(list.size())
	for _i in range(list.size()):
		var x = randi() % indexList.size()
		shuffledList.append(list[indexList[x]])
		indexList.remove(x)
	return shuffledList

func block_comparison(a, b):
	if a.p.y > b.p.y:
		return true
	else:
		return a.p.x > b.p.x

func update_blocks():
	block_children = []
	block_children_null = {null: null}
	for i in range(0, width):
		for e in range(0, height):
			block_children_null[Vector2(i,e)] = null
	for child in get_children():
		if child.get("is_block") != null:
			if not child.preview and not child.removed:
				block_children.append(child)
				for i in range(child.p.x, child.p.x + child.size.x):
					for e in range(child.p.y, child.p.y + child.size.y):
						block_children_null[Vector2(i,e)] = child
				block_children_null[child.p] = child

func get_blocks(do_null):
	if block_children == null:
		update_blocks()
	if do_null:
		return block_children_null
	else:
		return block_children

func get_block(index):
	return get_blocks(true)[index]

func get_p_adjacent_null(index, direction):
	var result = index
	match direction:
		enums.DIRECTION.LEFT:
			if (result.x - 1) >= 0:
				result.x -= 1
			else:
				return null
		enums.DIRECTION.RIGHT:
			if (result.x + 1) < width:
				result.x += 1
			else:
				return null
		enums.DIRECTION.UP:
			if (result.y - 1) >= 0:
				result.y -= 1
			else:
				return null
		enums.DIRECTION.DOWN:
			if (result.y + 1) < height:
				result.y += 1
			else:
				return null
	return result

func get_p_adjacent(index, direction):
	var result = index
	match direction:
		enums.DIRECTION.LEFT:
			if (result.x - 1) >= 0:
				result.x -= 1
		enums.DIRECTION.RIGHT:
			if (result.x + 1) < width:
				result.x += 1
		enums.DIRECTION.UP:
			if (result.y - 1) >= 0:
				result.y -= 1
		enums.DIRECTION.DOWN:
			if (result.y + 1) < height:
				result.y += 1
	return result

func get_adjacent_blocks(block):
	var arr = []
	for direction in range(0,3):
		var block_adj = get_p_adjacent_null(block.p, direction)
		if block_adj != null and get_block(block_adj) != null:
			arr.append(get_block(block_adj))
	return arr

func get_position_vector(v):
	return v * block_size - Vector2(0, floor(block_size * progress))

func move_cursor(direction):
	var new_p = get_p_adjacent(cursor_p, direction)
	if new_p.x > (width - 2):
		new_p.x -= 1
	if new_p.y < 1:
		new_p.y = 1
	if new_p == cursor_p:
		return false
	cursor_p = new_p
	return true 

func make_trash_block(size):
	var trash = load("Block.tscn").instance()
	trash.block_graphics = block_graphics
	trash.trash_graphics = trash_graphics
	trash.size = size
	trash.p = Vector2(randi() % (width - int(size.x - 1)), 0)
	trash.type = enums.BLOCKTYPE.TRASH
	add_child(trash)
	update_blocks()

func generate_trash_blocks(severity):
	var size = severity_sizes[min(4, severity)]
	if get_max_height(true) + size.y < height:
		make_trash_block(size)

func swap_cursor():
	return swap(cursor_p)

func swap_random():
	var pos = Vector2(randi() % (width - 1), randi() % height)
	return swap(pos)

func swap(pos):
	var first = get_block(pos)
	var second = get_block(pos + Vector2(1, 0))
	
	var block_above = get_block(get_p_adjacent_null(pos, enums.DIRECTION.UP))
	if block_above != null:
		if block_above.drop_timer > 0:
			return false
	block_above = get_block(get_p_adjacent_null(pos + Vector2(1, 0), enums.DIRECTION.UP))
	if block_above != null:
		if block_above.drop_timer > 0:
			return false
	
	if first != null:
		if first.drop_timer > 0:
			return false
		if first.matching_timer > 0:
			return false
		if first.popping_timer > 0:
			return false
		if first.type == enums.BLOCKTYPE.TRASH:
			return false
		if second != null:
			if second.drop_timer > 0:
				return false
			if second.matching_timer > 0:
				return false
			if second.popping_timer > 0:
				return false
			if second.type == enums.BLOCKTYPE.TRASH:
				return false
		first.p = pos + Vector2(1,0)
	if second != null:
		if second.drop_timer > 0:
			return false
		if second.matching_timer > 0:
			return false
		if second.popping_timer > 0:
			return false
		if second.type == enums.BLOCKTYPE.TRASH:
			return false
		second.p = pos
	return true
	
	for block in (get_column(pos.x) + get_column(pos.x + 1)):
		if block.p.y <= pos.y:
			block.fell_from_match = false
	
	update_blocks()

func drop():
	var sorted_blocks = get_blocks(false)
	for block in sorted_blocks:
		var bottom_block
		for i in range(0, block.size.x):
			var temp_block = get_block(get_p_adjacent_null((
				block.p + Vector2(i, block.size.y - 1)), enums.DIRECTION.DOWN))
			if temp_block != null:
				bottom_block = temp_block
		if bottom_block == null:
			if block.p.y + + block.size.y < height and block.popping_timer == 0 and block.matching_timer == -1:
				block.drop()
			else:
				block.on_bottom(0)
		else:
			block.on_bottom(bottom_block.drop_timer)

func going_to_lose():
	return get_max_height(true) >= height - 1

func generate_preview_blocks():
	for block in preview_blocks:
		remove(block)
	preview_blocks = []
	var last_two = [null, null]
	for i in range(0, width):
		var block = load("Block.tscn").instance()
		
		block.block_graphics = block_graphics
		block.trash_graphics = trash_graphics
		block.p = Vector2(i, height)
		var stop_loop = false
		while not stop_loop:
			block.type = get_random_color()
			stop_loop = true
			if last_two[0] != null and last_two[1] != null:
				if last_two[0] == last_two[1] and last_two[1] == block.type:
					stop_loop = false
			var block_above = get_block(get_p_adjacent_null(block.p, enums.DIRECTION.UP)) 
			if block_above != null:
				if block_above.type == block.type:
					stop_loop = false
		block.preview = true
		add_child(block)
		preview_blocks.append(block)
		block.position = get_position_vector(block.p + Vector2(0,1))
		last_two[0] = last_two[1]
		last_two[1] = block.type
	update_blocks()

func push_preview_blocks():
	if going_to_lose():
		return false
	for block in preview_blocks:
		block.preview = false
	update_blocks()
	for block in get_blocks(false):
		block.p.y -= 1
	cursor_p.y -= 1
	if cursor_p.y < 1:
		cursor_p.y = 1
	preview_blocks = []
	return true

func set_progress(progress_p):
	progress = progress_p

func get_column_height(column, include_trash):
	var count = 0
	for i in range(0, height):
		var block = get_block(Vector2(column, i))
		if block != null:
			if block.drop_timer == 0 and (include_trash or block.type != enums.BLOCKTYPE.TRASH):
				count = height - i
				break
	return count

func get_max_height(include_trash):
	var count = 0
	for i in range(0, width):
		var height = get_column_height(i, include_trash)
		if height > count:
			count = height
	return count

func get_min_height(include_trash):
	var count = height + 1
	var col
	for i in range(0, width):
		var height = get_column_height(i, include_trash)
		if height < count:
			count = height
			col = i
	return {"count": count, "column": col}

func lose_game():
	for block in get_blocks(false) + preview_blocks:
		block.lose()
	has_lost = true

func trash_break(block):
	var last_two = [null, null]
	var plus = 0
	for i in range(0, block.size.x):
		for e in range(0, block.size.y):
			plus += 5
			var block_new = load("Block.tscn").instance()
			
			block_new.block_graphics = block_graphics
			block_new.trash_graphics = trash_graphics
			block_new.p = Vector2(i, e) + block.p
			var stop_loop = false
			while not stop_loop:
				block_new.type = get_random_color()
				stop_loop = true
				if last_two[0] != null and last_two[1] != null:
					if last_two[0] == last_two[1] and last_two[1] == block_new.type:
						stop_loop = false
			add_child(block_new)
			block_new.pop(base_time + plus)
			block_new.position = get_position_vector(block_new.p)
			last_two[0] = last_two[1]
			last_two[1] = block_new.type
	remove(block)

func check_matches():
	var current_matches = {}
	for i in range(0, width + height):
		var last_blocks = []
		var r
		if i < width:
			r = range(0, height)
		else:
			r = range(0, width)
		for e in r:
			var block
			if i < width:
				block = get_block(Vector2(i, e))
			else:
				block = get_block(Vector2(e,i - width))
			if block != null: 
				if not block.can_match():
					last_blocks = []
				else:
					if last_blocks.size() == 0 or last_blocks[0].type == block.type:
						last_blocks.append(block)
					else:
						last_blocks = [block]
					if last_blocks.size() >= 3:
						for x in last_blocks:
							current_matches[x] = 1
			else:
				last_blocks = []
	
	var i = 0
	var current_matches_array = []
	for block in current_matches:
		current_matches_array.append(block)
	current_matches_array.sort_custom(self, "block_comparison")

	var chain_progress = false
	var item_matched
	for block in current_matches_array:
		block.set_match(base_time + i * additional_block_time)
		if block.type == enums.BLOCKTYPE.ITEM:
			item_matched = true
		if block.last_fell > 0 and block.fell_from_match:
			chain_progress = true

		for bl in get_adjacent_blocks(block):
			if bl.type == enums.BLOCKTYPE.TRASH:
				trash_break(bl)
		i += 1
	if current_matches_array.size() > 0:
		match_sets.append(current_matches_array)
	
	update_blocks()
	return {"matches": current_matches_array, "chain": chain_progress, "item": item_matched}

func update_matches():
	var blocks_remaining = false
	var sets_to_remove = []
	
	for match_set in match_sets:
		var set_done = true
		for block in match_set:
			if block.update_match():
				set_done = false
		if set_done:
			for block in match_set:
				remove(block)
			sets_to_remove.append(match_set)
		else:
			blocks_remaining = true
	
	for match_set in sets_to_remove:
		match_sets.remove(match_sets.find(match_set))
	
	for block in get_blocks(false):
		if not block.update_popping():
			blocks_remaining = true
	return blocks_remaining

func remove(block):
	var block_above = get_block(get_p_adjacent_null(block.p, enums.DIRECTION.UP))
	if block_above != null:
		block_above.drop_timer = 10
	block.remove()
	update_blocks()

func show_chain(chain, position, is_chain):
	var node = load("ChainCombo.tscn").instance()
	node.position = get_position_vector(position) + Vector2(0, -15)
	if node.position.x < 12:
		node.position.x = 12
	if node.position.x > 84:
		node.position.x = 84
	if is_chain:
		node.texture = chain_graphics[max(2, min(9, chain))]
	else:
		node.texture = combo_graphics[max(4, min(9, chain))]
	add_child(node)

func destroy_all_trash():
	for block in get_blocks(false):
		if block.type == enums.BLOCKTYPE.TRASH:
			trash_break(block)

func tab():
	if not going_to_lose():
		push_preview_blocks()
		generate_preview_blocks()

###########
### ai
###########

func toggle():
	var block = get_block(cursor_p)
	if block == null:
		return
	if block.type + 2 > colors.size():
		block.type = 0
	else:
		block.type += 1

func get_direction(target, obj):
	if target.y > obj.y:
		return enums.DIRECTION.DOWN
	if target.y < obj.y:
		return enums.DIRECTION.UP
	if target.x < obj.x:
		return enums.DIRECTION.LEFT
	if target.x > obj.x:
		return enums.DIRECTION.RIGHT
	return null

func get_row(id):
	if id == height:
		return preview_blocks
	var arr = []
	for block in get_blocks(false):
		if block.p.y == id:
			arr.append(block)
	return arr

func get_column(id):
	var arr = []
	for block in get_blocks(false):
		if block.p.x == id:
			arr.append(block)
	return arr

func get_new_targets():
	if randi() % 4 == 0:
		var minimum_col = get_min_height(false)
		if minimum_col.count + 1 < get_max_height(false):
			for i in range(0, height):
				var row = get_row(i)
				for z in range(0, row.size()):
					var block = row[z]
					if block.type != enums.BLOCKTYPE.TRASH:
						block_targets.append({"target": minimum_col.column, "block": block})
						return
	
	for threshold in range(6, 2 + randi() % 3 + randi() % 2, -1):
		match (randi() % 2):
			0: 
				for i in range(0, height):
					var color_dict = {}
					for x in range(0, 7):
						color_dict[x] = []
					var row = get_row(i)
					for block in row:
						if not block.matching_timer > 0 and not block.type == enums.BLOCKTYPE.TRASH:
							color_dict[block.type].append(block)
					var target_color
					for color in color_dict:
						if color_dict[color].size() > threshold - 1:
							target_color = color
					if target_color != null:
						var offset = color_dict[target_color][0].p.x
						if color_dict[target_color].size() + offset > width - 1:
							offset -= color_dict[target_color].size() + offset - width
						for block in color_dict[target_color]:
							block_targets.append({"target": offset, "block": block})
							offset += 1
						break
			1:
				var rows = [null, null, null, null, null]
				for i in range(0, height + 1):
					var color_dict = {}
					for x in range(0, 7):
						color_dict[x] = []
					var row = get_row(i)
					for block in row:
						if not block.matching_timer > 0 and not block.type == enums.BLOCKTYPE.TRASH:
							color_dict[block.type].append(block)
					for color in color_dict:
						color_dict[color].sort_custom(self, "block_comparison")
					rows.append(color_dict)
					rows.remove(0)
					
					var unnull_rows = []
					for r in rows:
						if r != null:
							unnull_rows.append(r)
					if unnull_rows.size() > threshold - 1:
						var total_colors = {}
						for x in range(0, 7):
							total_colors[x] = 0
							for r in unnull_rows:
								if r[x].size() > 0:
									total_colors[x] += 1
								else:
									total_colors[x] = 0
						var target_colors = []
						for color in total_colors:
							if total_colors[color] > threshold - 1:
								target_colors.append(color)
						target_colors = shuffle_list(target_colors)
						var z = 0
						for color in target_colors:
	#						var position_x 
	#						if target_colors.size() == 2:
	#							position_x = color_dict[color][0].p.x
	#						position_x += z
							for r in range(i + 1 - unnull_rows.size(), i + 1):
								var r_blocks = get_row(r)
								var cease = false
								for block in r_blocks:
									if block.type == color and not cease:
										block_targets.append({"target": color_dict[target_colors[0]][0].p.x + z, "block": block})
										cease = true
							z += 1

func ai():
	if not ai_cursor():
		if block_targets.size() == 0:
			get_new_targets()
			ai_stalling += 1
			if ai_stalling > 7:
				if get_max_height(true) < 5:
					tab()
				ai_stalling = -5
		else:
			var t = block_targets[0]["target"]
			var b = block_targets[0]["block"]
			if b == null or b.p.x == t or b.matching_timer > 0 or (b.type == enums.BLOCKTYPE.TRASH) or (b.p.y == height) or t < 0 or t > width - 1:
				block_targets.remove(0)
			else:
				if t < b.p.x:
					if cursor_target != Vector2(b.p.x - 1, b.p.y):
						ai_stalling = 0
					cursor_target = Vector2(b.p.x - 1, b.p.y)
				elif t > b.p.x:
					if cursor_target != Vector2(b.p.x, b.p.y):
						ai_stalling = 0
					cursor_target = Vector2(b.p.x, b.p.y)
				if ((get_block(cursor_target) != null and get_block(cursor_target).matching_timer > 0) or
					(get_block(cursor_target + Vector2(1, 0)) != null and get_block(cursor_target + Vector2(1, 0)).matching_timer > 0)):
					block_targets.remove(0)
					cursor_target = null

func ai_cursor():
	if cursor_target == null:
		return false
	var direction = get_direction(cursor_target, cursor_p)
	if direction != null:
		move_cursor(direction)
	else:
		cursor_target = null
		if first_time or not swap_cursor():
			first_time = false
			if block_targets.size() > 0:
				block_targets.remove(0)
	return true

func _process(_delta):
	if has_lost:
		$Cursor.modulate.a -= $Cursor.modulate.a * .1
	if has_started:
		$Cursor.position += (get_position_vector(cursor_p) - $Cursor.position) * .4
	
	for block in (get_blocks(false) + preview_blocks):
		block.position += (get_position_vector(block.p) + Vector2(8 * block.size.x, 8 * block.size.y) - block.position) * .6
		if get_column_height(block.p.x, true) > height - 2:
			block.set_wobble()
			block.going_to_lose = true
		else:
			block.going_to_lose = false
