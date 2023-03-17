extends Node2D

#var filterRefRectNodes = func(node): return node is ReferenceRect
#var filterButtonNodes = func(node): return node is Button
#var mapToRefRectChildren = func(node): return node.get_children().filter(filterRefRectNodes)[0]
#var mapToEnemyButtons = func(node): return node.get_children().filter(filterButtonNodes)[0]
#var getEnemyButtons = func(enemyParent): return enemyParent.get_children().map(mapToRefRectChildren).map(mapToEnemyButtons)
var memberOneStats = PartyStats.partyMemberOne
var memberTwoStats = PartyStats.partyMemberTwo
var memberThreeStats = PartyStats.partyMemberThree
var memberFoutStats = PartyStats.partyMemberFour
var membersStats = [memberOneStats, memberTwoStats, memberThreeStats, memberFoutStats]

@onready var Character = preload('res://chars/Character.tscn')

@onready var partyContainer = $Party
@onready var enemiesContainer = $Enemies
@onready var partyMemberSpots = partyContainer.get_children()

var characterNodes = null
var enemyNodes = null

var turnQueue = []

func activateBattler():
	var activeBattler = turnQueue[0]
	Signals.emit_signal('battlerActivated', activeBattler)

func initTurnQueue():
	characterNodes = get_tree().get_nodes_in_group('character')
	enemyNodes = get_tree().get_nodes_in_group('enemy')
	turnQueue = turnQueue + characterNodes + enemyNodes

	Signals.emit_signal('charactersSpawned', characterNodes)
	turnQueue.sort_custom(func(a, b): return a.speed > b.speed)
	activateBattler()

func onBattlerFinishedTurn():
	var finishedBattler = turnQueue.pop_front()
	turnQueue.push_back(finishedBattler)
	activateBattler()

func _ready():
	var placeHolderChars = get_tree().get_nodes_in_group('character')

#	var battlers = [] + characters + enemies
	var characters = membersStats.map(
		func(memberStats): return Character.instantiate().init(memberStats)
	)

	for index in len(membersStats):
		var memberStats = membersStats[index]
		var parent = partyMemberSpots[index]
		var placeHolderChar = placeHolderChars[index]
		var charInstance = characters[index]
		parent.remove_child(placeHolderChar)
		parent.add_child(charInstance)

	initTurnQueue()
	Signals.connect('battlerFinishedTurn', onBattlerFinishedTurn)
