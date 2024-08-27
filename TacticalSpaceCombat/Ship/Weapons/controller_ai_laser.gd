@tool
class_name ControllerAILaser extends Controller


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# This is the exact approach we took in `ControllerAIProjectile`'s case
	# except this time we send the `weapon.targeting_length` information. This
	# length is used to generate the sweeping line in the other viewport.
	var msg: Dictionary = { "targeting_length": weapon.targeting_length }
	weapon.fire_stopped.connect(func(): targeting.emit(msg))

	await get_tree().process_frame
	targeting.emit(msg)
