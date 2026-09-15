extends Node2D

@export var projectile_spawn_node_path: Node
var projectile_scene := preload("uid://dd3m6c26vhrem")
@onready var projectile_spawn_point: Marker2D = %ProjectileSpawnPoint

const SECONDS_BETWEEN_SHOTS := 1.75
const DAMAGE := 1
var last_search_time := 0.0

func _physics_process(_delta: float) -> void:
	if Util.time - last_search_time > SECONDS_BETWEEN_SHOTS:
		last_search_time = Util.time

		var monsters := get_tree().get_nodes_in_group("monsters")
		var closest_monster: Monster = null
		var closest_distance := 100.0
		for monster: Monster in monsters:
			var distance_to_monster := monster.position.distance_to(position)
			if distance_to_monster < closest_distance:
				closest_monster = monster
				closest_distance = distance_to_monster

		if closest_monster != null:
			var projectile: Node2D = projectile_scene.instantiate()
			projectile.damage = DAMAGE
			projectile.direction = projectile_spawn_point.global_position.direction_to(closest_monster.global_position)
			projectile_spawn_node_path.add_child(projectile)
			projectile.global_position = projectile_spawn_point.global_position
