extends Node2D

@onready var projectile_spawn_point: Marker2D = %ProjectileSpawnPoint
@onready var weapon_sprite: AnimatedSprite2D = %WeaponSprite

@export var projectile_spawn_node_path: Node
var projectile_scene := preload("uid://dd3m6c26vhrem")

const SECONDS_BETWEEN_SHOTS := 1.75
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
			weapon_sprite.play(&"shoot")

			var projectile: Node2D = projectile_scene.instantiate()
			projectile.damage = DAMAGE
			projectile.direction = projectile_spawn_point.global_position.direction_to(closest_target.global_position)

			await get_tree().create_timer(0.2).timeout # Wait for the animation to play

			projectile_spawn_node_path.add_child(projectile)
			projectile.global_position = projectile_spawn_point.global_position


func _on_weapon_sprite_animation_finished() -> void:
	if weapon_sprite.animation == &"shoot":
		weapon_sprite.play(&"idle")
