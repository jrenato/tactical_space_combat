class_name Door extends Area2D

## Emitted when the door opened.
signal opened

## If `true`, the door is open, and units can pass through it. We'll define the
## setter function in a moment to control this behavior.
var is_open: bool = false: set = set_is_open

## Keeps track of the number of units passing this door right now.
var _units := 0

@onready var sprite: Sprite2D = %Sprite2D
@onready var timer: Timer = %Timer


func _ready() -> void:
	area_entered.connect(_on_area_exited.bind(true))
	area_exited.connect(_on_area_exited.bind(false))
	timer.timeout.connect(set_is_open)


## Updates `is_open` and the door's sprite. Emits the `opened` signal
## when `is_open` is `true`.
func set_is_open(value: bool) -> void:
	is_open = value
	if is_open:
		sprite.frame = 1
		opened.emit()
	else:
		sprite.frame = 0


func _on_area_exited(area: Variant, has_entered: bool) -> void:
	if area is Unit:
		# Add or subtract 1 to `_units` based on `has_entered`.
		_units += 1 if has_entered else -1

		# We need to meet two conditions to open or close the door. With
		# `match`, we check them both at once.
		match [_units, has_entered]:
			# If there's no unit passing through the door and the last one just
			# exited the area, we close the door.
			[0, false]:
				self.is_open = false

			# If the first unit is entering the door, it's closed, so we start
			# the timer before opening it.
			[1, true]:
				timer.start()
