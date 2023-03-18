extends Node2D

@onready var enemySpots = get_tree().get_nodes_in_group('enemySpots')
@onready var placeHolderEnemies = get_tree().get_nodes_in_group('enemy')
# this will be dynamically loaded, it will be an array of enemies, depending on weighting in a list of possible enemies
@onready var enemy = preload("res://enemies/ghost.tscn")

var selectables = [[], []]
var selected
var selectedX
var selectedY
var isSelectingEnemy

# TODO: somethings not right

func getFirstNonNullIdx(arr):
	for idx in len(arr):
		if arr[idx]:
			return idx

func getFirstSelectable():
	for outerIdx in len(selectables):
		for innerIdx in len(selectables[outerIdx]):
			var selectable = selectables[outerIdx][innerIdx]
			if selectable:
				selectedX = outerIdx
				selectedY = innerIdx
				return selectable
			else:
				return null

func onSelectingEnemies():
	if selected:
		# remember to clear selected if it died
		return

	var firstSelectable = getFirstSelectable()
	if firstSelectable:
		isSelectingEnemy = true
		selected = firstSelectable
		selected.get_children()[0].onSelected()

func resetSelectionTween():
	for node in enemySpots:
		var maybeTweeningNode = node.get_children()[0]
		if maybeTweeningNode.tween:
			maybeTweeningNode.tween.kill()
			maybeTweeningNode.modulate = Color(1, 1, 1, 1)

func onSelectEnemy():
	if selected:
		resetSelectionTween()

	if selectables[selectedX][selectedY]:
		selected = selectables[selectedX][selectedY]
	else:
		selectedY = getFirstNonNullIdx(selectables[selectedX])
		selected = selectables[selectedX][selectedY]

	selected.get_children()[0].onSelected()


# Called when the node enters the scene tree for the first time.
func _ready():
	for placeholderEnemy in placeHolderEnemies:
		placeholderEnemy.get_parent().remove_child(placeholderEnemy)

	for index in len(enemySpots):
		var enemySpot = enemySpots[index]

		if enemySpot.name.begins_with('front'):
			selectables[0].append(enemySpot)
		else:
			selectables[1].append(enemySpot)
		# this will be dynamically filled later
		enemySpot.add_child(enemy.instantiate())

	Signals.connect('selectingEnemies', onSelectingEnemies)


func _input(event):
	if !isSelectingEnemy:
		return

	var lenX = len(selectables)
	var lenY = len(selectables[selectedX])
	if event.is_action_released('ui_up'):
		selectedY = (selectedY - 1 + lenY) % lenY
		onSelectEnemy()
	if event.is_action_released('ui_right'):
		selectedX = (selectedX + 1) % lenX
		onSelectEnemy()
	if event.is_action_released('ui_down'):
		selectedY = (selectedY + 1) % lenY
		onSelectEnemy()
	if event.is_action_released('ui_left'):
		selectedX = (selectedX - 1) + lenX % lenX
		onSelectEnemy()
	if event.is_action_released('ui_accept'):
		isSelectingEnemy = false
	if event.is_action_released('ui_cancel'):
		isSelectingEnemy = false
