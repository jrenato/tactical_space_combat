@tool
## Represents a room in the ship.
class_name Room extends Area2D

## Room size in `TileMap` cells.
# We'll use the setter function to resize the room's collision shapes.
@export var size: Vector2i = Vector2i.ONE: set = set_size

## Reference to the ship's `TileMap` to convert from world to map
## positions and the other way around.
var _tilemap: TileMapLayer = null

## Room area in _TileMap_ cells =`size.x * size.y`.
var _area: int = 0

## Positions in `TileMap` coordinates for the top-left and bottom-right corners
## of the room.
var _top_left := Vector2i.ZERO
var _bottom_right := Vector2i.ZERO

## We'll keep track of our iteration index with this property.
var _iter_index: int = 0

## We'll update this node with the `set_size()` setter function.
@onready var collision_shape: CollisionShape2D = %CollisionShape2D


## Initializes the room's properties in the `tilemap`'s coordinates.
func setup(tilemap: TileMapLayer) -> void:
	_tilemap = tilemap
	_setup_extents()

	_area = size.x * size.y

	# With the room's size, we can calculate the coordinates of its top-left and
	# bottom-right corners.
	_top_left = _tilemap.local_to_map(position - collision_shape.shape.extents)
	_bottom_right = _top_left + size


func _setup_extents() -> void:
	# Since we run this code in the editor, we first make sure that `_tilemap`
	# is an actual reference to the `TileMap` node.
	if _tilemap != null:
		collision_shape.shape.set_size(Vector2i(size) * _tilemap.tile_set.tile_size)


## This setter function gets called whenever we change the _Size_ property
## in the _Inspector_.
func set_size(value: Vector2i) -> void:
	# This operation ensures the size never goes below `Vector2(1, 1)`.
	for axis in [Vector2i.AXIS_X, Vector2i.AXIS_Y]:
		# We make sure to not let the value go below
		size[axis] = max(1, value[axis])
	# Every time we change the size, we update the collision shape's extents.
	_setup_extents()


# The `arg` parameter is undocumented in the official manual, but we don't
# need it for this iterator.
func _iter_init(_arg) -> bool:
	_iter_index = 0
	return _iter_is_running()


# Increments the iterator.
func _iter_next(_arg) -> bool:
	_iter_index += 1
	return _iter_is_running()


# Calculates and returns the iterator's current value.
func _iter_get(_arg) -> Vector2i:
	# Our iterator works with an index which we convert to a cell coordinate
	# inside our room. This is where we make use of our new `Utils` class.
	var offset: Vector2i = Utils.index_to_xy(size.x, _iter_index)
	return _top_left + offset


# As we need to check whether the iterator should keep running in two places,
# we put that expression inside a function.
func _iter_is_running() -> bool:
	return _iter_index < _area
