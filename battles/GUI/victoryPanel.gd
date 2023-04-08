extends Panel

var tween
var itemSprite = preload('res://items/ItemSprite.tscn')
var lootItem = preload('res://battles/GUI/lootItem.tscn')
@onready var lootContainer = $LootContainer
@onready var amountCurrency = $amountCurrency
@onready var amountXP = $amountXP
@onready var amountTotalXP = $amountTotalXP
@onready var amountToNextXP = $amountToNextXP

func onGainedLoot(droppedLoot):
	for placeholder in lootContainer.get_children():
		lootContainer.remove_child(placeholder)
	for item in droppedLoot:
		var lootItemInstance = lootItem.instantiate()
		for child in lootItemInstance.get_children():
			if child is TextureRect:
				child.myItem = item
			if child is Label:
				child.text = item.name
		lootContainer.add_child(lootItemInstance)

func onGainedExp(xp):
	amountXP.text = str(xp)
	amountTotalXP.text = str(float(amountTotalXP.text) + xp)

func onGainedCurrency(currency):
	amountCurrency.text = str(currency) + ' C'

func onVictory():
	var positionY = position.y
	tween = create_tween()
	tween.tween_property(self, 'position', Vector2(430, positionY), 0.4)

func _ready():
	Signals.connect('victory', onVictory)
	Signals.connect('gainedLoot', onGainedLoot)
	Signals.connect('gainedExp', onGainedExp)
	Signals.connect('gainedCurrency', onGainedCurrency)
