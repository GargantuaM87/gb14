extends Node

const INITIAL_MONEY_EXPORTED := 0
const INITIAL_MONEY_LOCAL := 10
const INITIAL_MONEY_MULTIPLIER := 1
const WAVE_LENGTH_SECONDS := 60
const INITIAL_MAX_SHIELD_HEALTH := 100
const INITIAL_MAX_WAVE_COUNT := 5
const INITIAL_WAVE := 0

var moneyMult = INITIAL_MONEY_MULTIPLIER
var money := INITIAL_MONEY_EXPORTED if Util.is_exported_build() else INITIAL_MONEY_LOCAL:
	set(value):
		money = value
		EventBus.trigger_money_changed()

var seconds_until_next_wave := WAVE_LENGTH_SECONDS:
	set(value):
		seconds_until_next_wave = value
		EventBus.trigger_seconds_until_next_wave_changed()
var max_shield_health := INITIAL_MAX_SHIELD_HEALTH
var shield_health := max_shield_health:
	set(value):
		if value <= max_shield_health:
			shield_health = value
		EventBus.trigger_shield_health_changed()

var max_wave_count := INITIAL_MAX_WAVE_COUNT
var current_wave := INITIAL_WAVE
var wave_in_progress := false

var is_player_above_ground := false:
	set(value):
		if is_player_above_ground == value:
			return
		is_player_above_ground = value
		EventBus.trigger_player_above_ground_changed()

var is_shop_open := false
var is_game_over := false
var player: Player = null

func reset_for_new_run() -> void:
	moneyMult = INITIAL_MONEY_MULTIPLIER
	money = INITIAL_MONEY_EXPORTED if Util.is_exported_build() else INITIAL_MONEY_LOCAL
	seconds_until_next_wave = WAVE_LENGTH_SECONDS
	max_shield_health = INITIAL_MAX_SHIELD_HEALTH
	shield_health = max_shield_health
	max_wave_count = INITIAL_MAX_WAVE_COUNT
	current_wave = INITIAL_WAVE
	wave_in_progress = false
	is_player_above_ground = false
	is_shop_open = false
	is_game_over = false
	player = null
