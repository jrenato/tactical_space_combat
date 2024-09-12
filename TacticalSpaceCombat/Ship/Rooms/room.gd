@tool
## Represents a room in the ship.
class_name Room extends Area2D

signal targeted(msg: Dictionary)

## Room size in `TileMap` cells.
# We'll use the setter function to resize the room's collision shapes.
@export var size: Vector2i = Vector2i.ONE: set = set_size

## Reference to the ship's `TileMap` to convert from world to map
## positions and the other way around.
var _tilemap: TileMapLayer = null

## Room area in _TileMap_ cells =`size.x * size.y`.
var _area: int = 0

## Keeps track of tiles next to doors.
##
## The reason we use a dictionary instead of an array is because it's much
## faster to check for keys in a dictionary than for elements in an array.
var _entrances: Dictionary = {}

## Positions in `TileMap` coordinates for the top-left and bottom-right corners
## of the room.
var _top_left := Vector2i.ZERO
var _bottom_right := Vector2i.ZERO

## We'll keep track of our iteration index with this property.
var _iter_index: int = 0

var _rng := RandomNumberGenerator.new()

## We initialize it with an invalid value that will help us in checking for
## targeting conditions.
var _target_index: int = -1

## We'll update this node with the `set_size()` setter function.
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var feedback: NinePatchRect = %Feedback
@onready var sprite_target: Sprite2D = %SpriteTarget
@onready var hit_area: Area2D = %HitArea2D


func _ready() -> void:
	mouse_entered.connect(_on_mouse_exited.bind(true))
	mouse_exited.connect(_on_mouse_exited.bind(false))
	area_entered.connect(_on_area_entered)
	input_event.connect(_on_input_event)


	_rng.randomize()


## Initializes the room's properties in the `tilemap`'s coordinates.
func setup(tilemap: TileMapLayer) -> void:
	_tilemap = tilemap
	_setup_extents()

	if not Engine.is_editor_hint():
		hit_area.collision_mask = (
			Globals.Layers.SHIPPLAYER
			if owner.is_in_group("player")
			else Globals.Layers.SHIPAI
		)

	_area = size.x * size.y

	# With the room's size, we can calculate the coordinates of its top-left and
	# bottom-right corners.
	_top_left = _tilemap.local_to_map(position - collision_shape.shape.extents)
	_bottom_right = _top_left + size

	feedback.custom_minimum_size = 2 * collision_shape.shape.extents


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


## Checks if the given point is within the bounds of the room
func has_point(point: Vector2) -> bool:
	return Rect2(_top_left, size).has_point(point)


func get_slot(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.INF
	var entrance := _get_entrance(_tilemap.local_to_map(unit.path_follow.position))

	var valid_positions := []
	for offset in self:
		valid_positions.push_back([offset, offset.distance_to(entrance)])
	valid_positions.sort_custom(sort_by_second_index)

	for data in valid_positions:
		var offset: Vector2 = data[0]
		if not (offset in slots and slots[offset] != unit):
			out = offset
			break
	return out


static func sort_by_second_index(a: Array, b: Array) -> bool:
	return a[1] < b[1]


## Returns the closest entrance from the `from` location.
func _get_entrance(from: Vector2) -> Vector2:
	var out: Vector2 = Vector2.INF
	var distance := INF
	for entrance in _entrances:
		var curve: Curve2D = _tilemap.find_path(from, entrance)
		var length: float = curve.get_baked_length()
		if distance > length:
			distance = length
			out = entrance
	return out


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


## Returns a random `Vector2` in the `Room` perimeter in world coordinates.
func randv() -> Vector2:
	var top_left_world := _tilemap.map_to_local(_top_left)
	var bottom_right_world := _tilemap.map_to_local(_bottom_right)
	return Utils.randvf_range(_rng, top_left_world, bottom_right_world)


func _on_mouse_exited(has_entered: bool) -> void:
	#We use the emitted parameter to toggle the outline's visibility.
	feedback.visible = has_entered

	# We also add/remove the room from `selected_room` group as needed. We can then get
	# these nodes from other parts of our code based on the assigned group.
	var group := "selected_rooms"
	if has_entered:
		add_to_group(group)
	elif is_in_group(group):
		remove_from_group(group)


func _on_area_entered(area: Area2D) -> void:
	if area is Door:
		# Here, we find the coordinates of the room tile next to the door.
		# First, we get the vector pointing from the door to the middle of the
		# room.
		var entrance: Vector2 = position - area.position
		# We project that onto the door normal so it's either vertical or
		# horizontal and points towards the room.
		entrance = entrance.project(Vector2.DOWN.rotated(area.rotation)).normalized()
		# We multiply by half the cell size to get an offset towards the cell's
		# center.
		entrance *= 0.5 * _tilemap.tile_set.tile_size.x
		# We add the door position to calculate the tile's position on the
		# tilemap.
		entrance += area.position
		# As we have a position in pixels, we need to convert it to `TileMap`
		# coordinates to get the cell's coordinates.
		entrance = _tilemap.local_to_map(entrance)
		# Finally, we store the entrance tile position as a key in the
		# `_entrances` dictionary.
		# We only want the door's coordinates here so we don't associate a value
		# to it.
		_entrances[entrance] = null


func _on_controller_targeting(msg: Dictionary) -> void:
	# Update `_target_index`. This is useful when emitting `targeted` when
	# clicking on a `Room`.
	_target_index = msg.index

	# We might get an invalid input if the player cancels the targeting process.
	if _target_index != -1:
		# Every time the player enters targeting mode we first try to reset the
		# targeting reticle.
		sprite_target.visible = false

		# And the specific child reticle number given the weapon index.
		sprite_target.get_child(_target_index).visible = false

		for node in sprite_target.get_children():
			if node.visible:
				# If there are other visible children, other than `_target_index`,
				# then reenable the targeting reticle visibility and break out of
				# the loop since one is enough.
				sprite_target.visible = true
				break


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (
		event.is_action_pressed("left_click")

		# Note these checks. Like I mentioned before, we use
		# `Input.CURSOR_CROSS` to check for player targeting mode.
		and Input.get_current_cursor_shape() == Input.CURSOR_CROSS

		# And we further assume that if `_target_index != -1`, it has to be
		# valid and continue handling the `left_click`.
		and _target_index != -1
	):
		# Turn on the appropriate targeting reticle.
		sprite_target.visible = true
		sprite_target.get_child(_target_index).visible = true

		# And send back the position of the Room along with the other weapon
		# information.
		emit_signal(
			"targeted",
			{
				"type": Controller.TYPE.PROJECTILE,
				"index": _target_index,
				"target_position": position
			}
		)
		_target_index = -1
