class_name ControllerPlayer extends Controller

var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")

	# Remember we defined `MIN_CHARGE` and `MAX_CHARGE` on `Weapon`. Since they
	# could be anything, we make sure to assign these values to the
	# `ProgressBar` to keep it consistent.
	_ui_weapon_progress_bar.min_value = 0.0
	_ui_weapon_progress_bar.max_value = 1.0

	# We use the "trick" that `gui_input` is a signal on `Control` nodes instead
	# of overwriting the `_gui_input()` function in a script attached to
	# UIWeapon
	_ui_weapon_button.gui_input.connect(_on_ui_weapon_button_gui_input)
	_ui_weapon_button.toggled.connect(_on_ui_weapon_button_toggled)
	_ui_weapon_button.text = weapon.weapon_name


func _ready() -> void:
	super()
	#weapon.tween.step_finished.connect(_on_weapon_tween_tween_step)
	weapon.charge_updated.connect(_on_weapon_charge_updated)


func _input(event: InputEvent) -> void:
	if (
		event.is_action("right_click")
		and _ui_weapon_button.pressed
		# Note the use of `Input.CURSOR_CROSS` to check if the player is in
		# targeting mode.
		and Input.get_current_cursor_shape() == Input.CURSOR_CROSS
	):
		_ui_weapon_button.button_pressed = false


## Updates the weapon charge progress bar
func _on_weapon_charge_updated(value: float) -> void:
	_ui_weapon_progress_bar.value = value


## Cancels targeting mode on `RMB` click on the button.
func _on_ui_weapon_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		_ui_weapon_button.button_pressed = false


## Updates the mouse cursor when the player enters or leaves targeting mode.
## Since `Input` is a singleton that's available to us from anywhere in code, we
## use the cursor shape as a global value for checking if the player entered
## targeting mode instead of keeping track of it through a custom global
## variable.
func _on_ui_weapon_button_toggled(is_pressed: bool) -> void:
	var cursor_shape := Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor_shape)
