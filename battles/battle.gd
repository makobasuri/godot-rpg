extends Node2D

#var filterRefRectNodes = func(node): return node is ReferenceRect
#var filterButtonNodes = func(node): return node is Button
#var mapToRefRectChildren = func(node): return node.get_children().filter(filterRefRectNodes)[0]
#var mapToEnemyButtons = func(node): return node.get_children().filter(filterButtonNodes)[0]
#var getEnemyButtons = func(enemyParent): return enemyParent.get_children().map(mapToRefRectChildren).map(mapToEnemyButtons)

@onready var Character = preload('res://chars/Character.tscn')

@onready var partyContainer = $Party
@onready var enemiesContainer = $Enemies
@onready var partyMemberSpots = partyContainer.get_children()

var characterNodes = null
var enemyNodes = null

var turnQueue = []
var battleIsOver = false

func getSpeed(node):
	if 'stats' in node && node.stats.speed:
		return node.stats.speed
	return node.speed

func activateBattler():
	var activeBattler = turnQueue[0]
	Signals.emit_signal('battlerActivated', activeBattler)

func initTurnQueue():
	characterNodes = get_tree().get_nodes_in_group('character')
	enemyNodes = get_tree().get_nodes_in_group('enemy')
	turnQueue = turnQueue + characterNodes + enemyNodes

	Signals.emit_signal('charactersSpawned', characterNodes)
	turnQueue.sort_custom(func(a, b): return getSpeed(a) > getSpeed(b))
	activateBattler()

func onBattlerFinishedTurn():
	var finishedBattler = turnQueue.pop_front()
	turnQueue.push_back(finishedBattler)
	activateBattler()

func onBattlerDied(battler):
	turnQueue = turnQueue.filter(func(item): return item != battler)

func calcExpGained():
	var totalChrCr = characterNodes.reduce(func(accum, curr): return accum + curr.stats.level, 0)
	var totalEnemyCr = enemyNodes.reduce(func(acc, curr): return acc + curr.CR, 0.0)
	var partyCR = float(totalChrCr / len(characterNodes))
	var enemyCR = float(totalEnemyCr / len(characterNodes))
	var difference = (partyCR - enemyCR) * 10.0
	var expEarned = enemyCR * 10.0
	var expGained = expEarned - difference if expEarned > difference else enemyCR
#	print('exp: ', partyCR, ' ', enemyCR, ' ', expGained)
	return ceil(expGained)

func onVictory():
	var droppedLoot = []
	var gainedExp = calcExpGained()
	var gainedCurrency = 0

	for enemyNode in enemyNodes:
		if enemyNode.currencyMax > 0:
			gainedCurrency += randi_range(enemyNode.currencyMin, enemyNode.currencyMax)
		if len(enemyNode.loot) > 0:
			for lootItem in enemyNode.loot:
				if randf() < lootItem.rarity:
					droppedLoot.append(lootItem)
	Signals.emit_signal('gainedLoot', droppedLoot)
	Signals.emit_signal('gainedExp', gainedExp)
	Signals.emit_signal('gainedCurrency', gainedCurrency)
	battleIsOver = true

func _ready():
	var placeHolderChars = get_tree().get_nodes_in_group('character')
	for placeHolderCharIdx in len(placeHolderChars):
		var parent = partyMemberSpots[placeHolderCharIdx]
		parent.remove_child(placeHolderChars[placeHolderCharIdx])

	var characters = PartyStats.partyMembers.map(
		func(memberStats):
			var charInstance = Character.instantiate()
			charInstance.init(memberStats)
			return charInstance
	)

	for index in len(PartyStats.partyMembers):
		var parent = partyMemberSpots[index]
		var charInstance = characters[index]
		parent.add_child(charInstance)

	initTurnQueue()
	Signals.connect('victory', onVictory)
	Signals.connect('died', onBattlerDied)
	Signals.connect('battlerFinishedTurn', onBattlerFinishedTurn)

func _input(event):
	if !battleIsOver:
		return
	if event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel"):
		Signals.emit_signal('battleIsOver')
		self.queue_free()
