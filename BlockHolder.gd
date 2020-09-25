extends Control

signal removed

var cursor_p = Vector2(2,5)
var preview_blocks = []

const width = 6
const height = 12
const block_size = 16
const base_time = 85
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
	Vector2(1,1): load("res://lip/1.png"),
	Vector2(3,1): load("res://lip/2.png"),
	Vector2(4,1): load("res://lip/3.png"),
	Vector2(5,1): load("res://lip/4.png"),
	Vector2(6,1): load("res://lip/5.png"),
	Vector2(6,2): load("res://lip/6.png")
}
var severity_sizes = [Vector2(3,1), Vector2(4,1), Vector2(5,1), Vector2(6,1), Vector2(6,2)]

var progress = 0
var rand

var match_groups = 0

var block_children

var has_lost = false

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
	return colors[rand.randi() % (colors.size())]

func shuffle_list(list):
	var shuffledList = [] 
	var indexList = range(list.size())
	for i in range(list.size()):
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
	for child in get_children():
		if child.get("is_block") != null:
			if not child.preview and not child.removed:
				block_children.append(child)

func get_blocks():
	if block_children == null:
		update_blocks()
	return block_children

func get_block(index):
	if index == null:
		return
	for block in get_blocks():
		if ((block.p.x <= index.x) and (block.p.x + block.size.x > index.x)
			and (block.p.y <= index.y) and (block.p.y + block.size.y > index.y)):
			return block
	return null

# from bottom to top, right to left
func get_blocks_sorted():
	var blocks = get_blocks()
	blocks.sort_custom(self, "block_comparison")
	return blocks

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
	var size = severity_sizes[severity]
	make_trash_block(size)

func swap():
	var first = get_block(cursor_p)
	var second = get_block(cursor_p + Vector2(1, 0))
	
	var block_above = get_block(get_p_adjacent_null(cursor_p, enums.DIRECTION.UP))
	if block_above != null:
		if block_above.drop_timer > 0:
			return
	block_above = get_block(get_p_adjacent_null(cursor_p + Vector2(1, 0), enums.DIRECTION.UP))
	if block_above != null:
		if block_above.drop_timer > 0:
			return
	
	if first != null:
		if first.drop_timer > 0:
			return
		if first.matching_timer > 0:
			return
		if first.type == enums.BLOCKTYPE.TRASH:
			return
		if second != null:
			if second.drop_timer > 0:
				return
			if second.matching_timer > 0:
				return
			if second.type == enums.BLOCKTYPE.TRASH:
				return
		first.p = cursor_p + Vector2(1,0)
	update_blocks()
	if second != null:
		if second.drop_timer > 0:
			return
		if second.matching_timer > 0:
			return
		if second.type == enums.BLOCKTYPE.TRASH:
			return
		second.p = cursor_p
	update_blocks()

func drop():
	var sorted_blocks = get_blocks_sorted()
	for block in sorted_blocks:
		var bottom_block
		for i in range(0, block.size.x):
			var temp_block = get_block(get_p_adjacent_null((
				block.p + Vector2(i, block.size.y - 1)), enums.DIRECTION.DOWN))
			if temp_block != null:
				bottom_block = temp_block
		if bottom_block == null:
			if block.popping_timer != 0:
				print(block.popping_timer)
			if block.p.y + + block.size.y < height and block.popping_timer == 0:
				block.drop()
			else:
				block.on_bottom(0)
		else:
			block.on_bottom(bottom_block.drop_timer)

func going_to_lose():
	return get_max_height() >= height - 1

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
	for block in get_blocks():
		block.p.y -= 1
	cursor_p.y -= 1
	if cursor_p.y < 1:
		cursor_p.y = 1
	preview_blocks = []
	return true

func set_progress(progress_p):
	progress = progress_p

func set_match(block, time, additional, match_group):
	var final = block.set_match(time, additional, match_group)
	var plus = 0
	if block.type == enums.BLOCKTYPE.TRASH:
		var last_two = [null, null]
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
				block_new.pop(time + additional + plus)
				block_new.position = get_position_vector(block_new.p)
				last_two[0] = last_two[1]
				last_two[1] = block_new.type
	for block_adj in get_adjacent_blocks(block):
		if block_adj.type == enums.BLOCKTYPE.TRASH and not block_adj.matching:
			set_match(block_adj, time, additional, match_group)
	return final

