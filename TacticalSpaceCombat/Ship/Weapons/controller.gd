class_name Controller extends Node2D

## Every time the weapon fires, we emit the `targeting` signal.
signal targeting(msg: Dictionary)

## List of all weapon types. Currently, we only have projectile-based weapons,
## but we'll add lasers in another lesson.
enum TYPE {PROJECTILE}

## This is why we used the generic `Weapon` name for both projectile and laser
## specializations. We reference them with the same name.
##
## This is also the parent class of scripts that will run in the editor so we
## make sure to check for that.
@onready var weapon: Weapon = null if Engine.is_editor_hint() else $Weapon


func _on_ship_targeted(msg: Dictionary) -> void:
	match msg:
		# The `..` syntax means "match anything" inside dictionaries and arrays.
		#
		# Here, the pattern matches any dictionary with at least a key named "type"
		# with a value of `Type.PROJECTILE`.
		{"type": TYPE.PROJECTILE, ..}:
			# A ship can have more than one weapon of each type. To distinguish
			# between them we use the `Controller` index position in the scene
			# tree.
			if msg.index == get_index():
				weapon.target_position = msg.target_position
				print("New `target_position` requested: ", msg.target_position)


func _get_configuration_warning() -> String:
	return "" if has_node("Weapon") else "%s needs a Weapon child" % name
