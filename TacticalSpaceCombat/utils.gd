class_name Utils extends Node


## Converts `offset` coordinates to an integer index.
static func xy_to_index(width: int, offset: Vector2i) -> int:
	return int(offset.x + width * offset.y)


## Converts an integer `index` to `Vector2(x, y)` coordinates.
static func index_to_xy(width: int, index: int) -> Vector2i:
	#prints("Width", width, "Index", index, " -> ", Vector2i(index % width, index / width))
	return Vector2i(index % width, index / width)
