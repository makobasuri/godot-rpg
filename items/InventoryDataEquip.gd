extends InventoryData

class_name InventoryDataEquip

func dropSlotData(grabbedItem: Item, index: int):
	if not grabbedItem is Equipment:
		return grabbedItem
	if grabbedItem.slot != index:
		return grabbedItem
	return super.dropSlotData(grabbedItem, index)

func dropSingleSlotData(grabbedItem: Item, index: int):
	if not grabbedItem is Equipment:
		return grabbedItem
	if grabbedItem.slot != index:
		return grabbedItem
	return super.dropSingleSlotData(grabbedItem, index)
