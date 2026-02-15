class_name Boon extends Resource

enum Type { 
    HEALTH_PLUS, 
    ATTACK_MULTIPLIER, 
    ATTACK_SPEED_MULTIPLIER, 
    SPEED_MULTIPLIER, 
    SHIELD_STAMINA_PLUS,
    BLOCK_MOVEMENT_SPEED_MULTIPLIER,
    LIFESTEAL_CHANCE,
    BLOCK_KNOCKBACK_MULTIPLIER
}

enum Rarity { 
    COMMON, 
    RARE, 
    EPIC 
}

static var chance_by_rarity = {
    Boon.Rarity.COMMON: 0.55, 
    Boon.Rarity.RARE: 0.30, 
    Boon.Rarity.EPIC: 0.15
}

@export var title: String
@export var description: String
@export var is_dark: bool

@export var type: Type
@export var value_common: float
@export var value_rare: float
@export var value_epic: float

var rarity: Rarity
var value: float:
    get:
        match rarity:
            Rarity.COMMON:
                return value_common
            Rarity.RARE:
                return value_rare
            Rarity.EPIC:
                return value_epic
        return 0.0