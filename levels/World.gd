extends Node2D

var positionChangedTimes = 0
@onready var battleGround = preload('res://battles/battle.tscn').instantiate()
@onready var transitionBG = $TransitionBG
@onready var player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var canvas = $CanvasLayer
@onready var inventory = $CanvasLayer/Inventory
var chanceToEncounter = 0
var inventoryShown = false
var tween

func onPositionChanged():
	positionChangedTimes += 1
	print(positionChangedTimes)
	if positionChangedTimes > 30:
		chanceToEncounter = randi() % 200
		if chanceToEncounter < 200:
			chanceToEncounter += 1
		if chanceToEncounter == 200:
			Signals.emit_signal('enterBattle')
			transitionBG.position.x = camera.position.x - get_viewport().size.x / 2
			transitionBG.position.y = camera.position.y - get_viewport().size.y / 2
			transitionBG.size = get_viewport().size
			player.play("fadeOut")
			await player.animation_finished
			transitionBG.position = get_viewport_rect().position
			transitionBG.size = get_viewport().size
			camera.enabled = false
			add_child(battleGround)
			player.play("fadeIn")
			await player.animation_finished

func _ready():
	Signals.connect('positionChanged', onPositionChanged)
