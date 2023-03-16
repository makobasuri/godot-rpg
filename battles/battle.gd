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

@onready var buttonAttack = $ActionsPanel/Actions/ButtonAttack
@onready var enemyButtons = get_tree().get_nodes_in_group('enemyButtons')
@onready var allButtons = Utils.findByClass(self, 'Button')
@onready var lastButtonFocused = null
@onready var lastButtonPressed = null
@onready var tween = null
var characterNodes = null


func onAttackPressed():
	Signals.emit_signal('selectingEnemies')

	# these will be handled differently later
	characterNodes[0].isAttacking = true
	enemyButtons[0].grab_focus()

func setNewCursorPosition(target):
	cursor.position = target.get_screen_position()
	cursor.position.x -= cursor.size.x
	cursor.position.y +=  target.size.y / 2 - cursor.size.y / 2

func onFocusChanged(control:Control) -> void:
	if control == null:
		return

	if tween:
		var enemyNode = lastButtonFocused.get_parent().get_parent()
		tween.kill()
		enemyNode.modulate = Color(1, 1, 1, 1)

	if control.is_in_group('enemyButtons'):
		var enemyNode = control.get_parent().get_parent()
		tween = control.create_tween()
		tween.set_loops()
		tween.tween_property(enemyNode, 'modulate', Color(1.5, 1.5, 1.5, 1.5), 0.5)
		tween.tween_property(enemyNode, 'modulate', Color(1, 1, 1, 1), 0.5)

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
	characterNodes[0].isActive = true

	remove_child(statblockPlaceholder)
	add_child(statblock)
	get_viewport().connect("gui_focus_changed", onFocusChanged)
	buttonAttack.grab_focus()
	buttonAttack.pressed.connect(onAttackPressed)

#func _input(event):
#	if Input.is_action_pressed("ui_cancel"):
#		if lastButtonFocused.is_in_group('enemyButtons'):
#			buttonAttack.grab_focus()
#	if Input.is_action_pressed("ui_accept"):
#		if lastButtonFocused.is_in_group('enemyButtons'):
#		characterNodes[0].attack()
