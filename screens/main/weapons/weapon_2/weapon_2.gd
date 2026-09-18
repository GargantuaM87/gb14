extends Node2D

@export var laser_parent: Node
var laser_scene := preload("uid://by4ms12lc0wr5")
@onready var laser_spawn_point: Marker2D = %LaserSpawnPoint

const SECONDS_BETWEEN_SHOTS := 3.75
const DAMAGE := 1
var last_search_time := 0.0

func _physics_process(_delta: float) -> void:
	if Util.time - last_search_time > SECONDS_BETWEEN_SHOTS:
		last_search_time = Util.time

		# Primary target: Monsters
		var targets := get_tree().get_nodes_in_group("monsters")
		if targets.is_empty():
			# Secondary target: Monster projectiles
			targets = get_tree().get_nodes_in_group("monster_projectiles")

		var closest_target: Node2D = null
		var closest_distance := INF
		for target: Node2D in targets:
			var distance_to_target := target.global_position.distance_to(global_position)
			if distance_to_target < closest_distance:
				closest_target = target
				closest_distance = distance_to_target

		if closest_target != null:
			var laser: Node2D = laser_scene.instantiate()
			laser.damage = DAMAGE
			laser.direction = laser_spawn_point.global_position.direction_to(closest_target.global_position)
			laser_parent.add_child(laser)
			laser.global_position = laser_spawn_point.global_position
