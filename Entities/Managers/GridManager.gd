extends TileMap

class_name GridManager

var astar: AStar2D

signal grid_refreshed

func _ready():
	astar = AStar2D.new()
	generate_grid()
	
func generate_grid():
	astar.clear()
	
	# Get the used area of the tilemap
	var size: Vector2 = get_used_rect().size
	
	# Prepare astar area
	astar.reserve_space(size.x * size.y)
	
	# Build Grid by mapping every tile to a point (grid cell)
	for x in size.x:
		for y in size.y:
			var tile_position = Vector2(x, y)
			astar.add_point(get_tile_id(tile_position), map_to_world(tile_position), 1)
			
	# Register Neighbours
	for x in size.x:
		for y in size.y:
			var id = get_tile_id(Vector2(x, y))
			var peek_tile_id
			
			# Neighbours (UP, DOWN, LEFT, RIGHT)
			peek_tile_id = get_tile_id(Vector2(x, y - 1))
			if astar.has_point(peek_tile_id):
				astar.connect_points(id, peek_tile_id, false)

			peek_tile_id = get_tile_id(Vector2(x, y + 1))
			if astar.has_point(peek_tile_id):
				astar.connect_points(id, peek_tile_id, false)
				
			peek_tile_id = get_tile_id(Vector2(x - 1, y))
			if astar.has_point(peek_tile_id):
				astar.connect_points(id, peek_tile_id, false)

			peek_tile_id = get_tile_id(Vector2(x + 1, y))
			if astar.has_point(peek_tile_id):
				astar.connect_points(id, peek_tile_id, false)
			
			# Reserve points with tiles
			if get_cell(x, y) != INVALID_CELL:
				astar.set_point_disabled(id, true)
				
	emit_signal("grid_refreshed")
	
func get_tile_id(tile_pos: Vector2) -> int:
	tile_pos = tile_pos - get_used_rect().position
	
	return int(tile_pos.x + (tile_pos.y * get_used_rect().size.x))
	
func free_cell(pos: Vector2):
	var mapPos = world_to_map(pos)
	var point_id = get_tile_id(mapPos)
	
	if astar.has_point(point_id):
		astar.set_point_disabled(point_id, false)

func reserve_cell(pos: Vector2):
	var mapPos = world_to_map(pos)
	var point_id = get_tile_id(mapPos)
	
	if astar.has_point(point_id):
		astar.set_point_disabled(point_id, true)
	
func can_move_to(pos: Vector2) -> bool:
	var mapPos = world_to_map(pos)
	var point_id = get_tile_id(mapPos)
	
	return astar.has_point(point_id) and ! astar.is_point_disabled(point_id)
	
func get_move_path(current_pos: Vector2, target_pos: Vector2) -> Array:
	var start_id = get_tile_id(world_to_map(current_pos))
	var target_id = get_tile_id(world_to_map(target_pos))
	
	if astar.has_point(start_id) && astar.has_point(target_id):
		return Array(astar.get_point_path(start_id, target_id))
	return []

func _on_Player_moved():
	for child in get_children():
		if child.has_method("move_towards_player"):
			child.move_towards_player()
