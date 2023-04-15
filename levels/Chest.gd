extends StaticBody2D

class_name Chest

@onready var chestOpened = $"Chest Opened"
@onready var chestIntact = $"Chest Intact"

@export var inventoryExternal: InventoryData

var inventoryOpen = false
var isInteracting = false

func interact():
	if isInteracting:
		return
	inventoryOpen = true
	isInteracting = true
	Signals.emit_signal('openedChest', self)
	if chestIntact.visible:
		chestOpened.show()
		chestIntact.hide()

func quitInteracting():
	onChestClosed(self)
	Signals.emit_signal('quitInteractingWithInventory', self)

func onChestClosed(chest: Chest):
	if chest == self && isInteracting:
		isInteracting = false
		if inventoryExternal.isEmpty():
			return
		chestOpened.hide()
		chestIntact.show()

func _ready():
	Signals.connect('chestClosed', onChestClosed)