func get_column_height(column):
	var count = 0
	for i in range(0, height):
		var block = get_block(Vector2(column, i))
		if block != null:
			if block.drop_timer == 0:
				count = height - i
				break
	return count

func get_max_height():
	var count = 0
	for i in range(0, width):
		var height = get_column_height(i)
		if height > count:
			count = height
	return count

func get_min_height():
	var count = height + 1
	var col
	for i in range(0, width):
		var height = get_column_height(i)
		if height < count:
			count = height
			col = i
	return {"count": count, "column": col}

func lose_game():
	for block in get_blocks() + preview_blocks:
		block.lose()
	has_lost = true

func check_matches():
	var total_matching = 0
	var last_block
	# updown
	for i in range(0, width):
		var last_blocks = [null, null]
		var falling = false
		for e in range(0, height):
			var block = get_block(Vector2(i, e))
			if block != null:
				if block.drop_timer > 0:
					falling = true
				var time = base_time
				if falling:
					time += falling_time
				if (block.matching_timer == -1 or block.matching_now) and block.type != enums.BLOCKTYPE.TRASH:
					if last_blocks[0] != null and last_blocks[1] != null:
						if block.type == last_blocks[1].type and last_blocks[0].type == last_blocks[1].type:
							if set_match(last_blocks[0], time, total_matching, match_groups + 1):
								total_matching += 1
							if set_match(last_blocks[1], time, total_matching, match_groups + 1):
								total_matching += 1
							if set_match(block, time, total_matching, match_groups + 1):
								total_matching += 1
							last_block = block
				last_blocks[0] = last_blocks[1]
				if (block.matching_timer == -1 or block.matching_now) and block.type != enums.BLOCKTYPE.TRASH:
					last_blocks[1] = block
				else:
					last_blocks[1] = null
			else:
				last_blocks[0] = last_blocks[1]
				last_blocks[1] = null
		
	for i in range(0, height):
		var last_blocks = [null, null]
		var falling = false
		for e in range(0, width):
			var block = get_block(Vector2(e, i))
			if block != null:
				if block.drop_timer > 0:
					falling = true
				var time = 40
				if falling:
					time += 20
				if (block.matching_timer == -1 or block.matching_now) and block.last_fell == 0 and block.type != enums.BLOCKTYPE.TRASH:
					if last_blocks[0] != null and last_blocks[1] != null:
						if block.type == last_blocks[1].type and last_blocks[0].type == last_blocks[1].type:
							if set_match(last_blocks[0], time, total_matching, match_groups + 1):
								total_matching += 1
							if set_match(last_blocks[1], time, total_matching, match_groups + 1):
								total_matching += 1
							if set_match(block, time, total_matching, match_groups + 1):
								total_matching += 1
							last_block = block
				last_blocks[0] = last_blocks[1]
				if ((block.matching_timer == -1 or block.matching_now) and block.last_fell == 0
					 and block.type != enums.BLOCKTYPE.TRASH):
					last_blocks[1] = block
				else:
					last_blocks[1] = null
			else:
				last_blocks[0] = last_blocks[1]
				last_blocks[1] = null
	update_blocks()
	if total_matching > 0:
		match_groups += 1
	return {"matches": total_matching, "block": last_block}

func toggle():
	var block = get_block(cursor_p)
	if block == null:
		return
	block.type += 1
	if block.type > 4:
		block.type = 0

func update_matches():
	var blocks_remaining = 0
	
	for i in range(0, match_groups + 1):
		var temp_remaining = 0
		var max_match = 0
		for block in get_blocks():
			if block.match_group == i:
				if block.matching:
					if not block.update_match():
						temp_remaining += 1
					if block.matching_visual_timer > max_match:
						max_match = block.matching_visual_timer
		for block in get_blocks():
			if block.match_group == i:
				if block.matching_timer > 0:
					block.matching_timer = max_match
		if temp_remaining == 0:
			for block in get_blocks():
				if block.match_group == i:
					if block.matching:
						remove(block)
		blocks_remaining += temp_remaining
	
	for block in get_blocks():
		if not block.update_popping():
			blocks_remaining += 1
	return blocks_remaining > 0

