extends Node3D
@onready var forward: = $RayForward
@onready var right: = $RayRight
@onready var back: = $RayBack
@onready var left: = $RayLeft
@onready var rays = [forward, right, back, left]
@onready var timerprocessor: = $Timer

func collisionCheck(direction):
	if direction != null:
		return direction.is_colliding()
	else:
		return false

func getDirection(direction):
	if not direction is RayCast3D: return
	if direction.get_collider():
		print('dir: ', direction.get_collider().global_transform.origin)
		return direction.get_collider().global_transform.origin - global_transform.origin


func tweenRotation(change):
	var tween = create_tween()
	tween.tween_property(
		self, "rotation", rotation + Vector3(0, change, 0),
		0.5
	)
	await tween.finished

func tweenTranslation(change):
	if not change is Vector3:
		return
	var tween = create_tween()
	var adjustedChange = Vector3(change.x, 0, change.z)
	tween.tween_property(
		self, "position", position + adjustedChange,
		0.5
	)
	await tween.finished

func rotateAtStart():
	var directions = [ forward, right, back, left ]
	for dirIdx in len(directions):
		if collisionCheck(directions[dirIdx]):
			rotation = Vector3(rotation.x, PI/2 * dirIdx, rotation.y)


func _on_timer_timeout():
	var GO_W := Input.is_action_pressed('ui_up') || Input.is_action_pressed('forward')
	var GO_S := Input.is_action_pressed('ui_down') || Input.is_action_pressed('backward')
	var GO_Q := Input.is_action_pressed('strafe_left')
	var GO_E := Input.is_action_pressed('strafe_right')
	var TURN_Q := Input.is_action_pressed('ui_left') || Input.is_action_pressed('left')
	var TURN_E := Input.is_action_pressed('ui_right') || Input.is_action_pressed('right')

	var ray_dir
	var turn_dir = int(TURN_Q) - int(TURN_E)

	if GO_W:
		ray_dir = forward
	elif GO_S:
		ray_dir = back
	elif GO_Q:
		ray_dir = left
	elif GO_E:
		ray_dir = right
	elif turn_dir:
		timerprocessor.stop()
		await tweenRotation(PI/2 * turn_dir)
		timerprocessor.start()

	if collisionCheck(ray_dir):
		timerprocessor.stop()
		await tweenTranslation(getDirection(ray_dir))
		timerprocessor.start()
