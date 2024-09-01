class_name Weapon extends Sprite2D

## Controls the time it takes for the weapon to charge completely and get ready to fire.
@export var charge_time: float = 2.0

## These two properties define the range of the `_charge` variable below.
##
## We also use them later, with the player UI progress bar to display the
## charge amount.
const MIN_CHARGE: float = 0.0
const MAX_CHARGE: float = 100.0

## We'll use this property to get the weapon to fire.
var is_charging: bool = false: set = set_is_charging

## This variable keeps track of the current charge level.
## We'll later tie it with the player weapon's interface.
var _charge: float = MIN_CHARGE

var tween: Tween


func _ready() -> void:
	is_charging = true


## Virtual function to overwrite to define how each weapon fires.
func fire() -> void:
	pass


func enable_weapon() -> void:
	is_charging = false


func set_is_charging(value: bool) -> void:
	print("charging")
	is_charging = value
	# When we start charging, we animate the `_charge` property using our `Tween` node.
	if is_charging:
		#if tween and tween.is_running():
			#tween.kill()

		if not tween or not tween.is_running():
			tween = create_tween()
			tween.finished.connect(enable_weapon)
			tween.tween_property(self, "_charge", MAX_CHARGE, charge_time)

	# Every time we update the `is_charging` value, attempt to fire.
	# We'll handle the condition to fire in each weapon, inside the `fire()` function.
	# This lowers the cognitive burden of checking for fire conditions every time we
	# call the function.
	fire()
