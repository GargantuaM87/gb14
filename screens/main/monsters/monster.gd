class_name Monster
extends Node2D

@onready var canvas_group: CanvasGroup = %CanvasGroup

@export var base_hp := 1

const HP_INCREASE_INTERVAL := 2

var hp := 1
var max_hp := 1
var _flash_tween: Tween

func initialize_for_wave(wave_number: int) -> void:
	var hp_bonus := floori(float(maxi(wave_number - 1, 0)) / HP_INCREASE_INTERVAL)
	max_hp = maxi(base_hp + hp_bonus, 1)
	hp = max_hp

func take_damage(damage: int) -> void:
	if is_queued_for_deletion():
		return
	
	hp -= damage

	if hp <= 0:
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
