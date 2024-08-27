@tool
class_name WeaponLaser extends Weapon

signal fire_started(params: Dictionary)
signal fire_stopped

## The sweeping laser length to vary the reach of the weapon.
@export_range(0, 250) var targeting_length: int = 140

## The laser color.
@export var color := Color("b0305c")

## This gets updated by the controller so that the weapon knows
##  if it acquired a target or not.
var has_targeted := false

@onready var timer: Timer = %Timer
@onready var line_2d: Line2D = %Line2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# When the `Timer` times out it means the weapon finished firing so we can
	# start a new cycle.
	timer.timeout.connect(fire_stopped.emit)
	timer.timeout.connect(func(): set_is_charging(true))

	# We also directly connect to `Line2D.set_visible()`. This skips having to
	# deal with conditions in `set_is_charging()`.
	timer.connect("timeout", line, "set_visible", [false])

	line.default_color = color
