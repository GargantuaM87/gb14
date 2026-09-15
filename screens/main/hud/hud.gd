extends Node2D

@onready var money_label: Label = %MoneyLabel
@onready var time_left_label: Label = %TimeLeftLabel
@onready var shield_hp_label: Label = %ShieldHpLabel


func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.seconds_until_next_wave_changed.connect(_on_seconds_until_next_wave_changed)
	EventBus.shield_health_changed.connect(_on_shield_health_changed)

	_on_money_changed()
	_on_seconds_until_next_wave_changed()
	_on_shield_health_changed()

func _on_money_changed() -> void:
	money_label.text = "$" + str(GlobalState.money)

func _on_seconds_until_next_wave_changed() -> void:
	var time_left := int(GlobalState.seconds_until_next_wave)
	var minutes := floori(time_left / 60.0)
	var seconds := time_left % 60
	time_left_label.text = str(minutes).pad_zeros(1) + ":" + str(seconds).pad_zeros(2)

func _on_shield_health_changed() -> void:
	shield_hp_label.text = str(GlobalState.shield_health) + " HP"