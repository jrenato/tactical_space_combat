class_name ControllerPlayerLaser extends ControllerPlayer

func _on_ship_targeted(msg: Dictionary) -> void:
	super(msg)

	# Unlike the projectile controller, I decided to reset the firing state
	# after every laser swipe since lasers are supposed to be used as precision
	# weapons. And later, they'll also be stopped by shields.
	_ui_weapon_button.button_pressed = false

	# Like before, we try firing the weapon to cover the case in which the
	# weapon is fully charged.
	match msg:
		{"type": TYPE.LASER, "success": true}:
			weapon.fire()


func _on_ui_weapon_button_gui_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("right_click"):
		weapon.has_targeted = false


func _on_ui_weapon_button_toggled(is_pressed: bool) -> void:
	super(is_pressed)
	# Note that, unlike `ControllerAILaser`, we also send `is_targeting` state
	# based on the button press state. We can use this later, to distinguish
	# between player and AI requests as well as knowing when to enter and exit
	# targeting mode in `LaserTracker`.
	var msg: Dictionary = {"is_targeting": is_pressed, "targeting_length": weapon.targeting_length}
	targeting.emit(msg)
