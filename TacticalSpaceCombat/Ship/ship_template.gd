@tool
extends Node2D

var _slots: Dictionary = {}

@onready var tilemap: TileMapLayer = %TileMapLayer
@onready var rooms: Node2D = %Rooms
@onready var doors: Node2D = %Doors
@onready var units: Node2D = %Units


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

		var points: Array[Vector2i] = []
		for point in room:
			points.append(point)

		tilemap.set_cells_terrain_connect(points, 0, 0)

	tilemap.setup(rooms, doors)


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
			# We have yet to define `Room.get_slot()`, we'll do it later in the lesson.
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
