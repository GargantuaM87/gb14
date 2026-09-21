extends Node2D

@onready var money_label: Label = %MoneyLabel
@onready var time_left_label: Label = %TimeLeftLabel
@onready var hp_bar: HPBar = %HpBar
@onready var wave_count_label: Label = %WaveCountLabel


func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.seconds_until_next_wave_changed.connect(_on_seconds_until_next_wave_changed)
	EventBus.wave_state_changed.connect(_on_wave_state_changed)
	EventBus.player_above_ground_changed.connect(_on_player_above_ground_changed)
	EventBus.shield_health_changed.connect(_on_shield_health_changed)

	_on_money_changed()
	_on_seconds_until_next_wave_changed()
	_on_wave_state_changed()
	_on_player_above_ground_changed()
	_on_shield_health_changed()

func _on_money_changed() -> void:
	money_label.text = "$" + str(GlobalState.money)

func _on_seconds_until_next_wave_changed() -> void:
	var time_left := int(GlobalState.seconds_until_next_wave)
	var minutes := floori(time_left / 60.0)
	var seconds := time_left % 60
	time_left_label.text = str(minutes).pad_zeros(1) + ":" + str(seconds).pad_zeros(2)

func _on_wave_state_changed() -> void:
	var wave_number := GlobalState.current_wave
	if !GlobalState.wave_in_progress:
		wave_number += 1
	if GlobalState.is_endless_mode:
		wave_count_label.text = "Wave %d" % wave_number
	else:
		wave_number = clampi(wave_number, 1, GlobalState.max_wave_count)
		wave_count_label.text = "Wave %d/%d" % [wave_number, GlobalState.max_wave_count]

func _on_player_above_ground_changed() -> void:
	# Let's just always show it for now
	#wave_count_label.visible = GlobalState.is_player_above_ground
	pass

func _on_shield_health_changed() -> void:
	hp_bar.max_hp = GlobalState.max_shield_health
	hp_bar.hp = GlobalState.shield_health
