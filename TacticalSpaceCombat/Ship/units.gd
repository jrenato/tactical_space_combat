extends Node2D

## Default value for the `_polygon` variable to reset to when we
## stop the selection process.
var DEFAULT_POLYGON: PackedVector2Array = PackedVector2Array(
	[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
)

## If `true`, the player has an active selection.
var _is_selecting: bool = false
## Stores the four vertices for the selection rectangle we'll draw on-screen.
var _polygon: PackedVector2Array = DEFAULT_POLYGON.duplicate()


# Draws our rectangle using colors from the array passed as the second argument.
# Here, we use only one color: `self_modulate`.
func _draw() -> void:
	draw_polygon(_polygon, [self_modulate])


func _input(event: InputEvent) -> void:
	# We only want to listen to mouse events: clicking, dragging, and releasing mouse clicks.
	# So we return if we get any other kind of input.
	if not event is InputEventMouse:
		return

	# `get_local_mouse_position()` calculates the mouse's position relative to
	# the node.
	var mouse_position := get_local_mouse_position()

	if event.is_action_pressed("left_click"):
		# When we first detect the `left_click` action pressed we assign
		# `true` to `_is_selecting`. On next calls to `_input()`, this allows
		# us to run the code in the other branches of this condition.
		_is_selecting = true

		# Assign `mouse_position` to all points in `_polygon`. This is the starting
		# position of the rectangle.
		for index in range(_polygon.size()):
			_polygon[index] = mouse_position

		# When starting a new selection, we also deselect all _UnitPlayer_ child
		# nodes to reset the state to before commiting to the selection rectangle.
		for unit in get_children():
			unit.is_selected = false

	# On mouse drag, we update the last three indices in `_polygon` with the appropriate positions based on
	# `mouse_position` such that we construct a rectangle.
	elif _is_selecting and event is InputEventMouseMotion:
		_polygon[1] = Vector2(mouse_position.x, _polygon[0].y)
		_polygon[2] = mouse_position
		_polygon[3] = Vector2(_polygon[0].x, mouse_position.y)

	# When the player releases `left_click`, we apply the selection.
	elif event.is_action_released("left_click"):
		# We define a function to do a physics query and find units intersecting
		# with the `_polygon`.
		select_units()

		# We reset to default values to end the selection process.
		_is_selecting = false
		_polygon = DEFAULT_POLYGON.duplicate()

	# We call `queue_redraw()` to tell Godot to call the `_draw()` function and update
	# the polygon's shape.
	# This will only run with mouse input as we return early from the function
	# for every other input type.
	queue_redraw()


## Finds and returns units overlapping with the shape defined by the `_polygon`
## memberr variable, an array of Vector2 coordinates.
func select_units() -> void:
	# We use `Physics2DShapeQueryParameters` class to identify collisions on demand.
	# That's our strategy for checking which units overlap our rectangular selection
	# region.
	#var query := Physics2DShapeQueryParameters.new()
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := ConvexPolygonShape2D.new()
	shape.points = _polygon

	# To ask Godot for collision information we need to adjust the `query` properties.
	# `shape` uses `polygon` data here, that's how Godot knows where to look for
	# collisions.
	query.set_shape(shape)
	query.transform = global_transform
	query.collide_with_bodies = false
	query.collide_with_areas = true
	# The units' `AreaSelect` collision mask is on the UI physics layer so we use
	# it on the query to detect units.
	query.collision_mask = Globals.Layers.UI

	# get_world_2d().direct_space_state gives you access to the 2D world's
	# `Physics2DDirectSpaceState` object, which gives us access to Godot's 2D
	# physics server. We can use to do physics queries, like `intersect_shape()`.
	for dict in get_world_2d().direct_space_state.intersect_shape(query):
		# `intersect_shape()` returns an array of dictionaries with physics data.
		# We extract the collider, which should be our `AreaSelect`. Their `owner`
		# should be a `UnitPlayer`.
		dict.collider.owner.is_selected = true
