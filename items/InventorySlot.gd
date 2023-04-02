extends PanelContainer

class_name InventorySlot
@export var item: Item

func setItem(slotData = null):
	var textureRect = $MarginContainer/TextureRect
	var labelQuantity = $LabelQuantity
	if slotData:
		textureRect.texture = slotData.texture if slotData.texture else null
		if slotData.quantity > 1:
			labelQuantity.text = str(slotData.quantity)
			labelQuantity.show()
		else:
			labelQuantity.hide()
		return
	textureRect.texture = null
	labelQuantity.text = ''

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton \
		and (
			event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT
		) and event.is_pressed():
			Signals.emit_signal('slotClicked', get_parent(), get_index(), event.button_index)