func remove(block):
	var block_above = get_block(get_p_adjacent_null(block.p, enums.DIRECTION.UP))
	if block_above != null:
		block_above.drop_timer = 10
	block.remove()
	emit_signal("removed")
	update_blocks()

###########
### ai
###########

func get_direction(target, obj):
	if target.x < obj.x:
		return enums.DIRECTION.LEFT
	if target.x > obj.x:
		return enums.DIRECTION.RIGHT
	if target.y > obj.y:
		return enums.DIRECTION.DOWN
	if target.y < obj.y:
		return enums.DIRECTION.UP
	return null

func get_row(id):
	if id == height:
		return preview_blocks
	var arr = []
	for block in get_blocks():
		if block.p.y == id:
			arr.append(block)
	return arr

func get_column(id):
	var arr = []
	for block in get_blocks():
		if block.p.x == id:
			arr.append(block)
	return arr

func get_new_targets():
	var minimum_col = get_min_height()
	if minimum_col.count + 1 < get_max_height():
		for i in range(0, height):
			var row = get_row(i)
			if row.size() != 0:
				var block = row[0]
				block_targets.append({"target": minimum_col.column, "block": block})
				return
	match (randi() % 2):
		0: 
			for i in range(0, height):
				var color_dict = {}
				for x in range(0, 7):
					color_dict[x] = []
				var row = get_row(i)
				for block in row:
					if not block.matching and not block.type == enums.BLOCKTYPE.TRASH:
						color_dict[block.type].append(block)
				var target_color
				for color in color_dict:
					if color_dict[color].size() > 2:
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
					if not block.matching and not block.type == enums.BLOCKTYPE.TRASH:
						color_dict[block.type].append(block)
				for color in color_dict:
					color_dict[color].sort_custom(self, "block_comparison")
				rows.append(color_dict)
				rows.remove(0)
				
				var unnull_rows = []
				for r in rows:
					if r != null:
						unnull_rows.append(r)
				if unnull_rows.size() > 2:
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
						if total_colors[color] > 2:
							target_colors.append(color)
					target_colors = shuffle_list(target_colors)
					var block_queue = []
					for color in target_colors:
						for r in range(i + 1 - unnull_rows.size(), i + 1):
							var r_blocks = get_row(r)
							var cease = false
							for block in r_blocks:
								if block.type == color and not cease:
									var e = color
#									if r == i - 2 and target_colors.size() > 1:
#										e = (e + 1) % 5
									block_targets.append({"target": color_dict[color][0].p.x, "block": block})
#									block_queue.append({"target": e + 1, "block": block})
									cease = true
						for command in block_queue:
							block_targets.append(command)

var cursor_target 
var block_targets = []
func ai():
	if cursor_target == null:
		if block_targets.size() == 0:
			get_new_targets()
		else:
			var t = block_targets[0]["target"]
			var b = block_targets[0]["block"]
			if b == null or b.p.x == t or b.matching or (b.type == enums.BLOCKTYPE.TRASH) or (b.p.y == height) or t < 0 or t > width - 1:
				block_targets.remove(0)
			else:
				if t < b.p.x:
					cursor_target = Vector2(b.p.x - 1, b.p.y)
				else:
					cursor_target = Vector2(b.p.x, b.p.y)
				if ((get_block(cursor_target) != null and get_block(cursor_target).matching) or
					(get_block(cursor_target + Vector2(1, 0)) != null and get_block(cursor_target + Vector2(1, 0)).matching)):
					block_targets.remove(0)
					cursor_target = null
	else:
		var direction = get_direction(cursor_target, cursor_p)
		if direction != null:
			move_cursor(direction)
		else:
			cursor_target = null
			swap()

func _process(_delta):
	if has_lost:
		$Cursor.modulate.a -= $Cursor.modulate.a * .1
	
	for block in (get_blocks() + preview_blocks):
		block.position += (get_position_vector(block.p) + Vector2(8 * block.size.x, 8 * block.size.y) - block.position) * .4
		if get_column_height(block.p.x) > height - 2:
			block.set_wobble()
			block.going_to_lose = true
		else:
			block.going_to_lose = false
	$Cursor.position += (get_position_vector(cursor_p) - $Cursor.position) * .4
