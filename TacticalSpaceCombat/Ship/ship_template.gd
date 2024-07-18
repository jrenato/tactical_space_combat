@tool
extends Node2D

@onready var tilemap: TileMapLayer = %TileMapLayer
@onready var rooms: Node2D = %Rooms
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
	for room: Room in rooms.get_children():
		room.setup(tilemap)

		var points: Array[Vector2i] = []
		for point in room:
			points.append(point)

		tilemap.set_cells_terrain_connect(points, 0, 0)

		# We can loop over the room as it's now an iterator.
		# `point` takes the coordinates of every cell in the room's area.
		#for point in room:
			# We use each point to draw the corresponding cell on the tile.
			#tilemap.set_cell(point, 0)
	# We call `update_bitmask_region()` to leverage the tileset's floor auto-tile.
	#tilemap.update_bitmask_region()
