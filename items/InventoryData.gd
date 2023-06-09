extends Resource

class_name InventoryData

@export var slotData: Array[Item]
var parent = null

func onSlotClicked(clickedParent, index: int, button: int):
	if clickedParent != parent:
		return
	Signals.emit_signal('inventoryInteract', self, index, button)

func useItemInSlot(index: int, target):
	var slotDataToUse = slotData[index]
	if slotDataToUse:
		slotDataToUse.use(target)
		if slotDataToUse.consumed:
			slotData[index] = null
		Signals.emit_signal('inventoryUpdated', self, parent)

func grabSlotData(index: int) -> Item:
	var slotDataToGrab = slotData[index]
	if slotDataToGrab:
		slotData[index] = null
		Signals.emit_signal('inventoryUpdated', self, parent)
	return slotDataToGrab

func dropSlotData(grabbedItem: Item, index: int):
	var slotDataToGrab: Item = slotData[index]
	var returnSlotData: Item
	if slotDataToGrab && slotDataToGrab.canMergeWith(grabbedItem):
		slotDataToGrab.mergeWith(grabbedItem)
	else:
		slotData[index] = grabbedItem
		returnSlotData = slotDataToGrab
	Signals.emit_signal('inventoryUpdated', self, parent)
	return returnSlotData

func dropSingleSlotData(grabbedItem: Item, index: int):
	var slotDataToGrab: Item = slotData[index]
	if not slotDataToGrab:
		slotData[index] = grabbedItem.splitQuantity()
	elif slotDataToGrab.canMergeWith(grabbedItem):
		slotDataToGrab.mergeWith(grabbedItem.splitQuantity())
	Signals.emit_signal('inventoryUpdated', self, parent)
	if grabbedItem.quantity > 0:
		return grabbedItem
	else:
		return null

func isEmpty():
	return len(slotData.filter(func(item): return item != null)) == 0
