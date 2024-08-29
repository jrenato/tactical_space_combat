extends Node2D

## We send back to the `Controller` a message with target information via
## this signal.
signal targeted(msg: Dictionary)

## To keep it interesting we'll pick random targets using this random number generator.
var _rng := RandomNumberGenerator.new()
var _rooms_count := 0
var mean_position := Vector2.INF


func _ready() -> void:
	_rng.randomize()
	_rooms_count = get_child_count()
	mean_position = _get_mean_position()


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	for room in get_children():
		out += room.position

	if _rooms_count > 0:
		out /= _rooms_count
	return out


## Returns an array of the form `[point1, point2]` defining a segment for
## sweeping the laser across two random rooms.
func get_laser_points(targeting_length: float) -> Array:
	# Get a random room index.
	var room_index_first := _rng.randi_range(0, _rooms_count - 1)

	# Create an array with the remaining room indices skipping
	# `room_index_first`.
	var remaining := []
	for room_index in range(_rooms_count):
		if room_index != room_index_first:
			remaining.push_back(room_index)

	# Pick a random index from the array for the second room.
	var index = _rng.randi_range(0, remaining.size() - 1)
	var room_index_second = remaining[index]

	# Get two random positions in the two rooms.
	var point1: Vector2 = get_child(room_index_first).randv()
	var point2: Vector2 = get_child(room_index_second).randv()

	# Update `point2` to be `targeting_length` distance away from `point1` in
	# the same direction.
	point2 = point1.move_toward(point2, targeting_length)
	return [point1, point2]


func _on_controller_targeting(msg: Dictionary) -> void:
	# Get a random room index.
	var random_index := _rng.randi_range(0, _rooms_count - 1)
	var room: Room = get_child(random_index)

	# Add extra `type` and `target_position` keys with the requested information.
	# We use `msg.type` in the `match` statement back in the
	# `Controller._on_Ship_targeted()` function to distinguish between weapon
	# update messages.
	msg.type = Controller.TYPE.PROJECTILE
	msg.target_position = room.position
	targeted.emit(msg)
