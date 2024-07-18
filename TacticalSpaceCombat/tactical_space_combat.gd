extends Node2D

var ui_unit_scene: PackedScene = preload("res://TacticalSpaceCombat/UI/ui_unit.tscn")

@onready var ship_player: Node2D = %ShipPlayer
@onready var ui_units: VBoxContainer = %Units


func _ready() -> void:
	_ready_units()


## Creates the player UI to select units.
func _ready_units() -> void:
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = ui_unit_scene.instantiate()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)
