class_name Monster
extends Node2D

@onready var canvas_group: CanvasGroup = %CanvasGroup

@export var base_hp := 1

const DEATH_SCENE: PackedScene = preload("uid://b3q04anuih0or")
var hp := 1
var max_hp := 1
var _flash_tween: Tween

func initialize_for_wave(_wave_number: int) -> void:
	max_hp = maxi(base_hp, 1)
	hp = max_hp

func take_damage(damage: int) -> void:
	if is_queued_for_deletion():
		return
	
	hp -= damage

	if hp <= 0:
		var death_effect := DEATH_SCENE.instantiate() as Node2D
		get_parent().add_child(death_effect)
		death_effect.global_position = global_position
		SfxManager.play_sfx_enemy_die()
		EventBus.trigger_monster_killed()
		queue_free()
	else:
		flash_white()

func flash_white() -> void:
	var mat := canvas_group.material as ShaderMaterial
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	mat.set_shader_parameter("flash_amount", 1.0)

	_flash_tween = create_tween()
	_flash_tween.tween_method(
		func(v): mat.set_shader_parameter("flash_amount", v),
		1.0,
		0.0,
		0.12
	)
	_flash_tween.tween_callback(func(): mat.set_shader_parameter("flash_amount", 0.0))
