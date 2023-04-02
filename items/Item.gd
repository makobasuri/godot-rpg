@tool
extends Resource

class_name Item


@export var name: String = ''
@export var cost: int = 0
@export var texture: Texture
@export var rarity: float = 0.5
@export var quantity: int = 1
@export var stackable: bool = false
@export var usable: bool = false
@export var consumable: bool = false
@export var needsTarget: bool = true
@export_enum('healHP', 'healMP') var effectAction: String
@export var effectType: Enums.EFFECT_TYPE
@export var effectValue: int = 0

#@export var partIn: Array[Recepe]
var consumed = false

func getTexture() -> Texture:
	return texture

func canMergeWith(otherItem: Item) -> bool:
	return name == otherItem.name && stackable

func mergeWith(otherItem: Item) -> void:
	quantity += otherItem.quantity

func splitQuantity(quant = null) -> Item:
	var splitStack = duplicate()
	splitStack.quantity = quant || 1
	quantity -= 1
	return splitStack

func use(target):
	if usable:
		if needsTarget && target == null:
			return
		pass
	if consumable:
		if needsTarget && target == null:
			return
		if needsTarget && target != null:
			PartyStats.actions[effectAction].call(target, effectValue)
		Signals.emit_signal('itemUsed', self)
		quantity -= 1
		if quantity < 1:
			consumed = true
