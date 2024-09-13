extends Node2D

const UI_UNIT: PackedScene = preload("res://TacticalSpaceCombat/UI/ui_unit.tscn")
const UI_WEAPON: PackedScene = preload("res://TacticalSpaceCombat/UI/ui_weapon.tscn")
const UI_WEAPONS: PackedScene = preload("res://TacticalSpaceCombat/UI/ui_weapons.tscn")
const END_SCENE: PackedScene = preload("res://TacticalSpaceCombat/end.tscn")

@onready var ship_player: Node2D = %ShipPlayer
@onready var ship_ai: Node2D = %ShipAI
@onready var ui_units: VBoxContainer = %Units
@onready var ui_doors: Button = %Doors
@onready var ui_systems: HBoxContainer = %Systems
@onready var player_hit_points: Label = %PlayerHitPoints
@onready var enemy_hit_points: Label = %EnemyHitPoints


func _ready() -> void:
	ship_player.hitpoints_changed.connect(_on_ship_hitpoints_changed)
	ship_ai.hitpoints_changed.connect(_on_ship_hitpoints_changed)
	_ready_units()
	_ready_weapons_ai()
	_ready_weapons_player()
	ui_doors.pressed.connect(ship_player._on_ui_doors_button_pressed)
	_on_ship_hitpoints_changed(ship_player.hitpoints, true)
	_on_ship_hitpoints_changed(ship_ai.hitpoints, false)


## Creates the player UI to select units.
func _ready_units() -> void:
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = UI_UNIT.instantiate()
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


func _ready_weapons_player() -> void:
	for controller in ship_player.weapons.get_children():
		if not ui_systems.has_node("Weapons"):
			ui_systems.add_child(UI_WEAPONS.instantiate())

		var ui_weapon: VBoxContainer = UI_WEAPON.instantiate()
		ui_systems.get_node("Weapons").add_child(ui_weapon)

		if controller is ControllerPlayerProjectile:
			controller.weapon.projectile_exited.connect(ship_ai.projectiles._on_weapon_projectile_exited)
			for room in ship_ai.rooms.get_children():
				controller.targeting.connect(room._on_controller_targeting)
				room.targeted.connect(controller._on_ship_targeted)

		elif controller is ControllerPlayerLaser:
			var laser_tracker: Node = ship_ai.add_laser_tracker(controller.weapon.color)
			controller.targeting.connect(
				laser_tracker._on_controller_targeting, CONNECT_DEFERRED
			)
			controller.weapon.fire_started.connect(laser_tracker._on_weapon_fire_started)
			controller.weapon.fire_stopped.connect(laser_tracker._on_weapon_fire_stopped)
			laser_tracker.targeted.connect(controller._on_ship_targeted)

		controller.setup(ui_weapon)


func _on_ship_hitpoints_changed(hitpoints: int, is_player: bool) -> void:
	var label := player_hit_points if is_player else enemy_hit_points
	label.text = "HP: %d" % hitpoints
	if hitpoints == 0:
		Globals.winner_is_player = not is_player
		get_tree().change_scene_to_packed.bind(END_SCENE).call_deferred()
