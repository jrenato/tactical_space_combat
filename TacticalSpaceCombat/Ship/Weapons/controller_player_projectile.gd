class_name ControllerPlayerProjectile extends ControllerPlayer


func _ready() -> void:
	# Remember  we initialize the projectile weapon with info on the enemy ship
	# physics layer.
	weapon.setup(Globals.Layers.SHIPAI)


func _on_ship_targeted(msg: Dictionary) -> void:
	super(msg)

	if msg.index == get_index():
		_ui_weapon_button.button_pressed = false
	# On top of the setting the targeting information on the weapon, we also try
	# to fire the weapon. This is so we can handle the case in which the weapon
	# is fully chared when the player targets a room.
	match msg:
		{"type": TYPE.PROJECTILE, ..}:
			weapon.fire()


func _on_ui_weapon_button_gui_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("right_click"):
		# Cancel projectile weapon targeting on `right_click` by resetting
		# `weapon.target_position` even if targeting mode isn't enabled yet.
		weapon.target_position = Vector2.INF

		# We use the same `targeting` signal when disengaging to turn off the
		# numbered reticle.
		targeting.emit({"index": get_index()})

		# We trigger it one more time to reset the targeting state to an
		# invalid value. More on this when covering the `Room` script.
		targeting.emit({"index": -1})


func _on_ui_weapon_button_toggled(is_pressed: bool) -> void:
	super(is_pressed)

	# We initialize the weapon `index` with an invalid position which signifies
	# that the player might cancel the process if not updated.
	var index := -1
	if is_pressed:
		# Entering the targeting mode updates the weapon index and resets the
		# weapon targeting state.
		index = get_index()
		weapon.target_position = Vector2.INF

	targeting.emit({"index": index})
