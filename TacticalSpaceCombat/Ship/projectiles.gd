extends Node2D

const PROJECTILE_SCENE = preload("res://TacticalSpaceCombat/Ship/Weapons/projectile.tscn")

var _rng := RandomNumberGenerator.new()
var _mean_position := Vector2.INF


func setup(mean_position: Vector2) -> void:
	_mean_position = mean_position


func _ready() -> void:
	_rng.randomize()


func _on_weapon_projectile_exited(params: Dictionary) -> void:
	var projectile: RigidBody2D = PROJECTILE_SCENE.instantiate()
	# The spawn position is on a circle of radius `projectile.MAX_DISTANCE`,
	# centered at `_mean_position`.
	var spawn_position := _mean_position + Utils.randvf_circle(_rng, projectile.MAX_DISTANCE)

	# Remember that we request new `target_position` from the `Controller`
	# scripts. We get it from the `projectile_exited` payload and use it to
	# calculate the Projectile's direction.
	var direction: Vector2 = (params.target_position - spawn_position).normalized()

	# We calculate matching properties based on `direction`. Once these are set,
	# the `RigidBody2D` node takes care of the motion.
	projectile.position = spawn_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()

	# We also update the `collision_layer` so that it interacts with the correct
	# ship.
	projectile.collision_layer = params.physics_layer

	# We double the `max_distance` parameter so that the `Projectile` has enough
	# room to travel outside the screen before it gets removed.
	projectile.max_distance *= 2

	add_child(projectile)
