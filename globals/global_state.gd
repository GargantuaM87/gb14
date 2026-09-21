extends Node

var moneyMult = 1
var money := 0 if Util.is_exported_build() else 10:
	set(value):
		money = value
		EventBus.trigger_money_changed()

var seconds_until_next_wave := 120:
	set(value):
		seconds_until_next_wave = value
		EventBus.trigger_seconds_until_next_wave_changed()
var max_shield_health := 100
var shield_health := max_shield_health:
	set(value):
		if value <= max_shield_health:
			shield_health = value
		EventBus.trigger_shield_health_changed()

var max_wave_count := 5
var current_wave := 0
var wave_in_progress := false

var is_player_above_ground := false:
	set(value):
		if is_player_above_ground == value:
			return
		is_player_above_ground = value
		EventBus.trigger_player_above_ground_changed()

var is_shop_open := false
var player: Player = null
