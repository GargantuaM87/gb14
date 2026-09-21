extends Node2D

@onready var camera : Camera2D = %Camera

var unlockedUpgrades : Dictionary[String, bool] = {
	"reflection1" = false,
	"reflection2" = false
}
var ignoreDamage := false

func _ready() -> void:
	EventBus.monster_hit_shield.connect(_on_monster_hit_shield)
	EventBus.shield_upgraded.connect(update_upgrade)

func _on_monster_hit_shield(damage: int) -> void:
	if !ignoreDamage:
		var previous_shield_health := GlobalState.shield_health
		GlobalState.shield_health -= damage
		if GlobalState.shield_health < previous_shield_health:
			SfxManager.play_sfx_shield_damage()
	else:
		ignoreDamage = false
	#if GlobalState.shield_health <= GlobalState.max_shield_health * 0.25:
	#camera.add_trauma(1.0)
	
	if unlockedUpgrades["reflection1"] or unlockedUpgrades["reflection2"]:
		ignore_damage()
	
	if GlobalState.shield_health <= 0:
		print("Game Over")

func update_upgrade(upgrade : String) -> void:
	unlockedUpgrades[upgrade] = true
	
func ignore_damage() -> void:
	var chance = 0
	if unlockedUpgrades["reflection1"]:
		chance = 5
	if unlockedUpgrades["reflection2"]:
		chance = 10
	
	var randomNum = randi() % 100 + 1
	
	if randomNum <= chance:
		ignoreDamage = true
