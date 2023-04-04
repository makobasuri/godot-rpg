@tool
extends Item

class_name Equipment

@export var slot = Enums.SLOTS
@export var twoHanded: bool = false
@export var armor: int = 0
@export var damageMin: int = 0
@export var damageMax: int = 0
@export var damageType: Enums.DAMAGE_TYPE = Enums.DAMAGE_TYPE.PHYSICAL
@export var tier: int = 0
@export var enchantments: Array = []
