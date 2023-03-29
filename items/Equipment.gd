@tool
extends Item

class_name Equipment

@export var slot = Enums.SLOTS
@export var armor: int = 0
@export var damageMin: int = 0
@export var damageMax: int = 0
@export var tier: int = 0
@export var enchantments: Array = []
