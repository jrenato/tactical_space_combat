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


## Returns a random `Vector2` on a circle of the given `radius` by picking a
## random angle.
static func randvf_circle(_rng: RandomNumberGenerator, radius: float) -> Vector2:
	# `TAU` is a built in constant equal with `2 * PI` - a full circle.
	return (radius * Vector2.RIGHT).rotated(_rng.randf_range(0, TAU))


## Returns a random `Vector2` within the perimeter defined by `top_left` and
## `bottom_right`.
static func randvf_range(_rng: RandomNumberGenerator, top_left: Vector2, bottom_right: Vector2) -> Vector2:
	var x := _rng.randf_range(top_left.x, bottom_right.x)
	var y := _rng.randf_range(top_left.y, bottom_right.y)
	return Vector2(x, y)
