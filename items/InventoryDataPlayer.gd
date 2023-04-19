extends InventoryData

class_name InventoryDataPlayer

func findFirstUnusedSlotIdx() -> int:
	for slotIdx in len(slotData):
		if slotData[slotIdx] == null:
			return slotIdx
	slotData.push_back(null)
	return findFirstUnusedSlotIdx()

func findSlotToStackOn(item):
	for slotIdx in len(slotData):
		if slotData[slotIdx] is Item && slotData[slotIdx].name == item.name:
			return slotIdx
	return findFirstUnusedSlotIdx()

func store(loot):
	for item in loot:
		# check if item is stackable and we have an item like that
		var slotIdxToFill = (
			findSlotToStackOn(item) if item.stackable else findFirstUnusedSlotIdx()
		)
		dropSlotData(item, slotIdxToFill)

