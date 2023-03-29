extends Node2D

@onready var enemySpots = get_tree().get_nodes_in_group('enemySpots')
@onready var placeHolderEnemies = get_tree().get_nodes_in_group('enemy')
# this will be dynamically loaded, it will be an array of enemies, depending on weighting in a list of possible enemies
@onready var enemy = preload("res://enemies/ghost.tscn")

var selectables = [[], []]
var selected = null
var lastSelected = null
var selectedX
var selectedY
var isSelectingEnemy: bool
var fightIsOver: bool = false

func getFirstNonDeadIdx(arr):
	for idx in len(arr):
		if !getEnemy(arr[idx]).isDead:
			return idx

func getEnemy(spot):
	var spotChildren = spot.get_children()
	if len(spotChildren) > 0:
		return spot.get_children()[0]

func getFirstSelectable():
	for outerIdx in len(selectables):
		for innerIdx in len(selectables[outerIdx]):
			var selectable = selectables[outerIdx][innerIdx]
			if  getEnemy(selectable) && !getEnemy(selectable).isDead:
				selectedX = outerIdx
				selectedY = innerIdx
				return selectable

func onSelectingEnemies():
	if fightIsOver:
		return
	isSelectingEnemy = true
	if lastSelected:
		if !getEnemy(lastSelected).isDead:
			getEnemy(lastSelected).onSelected()
			return
	selected = getFirstSelectable()
	getEnemy(selected).onSelected()

func resetSelectionTween():
	for node in enemySpots:
		var enemySpotChildren = node.get_children()
		if len(enemySpotChildren) > 0:
			var maybeTweeningNode = node.get_children()[0]
			if maybeTweeningNode && maybeTweeningNode.isDead:
				maybeTweeningNode.selectedTween.kill()
				continue
			if maybeTweeningNode && maybeTweeningNode.selectedTween:
				maybeTweeningNode.selectedTween.kill()
				maybeTweeningNode.modulate = Color(1, 1, 1)

func onSelectEnemy():
	var aliveEnemyIdx = -1
	if selectables[selectedX]:
		for selXIdx in len(selectables[selectedX]):
			if !getEnemy(selectables[selectedX][selXIdx]).isDead:
				aliveEnemyIdx = selXIdx
				break
	if !getEnemy(selectables[selectedX][selectedY]).isDead:
		selected = selectables[selectedX][selectedY]
	elif aliveEnemyIdx != -1:
		selected = selectables[selectedX][aliveEnemyIdx]
	else:
		selected = getFirstSelectable()

	resetSelectionTween()
	getEnemy(selected).onSelected()


func onChoseEnemy():
	isSelectingEnemy = false
	if selected:
		lastSelected = selected
		selected = null
	resetSelectionTween()

func onDied(_node):
	if !getFirstSelectable():
		isSelectingEnemy = false
		fightIsOver = true
		Signals.emit_signal('victory')

# Called when the node enters the scene tree for the first time.
func _ready():
	for placeholderEnemy in placeHolderEnemies:
		placeholderEnemy.get_parent().remove_child(placeholderEnemy)

	for index in len(enemySpots):
		var enemySpot = enemySpots[index]

		if enemySpot.name.begins_with('front'):
			selectables[0].append(enemySpot)
			# this will be dynamically filled later
			enemySpot.add_child(enemy.instantiate())
		else:
			selectables[1].append(enemySpot)

	Signals.connect('selectingEnemies', onSelectingEnemies)
	Signals.connect('choseEnemy', onChoseEnemy)
	Signals.connect('died', onDied)


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
	if event.is_action_released('ui_cancel'):
		isSelectingEnemy = false
