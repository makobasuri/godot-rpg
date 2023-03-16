extends Node2D

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

func get_input():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if (input_direction == Vector2.ZERO):
		animationState.travel("End")
	else:
		animationTree.set("parameters/run/blend_position", input_direction)
		animationState.travel("run")

@warning_ignore("unused_parameter")
func _physics_process(delta):
	get_input()
