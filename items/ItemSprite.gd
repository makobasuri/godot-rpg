@tool
extends TextureRect

class_name ItemSprite

@export var myItem: Item

func _ready():
	if myItem:
		self.texture = myItem.getTexture()
