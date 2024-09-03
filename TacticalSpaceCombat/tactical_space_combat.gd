extends Node2D

var ui_unit_scene: PackedScene = preload("res://TacticalSpaceCombat/UI/ui_unit.tscn")

@onready var ship_player: Node2D = %ShipPlayer
@onready var ship_ai: Node2D = %ShipAI
@onready var ui_units: VBoxContainer = %Units
@onready var ui_doors: Button = %Doors


func _ready() -> void:
	_ready_units()
	_ready_weapons_ai()
	ui_doors.pressed.connect(ship_player._on_ui_doors_button_pressed)


## Creates the player UI to select units.
func _ready_units() -> void:
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = ui_unit_scene.instantiate()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)


func _ready_weapons_ai() -> void:
	for controller in ship_ai.weapons.get_children():
		if controller is ControllerAIProjectile:
			# We request new target positions via the controller `targeting` signal.
			controller.targeting.connect(ship_player.rooms._on_controller_targeting)
			# We update the requested target position via the rooms' `targeted` signal.
			ship_player.rooms.targeted.connect(controller._on_ship_targeted)

			controller.weapon.projectile_exited.connect(
				ship_player.projectiles._on_weapon_projectile_exited
			)
		elif controller is ControllerAILaser:
			# We add a `LaserTracker` node to the player ship for every
			# `ControllerAILaser` in `ShipAI`.
			var laser_tracker: LaserTracker = ship_player.add_laser_tracker(controller.weapon.color)
			controller.targeting.connect(func(msg: Dictionary): laser_tracker._on_controller_targeting(msg), CONNECT_DEFERRED)
			controller.weapon.fire_started.connect(func(params: Dictionary): laser_tracker._on_weapon_fire_started(params))
			controller.weapon.fire_stopped.connect(laser_tracker._on_weapon_fire_stopped)
			laser_tracker.targeted.connect(controller._on_ship_targeted)
