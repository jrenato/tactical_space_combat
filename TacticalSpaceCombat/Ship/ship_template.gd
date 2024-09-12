@tool
extends Node2D

signal hitpoints_changed(hitpoints: int, is_player: bool)

const laser_tracker_scene := preload("res://TacticalSpaceCombat/Ship/Weapons/laser_tracker.tscn")
const attack_label_scene := preload("res://TacticalSpaceCombat/UI/attack_label.tscn")

@export_range(0, 30) var hitpoints: int = 30

var _slots: Dictionary = {}

@onready var tilemap: TileMapLayer = %TileMapLayer
@onready var rooms: Node2D = %Rooms
@onready var doors: Node2D = %Doors
@onready var units: Node2D = %Units
@onready var weapons: Node2D = %Weapons
@onready var projectiles: Node2D = %Projectiles
@onready var lasers: Node2D = %Lasers


func _ready() -> void:
	if Engine.is_editor_hint():
		_ready_editor_hint()
	else:
		_ready_not_editor_hint()


## This is our former `_ready()` function from the previous lesson.
## It gets called when running the script in the editor.
func _ready_editor_hint() -> void:
	for room: Room in rooms.get_children():
		room.setup(tilemap)


func _get_configuration_warning() -> String:
	var is_verified := (
		(is_in_group("player") and weapons.get_child_count() <= 4)
		or not is_in_group("player")
	)
	return "" if is_verified else "%s can't have more than 4 weapons!" % name


## This gets called when running the script in the game.
func _ready_not_editor_hint() -> void:
	for unit: Unit in units.get_children():
		for door: Door in doors.get_children():
			door.opened.connect(unit.set_is_walking.bind(true))
		# We calculate the cell coordinates of each unit and store the unit in
		# the dictionary.
		var position_map: Vector2i = tilemap.local_to_map(unit.path_follow.position)
		_slots[position_map] = unit

	for room: Room in rooms.get_children():
		room.setup(tilemap)

		room.area_entered.connect(_on_room_area_area_entered.bind(room))
		room.hit_area.body_entered.connect(_on_room_hit_area_body_entered.bind(room))

		var points: Array[Vector2i] = []
		for point in room:
			points.append(point)

		tilemap.set_cells_terrain_connect(points, 0, 0)

	tilemap.setup(rooms, doors)
	projectiles.setup(rooms.mean_position)


func _unhandled_input(event: InputEvent) -> void:
	# Units should move only when right-clicking, so we return from the
	# function on any other input.
	if not event.is_action_pressed("right_click"):
		return

	# If the player right-clicked, we get all selected units and make them move to the selected room.
	for unit: Unit in get_tree().get_nodes_in_group("selected_units"):
		# Below, point1 and point2 are respectively the unit's position and an empty slot the room will find for us.
		var point1: Vector2i = tilemap.local_to_map(unit.path_follow.position)
		for room: Room in get_tree().get_nodes_in_group("selected_rooms"):
			# We ensure the room is part of the player ship by checking the ship is in the `player` group.
			if not room.owner.is_in_group("player"):
				break

			var point2: Vector2 = room.get_slot(_slots, unit)
			# If the location isn't valid we break out of the loop.
			# `Room.get_slot()` will return infinity values so we can reliably check for an invalid slot.
			# The location can be invalid if the room is already full, in which case we don't want to move more units there.
			if is_inf(point2.x):
				break

			# If the location is valid, we pathfind from the current to the target slot.
			var path: Curve2D = tilemap.find_path(point1, point2)
			# We update the dictionary tracking where units are.
			# We need to use `erase_value()` here because of how units will
			# slowly walk to their target.
			# It's a reliable way to remove the correct keys from the dictionary.
			Utils.erase_value(_slots, unit)
			_slots[point2] = unit
			unit.walk(path)


func add_laser_tracker(color: Color) -> Node:
	var laser_tracker := laser_tracker_scene.instantiate()
	lasers.add_child(laser_tracker)
	laser_tracker.setup(color, rooms)
	return laser_tracker


## Open doors if none are already open, otherwise close them.
func _on_ui_doors_button_pressed() -> void:
	var has_opened_doors: bool = false
	for door in doors.get_children():
		if door.is_open:
			has_opened_doors = true
			break

	for door: Door in doors.get_children():
		# We have to reactivate the doors before closing them
		if not door.is_enabled and has_opened_doors:
			door.is_enabled = has_opened_doors

		door.is_open = not has_opened_doors

		# Now we make sure the door enabled is correct
		if door.is_enabled != has_opened_doors:
			door.is_enabled = has_opened_doors


## Handles projectiles.
func _on_room_hit_area_body_entered(body: RigidBody2D, room: Room) -> void:
	# We make sure that the projectiles interact with the correct `Room` by
	# checking their positions.
	if not room.position.is_equal_approx(body.params.target_position):
		return

	body.queue_free()
	_take_damage(body.params.attack, room.position)


## Handles lasers.
func _on_room_area_area_entered(area: Area2D, room: Room) -> void:
	if area.is_in_group("laser"):
		_take_damage(area.params.attack, room.position)


func _take_damage(attack: int, object_position: Vector2) -> void:
	var attack_label := attack_label_scene.instantiate()
	attack_label.setup(attack, object_position)
	add_child(attack_label)

	hitpoints -= attack
	hitpoints = max(0, hitpoints)
	hitpoints_changed.emit(hitpoints, is_in_group("player"))
