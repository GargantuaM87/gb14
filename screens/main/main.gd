extends Node2D

@onready var monsters: Node2D = %Monsters
@onready var player: Player = %Player
@onready var ground: Node2D = %Ground
@onready var camera: Camera2D = %Camera
@onready var monster_spawn_position: Marker2D = %MonsterSpawnPosition
@onready var shop: Node2D = %Shop
@onready var shop_notification: Node2D = %ShopNotification

const WAVE_LENGTH_SECONDS := 10

var monster_scenes := [
	preload("uid://bapq6tesgu84k"),
	preload("uid://tprv2crptn14"),
	preload("uid://dxmfm0d5pmloh"),
]

func _ready() -> void:
	GlobalState.seconds_until_next_wave = WAVE_LENGTH_SECONDS

func _process(_delta: float) -> void:
	if is_above_ground():
		set_look_up(true)
		if !GlobalState.is_shop_open:
			shop_notification.show()

			if Input.is_action_just_pressed("b_button"):
				await get_tree().process_frame # Avoid the same button being processed by the shop too.
				GlobalState.is_shop_open = true
				shop.show()
				shop_notification.hide()
	else:
		set_look_up(false)
		shop_notification.hide()

var offset_tween: Tween
var is_looking_up := false
func set_look_up(enabled: bool) -> void:
	if is_looking_up == enabled:
		return
	is_looking_up = enabled

	if offset_tween:
		offset_tween.kill()

	var target_offset := Vector2(0, -50) if enabled else Vector2.ZERO

	offset_tween = create_tween()
	offset_tween.set_trans(Tween.TRANS_CUBIC)
	offset_tween.set_ease(Tween.EASE_OUT)
	offset_tween.tween_property(camera, "offset", target_offset, 1.0)

func _on_wave_countdown_timer_timeout() -> void:
	# Let the timer stay at 0:00 for a second before starting the next countdown.
	if GlobalState.seconds_until_next_wave <= 0:
		spawn_monster_wave()

		GlobalState.seconds_until_next_wave = WAVE_LENGTH_SECONDS
	
	elif GlobalState.seconds_until_next_wave > 0:
		GlobalState.seconds_until_next_wave -= 1

func spawn_monster_wave() -> void:
	# Spread out the monsters horizontally
	var spawn_x_offsets: Array[float] = []
	const spawn_offset_count := 8
	for i in range(spawn_offset_count):
		spawn_x_offsets.append(lerpf(-80.0, 80.0, float(i) / (spawn_offset_count - 1.0)))
	spawn_x_offsets.shuffle()

	for i in range(3):
		var monster := monster_scenes.pick_random().instantiate() as Node2D
		monster.global_position.y = monster_spawn_position.global_position.y
		monster.global_position.x = monster_spawn_position.global_position.x + spawn_x_offsets[i] + randf_range(-2.0, 2.0)
		monsters.add_child(monster)

func is_above_ground() -> bool:
	return player.global_position.y < ground.global_position.y
