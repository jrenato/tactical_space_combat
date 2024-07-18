extends TileMapLayer

var _astar: AStar2D = AStar2D.new()
var _size: Vector2 = Vector2.ZERO


func setup(rooms: Node2D, doors: Node2D) -> void:
	_size = get_used_rect().size

	# This loop detects and connects all the points inside each room, but not
	# across rooms.
	for room: Room in rooms.get_children():
		# We iterate over the points using our custom `Room` iterator.
		for point in room:
			# We convert each point from `Vector2(x, y)` coordinates into a unique index
			# using `Utils.xy_to_index()`. This conversion requires the width of the
			# `TileMap` which we get from `_size.x`
			var id := Utils.xy_to_index(_size.x, point)
			# We add the point and its unique ID to the AStar graph.
			_astar.add_point(id, point)
			# For each valid `neighbor` position, we add it to the `AStar2D`
			# algorithm and connect it with the current `point` via its `id`.
			for neighbor in _get_neighbors(room, point):
				var neighbor_id := Utils.xy_to_index(_size.x, neighbor)
				_astar.add_point(neighbor_id, neighbor)
				_astar.connect_points(id, neighbor_id)
		# Here, we connect rooms through doors. Doors are between two cells, so we
	# need to offset their position by half a cell forward and backward, based
	# on their position and orientation, to find their neighbors.
	# I explain how this works in greater detail below.
	var offset := tile_set.tile_size / 2 * Vector2i.UP
	for door in doors.get_children():
		# We use the door's transform to apply the offset forward and backward,
		# based on the door's orientation.
		#
		# The `Transform2D.xform()` method applies the node's transform to the
		# passed vector.
		#
		# In other words, it applies the position, rotation, and scale of each
		# door to the `offset` vector, making it point to the cells facing each
		# door.
		var id1 := Utils.xy_to_index(_size.x, local_to_map(door.transform * Vector2(offset)))
		var id2 := Utils.xy_to_index(_size.x, local_to_map(door.transform * Vector2(-offset)))
		_astar.connect_points(id1, id2)


## Returns neighboring positions within a `room` given the input `point` location.
func _get_neighbors(room: Room, point: Vector2) -> Array:
	var out := []
	# We traverse the list of valid `DIRECTIONS` defined in our `Utils` class.
	for offset in Utils.DIRECTIONS:
		# Since these are directions, we first need to add them to the position of
		# the `point` location.
		offset += point
		# We have yet to define this function, we'll do it in a second.
		if room.has_point(offset):
			# In case the `room` contains the calculated position, it means it's a valid
			# neighboring tile so we add it to the array.
			out.push_back(offset)
	return out


## Finds a path between two cells using AStar and returns a `Curve2D` for units to follow.
func find_path(point1: Vector2i, point2: Vector2i) -> Curve2D:
	var out := Curve2D.new()
	# Given the two points we first calculate the 1D index IDs
	var id1 := Utils.xy_to_index(_size.x, point1)
	var id2 := Utils.xy_to_index(_size.x, point2)

	if _astar.has_point(id1) and _astar.has_point(id2):
		# If these are valid points in our `AStar2D` object then we
		# get the `path` between these points
		var path := _astar.get_point_path(id1, id2)
		# We drop the first point in `path` because that's the location of the tile
		# the unit is in, but we'd like to add the location of the unit instead.
		# That's because if the unit is already moving, we don't want it to jump to the
		# tile first before starting to move again.
		#
		# We make sure to convert to world coordinates considering the centers of
		# the tiles.
		for i in range(1, path.size()):
			out.add_point(Vector2i(map_to_local(path[i])))
	return out
