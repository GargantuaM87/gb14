extends Resource
class_name UpgradeResource

@export var upgradeName : String
@export var upgradeDesc : String
@export var upgIcon : CompressedTexture2D
@export var isUnlocked := false
@export var unlockUpgs : Array[UpgradeResource]
@export var upgradeCost := 0
@export var app : Upgrade = null
