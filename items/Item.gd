@tool
extends Resource

class_name Item

@export var name: String = ''
@export var cost: int = 0
@export var texture: Texture
@export var rarity: float = 0.5
#@export var partIn: Array[Recepe]

func getTexture() -> Texture:
	return texture
