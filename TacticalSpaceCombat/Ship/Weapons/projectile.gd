class_name Projectile extends RigidBody2D

const MAX_DISTANCE: float = 2000


func _process(delta: float) -> void:
	if position.length() > MAX_DISTANCE:
		queue_free()
