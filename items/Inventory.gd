extends Panel

@onready var itemGrid = $ItemGrid
@onready var Slot = preload("res://items/InventorySlot.tscn")
@onready var CharTabContents = preload("res://items/CharTabContents.tscn")
@onready var statsInspectorItem = preload('res://items/statsInspectorItem.tscn')
@onready var grabbedItemSlot = $GrabbedItemSlot
@onready var externalItemGridPanel = $ExternalItemGridPanel
@onready var externalItemGrid = $ExternalItemGridPanel/ExternalItemGrid
@onready var charEquipmentSwitcher = $CharEquipmentSwitcher

var inventoryShown = false
var tween
var grabbedItem: Item
var slotClickedConnected = false
var externalInventoryOwner = null
var externalInventoryOpened = false
var focusedPartyMember = null
var inBattle: bool = false

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
		if externalInventoryOpened:
			populateInventory(null, externalItemGrid)
			externalItemGridPanel.hide()
			Signals.disconnect('slotClicked', externalInventoryOwner.inventoryExternal.onSlotClicked)
			Signals.emit_signal('chestClosed', externalInventoryOwner)
			externalInventoryOwner = null
			externalInventoryOpened = false
	else:
		openInventory()

func onBattleEntered():
	inBattle = true
	if (inventoryShown):
		modulate = Color(1, 1, 1, 0)
		inventoryShown = false

func onBattleIsOver():
	inBattle = false

func populateInventory(inventoryData: InventoryData = null, grid = itemGrid):
	var gridChildren = grid.get_children()
	for gridIdx in len(gridChildren):
		gridChildren[gridIdx].setItem(null)
	if inventoryData:
		for slotIdx in len(inventoryData.slotData):
			gridChildren[slotIdx].setItem(inventoryData.slotData[slotIdx])
		inventoryData.parent = grid
		if Signals.is_connected('slotClicked', inventoryData.onSlotClicked):
			return
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
			inventoryData.useItemInSlot(index, focusedPartyMember)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbedItem = inventoryData.dropSingleSlotData(grabbedItem, index)
	updateGrabbedItem()

func onOpenedChest(chest: Chest):
	openInventory()
	externalInventoryOwner = chest
	populateInventory(chest.inventoryExternal, externalItemGrid)
	externalInventoryOpened = true
	externalItemGridPanel.show()

func setStatItem(parent, text, value):
	var statItem = statsInspectorItem.instantiate()
	var statItemLabel = statItem.get_node('MarginContainer/StatLabel')
	var statItemValue = statItem.get_node('MarginContainer/StatValue')
	statItemLabel.text = text
	statItemValue.text = str(value)
	parent.add_child(statItem)

func populateStatsInspector(member, statItemsParent):
	for statItemPlaceholder in statItemsParent.get_children():
		statItemsParent.remove_child(statItemPlaceholder)
	var doubledStatName = ''
	var doubledStatValue = ''
	for stat in member:
		var statValue = member[stat]
		if typeof(statValue) == TYPE_INT:
			if stat.contains('curr'):
				doubledStatName = stat.trim_prefix('curr')
				doubledStatValue = str(statValue) + '/'
				print(doubledStatName, doubledStatValue)
				continue
			if stat.contains('max') && len(doubledStatName) > 0:
				doubledStatValue += str(statValue)
				setStatItem(statItemsParent, doubledStatName, doubledStatValue)
				doubledStatName = ''
				doubledStatValue = ''
				continue
			if stat.contains('Min'):
				doubledStatName = stat.trim_suffix('Min')
				doubledStatValue = str(statValue) + '-'
				continue
			if stat.contains('Max'):
				doubledStatValue += str(statValue)
				setStatItem(statItemsParent, doubledStatName, doubledStatValue)
				doubledStatName = ''
				doubledStatValue = ''
				continue
			setStatItem(statItemsParent, stat, statValue)

func onStatsChanged(member):
	var tabCount = charEquipmentSwitcher.get_tab_count()
	for idx in range(0, tabCount):
		if member.charName == charEquipmentSwitcher.get_tab_title(idx):
			var charEquipmentTabContent = charEquipmentSwitcher.get_children()[idx]
			var statList = charEquipmentTabContent.get_node(
				'statsInspector/ScrollContainer/VBoxContainer'
			)
			populateStatsInspector(member, statList)


func _ready():
	var CharTabContentsPlaceHolder = $CharEquipmentSwitcher/CharTabContents
	charEquipmentSwitcher.remove_child(CharTabContentsPlaceHolder)
	for partyMemberIdx in len(PartyStats.partyMembers):
		var partyMember = PartyStats.partyMembers[partyMemberIdx]
		var charEquipmentInstance = CharTabContents.instantiate()
		charEquipmentSwitcher.add_child(charEquipmentInstance)
		charEquipmentSwitcher.set_tab_title(partyMemberIdx, partyMember.charName)
		populateInventory(partyMember.equipment, charEquipmentInstance.get_node('CharEquipment'))
		populateStatsInspector(
			partyMember, charEquipmentInstance.get_node('statsInspector/ScrollContainer/VBoxContainer')
		)
	focusedPartyMember = PartyStats.partyMembers[0]
	populateInventory(PartyStats.inventory)
	populateInventory(null, externalItemGrid)
	self.modulate = Color(1, 1, 1, 0)
	Signals.connect('inventoryUpdated', populateInventory)
	Signals.connect('enterBattle', onBattleEntered)
	Signals.connect('battleIsOver', onBattleIsOver)
	Signals.connect('inventoryInteract', onInventoryInteract)
	Signals.connect('openedChest', onOpenedChest)
	Signals.connect('statsChanged', onStatsChanged)

func _input(event):
	if event.is_action_pressed('inventoryToggle') && !inBattle:
		onInventoryToggle()

func _physics_process(_delta):
	if grabbedItemSlot.visible:
		grabbedItemSlot.global_position = get_global_mouse_position() + Vector2(3, 3)
