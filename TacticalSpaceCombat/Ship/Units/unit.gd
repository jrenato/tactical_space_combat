class_name Unit extends Path2D

# We group all possible unit colors here, even if the base unit doesn't have a
# selected state.
const COLORS: Dictionary = {"default": Color("323e4f"), "selected": Color("3ca370")}

# The speed at which the unit walks along the path in pixels per second.
@export var speed: float = 150

# If true, the unit should walk along the path until it reaches the end.
var is_walking: bool: set = set_is_walking

# We'll use this reference in the UnitPlayer in a second.
@onready var area_unit: Area2D = %AreaUnit
@onready var path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	area_unit.modulate = COLORS.default
	# By default, we want the units to start as stationary:
	# We use `self` to trigger a call to the `set_is_walking()` setter function.
	self.is_walking = false


func _process(delta: float) -> void:
	# We move along the path based on the unit's `speed`.
	# Updating the `PathFollow2D` node's `offset` automatically moves its children
	# along the curve.
	path_follow.progress += speed * delta
	# `curve` is a property of `Path2D` which gives us our path's length.
	# If the offset gets greater than the path's length, we reached the end
	# and stop walking.
	if path_follow.progress >= curve.get_baked_length():
		self.is_walking = false


func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)


## Assigns the given `Curve2D` `path` to `curve`. It appends `path_follow.position`
## as the starting point on the `curve`.
func walk(path: Curve2D) -> void:
	# This checks the path is valid.
	if path.get_point_count() == 0:
		return

	curve = path
	# As mentioned in the previous lesson, our `TileMap.find_path()` method
	# returns the path missing the start position. That's because we want the
	# current unit position instead to take into account already moving units.
	#
	# Note that the two `Vector2.ZERO` parameters are the in and out bezier
	# curve handles. They're an offset from the curve's position.
	# You can use them to curve the path.
	# We don't want any curves so we set them `Vector2.ZERO`.
	curve.add_point(path_follow.position, Vector2.ZERO, Vector2.ZERO, 0)
	# We place the unit at the start of the path and make it walk.
	path_follow.progress = 0
	self.is_walking = true
