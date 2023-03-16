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

@onready var statblockPlaceholder = $Statblock
@onready var statblock = preload(
	'res://battles/GUI/statblock.tscn'
).instantiate().setStatsBlock(membersStats)
@onready var Character = preload('res://chars/Character.tscn')


@onready var cursor = $cursor
@onready var partyContainer = $Party

@onready var enemiesContainer = $Enemies
@onready var partyMemberSpots = partyContainer.get_children()

@onready var enemyButtons = get_tree().get_nodes_in_group('enemyButtons')
@onready var allButtons = Utils.findByClass(self, 'Button')
@onready var lastButtonFocused = null
@onready var lastButtonPressed = null
@onready var tween = null
var characterNodes = null

func setNewCursorPosition(target):
	cursor.position = target.get_screen_position()
	cursor.position.x -= cursor.size.x
	cursor.position.y +=  target.size.y / 2 - cursor.size.y / 2

func onFocusChanged(control:Control) -> void:
	if control == null:
		return

	setNewCursorPosition(control)
	cursor.show()
	lastButtonFocused = control

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

	characterNodes = get_tree().get_nodes_in_group('character')
	# will be managed by a turn queue later
	var activeCharacter = characterNodes[2]
	activeCharacter.currentAction = Enums.ACTION.ACTIVE
	Signals.emit_signal('characterActivated', activeCharacter)

	remove_child(statblockPlaceholder)
	add_child(statblock)
	get_viewport().connect("gui_focus_changed", onFocusChanged)
#	buttonAttack.grab_focus()
#	buttonAttack.pressed.connect(onAttackPressed)
