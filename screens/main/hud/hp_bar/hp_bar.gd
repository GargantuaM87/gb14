class_name HPBar
extends Node2D

@onready var max_hpbar: ColorRect = %MaxHPBar
@onready var hpbar: ColorRect = %HPBar
@onready var shield_hp_label: Label = %ShieldHpLabel

@export var hp: int = GlobalState.INITIAL_MAX_SHIELD_HEALTH:
	set(value):
		hp = maxi(value, 0)
		_update_hp_bar()

@export var max_hp: int = GlobalState.INITIAL_MAX_SHIELD_HEALTH:
	set(value):
		max_hp = maxi(value, 1)
		_update_hp_bar()

func _ready() -> void:
	_update_hp_bar()

func _update_hp_bar() -> void:
	if not is_node_ready():
		return

	shield_hp_label.text = str(hp) + " HP"

	var hp_ratio := 0.0
	if max_hp > 0:
		hp_ratio = clampf(float(hp) / float(max_hp), 0.0, 1.0)

	hpbar.size.x = max_hpbar.size.x * hp_ratio
