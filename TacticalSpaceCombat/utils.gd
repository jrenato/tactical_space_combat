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


## Finds and erases all keys corresponding to the given `value` in the dictionary.
## `value` is left without type hint intentionally: it's so the function works with
## all types, including vectors, references, etc.
static func erase_value(dict: Dictionary, value: Variant) -> bool:
	var out: bool = false
	for key in dict:
		if dict[key] == value:
			out = dict.erase(key)
	return out
