extends Node2D

@export var damage := 1
@export var direction := Vector2.UP

const LIFETIME_SECONDS := 0.1

@onready var hit_area: Area2D = %HitArea

var remaining_lifetime := LIFETIME_SECONDS
var hit_target_ids: Dictionary[int, bool] = {}

func _ready() -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.UP
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	_damage_overlapping_targets()

	remaining_lifetime -= delta
	if remaining_lifetime <= 0.0:
		queue_free()

func _damage_overlapping_targets() -> void:
	for area: Area2D in hit_area.get_overlapping_areas():
		var monster: Monster = Util.find_ancestor_in_group(area, "monsters")
		if monster != null:
			_damage_target(monster)
			continue

		var monster_projectile: MonsterProjectile = Util.find_ancestor_in_group(area, "monster_projectiles")
		if monster_projectile != null:
			_damage_target(monster_projectile)

func _damage_target(target: Node) -> void:
	if target.is_queued_for_deletion():
		return

	var target_id := target.get_instance_id()
	if hit_target_ids.has(target_id):
		return

	hit_target_ids[target_id] = true
	if target is Monster:
		(target as Monster).take_damage(damage)
	elif target is MonsterProjectile:
		(target as MonsterProjectile).take_damage(damage)
