class_name Projectile extends RigidBody2D

const MAX_DISTANCE: float = 2000

## Variable to check traveled distance to set it from other scripts.
var max_distance := MAX_DISTANCE

## The position at which we spawn the `Projectile` to calculate the
## distance traveled.
var _origin := Vector2.ZERO
var params: Dictionary = {}


func _ready() -> void:
	_origin = position


func _process(delta: float) -> void:
	if position.distance_to(_origin) > max_distance:
		queue_free()
