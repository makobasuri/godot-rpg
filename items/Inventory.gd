extends Panel

@onready var itemGrid = $ItemGrid
@onready var Slot = preload("res://items/InventorySlot.tscn")
@onready var grabbedItemSlot = $GrabbedItemSlot
@onready var externalItemGridPanel = $ExternalItemGridPanel
@onready var externalItemGrid = $ExternalItemGridPanel/ExternalItemGrid

var inventoryShown = false
var tween
var grabbedItem: Item
var slotClickedConnected = false
var externalInventoryOwner = null

func openInventory():
	if (inventoryShown):
		return
	tween = create_tween()
	tween.tween_property(self, 'modulate', Color(1, 1, 1, 1), 0.4)
	inventoryShown = true


func onInventoryToggle():
	if (inventoryShown):
		tween = create_tween()
		tween.tween_property(self, 'modulate', Color(1, 1, 1, 0), 0.4)
		inventoryShown = false
		return
	openInventory()

func onBattleEntered():
	if (inventoryShown):
		modulate = Color(1, 1, 1, 0)
		inventoryShown = false

func populateInventory(inventoryData: InventoryData, grid = itemGrid):
	for child in grid.get_children():
		child.queue_free()
	for slotData in inventoryData.slotData:
		var slot = Slot.instantiate()
		slot.setItem(slotData)
		grid.add_child(slot)
	inventoryData.parent = grid
	Signals.connect('slotClicked', inventoryData.onSlotClicked)

func updateGrabbedItem():
	if grabbedItem:
		grabbedItemSlot.show()
		grabbedItemSlot.setItem(grabbedItem)
	else:
		grabbedItemSlot.hide()

func onInventoryInteract(inventoryData: InventoryData, index: int, button: int):
	match [grabbedItem, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbedItem = inventoryData.grabSlotData(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbedItem = inventoryData.dropSlotData(grabbedItem, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbedItem = inventoryData.dropSingleSlotData(grabbedItem, index)
	updateGrabbedItem()

func onOpenedChest(chest: Chest):
	openInventory()
	populateInventory(chest.inventoryExternal, externalItemGrid)
	externalItemGridPanel.show()

func _ready():
	populateInventory(PartyStats.inventory)
	self.modulate = Color(1, 1, 1, 0)
	Signals.connect('inventoryUpdated', populateInventory)
	Signals.connect('enterBattle', onBattleEntered)
	Signals.connect('inventoryInteract', onInventoryInteract)
	Signals.connect('openedChest', onOpenedChest)

func _input(event):
	if event.is_action_pressed('inventoryToggle'):
		onInventoryToggle()

func _physics_process(_delta):
	if grabbedItemSlot.visible:
		grabbedItemSlot.global_position = get_global_mouse_position() + Vector2(3, 3)
