@tool
extends Weapon

## Emitted every time the weapon fires a projectile.
signal fired

signal projectile_exited(params: Dictionary)

## The projectile to spawn and fire.
const projectile_scene := preload("res://TacticalSpaceCombat/Ship/Weapons/projectile.tscn")

## This gets updated every time the controller requests targeting information
## from the opponent ship.
var target_position := Vector2.INF

## When the AI shoots, we set this to the player ship's physics layer so that
## the projectile knows to interact with it. And vice-versa for the player.
var _physics_layer := -1


## By overwriting this function, we can tell Godot to issue a warning with
## showing the returned string. If the return value is an empty string, Godot
## doesn't show any warnings.
func _get_configuration_warning() -> String:
	var parent := get_parent()
	var is_verified: bool = parent != null and parent is ControllerAIProjectile
	return "" if is_verified else "WeaponProjectile needs to be a parent of ControllerAIProjectile"


func setup(physics_layer: int) -> void:
	_physics_layer = physics_layer


func fire() -> void:
	if not can_fire():
		return

	# We set `is_charging` to `true` to start the `Tween` animation.
	self.is_charging = true

	var projectile: Projectile = projectile_scene.instantiate()
	# We adjust `linear_velocity` by `rotation` because we can orient the weapon
	# in any direction we want.
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)

	var params: Dictionary = {
		"physics_layer": _physics_layer,
		"target_position": target_position
	}
	projectile.tree_exited.connect(func(): projectile_exited.emit(params))

	add_child(projectile)

	fired.emit()


func can_fire() -> bool:
	return not is_charging and target_position != Vector2.INF
