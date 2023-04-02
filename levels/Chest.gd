extends StaticBody2D

class_name Chest

@onready var chestOpened = $"Chest Opened"
@onready var chestIntact = $"Chest Intact"

@export var inventoryExternal: InventoryData

var inventoryOpen = false

func interact():
	if chestIntact.visible:
		inventoryOpen = true
		chestOpened.show()
		chestIntact.hide()
		Signals.emit_signal('openedChest', self)
