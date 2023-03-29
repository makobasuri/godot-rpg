extends Panel

class_name Statblock
@onready var vBoxContainer = $VBoxContainer
@onready var placeholderStatblockItems = vBoxContainer.get_children()
@onready var StatblockItem = preload('res://battles/GUI/statblockItem.tscn')
var memberStatContainers = []
var tween

func onCharactersSpawned(characterNodes):
	for chr in characterNodes:
		var charName = chr.charName
		var currHP = chr.currHP
		var maxHP = chr.maxHP
		var currMP = chr.currMP
		var maxMP = chr.maxMP
		var statblockItem = StatblockItem.instantiate()
		vBoxContainer.add_child(statblockItem)
		statblockItem.init(
			charName,
			currHP,
			maxHP,
			currMP,
			maxMP
		)
	tween = create_tween()
	tween.tween_property(self, 'position', Vector2(15, position.y), 0.4).set_trans(Tween.TRANS_CUBIC)

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in placeholderStatblockItems:
		vBoxContainer.remove_child(node)
	Signals.connect('charactersSpawned', onCharactersSpawned)
