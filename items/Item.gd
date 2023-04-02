@tool
extends Resource

class_name Item

@export var name: String = ''
@export var cost: int = 0
@export var texture: Texture
@export var rarity: float = 0.5
@export var quantity: int = 1
@export var stackable: bool = false
#@export var partIn: Array[Recepe]

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
