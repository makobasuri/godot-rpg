extends Node2D

@onready var battleGround = preload('res://battles/battle.tscn')
@onready var transitionBG = $TransitionBG
@onready var player = $AnimationPlayer
@onready var exploreMode = $ExploreMode
@onready var camera = $ExploreMode/Camera2D
@onready var dungeon = $Dungeon

var positionChangedTimes = 0
var chanceToEncounter = 0
var inventoryShown = false
var tween

var encounterChance = 200

func transitionBegin():
	transitionBG.position.x = camera.position.x - get_viewport().size.x / 2
	transitionBG.position.y = camera.position.y - get_viewport().size.y / 2
	transitionBG.size = get_viewport().size
	player.play("fadeOut")
	await player.animation_finished
	transitionBG.position = get_viewport_rect().position
	transitionBG.size = get_viewport().size
	camera.enabled = false

func transitionEnd():
	player.play("fadeIn")
	await player.animation_finished

func onPositionChanged():
	positionChangedTimes += 1
	print(positionChangedTimes)
	if positionChangedTimes > 30:
		chanceToEncounter = randi() % encounterChance
		if chanceToEncounter < encounterChance:
			chanceToEncounter += 1
		if chanceToEncounter == encounterChance:
			Signals.emit_signal('enterBattle')
			transitionBegin()
			var battleGroundInstance = battleGround.instantiate()
			add_child(battleGroundInstance)
			transitionEnd()

func onBattleIsOver():
	camera.enabled = true
	chanceToEncounter = 0

func onPlayerEntered(location):
	print('world should handle transition to dungeon, args: ', location)
	# if player entered dungeon:
	Signals.emit_signal('enteredDungeon')
	transitionBegin()
	exploreMode.hide()
	dungeon.generateMap()
	dungeon.show()
	transitionEnd()

func _ready():
	Signals.connect('positionChanged', onPositionChanged)
	Signals.connect('battleIsOver', onBattleIsOver)
	Signals.connect('playerEntered', onPlayerEntered)
