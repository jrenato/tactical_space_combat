class_name LaserTracker extends Node2D

signal targeted(msg: Dictionary)

## These are the default values for `Line2D` and `TargetLine2D` nodes.
## We start with invalid default positions so that they don't
## render anything while not firing.
var LINE_DEFAULT := PackedVector2Array([Vector2.INF, Vector2.INF])

## These are the positions of the `TargetLine2D` node - the sweeping path.
var _target_points: PackedVector2Array = LINE_DEFAULT

var _rng := RandomNumberGenerator.new()
var _rooms: Node2D = null

var tween: Tween

@onready var area: Area2D = %Area2D
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


func _on_controller_targeting(msg: Dictionary) -> void:
	# Update `TargetLine2D` with a randomly generated line from
	# `Rooms.get_laser_points()`.
	prints("Controller targeting", msg)
	target_line.points = _rooms.get_laser_points(msg.targeting_length)
	targeted.emit({"type": Controller.TYPE.LASER, "success": true})


func _on_weapon_fire_started(params: Dictionary) -> void:
	# Remember we initialized `target_line.points` with `LINE_DEFAULT` in the
	# `_ready()` function. So we first check if the target is valid.
	prints("laser fire started", params)
	if Vector2.INF in target_line.points:
		return

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
	print("laser fire stopped")
	if tween:
		tween.kill()
	line.points = LINE_DEFAULT
	area.position = Vector2.ZERO
	# We don't care to reset `target_line.points` here because each new cycle
	# it'll be updated to random positions anyway.


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
