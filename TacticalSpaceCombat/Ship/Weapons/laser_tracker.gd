class_name LaserTracker extends Node2D

signal targeted(msg: Dictionary)

## These are the default values for `Line2D` and `TargetLine2D` nodes.
## We start with invalid default positions so that they don't
## render anything while not firing.
var LINE_DEFAULT := PackedVector2Array([Vector2.INF, Vector2.INF])

## We keep track of the player targeting mode with this variable.
var _is_targeting: bool = false

## We also need to track the laser weapon targeting length depending on which
## weapon the player uses.
var _targeting_length: float = 0.0

## These are the positions of the `TargetLine2D` node - the sweeping path.
var _target_points: PackedVector2Array = LINE_DEFAULT

var _rng := RandomNumberGenerator.new()
var _rooms: Node2D = null

var tween: Tween

@onready var area: Area2D = %HitArea2D
@onready var line: Line2D = %Line2D
@onready var target_line: Line2D = %TargetLine2D


func _ready() -> void:
	_rng.randomize()
	target_line.points = LINE_DEFAULT
	line.points = LINE_DEFAULT


func setup(color: Color, rooms: Node2D) -> void:
	_rooms = rooms
	line.default_color = color
	target_line.default_color = color


func _unhandled_input(event: InputEvent) -> void:
	# We filter out any non-mouse event as long as the player is in targeting
	# mode.
	if not (event is InputEventMouse and _is_targeting):
		return

	if event.is_action_pressed("left_click"):
		# On `left_click` we update the first point of `target_line`. This means
		# that the second point is still `Vector2.INF`.
		target_line.points[0] = get_local_mouse_position()

	elif target_line.points[0] != Vector2.INF and event is InputEventMouseMotion:
		# This handles the events after `left_click`, meaning as we drag the
		# mouse with the button pressed.

		# Update an`offset` relative to the first `left_click` position stored
		# in `target_line.points[0]`. We make sure to clamp its length to
		# `_targeting_length`.
		var offset: Vector2 = get_local_mouse_position() - target_line.points[0]
		offset = offset.limit_length(_targeting_length)

		# Now we can commit the second point of the targeting path.
		target_line.points[1] = target_line.points[0] + offset

	elif event.is_action_released("left_click"):
		# If we finished dragging the mouse and release the `left_click` then we
		# commit to the calculated laser path by emitting the `targeted` signal
		# and switching out of the targeting mode.
		_is_targeting = false

		# If the player releases the `LMB` too fast then `success` will be `false`.
		var msg := {"type": Controller.TYPE.LASER, "success": target_line.points[1] != Vector2.INF}
		emit_signal("targeted", msg)


func _on_controller_targeting(msg: Dictionary) -> void:
		match msg:
			# We separate player and AI through the `is_targeting` key.
			{"targeting_length": var targeting_length, "is_targeting": var is_targeting}:
				_is_targeting = is_targeting
				_targeting_length = targeting_length
				if _is_targeting:
					# Handle targeting cancellation by resetting `target_line`.
					target_line.points = LINE_DEFAULT
			{"targeting_length": var targeting_length}:
				# We moved the previous AI implementation under this branch which
				# lacks the `is_targeting` key.
				target_line.points = _rooms.get_laser_points(targeting_length)
				targeted.emit({"type": Controller.TYPE.LASER, "success": true})


func _on_weapon_fire_started(params: Dictionary) -> void:
	# Remember we initialized `target_line.points` with `LINE_DEFAULT` in the
	# `_ready()` function. So we first check if the target is valid.
	if Vector2.INF in target_line.points:
		return

	# We also set the `Area2D` node to `monitorable` whenever we fire the
	# weapon.
	area.set_deferred("monitorable", true)
	area.params = params

	# Generate an off-screen position for the first `Line2D` point - the
	# incoming laser origin. We animate the second index with a helper function
	# and the `Tween` node.
	line.points[0] = _rooms.mean_position + Utils.randvf_circle(_rng, Projectile.MAX_DISTANCE)

	if tween:
		tween.kill()

	tween = create_tween()

	# We use `Tween.interpolate_method()` to "animate" the `_swipe_laser()`
	# helper function. The function gets an input going from
	# `target_line.poisnts[0]` to `target_line.points[1]`.
	tween.tween_method(
		_swipe_laser,
		target_line.points[0],
		target_line.points[1],
		params.duration
	)


func _on_weapon_fire_stopped() -> void:
	if tween:
		tween.kill()

	line.points = LINE_DEFAULT
	area.position = Vector2.ZERO
	area.set_deferred("monitorable", false)

	# We don't care to reset `target_line.points` here because each new cycle
	# it'll be updated to random positions anyway.
	target_line.points = LINE_DEFAULT

## Helper function to animate one end of `Line2D` - the end that swipes over the
## ship rooms.

## We need a function for this because we're interested in animating
## `Line2D.points[1]` and we can't do it with `Tween.interpolate_property()`
## function.
func _swipe_laser(offset: Vector2) -> void:
	line.points[1] = offset
	# We also move the position of `Area2D` to match the tip of the laser
	# strike.
	area.position = line.points[1]
