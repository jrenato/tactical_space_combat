extends Weapon

## The projectile to spawn and fire.
const projectile_scene := preload("res://TacticalSpaceCombat/Ship/Weapons/projectile.tscn")


func fire() -> void:
	if not can_fire():
		return

	# We set `is_charging` to `true` to start the `Tween` animation.
	self.is_charging = true

	var projectile: Projectile = projectile_scene.instantiate()
	# We adjust `linear_velocity` by `rotation` because we can orient the weapon
	# in any direction we want.
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)
	add_child(projectile)


func can_fire() -> bool:
	return not is_charging
