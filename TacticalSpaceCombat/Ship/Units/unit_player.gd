class_name UnitPlayer extends Unit

## `Units.gd` manages this property. That's  where we query Godot for the selected
## units under a rectangular area activated by `LMB` & dragging the mouse.
var is_selected: bool: set = set_is_selected

@onready var area_select: Area2D = %AreaSelect


func _ready() -> void:
	# Instead of assigning `false` on declaration we assign it here,
	# using `self.` to trigger the call to the setter function
	self.is_selected = false


func set_is_selected(value: bool) -> void:
	# We keep track of selected units using this group name
	var group := "selected-unit"

	is_selected = value
	if is_selected:
		area_unit.modulate = COLORS.selected
		add_to_group(group)
	else:
		area_unit.modulate = COLORS.default
		if is_in_group(group):
			remove_from_group(group)
