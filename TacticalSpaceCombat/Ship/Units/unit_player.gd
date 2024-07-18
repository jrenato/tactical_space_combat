class_name UnitPlayer extends Unit

## `Units.gd` manages this property. That's  where we query Godot for the selected
## units under a rectangular area activated by `LMB` & dragging the mouse.
var is_selected: bool: set = set_is_selected

## Reference to the UI player feedback element. We need to set its state when units
## get selected/deselected.
var _ui_unit_feedback: NinePatchRect

@onready var area_select: Area2D = %AreaSelect


func _ready() -> void:
	# Instead of assigning `false` on declaration we assign it here,
	# using `self.` to trigger the call to the setter function
	self.is_selected = false


func setup(ui_unit: ColorRect) -> void:
	_ui_unit_feedback = ui_unit.get_node("Feedback")

	# We get the icon and adjust its color from code so that it always stays in
	# sync with `COLORS.default`.
	# We don't add a script to UIUnit, which is why we're getting the Icon node
	# here.
	ui_unit.get_node("Icon").modulate = COLORS.default

	# Instead of overriding `_gui_input()` in the _UIUnit_ UI node, we prefer to
	# use the `gui_input` signal to handle all player interaction right here.
	#
	# This can simplify UI - game entities interactions by a lot.
	ui_unit.gui_input.connect(_on_ui_unit_gui_input)


func set_is_selected(value: bool) -> void:
	# We keep track of selected units using this group name
	var group: String = "selected_units"

	is_selected = value
	if is_selected:
		area_unit.modulate = COLORS.selected
		add_to_group(group)
	else:
		area_unit.modulate = COLORS.default
		if is_in_group(group):
			remove_from_group(group)
	# When changing the unit's selection state, we update the ui widget to show the
	# outline.
	# We need this `null` check here, otherwise, Godot will complain at the
	# start of the game, as setter functions run once before _ready(), when
	# the nodes' constructors (_init()) run.
	if _ui_unit_feedback != null:
		_ui_unit_feedback.visible = is_selected


func _on_ui_unit_gui_input(event: InputEvent) -> void:
	# Remember that we use used `_input()` instead of `_unhandled_input()`
	# in `Units.gd`. This function is why. With `_unhandled_input()`, we would
	# ignore the UI clicks in `Units.gd`. We'd keep on selecting new units
	# without deselecting previous ones.
	if event.is_action_pressed("left_click"):
		self.is_selected = true
