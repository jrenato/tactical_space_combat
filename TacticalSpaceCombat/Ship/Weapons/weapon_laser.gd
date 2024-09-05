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
@onready var line: Line2D = %Line2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	#timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	#timer.connect("timeout", self, "set_is_charging", [true])
	#timer.connect("timeout", line, "set_visible", [false])
	timer.timeout.connect(stopped_firing)

	line.default_color = color

	super()


func _get_configuration_warning() -> String:
	var parent := get_parent()
	var is_verified: bool = parent != null and parent is ControllerAILaser or parent is ControllerPlayerLaser
	return "" if is_verified else "WeaponLaser needs to be a parent of Controller*Laser"


func fire() -> void:
	if not can_fire():
		return

	super()

	timer.start()
	has_targeted = false
	line.visible = true
	var params: Dictionary = { "duration": timer.wait_time }
	fire_started.emit(params)



func stopped_firing() -> void:
	fire_stopped.emit()
	is_charging = true
	line.set_visible(false)


func can_fire() -> bool:
	return not is_charging and has_targeted
