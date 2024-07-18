class_name Utils extends Node

# A list of 8 directions: horizontal, vertical, and diagonal.
const DIRECTIONS := [
	Vector2.UP,
	Vector2.RIGHT + Vector2.UP,
	Vector2.RIGHT,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.LEFT + Vector2.DOWN,
	Vector2.LEFT,
	Vector2.LEFT + Vector2.UP
]

## Converts `offset` coordinates to an integer index.
static func xy_to_index(width: int, offset: Vector2i) -> int:
	return int(offset.x + width * offset.y)


## Converts an integer `index` to `Vector2(x, y)` coordinates.
static func index_to_xy(width: int, index: int) -> Vector2i:
	#prints("Width", width, "Index", index, " -> ", Vector2i(index % width, index / width))
	return Vector2i(index % width, index / width)
