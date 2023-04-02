extends Node2D

var membersStats = PartyStats.partyMembers

@onready var battleGround = preload('res://battles/battle.tscn')
@onready var transitionBG = $TransitionBG
@onready var player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var canvas = $CanvasLayer
@onready var inventory = $CanvasLayer/Inventory

var positionChangedTimes = 0
var chanceToEncounter = 0
var inventoryShown = false
var tween

var encounterChance = 100

func onPositionChanged():
	positionChangedTimes += 1
	print(positionChangedTimes)
	if positionChangedTimes > 30:
		chanceToEncounter = randi() % encounterChance
		if chanceToEncounter < encounterChance:
			chanceToEncounter += 1
		if chanceToEncounter == encounterChance:
			Signals.emit_signal('enterBattle')
			transitionBG.position.x = camera.position.x - get_viewport().size.x / 2
			transitionBG.position.y = camera.position.y - get_viewport().size.y / 2
			transitionBG.size = get_viewport().size
			player.play("fadeOut")
			await player.animation_finished
			transitionBG.position = get_viewport_rect().position
			transitionBG.size = get_viewport().size
			camera.enabled = false
			var battleGroundInstance = battleGround.instantiate()
			add_child(battleGroundInstance)
			battleGroundInstance.init(membersStats)
			player.play("fadeIn")
			await player.animation_finished

func onStatsChanged(charName, _whatChanged, currHP, _maxHP):
	# just for debugging
	print(charName, currHP)
	for member in membersStats:
		if member.charName == charName:
			print(member.currHP)

func _ready():
	Signals.connect('positionChanged', onPositionChanged)
	Signals.connect('statsChanged', onStatsChanged)
