extends Node

var money := 0:
	set(value):
		money = value
		EventBus.trigger_money_changed()

var seconds_until_next_wave := 120:
	set(value):
		seconds_until_next_wave = value
		EventBus.trigger_seconds_until_next_wave_changed()

var shield_health := 100:
	set(value):
		shield_health = value
		EventBus.trigger_shield_health_changed()

var is_shop_open := false