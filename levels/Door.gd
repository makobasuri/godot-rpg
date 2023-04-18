extends StaticBody2D

class_name Door

@export var location = 'here should be a reference to a dungeon'

@onready var doorClosed = $DoorClosed
@onready var doorOpened = $DoorOpened
@onready var collisionShapeDoorClosed = $CollisionShapeDoorClosed

var isInteracting: bool = false

func interact():
	if doorOpened.visible:
		doorOpened.hide()
		collisionShapeDoorClosed.set_deferred("disabled", false)
		doorClosed.show()
		return
	if doorClosed.visible:
		doorClosed.hide()
		collisionShapeDoorClosed.set_deferred("disabled", true)
		doorOpened.show()

func quitInteracting():
	pass


func _on_entrance_body_entered(body):
	if body is Player:
		Signals.emit_signal('playerEntered', location)
