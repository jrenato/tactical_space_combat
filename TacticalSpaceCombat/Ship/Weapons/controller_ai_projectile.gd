@tool
class_name ControllerAIProjectile extends Controller

## Since this is the AI, we initiate weapon targeting in the `_ready()`
## function.
##
## We also connect the `fired` signal to `emit_signal()` to request a new
## target every time the weapon fires. This completes the cycle:
## `targeting -> fired -> targeting`.
func _ready() -> void:
	# We only run the `_ready()` function if we're not in the editor.
	if Engine.is_editor_hint():
		return

	# Initialize the AI weapon for interaction with the player ship.
	weapon.setup(Globals.Layers.SHIPPLAYER)

	var msg: Dictionary = {"index": get_index()}
	weapon.fired.connect(func(): targeting.emit(msg))

	# We wait one frame to let the engine finish inintializing everything before
	# emitting the `targeting` signal.
	#yield(get_tree(), "idle_frame")
	await get_tree().process_frame
	targeting.emit(msg)
