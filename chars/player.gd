extends CharacterBody2D


const SPEED = 300.0
var currentPosition = Vector2(0, 0)
var battleEntered = false

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

func onBattleEntered():
	battleEntered = true

func _ready():
	Signals.connect('enterBattle', onBattleEntered)

func get_input():
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED

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
