extends Node2D

var positionChangedTimes = 0
var battleGround = load('res://battles/battle.tscn').instantiate()
@onready var transitionBG = $TransitionBG
@onready var player = $AnimationPlayer
@onready var camera = $Camera2D
var chanceToEncounter = 0

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
			print(transitionBG.position, transitionBG.size)
			player.play("fadeOut")
			await player.animation_finished
			transitionBG.position = get_viewport_rect().position
			transitionBG.size = get_viewport().size
			camera.enabled = false
			add_child(battleGround)
			player.play("fadeIn")
			await player.animation_finished


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect('positionChanged', onPositionChanged)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
