extends Panel

class_name Statblock
@onready var vBoxContainer = $VBoxContainer
@onready var placeholderStatblockItems = vBoxContainer.get_children()
@onready var StatblockItem = preload('res://battles/GUI/statblockItem.tscn')
var memberStatContainers = []

func onCharactersSpawned(characterNodes):
	for char in characterNodes:
		var charName = char.charName
		var currHP = char.currHP
		var maxHP = char.maxHP
		var currMP = char.currMP
		var maxMP = char.maxMP
		var statblockItem = StatblockItem.instantiate()
		vBoxContainer.add_child(statblockItem)
		statblockItem.init(
			charName,
			currHP,
			maxHP,
			currMP,
			maxMP
		)

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in placeholderStatblockItems:
		vBoxContainer.remove_child(node)
	Signals.connect('charactersSpawned', onCharactersSpawned)
