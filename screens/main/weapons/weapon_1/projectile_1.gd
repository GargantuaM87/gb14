extends Node2D

@onready var projectile_sprite: AnimatedSprite2D = %ProjectileSprite

const SPEED := 50.0

var damage := 1
var direction := Vector2.UP
var lifetime_secs := 10.0

func _ready() -> void:
	projectile_sprite.rotation = Vector2.UP.angle_to(direction)

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	lifetime_secs -= delta

	if lifetime_secs <= 0.0:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion():
		return

	queue_free()

	var monster: Monster = Util.find_ancestor_in_group(area, "monsters")
	if monster:
		monster.take_damage(damage)
	else:
		var monster_projectile: MonsterProjectile = Util.find_ancestor_in_group(area, "monster_projectiles")
		if monster_projectile:
			monster_projectile.take_damage(damage)
