class_name Unit extends Path2D

# We group all possible unit colors here, even if the base unit doesn't have a
# selected state.
const COLORS: Dictionary = {"default": Color("323e4f"), "selected": Color("3ca370")}

# We'll use this reference in the UnitPlayer in a second.
@onready var area_unit: Area2D = %AreaUnit


func _ready() -> void:
	area_unit.modulate = COLORS.default
