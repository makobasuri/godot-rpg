extends CharacterBody2D


const SPEED = 300.0
var currentPosition = Vector2(0, 0)
var battleEntered = false

@onready var playerClip = $PlayerClip
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var area2d = $Area2D

func onBattleEntered():
	playerClip.hide()
	battleEntered = true

func _ready():
	Signals.connect('enterBattle', onBattleEntered)

func getInteractibleInArea():
	if len(area2d.get_overlapping_bodies()) > 1:
		for body in area2d.get_overlapping_bodies():
			if body.is_in_group('Interactible'):
				return body

func get_input():
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED

	if Input.is_action_just_pressed("ui_accept") && getInteractibleInArea():
		getInteractibleInArea().interact()

	if (input_direction == Vector2.ZERO):
		animationState.travel("End")
	else:
		var positionNow = global_position
		if currentPosition.x != positionNow.x || currentPosition.y !=  positionNow.y:
			currentPosition = positionNow
			Signals.emit_signal('positionChanged')
		animationTree.set("parameters/run/blend_position", input_direction)
		animationState.travel("run")

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if battleEntered:
		return
	get_input()
	move_and_slide()
